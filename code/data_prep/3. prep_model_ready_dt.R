# prep model data
# rename variables
# keep complete dataset
library(tidyverse)
source("code/functions/prep_model_ready_dt.R")

# load lined abs medicare data 
load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr_union_4_def.rdata")


# debugonce(prep_model_ready_dt)
medicare_abs_model_ready_no_na = prep_model_ready_dt(data = abs_medicare_union)

nrow(medicare_abs_model_ready_no_na) # 710566
n_distinct(medicare_abs_model_ready_no_na$npi) # 7397


save(medicare_abs_model_ready_no_na, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na.rdata")
