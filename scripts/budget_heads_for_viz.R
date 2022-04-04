source("scripts/libraries.R")
source("scripts/functions.R")

budget_ts <- readr::read_csv("datasets/state-budgets/assam/budget_timeseries.csv", col_types = cols())

# Format Budget Heads -----------------------------------------------------

# Update budget title heads for certain codes

code_with_multiple_titles <-
  budget_ts %>% group_by(head_title, level_code) %>% summarise(total = n()) %>% filter(total ==
                                                                                         2) %>% pull(level_code) %>% unique()

budget_ts$head_title_updated[budget_ts$level_code=="4216__1__700"] <- "capital outlay on housing__government residential buildings__other housing programme"
budget_ts$head_title_updated[budget_ts$level_code=="4216__1__700__1501"] <- "capital outlay on housing__government residential buildings__other housing programme__administration of justice"
budget_ts$head_title_updated[budget_ts$level_code=="4216__1__700__1501__927"] <- "capital outlay on housing__government residential buildings__other housing programme__administration of justice__central share (block grant)"
budget_ts$head_title_updated[budget_ts$level_code=="4216__1__700__1501__927__13"] <- "capital outlay on housing__government residential buildings__other housing programme__administration of justice__central share (block grant)__major works"
budget_ts$head_title_updated[budget_ts$level_code=="4216__1__700__1501__584"] <- "capital outlay on housing__government residential buildings__other housing programme__administration of justice__works"
budget_ts$head_title_updated[budget_ts$level_code=="4216__1__700__1501__584__13"] <- "capital outlay on housing__government residential buildings__other housing programme__administration of justice__works__major works"

# Remove NULL from each level

budget_ts$head_title_updated <-
  stringr::str_replace_all(
    string = budget_ts$head_title,
    replacement = "__",
    pattern = "__null__"
  )

# For cases with a __null__null__ pattern
budget_ts$head_title_updated <-
  stringr::str_replace_all(
    string = budget_ts$head_title_updated,
    replacement = "__",
    pattern = "__null__"
  )

# For heads ending with __null
budget_ts$head_title_updated <-
  stringr::str_replace_all(
    string = budget_ts$head_title_updated,
    replacement = "",
    pattern = "__null"
  )

# Check for value of heads at each level ----------------------------------

budget_ts$level_num <- stringr::str_replace_all(string = budget_ts$level_col, pattern = "level_",replacement = "") %>% as.numeric()

head_min_level <- budget_ts %>% group_by(head_title_updated) %>% summarise(min_level=min(level_num))

budget_ts <- left_join(budget_ts, head_min_level, by="head_title_updated")
budget_ts_updated <- budget_ts[budget_ts$level_num==budget_ts$min_level,]

# Add display title for budget heads --------------------------------------
budget_ts_updated$display_title <- budget_ts_updated$head_title_updated %>% 
  stringr::str_replace_all(pattern = "__",replacement = " - ") %>% 
  stringr::str_to_title() %>% 
  stringr::str_trim()



# Write file --------------------------------------------------------------

readr::write_csv(budget_ts_updated,"datasets/state-budgets/assam/budget_timeseries_updated.csv")

# Checks ------------------------------------------------------------------

x <- budget_ts %>% 
  filter(year == "2018-19") %>% 
  group_by(head_title_updated) %>% 
  summarise(la = length(unique(total_actuals)),
            epy = length(unique(total_estimate_py)),
            rpy = length(unique(total_revised_py)),
            ecy = length(unique(total_estimate_cy)))

x$sum <- x$la + x$epy + x$rpy + x$ecy

