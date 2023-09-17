JMP is a visual data analysis software under SAS. This page provides some basic operation references and concept explanations for JMP.

## Importing and browsing data

=== "1. Importing data"

	<figure><img src="/assets/jmp-open-data.png"></figure>

=== "2. Browsing data"

	<figure><img src="/assets/jmp-data-browser.png"></figure>

## Creating new variables

=== "1. Creating a new column"
	
	<figure><img src="/assets/jmp-new-column.png"></figure>

=== "2. Creating a formula"
	
	<figure><img src="/assets/jmp-new-column-formula.png"></figure>

=== "3. Editing a formula"
	
	<figure><img src="/assets/jmp-edit-formula.png"></figure>

## Linear model analysis

### OLS and logistic regression

Select "Analyzing - Fit Model" in the main interface to enter the linear model settings interface.

<figure><img src="/assets/jmp-linear-model.png"></figure>

??? question "Unable to select the Logistic model"

	**Reason**
	
	The dependent variable is of continuous type and has not been set as ordinal or nominal.
	
	**Solution**
	
	Change the data type in the column information.
	
	<figure><img src="/assets/jmp-column-info.png"></figure>
	
	<figure><img src="/assets/jmp-change-type.png"></figure>

After the model runs, it will return to the report interface.

<figure><img src="/assets/jmp-model-report.png"></figure>

Clicking on the red triangle can expand more report options, such as the ROC curve and confusion matrix commonly used to evaluate models in binary classification problems. There is also an "Explorer" that can be used to interactively view the impact of independent variables on the dependent variable.

<figure><img src="/assets/jmp-interact.png"></figure>

### Survival analysis

## Nonlinear models

The "Explorer" mentioned in the linear model results report is particularly useful in the display of nonlinear models.

### Neural network

Select "Analyzing - Predictive Modeling - Neural" in the main interface to enter the neural network settings interface.

### Random forest

Select "Analyzing - Predictive Modeling - Bootstrap Forest" in the main interface to enter the random forest settings interface.