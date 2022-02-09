
library(readr)
library(glue)
library(dplyr)
library(stringr)

master_file_dir <- "datasets/union-budget/master-file/"
data_dir <- "datasets/union-budget/"

source("scripts/update_indicators.R")

all_datasets <- dir(data_dir)
scheme_datasets <- all_datasets[grepl("scheme-",all_datasets,ignore.case = TRUE)]
scheme_datasets <- scheme_datasets[!grepl("category",scheme_datasets,ignore.case = TRUE)]


# Create a master dataset of all metadata files ---------------------------

meta_master <- c()
for (i in 1:length(scheme_datasets)) {
  scheme_metadata_path <-
    glue::glue("{data_dir}{scheme_datasets[[i]]}/metadata.csv")
  meta_file <-
    readr::read_csv(scheme_metadata_path,
                    col_types = cols(),
                    col_names = FALSE)
  schemeName <- meta_file$X2[meta_file$X1 == "Name of the Scheme"]
  schemeID <- meta_file$X2[meta_file$X1 == "schemeID"]
  indicatorName <-
    meta_file$X1[grepl(x = meta_file$X1,
                       pattern = "Indicator",
                       ignore.case = TRUE)]
  indicatorName <-
    indicatorName[grepl(pattern = "Name", x = indicatorName)]
  indicatorName <- meta_file$X2[meta_file$X1 %in% indicatorName]
  indicatorName <-
    indicatorName[!is.na(indicatorName)] %>% stringr::str_squish()
  indicatorName <- indicatorName[nchar(indicatorName) > 0]
  totalIndicators <- length(indicatorName)
  total_datasets <-
    dir(glue::glue("{data_dir}{scheme_datasets[[i]]}/"))
  if (length(total_datasets) > 2) {
    dataset_path <-
      glue::glue("{data_dir}{scheme_datasets[[i]]}/u_datasheet.csv")
  } else {
    dataset_path <-
      glue::glue("{data_dir}{scheme_datasets[[i]]}/datasheet.csv")
  }
  
  meta_df <-
    data.frame(
      "schemeID" = schemeID,
      "schemeName" = schemeName,
      "totalIndicators" = totalIndicators,
      "datasetPath" = dataset_path
    )
  
  meta_master <- dplyr::bind_rows(meta_master, meta_df)
}


# Create a combined dataset of all master files ---------------------------

category_list <- c("law","police","wcd","home")

master_combined <- c()
for(i in 1:length(category_list)){
  master_file_path <- glue::glue("{master_file_dir}{category_list[[i]]}.csv")
  category_file <- readr::read_csv(master_file_path,col_types = cols())  
  category_file <- category_file %>% 
    mutate_all(funs(stringr::str_replace(., "\\.\\.", NA_character_)))
  valid_cols <-
    c(
      "Ministry",
      "Head",
      "Scheme",
      "schemeID",
      "Budget 2016-2017 _Revenue",
      "Budget 2016-2017 _Capital",
      "Budget 2016-2017 _Total",
      "Revised 2016-2017 _Revenue",
      "Revised 2016-2017 _Capital",
      "Revised 2016-2017 _Total",
      "Actual 2016-2017 _Revenue",
      "Actual 2016-2017 _Capital",
      "Actual 2016-2017 _Total",
      "Budget 2017-2018 _Revenue",
      "Budget 2017-2018 _Capital",
      "Budget 2017-2018 _Total",
      "Revised 2017-2018 _Revenue",
      "Revised 2017-2018 _Capital",
      "Revised 2017-2018 _Total",
      "Actual 2017-2018 _Revenue",
      "Actual 2017-2018 _Capital",
      "Actual 2017-2018 _Total",
      "Budget 2018-2019 _Revenue",
      "Budget 2018-2019 _Capital",
      "Budget 2018-2019 _Total",
      "Revised 2018-2019 _Revenue",
      "Revised 2018-2019 _Capital",
      "Revised 2018-2019 _Total",
      "Actual 2018-2019 _Revenue",
      "Actual 2018-2019 _Capital",
      "Actual 2018-2019 _Total",
      "Budget 2019-2020 _Revenue",
      "Budget 2019-2020 _Capital",
      "Budget 2019-2020 _Total",
      "Revised 2019-2020 _Revenue",
      "Revised 2019-2020 _Capital",
      "Revised 2019-2020 _Total",
      "Actual 2019-2020 _Revenue",
      "Actual 2019-2020 _Capital",
      "Actual 2019-2020 _Total",
      "Budget 2020-2021 _Revenue",
      "Budget 2020-2021 _Capital",
      "Budget 2020-2021 _Total",
      "Revised 2020-2021 _Revenue",
      "Revised 2020-2021 _Capital",
      "Revised 2020-2021 _Total",
      "Actual 2020-2021 _Revenue",
      "Actual 2020-2021 _Capital",
      "Actual 2020-2021 _Total",
      "Budget  2021-2022 _Revenue",
      "Budget  2021-2022 _Capital",
      "Budget  2021-2022 _Total",
      "Revised 2021-2022 _Revenue",
      "Revised 2021-2022 _Capital",
      "Revised 2021-2022 _Total",
      "Budget  2022-2023 _Revenue",
      "Budget  2022-2023 _Capital",
      "Budget  2022-2023 _Total"
    )
  category_file <- category_file[,valid_cols]
  master_combined <- dplyr::bind_rows(master_combined, category_file)
}


