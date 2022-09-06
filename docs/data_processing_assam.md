
## Budgets for Justice - State Budgets

### Context

The state budget datasets are crucial if one has to analyse the flow of funds in areas specific to law and justice. They contain a lot more info about how and where the funds will be spent or are spent in any financial year. Analysing state budget documents is difficult because:

1. The documents are rarely available in machine-readable formats.
2. All states follow their own formats for maintaining budget data which makes it hard to compare data across states. 
3. The budget data at the state level lacks good documentation and the budget heads are changed often between years which makes it hard to compare the data for the same state across years. 

Assam is one of the states which has been releasing budget datasets in [machine-readable formats](https://openbudgetsindia.org/organization/about/assam). These datasets are available on the [Open Budgets India](https://openbudgetsindia.org/) platform. This makes it possible for us to analyse the budget data for Assam for schemes related to law and justice. 


### Data visualisation for state budgets

A time-series graph for budget heads which include the Budget, Revised and Actual amounts. To know more about the how budget documents are structured, refer to the [Budget Basics Guidebook](https://budgetbasics.openbudgetsindia.org/glossary).


### Which heads to include - Checking by Head Title

1. The state budget data is hierarchical in nature. The funds are allocated under each budget head which is organised as - ```Major Head (L1) -> Sub-Major Head (L2) -> Minor Head (L3) -> Sub-Minor Head (L4) -> Detailed Head (L5) -> Object Head (L6) -> Voucher Head (L7) -> Scheme (L8) -> Area (L9) -> Voted/Charged (L10)```
2. In the past, we have developed [budget explorers](https://assam2021.openbudgetsindia.org/en/expenditure/all-grants/grant-no-3-administration-of-justice/) through which a user can view the budgets released under each head. 
3. The budget heads at all levels are not common between years, hence it's hard to compare the budget across years for heads that don't match. 
4. This [file](https://github.com/justicehub-in/budgets-for-justice-datasets/blob/main/datasets/state-budgets/assam/level_summary.csv) details the consistency in budget heads across years. The similarity between heads as we move deep in the hierarchy (from L2 to L10). _[Google Sheet](https://docs.google.com/spreadsheets/d/1eaCiyHIecujo0-waPDk4szL6icWT1RBmdoC6aIhEvsc/edit)_
5. For the three grants which we have selected for analysing the law and justice related budgets i.e. Jails, Justice, and Police, we get an average match of **55% at L5 (Detailed head)**. This means that if there are 100 heads at L5, we could only match 55 heads across all years. 
6. We have curated all heads at all levels across the last 4 years (till 2021) in this [file](https://docs.google.com/spreadsheets/d/16fl7icGznIEgJQ_g5MQTiqgROiDB9cwGXgC-oiFh024/edit#gid=414449477). 


### Checking by Head Code

_All budget heads are assigned a code. We can also use the code to compare heads across years. _

1. We observe more consistency in budget heads when we use codes instead of using titles
2. Overall coverage for each major head at each level is documented [here](https://github.com/justicehub-in/budgets-for-justice-datasets/blob/main/datasets/state-budgets/assam/code_level_summary.csv)
3. The consistency in heads varies among revenue and capital related heads ( _The major head code identifies whether a particular head is part of revenue or capital head_ ). 
4. Budget head codes have higher consistency for revenue related heads as compared to capital related heads.
5. The coverage (in percentage) for each major head till level 6 is as follows: 

|category | major_head| level_2_code| level_3_code| level_4_code| level_5_code| level_6_code|
|:--------|----------:|------------:|------------:|------------:|------------:|------------:|
|jails    |       2056|          100|        80.00|        75.00|        70.00|        81.67|
|jails    |       4059|          100|        50.00|        60.00|        55.56|        55.56|
|justice  |       2014|          100|        83.33|        90.91|        83.33|        77.27|
|justice  |       2041|          100|       100.00|       100.00|       100.00|        62.50|
|justice  |       2230|          100|       100.00|       100.00|       100.00|        85.19|
|justice  |       4059|          100|        50.00|        42.86|        20.83|        20.83|
|justice  |       4216|          100|        66.67|        66.67|        50.00|        50.00|
|police   |       2055|          100|        92.31|        93.65|        60.00|        50.00|
|police   |       4055|          100|       100.00|        37.50|        23.91|        20.41|

#### Including 2022

|category | major_head| level_2_code| level_3_code| level_4_code| level_5_code| level_6_code|
|:--------|----------:|------------:|------------:|------------:|------------:|------------:|
|jails    |       2056|          100|        80.00|        75.00|        70.00|        78.33|
|jails    |       4059|          100|         0.00|         0.00|         0.00|         0.00|
|justice  |       2014|          100|        71.43|        86.96|        76.00|        69.57|
|justice  |       2041|          100|       100.00|       100.00|       100.00|        62.50|
|justice  |       2230|          100|       100.00|       100.00|       100.00|        85.19|
|justice  |       4059|          100|         0.00|         0.00|         0.00|         0.00|
|justice  |       4216|          100|        66.67|        66.67|        50.00|        42.86|
|police   |       2055|          100|        92.31|        93.65|        56.52|        46.33|
|police   |       4055|          100|        66.67|        36.00|        22.00|        18.87|


### Year wise budget information of selected budget heads

The file is available [here](https://github.com/justicehub-in/budgets-for-justice-datasets/blob/main/datasets/state-budgets/assam/budget_timeseries.csv)


