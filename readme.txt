--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

Readme --- How to use PWMSE for model selection

Ver. 2.0 
Date: 03/03/2024

Two separate ado files are needed. 
- form_norms.ado for constructing the proximity norms;
- get_pwmse.ado for operating the PWMSE evaluation, using the generated norms.

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

form_norms --- form proximity norms used in the PWMSE

Syntax

	form_norms indepvar, data(filename) tau(#) unit(varname) dim_0(varname) dim_1(varname) [dim_2(varname)]

indepvar: Specify a single variable by which the proxmity will be calculated (e.g., average temperature).

data(filename): Declare the dta file that contains high-frequency historical and projected data as the input for computing proximity norms. Note: The projected data should be appended to the historical data and only have a single period (e.g., year of 2050).

tau(#): Declare the projected time (e.g., 2050).

unit(varname): Declare the variable indicating cross-sectional units in the empirical analysis.

dim_0(varname): Declare the time dimension in the empirical analysis. This dimension should be the lowest frequency one (e.g., year).

dim_1(varname): Declare the second lowest-frequency time dimension (e.g., month). Note: This dimension is required.

dim_2(varname): Declare the highest-frequency time dimension (e.g., day). Note: This dimension is optional if the input data do not have this dimension. In such case, leave this option out. The program will still return norms corresponding to this dimension (norms_D1 and norms_D2), but they will be the same as the norms corresponding to dim_1() (i.e., norms_M1 and norms_M2).

Additional Notes:
- The program accomandates the common data structure with three time dimensions (e.g., year, month, and day). At least two dimensions are required for running the program.
- Users do not need to pre-load data. The dta specified in data() will be loaded as long as path is correctly specified.
- If there are only two time dimensions (e.g., year and month), norms_D1 (norms_D2) will be the same as norms_M1 (norms_M2). 
- Users must save the program-generated dta after running form_norms into the local folder. This dta file will be required for executing the PWMSE procedure for evaluating models.


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

get_pwmse --- execute the PWMSE-based model evaluation

Syntax

	get_pwmse using filename, yvar(depvar) xvar(indepvars) [trends(varlist)] unit(varname) time(varname) t(#) train_ratio(#) num_simulations(#) [norms(chars)] h(#) seed(#) [quiet]

filename: Declare the dta file that contains the proximity norms (previously obtained using form_norms).

yvar(depvar): Declare the dependent variable in the regression model of interest. Note: this variable will be demeaned as in a FE estimation framework.

xvar(indepvars): Declare the list of explanatory variables in the regression model of interest. Note: all these variables will be demeaned as in a FE estimation framework.

trends(varlist): Specify additional controls such as time trends. This is optional and can be left out if not applied. Note: these variables will NOT be demeaned. 

unit(varname): Declare the variable indicating cross-sectional units in the empirical analysis.

time(varname): Declare the time dimension in the empirical analysis. This dimension should be the lowest frequency one as in dim_0() in form_norms.

t(#): Declare the last period of the historical data. All data after this period will be dropped in the model evaluation.

train_ratio(#): Specify the training-to-full sample ratio of the cross-validation procedure. This number must be between 0 and 1.

num_simulations(#): Specify the number of times for cross-validation.

norms(chars): Choose the specific MSEs to be reported. Options include: N, D1, D2, M1, M2, Y1, Y2 as in Cui, Gafarov, Ghanem, and Kuffner (2024). All norms will be reported if not specified.

h(#): Specify the tuning parameter h in specifying the weight. This should be an integer number.

seed(#): Declare the seed for replication.

quiet: Optional. If not specified, the program will report the running of each round of simulations. 

Additional Notes:
- Running this program requires first obtaining the proximity norms for constructing weights.
- Running this program requires pre-loading the data for regressions, with necessary variables for different model specifications.
- MSEs are not comparable across different weights. They are only comparable across different models under the same weight specification.


