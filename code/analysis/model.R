library(tidyverse)

# load lined abs medicare data 
load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10yr.rdata")

source("code/functions/prep_medicare_data.R")

# prep variables
medicare_abs_model_ready = prep_data_for_model(abs_medicare_10yr) %>% 
  mutate(re_cert_status = case_when(ReCeverPassed == 0 ~ "failed",
                                    ReCeverPassed == 1 ~ "passed",
                                    is.na(ReCeverPassed) ~ "no record, failed"),
         re_cert_status = factor(re_cert_status, levels = c("failed", "passed", "no record, failed")),
         re_cert_bin = ifelse(re_cert_status == "passed", "passed", "no_pass_or_NA"),
         
         n_attempts_recert = ifelse(nAttemptsReCert >=3, "≥3", nAttemptsReCert),
         n_attempts_recert = factor(n_attempts_recert, levels = c("1", "2", "≥3")))


save(medicare_abs_model_ready, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready.rdata")

# check
medicare_abs_model_ready %>% distinct(npi, re_cert_status) %>% count(re_cert_status)
n_distinct(medicare_abs_model_ready$e_proc_grp_lbl) #162

# model -------------------------------------------------------------------

covariates = c(
  # choose one cert status--
  # 're_cert_status',
  're_cert_bin',
  # other--
  'flg_male',
  'age_at_admit_std',
  'AHRQ_score_std',
  'race_white',
  'ses_binary',
  'emergent_admit',
  'year',
  'surgeon_yearly_load_std',
  # "had_assist_surg",
  'flg_hosp_ICU_hosp'
)

all(covariates %in% names(medicare_abs_model_ready))


# lme4 --------------------------------------------------------------------

f = formula(paste("flg_death_30d ~ 1", paste(covariates, collapse = ' + '),
                  "(1 | e_proc_grp_lbl)",
                  sep = " + "))


system.time({
  death_model_bin = glmer(formula = f,
                          data = medicare_abs_model_ready,
                          family = binomial)
})

# save(death_model_bin, file = "X://George_Surgeon_Projects/MOC_vs_Outcome/model/death_model_bin.rdata")


# glmmtmb -----------------------------------------------------------------
library(glmmTMB)

system.time({
  death_model_bin_glmtmb = glmmTMB(formula = f,
                          data = medicare_abs_model_ready,
                          family = binomial)
})

# save(death_model_bin_glmtmb, file = "X://George_Surgeon_Projects/MOC_vs_Outcome/model/death_model_bin_glmtmb.rdata")



# bayesian -----------------------------------------------------------------






