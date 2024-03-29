# rename/select variables
# remove na values

prep_model_ready_dt <- function(data = abs_medicare_10_20yr) {
  
  source("code/functions/prep_medicare_data.R")
  
  medicare_abs_model_ready = prep_data_for_model(data) %>% 
    mutate(re_cert_status = case_when(ReCeverPassed == 0 ~ "failed",
                                      ReCeverPassed == 1 ~ "passed",
                                      is.na(ReCeverPassed) ~ "no record, failed"),
           re_cert_status = factor(re_cert_status, levels = c("failed", "passed", "no record, failed")),
           re_cert_bin = ifelse(re_cert_status == "passed", "Passed", "Failed"),
           
           n_attempts_recert = ifelse(nAttemptsReCert >=3, "≥3", nAttemptsReCert),
           n_attempts_recert = factor(n_attempts_recert, levels = c("1", "2", "≥3")),
           years_after_initial_certification = facility_clm_yr - Gcertyear)
  
  
  # # check
  # medicare_abs_model_ready %>% distinct(npi, re_cert_status, re_cert_bin) %>% count(re_cert_status, re_cert_bin)
  # n_distinct(medicare_abs_model_ready$e_proc_grp_lbl) #162
  
  
  # choose variables to include in table1. The variables should be consistent with the model covariates.
  covariates = c(
    # id
    'npi', 
    'id_hospital',
    # choose one cert status--
    # 're_cert_status',
    're_cert_bin',
    # other--
    'flg_male',
    'age_at_admit_std',
    'AHRQ_score_std',
    'race_white',
    'ses',  # ses had a 7% missing too
    'emergent_admit',
    'year',
    # 'surgeon_yearly_load_std',
    'years_after_initial_certification',
    "had_assist_surg",
    # hospital--
    # 'hospital_icu',  # have 10% missing
    'hospital_urban',
    'hospital_beds_gt_350',
    'hospital_rn2bed_ratio_std',
    'hospital_mcday2inptday_ratio_std'
  )
  
  medicare_abs_model_ready = medicare_abs_model_ready %>%
    rename(
      id_hospital = facility_prvnumgrp,
      procedure = e_proc_grp_lbl,
      ses = ses_binary,
      hospital_urban = flg_hosp_urban,
      hospital_beds_gt_350 = hosp_beds_2grp,
      hospital_icu = flg_hosp_ICU_hosp,
      hospital_rn2bed_ratio_std = val_hosp_rn2bed_ratio_std,
      hospital_mcday2inptday_ratio_std = val_hosp_mcday2inptday_ratio_std,
      hospital_rn2inptday_ratio_std = val_hosp_rn2inptday_ratio_std,
      death_30d = flg_death_30d,
      severe_complication_no_poa = flg_cmp_po_any_not_poa,
      # this will ultimately need to be changed when named appropriately
      readmission_30d = flg_readmit_30d,
      reoperation_30d = flg_util_reop
    ) 
  
  all(covariates %in% names(medicare_abs_model_ready))
  
  medicare_abs_model_ready_no_na = medicare_abs_model_ready %>%
    drop_na(!!covariates)
  
  medicare_abs_model_ready_no_na
}