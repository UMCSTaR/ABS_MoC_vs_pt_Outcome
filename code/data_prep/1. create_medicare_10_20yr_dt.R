# this code were from archived/1_define_cohort.Rmd
# but more organized with less text explanation of why we choose the filters
# if you want to know why the filters were chosen, refer to the 1_define_cohort.pdf document.
# in the end we created abs_medicare_10_20yr.rdata 

# August 2022, the team(Andy, Bria, Kayla and Xilin) have decided to include fellowship trained surgeons in the dataset

library(tidyverse)

# load data ---------------------------------------------------------------
abs = data.table::fread("/Volumes/George_Surgeon_Projects/Surgeon Profile data/abs_with_npi.csv", colClasses = c('npi'='character'))
# fellow_council = data.table::fread("/Volumes/George_Surgeon_Projects/Surgeon Profile data/fellowship_council/fellowship_npi_manual_linked.csv")

# data processing ---------------------------------------------------------
selected_abs = abs %>% 
  mutate(npi = as.character(npi),
         # initial certification
         pass_CE = ifelse(PFfirstCE == "p" | !is.na(Gcertyear), "passed", "failed")
  ) %>% 
  select(npi, sex, gs_residency_yog, Gcertyear, Gcompyear, ReCeverPassed,
         pass_CE, nAttemptsReCert, PFfirstR, us_medschool, gs_specialty_cms, fellowship) 

## filter  -----------------------------------------------------------
# passed initial certification
abs_cert = selected_abs %>% 
  filter(pass_CE == "passed")

# remove fellowship trained surgeons 
# abs_gs = abs_cert %>% 
#   filter(!npi %in% fellow_council$npi, # fellowship council
#          fellowship == F) # ABS fellowship
# 
# nrow(abs_cert) - nrow(abs_gs)
# 
# # fellowship trained surgeons
# anti_join(abs_cert, abs_gs) %>% 
#   count(ReCeverPassed)

# 1987-2017 certification year
# abs_gs_87_17 = abs_gs %>% 
abs_gs_87_17 = abs_cert %>% 
  mutate(cutoff_2007 = ifelse(Gcertyear+10>=2017, "exlcude", "include")) %>% 
  filter(cutoff_2007 == "include" | is.na(cutoff_2007), Gcertyear>1987)

nrow(abs_cert) - nrow(abs_gs_87_17)

# the reason to start with 1987 is because our medicare data starts at 2007,
# we only analyze data 10-20 years after initial certification. surgeons who graduated before 
# 1987 don't have medicare outcomes

## recat recertification status
abs_w_recert = abs_gs_87_17 %>%
  mutate(
    npi = as.character(npi),
    Recert_status = case_when(
      ReCeverPassed == 0 ~ "failed",
      ReCeverPassed == 1 ~ "passed",
      is.na(ReCeverPassed) ~ "NA_failed"
    )
  ) 


# Link with Medicare data -------------------------------------------------
# all procedures
medicare = data.table::fread("/Volumes/George_Surgeon_Projects/standardized_medicare_data_using_R/analysis_ready_data/ecs_primary_surgeon_medicare2018.csv")
# Core medicare procedure
# medicare = data.table::fread("/Volumes/George_Surgeon_Projects/ECV_2.0/data/ecv_medicare_procedures.csv")
# medicare %>% 
#   count(score_core_advanced)

abs_medicare = abs_w_recert %>%
  inner_join(medicare, by = c("npi" = "id_physician_npi"))

nrow(abs_w_recert) - n_distinct(abs_medicare$npi)

# surgeons excluded by not having medicare records
abs_w_recert %>% anti_join(abs_medicare, by = "npi") %>% 
  count(Recert_status)

## filter only keep 10-20 years after initial certification medicare cases 
abs_medicare_10_20yr = abs_medicare %>%
  filter(facility_clm_yr - Gcertyear>10,
         facility_clm_yr - Gcertyear<=20)

n_distinct(abs_medicare_10_20yr$npi) - n_distinct(abs_medicare$npi)
nrow(abs_medicare_10_20yr)

# save data ---------------------------------------------------------------
# save(abs_medicare_10_20yr, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr.rdata")
# core procedures
# save(abs_medicare_10_20yr, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/ECV_data/abs_medicare_10_20yr.rdata")

# all proc include fellows
save(abs_medicare_10_20yr, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/ECV_data/abs_medicare_include_fellow.rdata")

