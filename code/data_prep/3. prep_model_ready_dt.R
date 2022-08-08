# prep model data
# rename variables
# keep complete dataset
library(tidyverse)
source("code/functions/prep_model_ready_dt.R")

# # load lined abs medicare data 
# load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr_union_4_def.rdata")
# load("x:\\/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr_union_4_def.rdata")
# # ecv: core procedure only
# load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/ECV_data/abs_medicare_10_20yr_union_4_def.rdata")

# all proc include fellows
load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/ECV_data/abs_medicare_include_fellow.rdata")

# remove multiple procedures
medicare_remove_muti = medicareAnalytics::remove_multi_proc(abs_medicare_10_20yr)
nrow(medicare_remove_muti) #774,395
n_distinct(abs_medicare_10_20yr$npi) - n_distinct(medicare_remove_muti$npi)

# medicare_remove_muti_ecv = medicareAnalytics::remove_multi_ecv_proc(abs_medicare_union %>% rename(id_physician_npi = npi))
# nrow(medicare_remove_muti_ecv) #775174


# debugonce(prep_model_ready_dt)
medicare_abs_model_ready_no_na = prep_model_ready_dt(data = medicare_remove_muti)

nrow(medicare_abs_model_ready_no_na) 
n_distinct(medicare_abs_model_ready_no_na$npi) - n_distinct(medicare_remove_muti$npi)

# save(medicare_abs_model_ready_no_na, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na.rdata")
# save(medicare_abs_model_ready_no_na, file = "x:\\/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na.rdata")
# 
# # ecv
# save(medicare_abs_model_ready_no_na, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/ECV_data/medicare_abs_model_ready_no_na.rdata")
# 
# # removed multi proc
# saveRDS(medicare_abs_model_ready_no_na, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na_remove_multi_proc.rds")

# save all surgeons medicare cases
saveRDS(medicare_abs_model_ready_no_na, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_ex_multi_include_fellowship.rds")


