# prep model data
# rename variables
# keep complete dataset
library(tidyverse)
source("code/functions/prep_model_ready_dt.R")

# load lined abs medicare data 
load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr_union_4_def.rdata")
load("x:\\/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr_union_4_def.rdata")
# ecv
load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/ECV_data/abs_medicare_10_20yr_union_4_def.rdata")

# remove mutiple procedures
medicare_remove_muti = medicareAnalytics::remove_multi_proc(abs_medicare_union)
nrow(medicare_remove_muti) #774,395

# medicare_remove_muti_ecv = medicareAnalytics::remove_multi_ecv_proc(abs_medicare_union %>% rename(id_physician_npi = npi))
# nrow(medicare_remove_muti_ecv) #775174


# debugonce(prep_model_ready_dt)
medicare_abs_model_ready_no_na = prep_model_ready_dt(data = medicare_remove_muti)

nrow(medicare_abs_model_ready_no_na) # 710566
n_distinct(medicare_abs_model_ready_no_na$npi) # 7397

save(medicare_abs_model_ready_no_na, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na.rdata")
save(medicare_abs_model_ready_no_na, file = "x:\\/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na.rdata")

# ecv
# save(medicare_abs_model_ready_no_na, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/ECV_data/medicare_abs_model_ready_no_na.rdata")

# removed multi proc
saveRDS(medicare_abs_model_ready_no_na, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na_remove_multi_proc.rds")


