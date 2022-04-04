library(readr)
library(dplyr)

file_path <- "datasets/union-budget/data_2022_23/update-100222/"
write_path <- "datasets/union-budget/data_2022_23/update-040422/"
source_files <- dir(file_path)

# file_title <-  source_files[[3]]
update_indicator_title <- function(file_title){
  file_to_read <- glue::glue("{file_path}{file_title}")
  budget_file <- readr::read_csv(file_to_read, col_types = cols())
  freq_department <- nrow(budget_file[budget_file$indicators == "Actual Expenditure as a % of Department",])
  freq_ministry <- nrow(budget_file[budget_file$indicators == "Actual Expenditure as a % of Ministry",])
  if(freq_department>freq_ministry){
    print(file_title)
    budget_file$indicators[budget_file$indicators == "Actual Expenditure as a % of Ministry"] <- "Actual Expenditure as a % of Department"
    file_to_write <- glue::glue("{write_path}{file_title}")
    readr::write_csv(x = budget_file, file = file_to_write)
  }
}

lapply(source_files, update_indicator_title)
file_titles <- dir("datasets/union-budget/data_2022_23/update-040422/")
