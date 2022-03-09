source("scripts/libraries.R")
source("scripts/functions.R")

# Which heads to include --------------------------------------------------

head_summary <- readr::read_csv("datasets/state-budgets/assam/comparing_head_codes_across_years.csv", col_types = cols())
cols_to_check <- c("2018-19","2019-20","2020-21","2021-22")
head_summary$include_in_analysis <- 1
for(i in 1:nrow(head_summary)){
  col_status <- head_summary[i,cols_to_check] %>% t()
  if(FALSE %in% col_status){
    head_summary$include_in_analysis[i] <- 0
  }
}

all_levels <- head_summary$level %>% unique()

# Only include levels 1 to 6
levels_to_include <- paste0("level_",2:6,"_code")
head_summary_sub <- head_summary[head_summary$level %in% levels_to_include,]

# Only include where include_in_analysis is 1

head_summary_sub_sub <- head_summary_sub[head_summary_sub$include_in_analysis == 1,]

# Creating grant wise time series -----------------------------------------------

all_heads <-
  readr::read_csv("datasets/state-budgets/assam/all_heads_list.csv",
                  col_types = cols(.default = "c"))
all_categories <- unique(head_summary_sub_sub$category)
all_levels <- unique(head_summary_sub_sub$level)
budget_timeseries <- c()
for(i in 1:length(all_categories)){
cat_i <- all_categories[[i]]  
for(j in 1:length(all_levels)){
  
  level_j <- all_levels[[j]]
  level_codes <-
    head_summary_sub_sub$unique_level_heads[head_summary_sub_sub$category ==
                                              cat_i &
                                              head_summary_sub_sub$level == level_j] %>% unique()
  for(k in 1:length(level_codes)){
    level_codes_k <- level_codes[[k]]
    print_string <- glue::glue("{cat_i} | {level_j} | {level_codes_k}")
    print(print_string)
    budget_data <- all_heads[all_heads[,level_j] == level_codes_k & all_heads$budget_for == cat_i,]
    level_col <- stringr::str_replace(level_j,pattern = "_code",replacement = "")
    budget_cols <- c("budget_for","year", level_col,level_j,"actuals","estimate_py","revised_py","estimate_cy")
    budget_data_sub <- budget_data[,budget_cols]
    names(budget_data_sub)[] <-
      c(
        "budget_for",
        "year",
        "head_title",
        "level_code",
        "actuals",
        "estimate_py",
        "revised_py",
        "estimate_cy"
      )
    budget_data_sub$actuals <- as.numeric(budget_data_sub$actuals)
    budget_data_sub$estimate_py <- as.numeric(budget_data_sub$estimate_py)
    budget_data_sub$revised_py <- as.numeric(budget_data_sub$revised_py)
    budget_data_sub$estimate_cy <- as.numeric(budget_data_sub$estimate_cy)
    budget_data_agg <-
      budget_data_sub %>% group_by(budget_for, year, head_title, level_code) %>% summarise(
        total_actuals = sum(actuals),
        total_estimate_py = sum(estimate_py),
        total_revised_py = sum(revised_py),
        total_estimate_cy = sum(estimate_cy)
      )
    budget_data_agg$level_col <- level_col
    budget_timeseries <- dplyr::bind_rows(budget_timeseries,budget_data_agg)
    
    # For converting the aggregate dataset from wide to long format
    
    # budget_data_agg_long <-
    #   pivot_longer(
    #     data = budget_data_agg,
    #     names_to = "indicator",
    #     values_to = "value",
    #     cols = c(
    #       "total_actuals" ,
    #       "total_estimate_py",
    #       "total_revised_py" ,
    #       "total_estimate_cy"
    #     )
    #   ) 
    
}
}
}

# Removing rows where actual expenditure is NA -----------------------------------

# In the year 2018-19, the same budget head code is present for two different budget heads
# code is - 4059__1
# We're removing all rows that start with this budget head and where the actual expenditure is NA. 
# This will remove 5 rows from the final dataset

budget_timeseries <- budget_timeseries[!is.na(budget_timeseries$total_actuals),]
readr::write_csv(budget_timeseries,"datasets/state-budgets/assam/budget_timeseries.csv")
