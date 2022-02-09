# Update dataset indicator function -------------------------------------------------

update_revised_estimate <<- function(schemeID){
  indicator_data <- data.frame("fiscalYear"="2021-2022","indicators"="Revised Estimates","budgetType"=c("Revenue","Capital","Total"))
  indicator_data$value <-
    as.character(t(master_combined[master_combined$schemeID == schemeID, c("Revised 2021-2022 _Revenue",
                                                                           "Revised 2021-2022 _Capital",
                                                                           "Revised 2021-2022 _Total")]))
  return(indicator_data)
}

update_actual_expenditure <<- function(schemeID){
  indicator_data <- data.frame("fiscalYear"="2020-2021","indicators"="Actual Expenditure","budgetType"=c("Revenue","Capital","Total"))
  indicator_data$value <-
    as.character(t(master_combined[master_combined$schemeID == schemeID, c("Actual 2020-2021 _Revenue" ,
                                                                           "Actual 2020-2021 _Capital" ,
                                                                           "Actual 2020-2021 _Total")]))
  return(indicator_data)
}

update_budget_estimates <<- function(schemeID){
  indicator_data <- data.frame("fiscalYear"="2022-2023","indicators"="Budget Estimates","budgetType"=c("Revenue","Capital","Total"))
  indicator_data$value <-
    as.character(t(master_combined[master_combined$schemeID == schemeID, c("Budget  2022-2023 _Revenue",
                                                                           "Budget  2022-2023 _Capital",
                                                                           "Budget  2022-2023 _Total")]))
  return(indicator_data)
}

update_actual_expenditure_as_percent <<- function(schemeID){
  indicator_data <- data.frame("fiscalYear"="2020-2021","indicators"="Actual Expenditure as a % of Ministry","budgetType"=NA_character_)
  if(grepl(schemeID,pattern = "L")){
    ministry_total <- master_combined$`Actual 2020-2021 _Total`[master_combined$schemeID=="LT7"]
  } else {
    ministry_total <- master_combined$`Actual 2020-2021 _Total`[master_combined$schemeID=="PT2"]
  }
  
  indicator_data$value <- round(as.numeric(master_combined$`Actual 2020-2021 _Total`[master_combined$schemeID==schemeID])/as.numeric(ministry_total)*100,2)
  indicator_data$value <- glue("{indicator_data$value}%")
  return(indicator_data)
}

update_fund_utilisation_percent <<- function(schemeID){
  indicator_data <- data.frame("fiscalYear"="2020-2021","indicators"="Fund Utilisation","budgetType"=NA_character_)
  actual_expenditure <- as.numeric(master_combined$`Actual 2020-2021 _Total`[master_combined$schemeID==schemeID])
  revised_estimate <- as.numeric(master_combined$`Revised 2020-2021 _Total`[master_combined$schemeID==schemeID])
  indicator_data$value <- round(actual_expenditure/revised_estimate*100,2)
  indicator_data$value <- glue("{indicator_data$value}%")
  return(indicator_data)
}


