
	***************************************************
	*  Program for evaluating model using PWMSE
	*  Ver. 2.0 (Feb 2024)
	***************************************************
	
	capture program drop get_pwmse
	program define get_pwmse
	
	* claim parameters

	syntax using/, yvar(varname) xvar(varlist fv ts) [trends(varlist fv ts)] unit(varname) time(varname) t(integer) train_ratio(real) num_simulations(integer) h(real) seed(real) [norms(string)] [quiet]
		local varlist  `yvar' `xvar' 

	* merge norms (generated using form_norm.ado)
		qui merge 1:1 `unit' `time' using `using'
		qui keep if _merge==3
		drop _merge	
		
		qui drop if `time'>`t'
		
	* demean variables
		foreach x of varlist `varlist' {
			qui egen m_`x' = mean(`x'), by(`unit')
			qui gen dm_`x' = `x' - m_`x'
			drop m_`x' `x'
			rename dm_`x' `x'
		}
		
	* gen y diff T vs T-s
		qui gen tempvar = `yvar' if year == `t'
		qui egen `yvar'_`t' = mean(tempvar), by(`unit')
		qui gen `yvar'_diff = `yvar'_`t' - `yvar'
		qui drop tempvar `yvar'_`t'		
		
	* save a temp file for cross-validation procedure		
		qui save your_dataset, replace	
		
	* cross-validate			
		use your_dataset, clear
			
	* restrict to non-missing obs (baesd on outcome)		
		qui keep if `yvar'!=.	
			
	* set seed for reproducibility
		set seed `seed'
		
	* prepare a dataset to store predictions
		tempfile predictions
		qui save `predictions', replace

	* loop for simulations
		forvalues sim = 1/`num_simulations' {
		
		if "`quiet'" == "" {
			di "running simulation #"`sim'
			}
			
    * generate a random number for each observation
			qui generate rand = runiform()

    * create train and test datasets
			qui generate train = rand < `train_ratio'
			qui generate test = 1 - train

    * training regression
			qui reg `yvar' `xvar' `trends'  if train == 1

    * prediction on the testing set
			qui predict yhat if test == 1

			qui keep if test == 1
	
	* Calculate MSE and PWMSE
			qui gen tempvar = yhat if year == `t'
			qui egen yhat_`t' = mean(tempvar), by(`unit')
			qui gen yhat_diff = yhat_`t' - yhat
			qui drop yhat_`t' yhat tempvar
			
			qui gen mse = (yhat_diff - `yvar'_diff)^2
			
			foreach norm in D1 D2 M1 M2 Y1 Y2 {
				qui gen mse_`norm'_`h'  = mse*exp(-norm_`norm'/`h')
				}
			
			qui collapse mse*
			
			qui generate sim_num = `sim'
			
			if `sim' == 1 {
				qui save `predictions', replace
				}
			else {
				qui append using `predictions'
				}
			qui save `predictions', replace
			use your_dataset, clear
		}
	
	
	* report 
		use `predictions'

		* rename vars for reporting 
		rename mse N
		rename mse_D1_`h' D1
		rename mse_D2_`h' D2
		rename mse_M1_`h' M1
		rename mse_M2_`h' M2
		rename mse_Y1_`h' Y1
		rename mse_Y2_`h' Y2
		
		di "reporting MSE and PWMSE for RHS spec: " `"`xvar'"'
		di "tuning parameter is set as h=`h'"

		if ("`norms'" == ""){
		    tabstat N D1 D2 M1 M2 Y1 Y2,s(mean) columns(statistics)
		}
		else{
		  
			tabstat `norms',s(mean) columns(statistics)
		}
		
		
	* delete temp dta file in local folder
		erase your_dataset.dta
	
	end