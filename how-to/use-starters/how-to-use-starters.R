#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console


# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) # enables piping : %>%
library(dplyr)    # data wrangling
library(ggplot2)  # graphs
library(tidyr)    # data tidying

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.
source("./scripts/common-functions.R") # used in multiple reports
source("./scripts/graphing/graph-presets.R") # fonts, colors, themes

# ---- declare-globals ---------------------------------------------------------
# select_manufacturer <- "ford"
select_manufacturer <- "toyota"
# ---- load-data ---------------------------------------------------------------
ds <- ggplot2::mpg
# ---- inspect-data -------------------------------------------------------------
ds %>% glimpse(60)
ds %>% group_by(manufacturer) %>% count()
ds %>% group_by(class) %>% count()
# ---- tweak-data --------------------------------------------------------------
# replace the string '2seater' by 'twoseater' in variables class
ds1 <- ds %>%
  dplyr::mutate(
    class = stringr::str_replace(class, "2seater", "twoseater")
  )
ds1 %>% group_by(class) %>% count()
# ---- basic-table --------------------------------------------------------------
# show how many cars are represented by each manufacturer and what their mean mpg on highway is
d1 <- ds1 %>%
  # filter(manufacturer == "ford") %>%
  # filter(manufacturer == "toyota") %>%
  filter(manufacturer == select_manufacturer) %>%
  dplyr::group_by(class) %>%
  summarize(
    n = n()
    ,mean_hwy = mean(hwy, nr.rm = T)
  )
d1 %>% knitr::kable(format = "pandoc",digits = 1)

# ---- basic-graph --------------------------------------------------------------
d1 %>%
  ggplot( aes(x = class, y = mean_hwy) )+
  geom_col()+
  coord_flip()+
  labs(
    title = paste0("Average MPG on highway by class, made by ", toupper(select_manufacturer) )
  )+
  main_theme

# ---- publish ---------------------------------------
path_report_1 <- "./how-to/use-starters/how-to-use-starters.Rmd"
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
