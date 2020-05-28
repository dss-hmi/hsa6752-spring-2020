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
path_file_input <- "data-public/raw/florida-population-suicide.csv"

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
ds0 %>%
  dplyr::group_by(year) %>%
  dplyr::summarize(
    n_population = sum(n_population, na.rm = T)
  ) %>%
  ggplot(aes(x=year, y = n_population))+
  geom_point()+
  geom_line()+
  scale_y_continuous(labels = scales::comma)+
  scale_x_continuous(breaks = seq(2007,2017,5))+
  theme_bw()

# ---- population_2 -----------------------------
# What was the trajectory of growth for each age group?
ds0 %>%
  dplyr::group_by(year, age_group) %>%
  dplyr::summarize(
    n_population = sum(n_population, na.rm = T)
  ) %>%
  ggplot(aes(x=year, y = n_population, group = age_group))+
  geom_point()+
  geom_line()+
  facet_wrap(~age_group, scales = "free")+
  scale_y_continuous(labels = scales::comma)+
  scale_x_continuous(breaks = seq(2007, 2017,5))+
  theme_bw()

# ---- population_3 -----------------------------
# For residends between 10 and 84 years of age,
# What was the trajectory of growth for each age group by sex?
ds0 %>%
  dplyr::filter(age_group %in% age_groups_10_84) %>%
  dplyr::group_by(year, age_group, sex) %>%
  dplyr::summarize(
    n_population = sum(n_population, na.rm = T)
  ) %>%
  ggplot(aes(x=year, y = n_population, group = interaction(age_group,sex), color = sex))+
  geom_point()+
  geom_line()+
  facet_wrap(~age_group, scales = "free")+
  scale_y_continuous(labels = scales::comma)+
  scale_x_continuous(breaks = seq(2007, 2017,5))+
  theme_bw()

# ---- population_4 -----------------------------
# For residends between 10 and 84 years of age,
# What was the trajectory of growth for each ethnic group?
ds0 %>%
  dplyr::filter(age_group %in% age_groups_10_84) %>%
  dplyr::group_by(year, age_group, race_ethnicity) %>%
  dplyr::summarize(
    n_population = sum(n_population, na.rm = T)
  ) %>%
  ggplot(aes(x=year, y = n_population, group = interaction(age_group,race_ethnicity), color = race_ethnicity))+
  geom_point()+
  geom_line()+
  facet_wrap(~age_group, scales = "free")+
  scale_y_continuous(labels = scales::comma)+
  scale_x_continuous(breaks = seq(2007, 2017,5))+
  theme_bw()



# ---- suicide_1 ----------------------------
# What is the trajectory of total suicides in FL between 2006 and 2017?
ds0 %>%
  dplyr::group_by(year) %>%
  dplyr::summarize(
    n_population = sum(n_population, na.rm = T)
    ,n_suicides = sum(n_suicides, na.rm = T)
  ) %>%
  ggplot(aes(x=year, y = n_suicides))+
  geom_point(shape = 21, size =3, color = "navyblue")+
  geom_line(color = "navyblue")+
  scale_y_continuous(labels = scales::comma)+
  scale_x_continuous(breaks = seq(2007,2017,5))+
  theme_bw()


# ---- suicide_2 ----------------------------
# For residends between 10 and 84 years of age,
# How does the trend of total suicides differ between men and women?
ds0 %>%
  dplyr::filter(age_group %in% age_groups_10_84) %>%
  dplyr::group_by(year, sex) %>%
  dplyr::summarize(
   n_suicides = sum(n_suicides, na.rm = T)
  ) %>%
  ggplot(aes(x=year, y = n_suicides, color = sex))+
  geom_point()+
  geom_line()+
  scale_y_continuous(labels = scales::comma)+
  scale_x_continuous(breaks = seq(2007,2017,5))+
  facet_wrap(~sex, scales = "free")+
  theme_bw()

# ---- suicide_3 ----------------------------
# For residends between 10 and 84 years of age,
# How does the trend of suicides counts among ethnic groups differ by sex
ds0 %>%
  dplyr::filter(age_group %in% age_groups_10_84) %>%
  dplyr::group_by(year, sex, race_ethnicity) %>%
  dplyr::summarize(
    n_suicides = sum(n_suicides, na.rm = T)
  ) %>%
  ggplot(aes(x=year, y = n_suicides, color = race_ethnicity))+
  geom_point()+
  geom_line()+
  scale_y_continuous(labels = scales::comma)+
  scale_x_continuous(breaks = seq(2007,2017,5))+
  facet_wrap(~sex, scales = "free")+
  theme_bw()

# ---- suicide_4 ----------------------------
# For residends between 10 and 84 years of age,
# How does the trend of total suicides between men and women differ across ethnic groups?
ds0 %>%
  dplyr::filter(age_group %in% age_groups_10_84) %>%
  dplyr::group_by(year, sex, race_ethnicity,) %>%
  dplyr::summarize(
    n_suicides = sum(n_suicides, na.rm = T)
  ) %>%
  ggplot(aes(x=year, y = n_suicides, color = sex))+
  geom_point()+
  geom_line()+
  scale_y_continuous(labels = scales::comma)+
  scale_x_continuous(breaks = seq(2007,2017,5))+
  facet_wrap(~race_ethnicity, scales = "free")+
  theme_bw()



# ----- compute_rate_function --------------------

# Compose the function that computes suicide rates per 100,000
compute_suicide_rate <- function(d_input, group_by_variables){
  d_output <- d_input %>%
    dplyr::group_by(.dots = group_by_variables) %>%
    dplyr::summarise(
      n_population = sum(n_population, na.rm = TRUE)
      ,n_suicides  = sum(n_suicides, na.rm = TRUE)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      rate_per100k_suicide  = (( n_suicides/n_population)*100000)
    )
  return(d_output)
}

# ---- suicide_rate_1 ----------------------------------
# What is the trend of the total suicide rates in Florida between 2006 and 2017?
ds0 %>%
  compute_suicide_rate("year") %>%
  ggplot(aes(x=year, y = rate_per100k_suicide))+
  geom_point(shape = 21, size =3, color = "navyblue")+
  geom_line(color = "navyblue")+
  scale_y_continuous(labels = scales::comma)+
  scale_x_continuous(breaks = seq(2007,2017,5))+
  theme_bw()


# ---- suicide_rate_2 ----------------------------------
# For residends between 10 and 24 years of age ( as a single group),
# How does the trend of suicide rates among ethnic groups differ by sex?
ds0 %>%
  dplyr::filter(age_group %in% age_groups_10_24) %>%
  compute_suicide_rate(c("year","race_ethnicity","sex")) %>%
  ggplot(aes(x=year, y = rate_per100k_suicide, color = race_ethnicity))+
  geom_point()+
  geom_line()+
  scale_y_continuous(labels = scales::comma)+
  scale_x_continuous(breaks = seq(2007,2017,5))+
  facet_wrap(~sex)+
  theme_bw()


# ---- publish ---------------------------------
rmarkdown::render(
  input = "./analysis/blogposts/florida-demographic-growth/fl-demo-growth.Rmd"
  ,output_format = c(
    "html_document"
    # ,"pdf_document"
    # ,"md_document"
    # "word_document"
  )
  ,clean=TRUE
)



