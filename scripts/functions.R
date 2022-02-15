

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
  
  grep_string <- package_info$title[grepl(package_info$title,pattern = ("Jails|Police|Justice"), ignore.case = TRUE)]
  package_info <- package_info[package_info$title %in% grep_string,]
  
  dataset_url <- lapply(package_info$package_id, get_dataset_url) %>% unlist()
  package_info$csv_url <- dataset_url
  package_info$org_id <- org_id
  return(package_info)
}