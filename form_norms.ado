	
	**************************************
	*  Program for forming norms in PWMSE
	*  Ver. 1.0 (Jan 2024)
	**************************************

	clear all
	
	* define program 
	capture program drop form_norms
	program define form_norms
		
		* parameters
		syntax anything(name=var), data(string) tau(integer) unit(name) dim_0(name) dim_1(name) [dim_2(name)] 
		
		use `data',clear
		qui reshape wide `var', i(`unit' `dim_1' `dim_2') j(`dim_0') 
				
		* calculate the proximity at the finest temporal dimension
		
		rename `var'`tau' TAU
		foreach x of varlist `var'* {
			qui replace `x' =  `x' - TAU
		}
			drop TAU
		
		qui reshape long `var', i(`unit' `dim_1' `dim_2') j(`dim_0') 
			
		
	* construct norms

		qui egen norm_D1 = max(abs(`var')), by(`unit' `dim_0')
		qui egen norm_D2 = sd(`var'), by(`unit' `dim_0')	
		
		collapse `var' norm*, by(`unit' `dim_1' `dim_0')
		qui egen norm_M1 = max(abs(`var')), by(`unit' `dim_0')
		qui egen norm_M2 = sd(`var'), by(`unit' `dim_0')		
		
		collapse `var' norm*, by(`unit' `dim_0')
		qui gen norm_Y1 = abs(`var')
		qui gen norm_Y2 = norm_Y1^2
		
		drop `var'
		
	end 
	
	* summarize norms
	sum
