
# Source Files ------------------------------------------------------------

# Create JH Links file ----------------------------------------------------

# jh_links <- readr::read_csv("datasets/union-budget/master-file/jh-links.csv",col_types = cols())
# jh_links$schemeID <- NULL
# jh_links$file_title <- NULL
# jh_links <- left_join(jh_links, meta_master[,c("schemeName","schemeID")], by=c("DatasetFor"="schemeName"), keep=FALSE)
# # jh_links <- jh_links[jh_links$Type=="Scheme",]
# jh_links <- jh_links[!is.na(jh_links$JHURL),]
# jh_links$file_title <- ""
# readr::write_csv(jh_links,"datasets/union-budget/master-file/jh_links_scheme_id.csv")


# Read JH links file with Scheme ID ---------------------------------------

# Note: This file should be updated whenever the jh_links.csv has been updated. The jh_links.csv should be updated whenever any new dataset needs to be added.

jh_links <- readr::read_csv("datasets/union-budget/master-file/jh_links_scheme_id.csv", col_types = cols())

