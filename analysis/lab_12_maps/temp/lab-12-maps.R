#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console

# ---- load-packages --------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) # enables piping : %>%
library(dplyr)    # data wrangling
library(ggplot2)  # graphs
library(tidyr)    # data tidying
library(maps)     # map data
# ---- load-sources ---------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.
source("./scripts/common-functions.R") # used in multiple reports
source("./scripts/graphing/graph-presets.R") # fonts, colors, themes

# ---- declare-globals -----------------------------------------

# ---- load-data -----------------------------------------------
path_file <- "./data-public/raw/Tableau_10_Training_Files/Tableau 10 Training Practice Data.xlsx"
sheet_names <- readxl::excel_sheets(path_file)
dto <- list()
for(sheet_i in sheet_names){
  # i <- sheet_names[1]
  dto[[sheet_i]] <- readxl::read_xlsx(path_file, sheet = sheet_i)
}
ds_cancer_deaths <- dto$`13 - Cancer Deaths by State`

# ---- inspect-data ---------------------------------------------
ds_cancer_deaths %>% glimpse(55)

# ---- tweak-data -----------------------------------------------
names(ds_cancer_deaths) <- c(
  "state"
  ,"gender"
  ,"year"
  ,"n_death_cancer"
  ,"n_population"
  ,"rate_death_cancer"
)

ds_usa <- map_data('state') %>% tibble::as_tibble()
ds_usa %>% head()

ds_cancer_map <- dplyr::inner_join(
   ds_cancer_deaths %>% dplyr::mutate(state = tolower(state))
  ,ds_usa
  # ,by = c("region" = "state")
  ,by = c("state" = "region")
) %>% tibble::as_tibble()


# ---- g1 ----------------
g1 <- ds_cancer_map %>%
  ggplot(aes(x = long, y = lat, group = group, fill = rate_death_cancer))+
  geom_polygon(color = "white")+
  coord_map() # to map onto flat surface
  # theme_void()

g1

ds_cancer_map %>%
  distinct(state, rate_death_cancer) %>%
  # arrange(rate_death_cancer)
  arrange(desc(rate_death_cancer))

ds_cancer_map %>%
  group_by(state) %>%
  dplyr::summarize(
    x_center = median(long, na.rm =T)
    ,y_center = median(lat, na.rm = T)
  ) %>%
  filter(state == "west virginia")



# g1 <- ds_cancer_map %>%
#   ggplot(aes(x = long, y = lat, group = group, fill = rate_death_cancer)) +
#   geom_polygon(colour = "black") +
#   coord_map() +
#   theme_void() +
#   annotate("text", x = -111.5, y = 40, label = "102", fontface = 2, size = 4) +
#   annotate("text", x = -80.5, y = 39, label = "254", fontface = 2, size = 4) +
#   theme(
#     legend.position = "bottom"
#   ) +
#   scale_fill_gradient2(
#     low       = "#deebf7"
#     ,mid      = "#9ecae1"
#     ,high     = "#3182bd"
#     ,midpoint = mean(ds_cancer_map$rate_death_cancer)
#   )
#
# g1

# ---- g2 -------------------------
# personal income by state
# https://www.bea.gov/data/income-saving/personal-income-by-state
# manually store only two columns in a separate CVS
# NOTE: remove regions (e.g. New England) and notice the `.` in Nebraska
ds_income <- readr::read_csv("./analysis/lab_12_maps/usa_per_capita.csv")

# get coordinates for state centers
datasets::state.name
datasets::state.center

ds_state_centers <-
  data.frame(state.name, state.center) %>%
  tibble::as_tibble() %>%
  dplyr::mutate(
    state = tolower(state.name)
  ) %>%
  dplyr::select(-state.name)

ds_state_income <-
  # dplyr::inner_join(
  dplyr::left_join(
    ds_state_centers
    ,ds_income %>% dplyr::mutate(state = tolower(state))
    ,by = "state"
  )

ds_cancer_map_state_income <- ds_cancer_map %>%
  dplyr::left_join(ds_state_income, by = "state")
ds_cancer_map_state_income %>% glimpse()

cancer_map_centers <-  cancer_map %>%
  inner_join(state_centers) %>%
  inner_join(ds_per_capita1)


g2 <- ds_cancer_map_state_income %>%
  ggplot(aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = per_capita_income_2019), color = "black", show.legend = FALSE) +
  coord_map() +
  geom_point(
    aes(x = x, y = y, size = rate_death_cancer)
    ,fill   = "#9ecae1"
    ,color  = "black"
    ,shape  = 21
    ,alpha  = 0.6
    ,na.rm  = TRUE
  ) +
  scale_radius(range = c(3,10)) +
  theme_void() +
  theme(
    legend.position = "bottom"
  ) +
  scale_fill_gradient2(
    low       = "#e5f5e0"
    ,mid      = "#74c476"
    ,high     = "#005a32"
    ,midpoint = mean(ds_cancer_map_state_income$per_capita_income_2019)
  )
g2

# ---- basic-table ---------------------------------------------

# ---- basic-graph ----------------------------------------------

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
