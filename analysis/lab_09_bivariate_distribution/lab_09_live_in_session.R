#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console

# ---- load-sources ------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.
# source("./scripts/common-functions.R") # used in multiple reports
# source("./scripts/graphing/graph-presets.R") # fonts, colors, themes

# ---- load-packages ----------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) # enables piping : %>%
library(dplyr)    # data wrangling
library(ggplot2)  # graphs
library(tidyr)    # data tidying

# ---- declare-globals ---------------------------------------------

# ---- load-data --------------------------------------------------
path_file <- "./data-public/raw/Tableau_10_Training_Files/Tableau 10 Training Practice Data.xlsx"
sheet_names <- readxl::excel_sheets(path_file)
dto <- list()
for(sheet_i in sheet_names){
  # i <- sheet_names[1]
  dto[[sheet_i]] <- readxl::read_xlsx(path_file, sheet = sheet_i)
}
ds_patient_metrics <- dto$`04 - Clinic Patients Metrics`
# ---- inspect-data -----------------------------------------------
ds_patient_metrics %>% glimpse(60)
# ---- tweak-data -------------------------------------------------
ds1 <- ds_patient_metrics
names(ds1) <- c("patient_id","bp_diastolic", "bp_systolic", "height_cm", "weight_kg","age")
ds1 %>% glimpse(60)

# ---- g1 ----------------------------
g1 <- ds1 %>%
  ggplot(aes(x = age))+
  geom_histogram(binwidth = 10 ,  color = "white", fill = "navyblue", alpha = .5)+
  scale_x_continuous(breaks = seq(20, 90, 5 ) )+
  labs(
    title = "Age Distribution of Clinic Patients"
    , x = "Age of patients", y = "Frequency"
  )+
  theme_bw()
g1

# ---- g1a ----------------------------
library(TabularManifest)
ds1 %>% TabularManifest::histogram_continuous("age", bin_width = 10, main_title = "Age Distribution of Clinic Patients")
ds1 %>% TabularManifest::histogram_continuous("bp_systolic")
ds1 %>% TabularManifest::histogram_continuous("bp_diastolic")

# ----- g2 -----------------------------
ds2 <- ds1 %>%
  dplyr::mutate(
    bmi = weight_kg/ ( (height_cm / 100)^2 )
  )

ds2 %>% glimpse(40)

threshold_obesity_bmi <- 30
threshold_highbp_systolic <- 140

g2 <- ds2 %>%
  ggplot(aes(x = bmi, y = bp_systolic))+
  geom_point(aes(color = bmi >= threshold_obesity_bmi), shape = 21, size = 2, show.legend = FALSE)+
  scale_x_continuous(breaks = seq(0,50,5), limits = c(0, 50))+
  scale_y_continuous(breaks = seq(0,200, 20), limits = c(0, 200))+
  geom_vline(xintercept = threshold_obesity_bmi, linetype="dashed")+
  geom_text(x = 10, y = 150,  label='High Blood Pressue', color = "grey60")+
  geom_hline(yintercept = threshold_highbp_systolic, linetype="dashed")+
  geom_text(x = 32, y = 65,label ="Obese", color = "grey60", angle = -90)+
  geom_smooth(method = "lm", se = F)+
  scale_color_manual(values = c("TRUE" = "red", "FALSE" = "blue"))+
  labs(
    title = "Correlation of Clinic Patients' Body Mass Index (BMI) \n
    and Systolic Blood Pressure. Obese vs Not Obese",
    x = "BMI", y = "BP (systolic)"
  )+
  theme_bw()
g2

# ---- basic-table ------------------------------------------------

# ---- basic-graph -------------------------------------------------

# ---- publish ---------------------------------------
path_report_1 <- "./analysis/*/report_1.Rmd"
# path_report_2 <- "./analysis/*/report_2.Rmd" # when linking multiple .Rmds to a single .R script
path_files_to_build <- c(path_report_1)
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
