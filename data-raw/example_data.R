## code to prepare `example_data` dataset goes here

# This will be a cleaned simulation file
library(dplyr)

# Set the seed for reproducibility
set.seed(1234)

# Define parameters
n_units <- 6400
n_firms <- 400
n_periods <- 2
#All control variables will be 0/1
x_all<-seq(0,1,1)
#Defining one margin of heterogeneity
treatment_effect_x1_1<-10
treatment_effect_x1_0<-1
firm_variances <- seq(0.1,1,0.1)


## generate the data frame
data <- data.frame(
  unit_id = rep(1:n_units, each = n_periods),
  firm_id = rep(sample(1:n_firms, n_units, replace = TRUE), each = n_periods),
  period = rep(1:n_periods, times = n_units),
  x_1 = rep(sample(x_all, n_units, replace = TRUE), each = n_periods),
  x_2= rep(sample(x_all, n_units, replace = TRUE), each = n_periods),
  firm_variance = rep(sample(firm_variances, n_units, replace = TRUE), each = n_periods)
)

####generate firm-specific variance
firm_variance <- data %>%
  group_by(firm_id) %>%
  summarize(
    fvar = mean(firm_variance)
  )%>%
  ungroup()


data <- data %>%
  left_join(firm_variance %>% select(firm_id, fvar), by = "firm_id")

#assign treatment based on firm-specific averages of x1 and x2
firm_treatment <- data %>%
  filter(period == 1) %>%
  group_by(firm_id) %>%
  summarize(
    fx_1 = mean(x_1),
    fx_2 = mean(x_2))%>%
  ungroup()

# then give some propensity to treatment
firm_treatment2<-firm_treatment%>%
  group_by(firm_id) %>%
  summarize(
    treat_prob = exp(fx_1) / (exp(fx_1) + exp(fx_2))
  ) %>%
  mutate(treated = rbinom(n(), 1, treat_prob)) %>%
  ungroup()

# merge it back inside the data
data <- data %>%
  left_join(firm_treatment2 %>% select(firm_id, treated, treat_prob), by = "firm_id")


# Ensure treatment persists across periods
data <- data %>%
  group_by(unit_id) %>%
  mutate(treated = if_else(period >= 1, treated, 0)) %>%
  ungroup()

data$t_indicator<-data$treated

data$treated[data$period==1]<-0



# Generate the outcome variable Y
data <- data %>%
  mutate(
    Y = rnorm(n(), mean = 10, sd = fvar),  # Base outcome
    Y = if_else(period == 2 & treated == 1 & x_1 == 1, Y + treatment_effect_x1_1, Y),
    Y = if_else(period == 2 & treated == 1 & x_1 == 0, Y + treatment_effect_x1_0, Y),
    Y = if_else(period == 2, Y + 1, Y), # time fixed effect for all units
    Y = if_else(x_1 == 1, Y + 1, Y), # different outcomes for X1
    Y = if_else(x_2 == 1 & period == 2, Y + 1, Y) # different outcomes for X2
  )


rm(firm_treatment)
rm(firm_treatment2)
rm(firm_variance)
rm(firm_variances)
rm(n_firms)
rm(n_periods)
rm(n_units)
rm(treatment_effect_x1_1)
rm(treatment_effect_x1_0)
rm(x_all)



# Set up the CF

# Set up panel identifiers as factors

# set up control vars as factors
data$x_1<-as.factor(data$x_1)
data$x_2<-as.factor(data$x_2)
example_data<-data



usethis::use_data(example_data, overwrite = TRUE)