# Create JH Links file ----------------------------------------------------

jh_links <<- readr::read_csv("datasets/union-budget/master-file/jh-links.csv",col_types = cols())
jh_links$schemeID <- NULL
jh_links$file_title <- NULL
jh_links <- left_join(jh_links, meta_master[,c("schemeName","schemeID")], by=c("DatasetFor"="schemeName"), keep=FALSE)
jh_links <- jh_links[jh_links$Type=="Scheme",]
jh_links <- jh_links[!is.na(jh_links$JHURL),]
jh_links$file_title <- ""

# schemeID <- "P9"

update_data <- function(schemeID){
  print(glue::glue("Processing Scheme -- {schemeID} \n "))
  scheme_file_path <-   meta_master$datasetPath[meta_master$schemeID==schemeID]
  scheme_file <- readr::read_csv(scheme_file_path, col_types = cols())
  scheme_file$value <- as.character(scheme_file$value)
  indicators <- unique(scheme_file$indicators)
  budgetFor <- meta_master$schemeName[meta_master$schemeID==schemeID]
  type <- "scheme"
  indicator_master <- c()
  for(i in 1:length(indicators)){
    indicator_name <- indicators[i]
    indicator_df <- switch (indicator_name,
            "Budget Estimates" = update_budget_estimates(schemeID),
            "Revised Estimates" = update_revised_estimate(schemeID),
            "Actual Expenditure" = update_actual_expenditure(schemeID),
            "Actual Expenditure as a % of Ministry" = update_actual_expenditure_as_percent(schemeID),
            "Fund Utilisation" = update_fund_utilisation_percent(schemeID)
            )
    indicator_master <- dplyr::bind_rows(indicator_master,indicator_df)
    
  }
    indicator_master$budgetFor <- budgetFor
    indicator_master$type <- type
    scheme_file_updated <- dplyr::bind_rows(scheme_file, indicator_master)
    updated_file_path <- stringr::str_split_fixed(scheme_file_path,pattern = "/",n = 4)
    dataset_title <- updated_file_path[[3]]
    updated_file_path <- glue::glue("{updated_file_path[[1]]}/{updated_file_path[[2]]}/data_2022_23/scheme_datasets/{dataset_title}.csv")
    jh_links$file_title[jh_links$schemeID==schemeID] <<- glue::glue("{dataset_title}.csv")
    print(glue("{jh_links$file_title[jh_links$schemeID==schemeID]} \n"))
    readr::write_csv(x = scheme_file_updated,file = updated_file_path)
    scheme_file_updated$schemeID <- schemeID
    return(scheme_file_updated) 
}


# Create updated files and write to disk ----------------------------------

updated_datasets <- lapply(meta_master$schemeID, update_data) %>% dplyr::bind_rows()
readr::write_csv(updated_datasets, "datasets/union-budget/data_2022_23/updated_datasets.csv")

readr::write_csv(jh_links,"datasets/union-budget/master-file/jh-links.csv")

