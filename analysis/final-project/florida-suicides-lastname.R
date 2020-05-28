rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run.
# This is not called by knitr, because it's above the first chunk.
cat("\f") # clear console when working in RStudio

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified
# see http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) # pipes %>%
library(ggplot2)  # graphs
library(dplyr)    # data wrangling
requireNamespace("tidyr")  # data tidying

#----- load-sources -------------------------------
# source("./scripts/modeling/model-basic.R")
source("./scripts/common-functions.R")
# ---- declare-globals ---------------------------------------------------------
# you will need to replace this path to the location where you stored your data file
path_file_input <- "florida-population-suicide.csv"

# to help with sorting the levels of the `age_group` factor
lvl_age_groups <-c(
  "less_than_1"
  ,"1_4"
  ,"5_9"
  ,"10_14"
  ,"15_19"
  ,"20_24"
  ,"25_34"
  ,"35_44"
  ,"45_54"
  ,"55_64"
  ,"65_74"
  ,"75_84"
  ,"85_plus"
)
age_groups_10_84 <- lvl_age_groups[4:12]
age_groups_10_24 <- lvl_age_groups[4:6]

# ---- load-data ---------------------------------------------------------------
# data from Florida Health Charts
ds_population_suicide <-   readr::read_csv(path_file_input)

# ---- tweak-data-1 -----------------------------------------------------
ds0 <- ds_population_suicide %>%
  dplyr::mutate(
    year            = as.integer(year)
    ,sex            = factor(sex)
    ,race_ethnicity = factor(paste0(race, " + ", ethnicity))
    ,race           = factor(race)
    ,ethnicity      = factor(ethnicity)
    ,age_group      = factor(age_group, levels = lvl_age_groups)
    ,n_population   = as.integer(n_population)
    ,n_suicides     = as.integer(n_suicides)
  )
ds0 %>% dplyr::glimpse(70)

# ---- population_1 -----------------------------
# How did the total population of Florida changed over the years?


# ---- population_2 -----------------------------
# What was the trajectory of growth for each age group?


# ---- population_3 -----------------------------
# For residends between 10 and 84 years of age,
# What was the trajectory of growth for each age group by sex?


# ---- population_4 -----------------------------
# For residends between 10 and 84 years of age,
# What was the trajectory of growth for each ethnic group?




# ---- suicide_1 ----------------------------
# What is the trajectory of total suicides in FL between 2006 and 2017?



# ---- suicide_2 ----------------------------
# For residends between 10 and 84 years of age,
# How does the trend of total suicides differ between men and women?


# ---- suicide_3 ----------------------------
# For residends between 10 and 84 years of age,
# How does the trend of suicides counts among ethnic groups differ by sex


# ---- suicide_4 ----------------------------
# For residends between 10 and 84 years of age,
# How does the trend of total suicides between men and women differ across ethnic groups?




# ----- compute_rate_function --------------------

# Compose the function that computes suicide rates per 100,000
compute_suicide_rate <- function(d_input, group_by_variables){
  d_output <- d_input %>%

  return(d_output)
}

# ---- suicide_rate_1 ----------------------------------
# What is the trend of the total suicide rates in Florida between 2006 and 2017?
ds0 %>%
  compute_suicide_rate("year") %>%



# ---- suicide_rate_2 ----------------------------------
# For residends between 10 and 24 years of age ( as a single group),
# How does the trend of suicide rates among ethnic groups differ by sex?
ds0 %>%
  dplyr::filter(age_group %in% age_groups_10_24) %>%
  compute_suicide_rate(c("year","race_ethnicity","sex")) %>%



# ---- publish ---------------------------------
rmarkdown::render(
  input = "./script.Rmd"
  ,output_format = c(
    "html_document"
    # ,"pdf_document"
    # ,"md_document"
    # "word_document"
  )
  ,clean=TRUE
)



