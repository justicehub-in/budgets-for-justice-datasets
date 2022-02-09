**Steps taken to update the budget datasets**

1. Updating the [master sheet](https://docs.google.com/spreadsheets/d/1HoikXV4udZRaJgHB0858BAQ0Rrv9qe--ecLUpEh5Bgk/edit?usp=sharing) with latest numbers from budget 2022 - This was done manually to avoid any error and inconsistencies.  
2. The format of the master sheet was updated. The google sheet is meant for public viewing. The format was updated by removing merged cells, updating column names, etc to make it more compatible for processing and updating datasets. The updated master files can be viewed [here](datasets/union-budget/master-file/)
3. A schemeID column was added to master files for all ministries/departments. This was done to create a foreign key between the master sheet and the induvidual scheme files. 
4. The same schemeID was added in the metadata sheet for all schemes. This process was done manually to avoid any inconsistencies.
5. The metadata for all schemes was combined in a single dataframe. This was done to collate variables like `schemeID`, `schemeName`, `datasetPath` and `totalIndicators` for each scheme.
6. Similarly, the master file for all ministries/departments was combined in a single dataframe.
7. The function `update_data` in the file [update_data_union_budget_2022.R](scripts/update_data_union_budget_2022.R) is used to create a file for each scheme for all the new indicators and append it to the existing file for that scheme.
8. The new scheme datasets are exported in a common directory.
9. The file [jh_links](datasets/union-budget/master-file/jh_links.csv) was created to store the mapping between the title of the scheme file and the Justice Hub URL of the file. This was done so the current datasets can be updated with the new ones from the backend.
10. The exported files (`jh_links` and the `individual scheme files`) were zipped and uploaded on drive [here](https://drive.google.com/drive/folders/1-lmO3y41xkpLE8McxD4ardiCD8-BRRZ7?usp=sharing)