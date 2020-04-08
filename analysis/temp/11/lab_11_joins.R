# knitr::stitch_rmd(script="./___/___.R", output="./___/stitched-output/___.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.
source("./scripts/common-functions.R") # used in multiple reports
source("./scripts/graphing/graph-presets.R") # fonts, colors, themes

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) # enables piping : %>%
library(dplyr)    # data wrangling
library(ggplot2)  # graphs
library(tidyr)    # data tidying

# ---- declare-globals ---------------------------------------------------------

# ---- load-data ---------------------------------------------------------------
path_file <- "./data-public/raw/Tableau_10_Training_Files/Tableau 10 Training Practice Data.xlsx"
sheet_names <- readxl::excel_sheets(path_file)
dto <- list()
for(sheet_i in sheet_names){
  # i <- sheet_names[1]
  dto[[sheet_i]] <- readxl::read_xlsx(path_file, sheet = sheet_i)
}
ds_drug_overdose_deaths <- dto$`17 - Drug Overdose Deaths`
ds_motor_vehicle_deaths <- dto$`18 - Motor Vehicle Deaths`
# ---- inspect-data -------------------------------------------------------------
ds_drug_overdose_deaths %>% glimpse(60)
ds_motor_vehicle_deaths %>% glimpse(60)

# ---- tweak-data --------------------------------------------------------------
names(ds_drug_overdose_deaths) <- c("state", "cause_of_death","cause_code", "n_death_overdose", "region","division","date")
names(ds_motor_vehicle_deaths)  <- c("state","region", "n_death_car", "date", "population")

ds_drugs <- ds_drug_overdose_deaths %>%
  dplyr::mutate(
    n_death_overdose = ifelse(n_death_overdose == "Suppressed", NA, n_death_overdose) %>% as.integer()
    ,year = lubridate::year(date) %>% as.integer()
  ) %>%
  dplyr::group_by(year) %>%
  dplyr::summarize(
    n_death_overdose = sum(n_death_overdose, na.rm = T)
  ) %>%
  dplyr::ungroup()
ds_drugs %>% neat()


ds_cars <- ds_motor_vehicle_deaths %>%
  dplyr::mutate(
    year = lubridate::year(date) %>% as.integer()
  ) %>%
  dplyr::group_by(year) %>%
  dplyr::summarize(
    n_death_car = sum(n_death_car, na.rm = T)
  ) %>%
  dplyr::ungroup()
ds_cars%>% neat()

ds_joined <- dplyr::left_join(ds_drugs, ds_cars, by = "year")
ds_joined %>% neat()

# ----- g1 --------------------
g1 <- ds_joined %>%
  tidyr::pivot_longer(cols = c("n_death_overdose", "n_death_car"), names_to = "cause_of_death", values_to = "n_death") %>%
  dplyr::mutate(
    cause_of_death = dplyr::recode( cause_of_death,
      `n_death_overdose` = "Drug Overdose",
      `n_death_car` = "Motor Vehicle Incident"
    )
  ) %>%
  ggplot(aes(x = year, y = n_death, color = cause_of_death ))+
  geom_line(aes(group = cause_of_death), size = 2)+
  scale_y_continuous(limits = c(0, 55000), breaks = seq(0,55000,10000), labels = scales::comma )+
  scale_x_continuous(breaks = seq(2006,2015,1))+
  annotate("text", x = 2006, y = 50000, label = "Motor Vehicle Incident", color = "blue", hjust =0)+
  annotate("text", x = 2006, y = 30000, label = "Drug Overdose", color = "red", hjust =0)+
  scale_color_manual(values = c("Motor Vehicle Incident" = "blue","Drug Overdose" = "red"))+
  theme_minimal()+
  theme(legend.position = "bottom")+
  labs(
    title = "Total Deaths from Drug Overdoses and Motor Vehicle Incidents"
    ,y = "Number of Deaths"
    ,x = ""
    ,color = "Cause of Death"
  )
g1


# ---- basic-table --------------------------------------------------------------

# ---- basic-graph --------------------------------------------------------------

# ---- publish ---------------------------------------
path_report_1 <- "./analysis/lab_09_bivariate_distribution/lab_09_bivariate.Rmd"
# path_report_2 <- "./analysis/*/report_2.Rmd" # when linking multiple .Rmds to a single .R script
path_files_to_build <- c(path_report_1) # add path_report_n to extend
# path_files_to_build <- c(path_report_1, path_report_2) # add path_report_n to extend

testit::assert("The knitr Rmd files should exist.", base::file.exists(path_files_to_build))
# Build the reports
for( pathFile in path_files_to_build ) {
  rmarkdown::render(input = pathFile,
                    output_format=c(
                      "html_document"
                      # "pdf_document"
                      # "word_document"
                    ),
                    clean=TRUE)
}
