
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


# Create cols for budget head IDs for 2018 --------------------------------

create_2018_heads <- function(){
  raw_file_path <- "datasets/state-budgets/assam/raw-files/"
  processed_file_path <- "datasets/state-budgets/assam/processed-files/"
  all_raw_files <- dir(raw_file_path)
  raw_files_2018 <- all_raw_files[grepl(x = all_raw_files,pattern = "2018")]
  for(i in 1:length(raw_files_2018)){
    print(glue::glue("Processing -- {raw_files_2018[[i]]}"))
    file_path <- glue::glue("{raw_file_path}{raw_files_2018[[i]]}")
    budget_csv <- readr::read_csv(file_path, col_types = cols())
    budget_csv$row_id <- 1:nrow(budget_csv)
    
    head_of_account <- budget_csv[,c("row_id","Head Of Account")]
    head_of_account$head_id_cols <- stringr::str_split(head_of_account$`Head Of Account`,pattern = "-",n = 8,simplify = TRUE) %>% data.frame()
    head_of_account$head_id_cols$X81 <- str_extract(head_of_account$head_id_cols$X8,pattern = "EE|TG-FFC|SOPD-G|SOPD-SS|CSS|SOPD-ODS")
    head_of_account$head_id_cols$X9 <- stringr::str_sub(head_of_account$head_id_cols$X8,start = -4,end = -3)
    head_of_account$head_id_cols$X10 <- stringr::str_sub(head_of_account$head_id_cols$X8,start = -1,end = -1)
    head_of_account$head_id_cols$X8 <- NULL  
    head_of_account$head_id_cols$row_id <- head_of_account$row_id
    head_of_account <- head_of_account$head_id_cols
    names(head_of_account)[1:10] <- c(
      "Major Head Code",
      "Sub-Major Head Code",
      "Minor Head Code",
      "Sub-Minor Head Code",
      "Detailed Head Code",
      "Object Head Code",
      "Voucher Head Code",
      "Scheme Code",
      "Area Code",
      "Voted/Charged Code"
    ) 
    
    budget_csv <- left_join(budget_csv, head_of_account, by="row_id", keep=FALSE)
    budget_csv$row_id <- NULL
    readr::write_csv(budget_csv,glue::glue("{processed_file_path}/{raw_files_2018[[i]]}"))
}
}

# Get all columns ---------------------------------------------------------

get_all_cols <- function(){
  
  processed_file_path <- "datasets/state-budgets/assam/processed-files/"
  all_processed_files <- dir(processed_file_path) 
  master_cols_df <- c()
  for(i in 1:length(all_processed_files)){
    file_path <- glue::glue("{processed_file_path}{all_processed_files[[i]]}")
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

budget_head_id_cols <- c(
  "Major Head Code",
  "Sub-Major Head Code",
  "Minor Head Code",
  "Sub-Minor Head Code",
  "Detailed Head Code",
  "Object Head Code",
  "Voucher Head Code",
  "Scheme Code",
  "Area Code",
  "Voted/Charged Code"
)

get_budget_heads <- function(){
  file_path <- "datasets/state-budgets/assam/processed-files/"
  all_files <- dir(file_path) 
  master_heads_df <- c()
  for(i in 1:length(all_files)){
    file_path_i <- glue::glue("{file_path}{all_files[[i]]}")
    budget_csv <- readr::read_csv(file_path_i, col_types = cols(.default = "c"))
    indicator_heads <-
      names(budget_csv)[grepl(pattern = "actual|revised|budget",
                              x = names(budget_csv),
                              ignore.case = TRUE)]
    indicator_heads <- indicator_heads[!indicator_heads %in% "Budget Entity"]
    budget_heads <-
      budget_csv[, c(budget_head_cols, budget_head_id_cols, indicator_heads)]
    
    names(budget_heads)[c(21:24)] <- c("actuals","estimate_py","revised_py","estimate_cy")
    
    budget_heads$row_id <- 1:nrow(budget_heads)
    # Convert budget head ID cols to numeric so we can compare "01" and "1"
    
    for(j in 1:length(budget_head_id_cols)){
      id_col_j <-
        budget_heads[, c("row_id", budget_head_id_cols[[j]])] %>% data.frame(check.names = FALSE)
      id_col_j$numeric_id <- id_col_j[,2] %>% as.numeric 
      id_col_j$numeric_id[is.na(id_col_j$numeric_id)] <-
        id_col_j[is.na(id_col_j$numeric_id), 2]
      budget_heads <- left_join(budget_heads,id_col_j[,c(1,3)], by="row_id", keep=FALSE)
      budget_heads[,c(budget_head_id_cols[[j]])] <- NULL
      names(budget_heads)[which(names(budget_heads)=="numeric_id")] <- budget_head_id_cols[[j]]
    }
    
    budget_heads$file_id <- all_files[[i]]
    master_heads_df <- bind_rows(master_heads_df, budget_heads)
  }
  return(master_heads_df)
}
