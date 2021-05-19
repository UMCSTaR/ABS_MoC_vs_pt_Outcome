library(tidyverse)
library(lme4)

# load dt
load("X:\\George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na.rdata")

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
  'ses',
  'emergent_admit',
  'year',
  'surgeon_yearly_load_std',
  "had_assist_surg"
  # hospital--
  # 'hospital_icu',
  # 'hospital_urban',
  # 'hospital_beds_gt_350',
  # 'hospital_icu',
  # 'hospital_rn2bed_ratio_std',
  # 'hospital_mcday2inptday_ratio_std'
)


all(covariates %in% names(medicare_abs_model_ready_no_na))


# lme4 --------------------------------------------------------------------
# random effect 
# id
# 'npi', 
# 'id_hospital'

f = formula(paste("death_30d ~ 1", paste(covariates, collapse = ' + '),
                  "(1 | procedure)",
                  sep = " + "))
f

system.time({
  death_model_bin = glmer(formula = f,
                          data = medicare_abs_model_ready_no_na,
                          family = binomial)
})

save(death_model_bin, file = "X://George_Surgeon_Projects/MOC_vs_Outcome/model/death_model_bin.rdata")


# glmmtmb -----------------------------------------------------------------
library(glmmTMB)

system.time({
  death_model_bin_glmtmb = glmmTMB(formula = f,
                          data = medicare_abs_model_ready,
                          family = binomial)
})

# save(death_model_bin_glmtmb, file = "X://George_Surgeon_Projects/MOC_vs_Outcome/model/death_model_bin_glmtmb.rdata")



# bayesian -----------------------------------------------------------------






