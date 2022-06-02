source("scripts/libraries.R")
source("scripts/functions.R")

col_list <- get_all_cols()
budget_heads <- get_budget_heads()

total_budget <-
  budget_heads %>% 
  group_by(file_id) %>% 
  summarise(total_budget = sum(as.numeric(estimate_cy)))

budget_heads <- left_join(budget_heads, total_budget, by="file_id")

budget_summary_file <- budget_heads[,c("file_id","row_id","estimate_cy","total_budget")]
budget_summary_file$estimate_cy <- as.numeric(budget_summary_file$estimate_cy)
budget_summary_file$head_percent <- budget_summary_file$estimate_cy/budget_summary_file$total_budget * 100

budget_summary_file <-
  budget_summary_file %>% 
  group_by(file_id) %>% 
  mutate(budget_rank = order(order(head_percent, decreasing = TRUE)))

cols_to_join <-
  c(
    "file_id",
    "row_id",
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

budget_summary_file_heads <-
  left_join(budget_summary_file, budget_heads[, cols_to_join], 
            by = c("file_id", "row_id"))

budget_summary_file_heads_category <-
  budget_summary_file_heads %>% 
  group_by(file_id, `Major Head`,`Minor Head`,`Sub-Minor Head`, total_budget) %>% 
  summarise(total_cy = sum(estimate_cy)) 

budget_summary_file_heads_category$category_percent <- budget_summary_file_heads_category$total_cy/budget_summary_file_heads_category$total_budget*100
budget_summary_file_heads_category <- budget_summary_file_heads_category %>% 
  group_by(file_id) %>% 
  mutate(budget_rank = order(order(category_percent, decreasing = TRUE)))
