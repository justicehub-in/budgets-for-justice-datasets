
# Source files ------------------------------------------------------------

source("scripts/libraries.R")
source("scripts/functions.R")

# Reading files from OBI --------------------------------------------------

# Reference - https://apoorv74.github.io/OBI-data-explorer/
org_url <- "https://openbudgetsindia.org/"
ckanr::ckanr_setup(url = org_url)
org_connect <- ckanr::src_ckan(url = org_url)


# Find dataset links from OBI ---------------------------------------------

organisations <-
  paste0("assam-budget-", c("2018-19", "2019-20", "2020-21"))

all_dataset_links <- lapply(organisations, find_dataset_links) %>% bind_rows()
