/****************************************************************************
 * Example SAS Demo
 * Summary Table and Linear Regression using the sashelp.cars dataset
 *
 * Dataset: sashelp.cars
 *   - Contains information on 428 car models (year 2004)
 *   - Variables include: Make, Model, Type, Origin, DriveTrain,
 *     MSRP, Invoice, EngineSize, Cylinders, Horsepower, MPG_City,
 *     MPG_Highway, Weight, Wheelbase, Length
 *
 * Sections:
 *   1. Data Exploration
 *   2. Summary Table (continuous and categorical variables)
 *   3. Linear Regression Model (outcome: MPG_Highway)
 ****************************************************************************/


/****************************************************************************
 * 1. Data Exploration
 ****************************************************************************/

/* Preview the first 10 rows */
proc print data=sashelp.cars(obs=10);
run;

/* Variable-level metadata */
proc contents data=sashelp.cars;
run;


/****************************************************************************
 * 2. Summary Table
 *
 *   PROC MEANS  - summary statistics for continuous variables
 *   PROC FREQ   - frequency counts for categorical variables
 ****************************************************************************/

/* ---- 2a. Continuous variables ---- */
proc means data=sashelp.cars n nmiss mean std median q1 q3 min max maxdec=2;
    var MSRP Invoice EngineSize Cylinders Horsepower
        MPG_City MPG_Highway Weight Wheelbase Length;
    title 'Summary Statistics for Continuous Variables (sashelp.cars)';
run;

/* Summary statistics stratified by car Type */
proc means data=sashelp.cars n mean std median q1 q3 maxdec=2;
    class Type;
    var MSRP Horsepower MPG_City MPG_Highway;
    title 'Summary Statistics by Car Type';
run;

/* ---- 2b. Categorical variables ---- */
proc freq data=sashelp.cars;
    tables Type Origin DriveTrain / nocum;
    title 'Frequency Counts for Categorical Variables (sashelp.cars)';
run;

/* Cross-tabulation: Type by Origin */
proc freq data=sashelp.cars;
    tables Type*Origin / nopercent norow nocol;
    title 'Cross-Tabulation: Car Type by Origin';
run;


/****************************************************************************
 * 3. Linear Regression Model
 *
 *   Outcome   : MPG_Highway (highway fuel efficiency, miles per gallon)
 *   Predictors: Horsepower, Weight, EngineSize, Cylinders
 *
 *   PROC REG  - ordinary least-squares regression
 *   PROC GLM  - general linear model (used here to include a
 *               categorical predictor: Type)
 ****************************************************************************/

/* ---- 3a. Simple linear regression: MPG_Highway ~ Horsepower ---- */
proc reg data=sashelp.cars plots=diagnostics;
    model MPG_Highway = Horsepower / clb;
    title 'Simple Linear Regression: MPG_Highway ~ Horsepower';
run;
quit;

/* ---- 3b. Multiple linear regression (continuous predictors only) ---- */
proc reg data=sashelp.cars plots=diagnostics;
    model MPG_Highway = Horsepower Weight EngineSize Cylinders / clb vif;
    title 'Multiple Linear Regression: MPG_Highway ~ Horsepower + Weight + EngineSize + Cylinders';
run;
quit;

/* ---- 3c. Multiple linear regression including a categorical predictor ---- */
/*
 * PROC GLM handles CLASS (categorical) variables natively.
 * Type is a nominal variable with levels: Hybrid, SUV, Sedan, Sports, Truck, Wagon
 * The SOLUTION option displays parameter estimates; CLPARM adds confidence intervals.
 */
proc glm data=sashelp.cars plots=diagnostics;
    class Type;
    model MPG_Highway = Horsepower Weight Type / solution clparm;
    lsmeans Type / pdiff adjust=tukey;
    title 'Multiple Linear Regression with Categorical Predictor: MPG_Highway ~ Horsepower + Weight + Type';
run;
quit;
