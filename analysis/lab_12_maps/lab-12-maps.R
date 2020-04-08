#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console

# ---- load-packages --------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) # enables piping : %>%
library(dplyr)    # data wrangling
library(ggplot2)  # graphs
library(tidyr)    # data tidying
library(maps)
# ---- load-sources ---------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.
# source("./scripts/common-functions.R") # used in multiple reports
# source("./scripts/graphing/graph-presets.R") # fonts, colors, themes

# ---- declare-globals ------------------------------------------------

# ---- load-data ------------------------------------------------------
path_file <- "./data-public/raw/Tableau_10_Training_Files/Tableau 10 Training Practice Data.xlsx"
sheet_names <- readxl::excel_sheets(path_file)
dto <- list()
for(sheet_i in sheet_names){
  # i <- sheet_names[1]
  dto[[sheet_i]] <- readxl::read_xlsx(path_file, sheet = sheet_i)
}
ds_cancer_deaths <- dto$`13 - Cancer Deaths by State`

ds_usa <- ggplot2::map_data('state') %>% tibble::as_tibble()

# ---- inspect-data ---------------------------------------------------
ds_cancer_deaths %>% glimpse()
# ---- tweak-data -----------------------------------------------------
names(ds_cancer_deaths) <- c(
  "state"
  ,"gender"
  ,"year"
  ,"n_death_cancer"
  ,"n_population"
  ,"rate_death_cancer"
)

ds_cancer_map <- dplyr::inner_join(
  ds_cancer_deaths %>% dplyr::mutate(state = tolower(state))
  ,ds_usa
  , by = c("state" = "region")
)
# ---- basic-table ----------------------------------------------

# ---- basic-graph ----------------------------------------------

# ---- g1 ---------------------------
g1 <- ds_cancer_map %>%
  ggplot(aes(x = long, y = lat, group = group, fill = rate_death_cancer ))+
  geom_polygon( color = "white")+
  annotate("text", x =-111.5 , y = 39 ,  label = "102", color = "white")+
  annotate("text", x =-80.5 , y = 38.5 ,  label = "255", color = "black", size = 5)+
  coord_map()+
  theme_void()+
  # theme_minimal()+
  scale_x_continuous(breaks = seq(-120,-60,10))+
  theme(
    legend.position = "bottom"
  )+
  labs(
    title = "2013 Cancer Mortality Rates (per 100,000) by State, All Cancers, All Patients"
    ,fill = "Crude Death Rate"
  )
g1

ds_cancer_deaths %>%
  distinct(state, rate_death_cancer) %>%
  arrange(rate_death_cancer) %>%
  knitr::kable()

ds_cancer_map %>%
  group_by(state) %>%
  summarize(
    x_center = median(long, na.rm = T)
    , y_center = median(lat, na.rm =T)
  ) %>%
  filter(state == "west virginia")




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
