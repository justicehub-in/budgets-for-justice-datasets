
## Budgets for Justice - State Budgets

### Context

The state budget datasets are crucial if one has to analyse the flow of funds in areas specific to law and justice. They contain a lot more info about how and where the funds will be spent or are spent in any financial year. Analysing state budget documents is difficult because:

1. The documents are rarely available in machine-readable formats.
2. All states follow their own formats for maintaining budget data which makes it hard to compare data across states. 
3. The budget data at the state level lacks good documentation and the budget heads are changed often between years which makes it hard to compare the data for the same state across years. 

[Assam](https://openbudgetsindia.org/organization/about/assam) is one of the states which has been releasing budget datasets in machine-readable formats. The datasets are available on the Open Budgets India platform. This makes it possible for us to include the budget data for Assam, on schemes related to law and justice, on the Budgets for Justice portal. 

### Data visualisation for state budgets

A time-series graph for all budget heads which include the Budget, Revised and Actual amounts. 


### Which heads to include

1. The state budget data is more hierarchical than union budget data. The hierarchy is as follows  - ```Major Head > Sub-Major Head > Minor Head > Sub-Minor Head > Detailed Head > Object Head > Voucher Head > Scheme > Area > Voted/Charged```
2. In the past, we have developed [budget explorers](https://assam2019.openbudgetsindia.org/en/expenditure/all-grants/grant-no-3-administration-of-justice/) through which a user can explore the entire hierarchy for each head. 
3. Since the budget heads at all levels are not consistent between years, it's hard to compare the budget across years for heads that don't match. 
4. This [file](https://github.com/justicehub-in/budgets-for-justice-datasets/blob/main/datasets/state-budgets/assam/level_summary.csv) details the consistency in budget heads across years. As evident from the file, the percentage of common heads reduces as we move from a Level 2 (combining the first two heads) to L10 (combining all heads). _[Google Sheet](https://docs.google.com/spreadsheets/d/1eaCiyHIecujo0-waPDk4szL6icWT1RBmdoC6aIhEvsc/edit)_
5. On an average, **55% of the heads match at Level 5 (till Detailed head)** for Jails, Justice, and Police related heads.
6. This [file](https://docs.google.com/spreadsheets/d/16fl7icGznIEgJQ_g5MQTiqgROiDB9cwGXgC-oiFh024/edit#gid=414449477) includes details about the heads at each level and whether they are repeated across years. 




