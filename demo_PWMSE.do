***************************************************	
* Demo for using PWMSE
***************************************************	

	* pre-requirement: install form_norms.ado and get_pwmse.ado to the relevant ado folder
	
	* 1st step: cd to folder that holds the high-frequency data for forming norms
	
	cd ...
	
		* - the program requires you prepare the high-frequency data by appending the high-frequency of the projected year into the historical high-frequency data 
	
	
	* 2nd step: run "form_norms":
		* - specify the input high-frequency data dta in data()
		* - specify the projection year in tau()
		* - specify the cross-sectional unit indicator in unit()
		* - specify the time dimension for the later panel regression (e.g., year) in dim_0()
		* - specify the second lowest time frequency (e.g., month) in dim_1()
		* - specify the highest time frequency (e.g., day) in dim_2(); can just type "dim_2()" if you don't have this time frequency
	
		form_norms tAvg, data("DataMY.dta") tau(2050) unit(fips) dim_0(year) dim_1(month) 
	
		* - in this demo, the input data only have year and month dimensions (no daily level), so we leave out the dim_2() here
	
	* 3rd step: save the formed norms as a dta in local folder (will be used later)
	
		save saved_norms, replace
	
	* 4th step: load the panel data for regression and run get_pwmse to get PWMSEs for a certain specification
		* - specify the norms generated by form_norms with using ...
		* - specify outcome variable in yvar()
		* - specify explanatory variables in xvar()
		* - specify additional controls such as time trends in trends() [optional]
		* - specify the cross-sectional units for the regressions in unit()
		* - specify the time dimension for the regressions in time()
		* - specify the last time period in the regression sample in t()
		* - specify the training-to-full ratio in train_ratio()
		* - specify the times of cross-validation in num_simulations()
		* - specify the specific norms to report in norms(), options include: N, D1, D2, M1, M2, Y1, Y2; the default will report all
		* - specify the tuning parameter in the proximity-weights in h()
		* - set seeds for replication in seed()
		* - the option quiet will hide the reporting of iterations
		
		
		* evaluate 1st model 

		use DataReg, clear			
		get_pwmse using "saved_norms.dta",yvar(lyield_corn) xvar(tAvg prec prec2) trends(i.stateansi#c.year##c.year) unit(fips) time(year) t(2015) train_ratio(0.75) num_simulations(100) norms(N Y1 M1) h(1) seed(10309) quiet
		
		* evaluate 2nd model
		use DataReg, clear			
		get_pwmse using "saved_norms.dta",yvar(lyield_corn) xvar(tAvg_avg_m* prec prec2) trends(i.stateansi#c.year##c.year) unit(fips) time(year) t(2015) train_ratio(0.75) num_simulations(100) norms(N Y1 M1) h(1) seed(10309) quiet
	
		* evaluate 3rd model
		use DataReg, clear			
		get_pwmse using "saved_norms.dta",yvar(lyield_corn) xvar(dday10_29C dday29C prec prec2) trends(i.stateansi#c.year##c.year) unit(fips) time(year) t(2015) train_ratio(0.75) num_simulations(100) norms(N Y1 M1) h(1) seed(10309) quiet
		
		* evaluate 4th model
		use DataReg, clear			
		get_pwmse using "saved_norms.dta",yvar(lyield_corn) xvar(dd3bin* prec prec2) trends(i.stateansi#c.year##c.year) unit(fips) time(year) t(2015) train_ratio(0.75) num_simulations(100) norms(N Y1 M1) h(1) seed(10309) quiet
		
		* Notes: In this example, we evaluate four different model specifications on how temperature affects corn yields using US data. All models have linear and quadratic precipitation and state-level linear and quadratic trends. The tuning parameter h is set at 1. The number of times for cross-validation is 100, and the training-to-full ratio is 0.75. The seed is set as 10309 for replicability. 
		
