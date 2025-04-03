    library(didcf)

## Introduction

This vignette accompanies the package DiDCF. The algorithms comes from
<a href="https://www.cesifo.org/en/publications/2023/working-paper/difference-difference-causal-forests-application-payroll-tax" target="_blank">*Gavrilova,
Evelina, Audun Langørgen, and Floris Zoutman. “Difference-in-difference
causal forests, with an application to payroll tax incidence in norway.”
(2025).*</a>

### How to install

Below I offer two options on how to install the package from GitHub. You
can use *devtools* (which needs to be installed beforehand).

    #install.packages(devtools)
    library(devtools)
    install_github("evelinagz/didcf")
    #> Skipping install of 'didcf' from a github remote, the SHA1 (100837d5) has not changed since last install.
    #>   Use `force = TRUE` to force installation

### estimate\_didcf

The function `estimate_DiDCF` takes in your data and estimates
difference-in-difference causal forests. Here is how you can use the
function:

    estimate_didcf(example_data$Y, 
                   example_data$t_indicator[example_data$period==1], 
                   model.matrix(~.,data=example_data[example_data$period==1,c("x_1","x_2")]), 
                   1, 
                   example_data$period, 
                   example_data$unit_id) 
    #> $DiDCF_2
    #> GRF forest object of type causal_forest 
    #> Number of trees: 2000 
    #> Number of training samples: 6400 
    #> Variable importance: 
    #>     1     2     3 
    #> 0.000 0.626 0.252

The example can be found also in the help file related to the function.
The inputs to the function are the following:

1.  **Y** - this is the outcome variable for all periods
2.  **t\_indicator** - this is a cross-sectional indicator for
    treatment, it should be the same in every period, here it is taken
    from the base period 1
3.  **X** - these are the variables describing the margins of
    heterogeneity in the treatment effect of interest
4.  **1** - this is the value of the base period in the variable
    denoting time
5.  **period** - variable denoting time
6.  **unit\_id** - variable denoting unit id

### vip

The function `vip` is a handy tool to extract a table from the variable
importance feature of the estimated causal forest. The table contains
variable names and their respective importance values, sorted in
descending order.

    my_forest<-estimate_didcf(example_data$Y, 
                   example_data$t_indicator[example_data$period==1], 
                   model.matrix(~.,data=example_data[example_data$period==1,c("x_1","x_2")]), 
                   1, 
                   example_data$period, 
                   example_data$unit_id) 
    vip(my_forest[[1]])
    #> # A tibble: 3 × 2
    #>   variable      vip
    #>   <chr>       <dbl>
    #> 1 x_11        0.623
    #> 2 x_21        0.255
    #> 3 (Intercept) 0

### Example Data

The `example_data` dataset included in this package contains a simulated
dataset tailored to the payroll example from the paper. Here is how you
can load and view the dataset:

    # Load the example dataset
    data(example_data, package = "didcf")

    # View the dataset
    head(example_data)
    #> # A tibble: 6 × 11
    #>   unit_id firm_id period x_1   x_2   firm_variance  fvar treated treat_prob t_indicator     Y
    #>     <int>   <int>  <int> <fct> <fct>         <dbl> <dbl>   <dbl>      <dbl>       <dbl> <dbl>
    #> 1       1     284      1 1     0               0.8 0.629       0      0.544           0  11.2
    #> 2       1     284      2 1     0               0.8 0.629       0      0.544           0  12.3
    #> 3       2     336      1 1     0               0.9 0.519       0      0.531           1  10.5
    #> 4       2     336      2 1     0               0.9 0.519       1      0.531           1  22.3
    #> 5       3     101      1 1     0               0.6 0.567       0      0.472           1  10.2
    #> 6       3     101      2 1     0               0.6 0.567       1      0.472           1  22.9
