
source("scripts/source-files.R")

# Find CSV URL from a package --------------------------------------------------------

get_dataset_url <- function(package_id){
  package_details <- ckanr::package_show(package_id)
  resource_details <- package_details$resources %>% bind_rows()
  
  # Get URL of the CSV file
  csv_url <- resource_details$url[resource_details$format=="CSV"]
  return(csv_url)
}


# Find links for all datasets in an org -----------------------------------

find_dataset_links <- function(org_id){
  
  print(glue::glue("Fetching data URL for {org_id}"))
  org_details <- ckanr::organization_show(id = org_id,include_datasets = TRUE)
  package_info <-
    data.frame(
      "package_id" = purrr::map(org_details$packages, "id") %>% unlist(),
      "title" = purrr::map(org_details$packages, "title") %>% unlist()
    )
  org_title <- org_details$title
  package_info$budget_for <-
    stringr::str_replace_all(package_info$title,
                             pattern = org_title,
                             replacement = "") %>% stringr::str_replace_all(pattern = ":", replacement = "") %>% stringr::str_squish()
  
  
  grep_string <- package_info$title[grepl(package_info$title,pattern = ("Jails|Police|Justice"), ignore.case = TRUE)]
  package_info <- package_info[package_info$title %in% grep_string,]
  
  dataset_url <- lapply(package_info$package_id, get_dataset_url) %>% unlist()
  package_info$csv_url <- dataset_url
  package_info$org_id <- org_id
  return(package_info)
}


# Download csv files ------------------------------------------------------

download_files <- function(package_id){
  print(glue::glue("Downloading {package_id}"))
  file_url <- all_dataset_links$csv_url[all_dataset_links$package_id==package_id]
  budget_csv <- readr::read_csv(file_url, col_types = cols())
  org_id <- all_dataset_links$org_id[all_dataset_links$package_id==package_id]
  budget_for_id <- all_dataset_links$budget_for[all_dataset_links$package_id==package_id] %>% stringr::str_replace_all(pattern = " ",replacement = "_")
  file_title <-  glue::glue("{org_id}_{budget_for_id}.csv")
  file_to_save <- glue::glue("datasets/state-budgets/assam/raw-files/{file_title}")
  readr::write_csv(x = budget_csv,file = file_to_save)
}

# Get all columns ---------------------------------------------------------

get_all_cols <- function(){
  
  raw_file_path <- "datasets/state-budgets/assam/raw-files/"
  all_raw_files <- dir(raw_file_path) 
  master_cols_df <- c()
  for(i in 1:length(all_raw_files)){
    file_path <- glue::glue("{raw_file_path}{all_raw_files[[i]]}")
    budget_csv <- readr::read_csv(file_path, col_types = cols())
    csv_cols <- names(budget_csv)
    cols_df <- data.frame("file_id"=all_raw_files[[i]],col_names=csv_cols)  
    master_cols_df <- dplyr::bind_rows(master_cols_df, cols_df)  
  }
  return(master_cols_df)
}

# Get all budget heads ----------------------------------------------------

budget_head_cols <-
  c(
    "Major Head",
    "Sub-Major Head",
    "Minor Head",
    "Sub-Minor Head",
    "Detailed Head",
    "Object Head",
    "Voucher Head",
    "Scheme",
    "Area",
    "Voted/Charged"
  )

get_budget_heads <- function(){
  raw_file_path <- "datasets/state-budgets/assam/raw-files/"
  all_raw_files <- dir(raw_file_path) 
  master_heads_df <- c()
  for(i in 1:length(all_raw_files)){
    file_path <- glue::glue("{raw_file_path}{all_raw_files[[i]]}")
    budget_csv <- readr::read_csv(file_path, col_types = cols())
    budget_heads <- budget_csv[,budget_head_cols]
    budget_heads$file_id <- all_raw_files[[i]]
    master_heads_df <- bind_rows(master_heads_df, budget_heads)
  }
  return(master_heads_df)
}
