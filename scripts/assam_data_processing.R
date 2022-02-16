
# Source files ------------------------------------------------------------

source("scripts/libraries.R")
source("scripts/functions.R")

# Reading files from OBI --------------------------------------------------

# Reference - https://apoorv74.github.io/OBI-data-explorer/
org_url <- "https://openbudgetsindia.org/"
ckanr::ckanr_setup(url = org_url)
org_connect <- ckanr::src_ckan(url = org_url)


# Find dataset links from OBI ---------------------------------------------

years <- c("2018-19", "2019-20", "2020-21","2021-22")
organisations <-
  paste0("assam-budget-", years)

all_dataset_links <- lapply(organisations, find_dataset_links) %>% bind_rows()
all_dataset_links$budget_for <-
  stringr::str_replace_all(all_dataset_links$budget_for,
                           pattern = "Grant.*- ",
                           replacement = "") %>% stringr::str_squish() %>% stringr::str_to_lower()



# Download CSV files ------------------------------------------------------

lapply(all_dataset_links$package_id, download_files)

# Check cols across files -------------------------------------------------

all_cols <- get_all_cols()
unique_cols_df <- data.frame("all_cols"=unique(all_cols$col_names))
unique_file_ids <- unique(all_cols$file_id) 
for(i in 1:length(unique_file_ids)){
  cols_in_year <-
    unique_cols_df$all_cols %in% all_cols$col_names[all_cols$file_id == unique_file_ids[[i]]] %>% data.frame()
  names(cols_in_year)[] <- glue::glue("cols_{unique_file_ids[i]}")
  unique_cols_df <- bind_cols(unique_cols_df, cols_in_year)
}

readr::write_csv(unique_cols_df,"datasets/state-budgets/assam/cols_across_years.csv")


# Compare budget heads across years ---------------------------------------

all_budget_heads <- get_budget_heads()

combined_heads <-
  all_budget_heads %>% mutate(
    level_2 = paste0(`Major Head`, "__", `Sub-Major Head`) %>% stringr::str_to_lower() %>% stringr::str_squish(),
    level_3 = paste0(`Major Head`, "__", `Sub-Major Head`, "__", `Minor Head`) %>% stringr::str_to_lower() %>% stringr::str_squish(),
    level_4 = paste0(
      `Major Head`,
      "__",
      `Sub-Major Head`,
      "__",
      `Minor Head`,
      "__",
      `Sub-Minor Head`
    ) %>% stringr::str_to_lower() %>% stringr::str_squish(),
    level_5 = paste0(
      `Major Head`,
      "__",
      `Sub-Major Head`,
      "__",
      `Minor Head`,
      "__",
      `Sub-Minor Head`,
      "__",
      `Detailed Head`
    ) %>% stringr::str_to_lower() %>% stringr::str_squish(),
    level_6 = paste0(
      `Major Head`,
      "__",
      `Sub-Major Head`,
      "__",
      `Minor Head`,
      "__",
      `Sub-Minor Head`,
      "__",
      `Detailed Head`,
      "__",
      `Object Head`
    ) %>% stringr::str_to_lower() %>% stringr::str_squish(),
    level_7 = paste0(
      `Major Head`,
      "__",
      `Sub-Major Head`,
      "__",
      `Minor Head`,
      "__",
      `Sub-Minor Head`,
      "__",
      `Detailed Head`,
      "__",
      `Object Head`,
      "__",
      `Voucher Head`
    ) %>% stringr::str_to_lower() %>% stringr::str_squish(),
    level_8 = paste0(
      `Major Head`,
      "__",
      `Sub-Major Head`,
      "__",
      `Minor Head`,
      "__",
      `Sub-Minor Head`,
      "__",
      `Detailed Head`,
      "__",
      `Object Head`,
      "__",
      `Voucher Head`,
      "__",
      `Scheme`
    ) %>% stringr::str_to_lower() %>% stringr::str_squish(),
    level_9 = paste0(
      `Major Head`,
      "__",
      `Sub-Major Head`,
      "__",
      `Minor Head`,
      "__",
      `Sub-Minor Head`,
      "__",
      `Detailed Head`,
      "__",
      `Object Head`,
      "__",
      `Voucher Head`,
      "__",
      `Scheme`,
      "__",
      `Area`
    ) %>% stringr::str_to_lower() %>% stringr::str_squish(),
    level_10 = paste0(
      `Major Head`,
      "__",
      `Sub-Major Head`,
      "__",
      `Minor Head`,
      "__",
      `Sub-Minor Head`,
      "__",
      `Detailed Head`,
      "__",
      `Object Head`,
      "__",
      `Voucher Head`,
      "__",
      `Scheme`,
      "__",
      `Area`,
      "__",
      `Voted/Charged`
    ) %>% stringr::str_to_lower() %>% stringr::str_squish()
  )

combined_heads$budget_for <- stringr::str_replace_all(string = combined_heads$file_id,pattern = "assam-budget.*_",replacement = "")
combined_heads$budget_for <- stringr::str_replace_all(string = combined_heads$budget_for,pattern = "\\.csv",replacement = "")
combined_heads$year <- stringr::str_replace_all(string = combined_heads$file_id,pattern = "assam-budget-",replacement = "")
combined_heads$year <- stringr::str_replace_all(string = combined_heads$year,pattern = "_.*",replacement = "")

all_categories <- c("jails","justice","police")
all_levels <- paste0("level_",seq(2,10))
all_years <- years
master_head_level_df <- c()
all_year_status <- c()
for(i in 1:length(all_categories)){
  category_rows <- combined_heads[combined_heads$budget_for == all_categories[[i]],]
  for(j in 1:length(all_levels)){
    print(glue::glue("{all_categories[[i]]} -- Level -- {all_levels[j]}"))
    level_rows <- category_rows[,c("year",all_levels[[j]])] %>% unique()
    names(level_rows)[] <- c("year","level")
    
    # output level match details to a sheet
    
    unique_level_heads <- unique(level_rows$level)
    year_status_master <- data.frame(
      "category" = all_categories[[i]],
      "level" = all_levels[[j]],
      "unique_level_heads" = unique_level_heads
    )
    for(k in 1:length(all_years)){
      year_status <- unique_level_heads %in% level_rows$level[level_rows$year == all_years[[k]]]
      year_status_df <- data.frame("year_status" = year_status)
      names(year_status_df)[] <- all_years[[k]]
      year_status_master <- bind_cols(year_status_master,year_status_df)  
    }
    
    head_distribution <-
      level_rows %>% group_by(level) %>% summarise(total = n())
    total_values <- nrow(head_distribution)
    common_values <- nrow(head_distribution[head_distribution$total==4,])
    percent_common <- round(common_values/total_values*100,2)
    head_level_df <- data.frame("category"=all_categories[[i]],
                                "level"=all_levels[[j]],
                                "total_values"=total_values,
                                "common_values"=common_values,
                                "percent_common"=percent_common)
    master_head_level_df <- bind_rows(master_head_level_df, head_level_df)
    all_year_status <- bind_rows(all_year_status,year_status_master)
  }
}

readr::write_csv(master_head_level_df,"datasets/state-budgets/assam/level_summary.csv")
readr::write_csv(all_year_status,"datasets/state-budgets/assam/comparing_heads_across_years.csv")
