# prep model data
# rename variables
# keep complete dataset
library(tidyverse)
source("code/functions/prep_model_ready_dt.R")

# load lined abs medicare data 
load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr_union_4_def.rdata")


medicare_abs_model_ready_no_na = prep_model_ready_dt(data = abs_medicare_union)


save(medicare_abs_model_ready_no_na, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na.rdata")

