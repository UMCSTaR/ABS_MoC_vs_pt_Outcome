# this script runs on the PC 
library(tidyverse)
library(glmmTMB)


# load data ---------------------------------------------------------------
# # all cohort
# load("x:\\/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na.rdata")
# 
# # core procedure cohort
# load("x:\\George_Surgeon_Projects/MOC_vs_Outcome/data/ECV_data/medicare_abs_model_ready_no_na.rdata") 

# removed multi proc, keep core procedure only
medicare_abs_model_ready_no_na = readRDS("x:\\/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na_remove_multi_proc.rds") 

ecv_proc = read_csv("data_public/ecv_proc_id.csv")

core_proc = ecv_proc %>%
  filter(`SCORE CORE/ADVANCED` == "CORE")

medicare_abs_model_ready_no_na = medicare_abs_model_ready_no_na %>% filter(e_proc_grp %in% core_proc$e_ecs_id)

# covariates -------------------------------------------------------------------
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
  # 'surgeon_yearly_load_std',
  "had_assist_surg",
  # hospital--
  'hospital_urban',
  'hospital_beds_gt_350',
  'hospital_rn2bed_ratio_std',
  'hospital_mcday2inptday_ratio_std'
)


all(covariates %in% names(medicare_abs_model_ready_no_na))


# GLME --------------------------------------------------------------------

f = formula(paste("death_30d ~ 1", paste(covariates, collapse = ' + '),
                  "(1 | procedure)", "(1 | npi)", "(1|id_hospital)",
                  sep = " + "))

death_model_bin = glmmTMB(formula = f,
                        data = medicare_abs_model_ready_no_na,
                        family = binomial)

broom.mixed::tidy(death_model_bin)
summary(death_model_bin)

# overall procedures
# save(death_model_bin, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/model/death_model_bin.rdata")
# save(death_model_bin, file = "X:\\George_Surgeon_Projects/MOC_vs_Outcome/model/death_model_bin.rdata")
# 
# # core procedure
# save(death_model_bin, file = "X:\\/George_Surgeon_Projects/MOC_vs_Outcome/model/core_proc/death_model_bin.rdata")

# remove multi proc
save(death_model_bin, file = "X:\\/George_Surgeon_Projects/MOC_vs_Outcome/model/death_model_core_bin_remove_multi_proc.rdata")

# complication
medicare_abs_model_ready_no_na = medicare_abs_model_ready_no_na %>% 
  mutate(severe_complication = ifelse(severe_complication_no_poa == "N/A (no var)", NA, severe_complication_no_poa),
         severe_complication = as.numeric(severe_complication))


f = formula(paste("severe_complication ~ 1", paste(covariates, collapse = ' + '),
                  "(1 | procedure)", "(1 | npi)", "(1|id_hospital)",
                  sep = " + "))

cmp_model_bin = glmmTMB(formula = f,
                          data = medicare_abs_model_ready_no_na,
                          family = binomial)

broom.mixed::tidy(cmp_model_bin)
summary(cmp_model_bin)


# save(cmp_model_bin, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/model/cmp_model_bin.rdata")
# save(cmp_model_bin, file = "X:\\George_Surgeon_Projects/MOC_vs_Outcome/model/cmp_model_bin.rdata")
# 
# # core procedure
# save(cmp_model_bin, file = "X:\\George_Surgeon_Projects/MOC_vs_Outcome/model/core_proc/cmp_model_bin.rdata")

# remove multi proc
save(cmp_model_bin, file = "X:\\/George_Surgeon_Projects/MOC_vs_Outcome/model/cmp_model_core_bin_remove_multi_proc.rdata")


# partial colectomy -------------------------------------------------------
load("x:\\George_Surgeon_Projects/MOC_vs_Outcome/data/ECV_data/medicare_abs_model_ready_no_na.rdata")
medicare_pc = medicare_abs_model_ready_no_na %>%
  filter(score_operation_procedure == "Colectomy - Partial")

unique(medicare_pc$cpt_cd)


f = formula(paste("death_30d ~ 1", paste(covariates, collapse = ' + '),
                   "(1 | npi)", "(1|id_hospital)",
                  sep = " + "))

death_model_bin = glmmTMB(formula = f,
                          data = medicare_pc,
                          family = binomial)

broom.mixed::tidy(death_model_bin)
summary(death_model_bin)


save(death_model_bin, file = "X:\\/George_Surgeon_Projects/MOC_vs_Outcome/model/partial_colectomy/death_model_bin.rdata")


# complication
medicare_pc = medicare_pc %>% 
  mutate(severe_complication = ifelse(severe_complication_no_poa == "N/A (no var)", NA, severe_complication_no_poa),
         severe_complication = as.numeric(severe_complication))


f = formula(paste("severe_complication ~ 1", paste(covariates, collapse = ' + '),
                   "(1 | npi)", "(1|id_hospital)",
                  sep = " + "))

cmp_model_bin = glmmTMB(formula = f,
                        data = medicare_pc,
                        family = binomial)

broom.mixed::tidy(cmp_model_bin)
summary(cmp_model_bin)

save(cmp_model_bin, file = "X:\\George_Surgeon_Projects/MOC_vs_Outcome/model/partial_colectomy/cmp_model_bin.rdata")




# re-certification 3 groups ------------------------------------------------
# all procedures
load("x:\\/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na.rdata") # pc location
# core procedure cohort
load("x:\\George_Surgeon_Projects/MOC_vs_Outcome/data/ECV_data/medicare_abs_model_ready_no_na.rdata") 

covariates = c(
  # choose one cert status--
  're_cert_status',
  # other--
  'flg_male',
  'age_at_admit_std',
  'AHRQ_score_std',
  'race_white',
  'ses',
  'emergent_admit',
  'year',
  # 'surgeon_yearly_load_std',
  "had_assist_surg",
  # hospital--
  'hospital_urban',
  'hospital_beds_gt_350',
  'hospital_rn2bed_ratio_std',
  'hospital_mcday2inptday_ratio_std'
)

# death
f = formula(paste("death_30d ~ 1", paste(covariates, collapse = ' + '),
                  "(1 | procedure)", "(1 | npi)", "(1|id_hospital)",
                  sep = " + "))

medicare_abs_model_ready_no_na = medicare_abs_model_ready_no_na %>%
  mutate(re_cert_status = factor(re_cert_status, levels = c("failed", "passed", "no record, failed"))) 

death_model_bin = glmmTMB(formula = f,
                          data = medicare_abs_model_ready_no_na,
                          family = binomial)

summary(death_model_bin)


save(death_model_bin, file = "X:\\George_Surgeon_Projects/MOC_vs_Outcome/model/death_model_bin_3_cert_cat.rdata")
# core procedure
save(death_model_bin, file = "X:\\George_Surgeon_Projects/MOC_vs_Outcome/model/core_proc/death_model_bin_3_cert_cat.rdata")

# complication
medicare_abs_model_ready_no_na = medicare_abs_model_ready_no_na %>% 
  mutate(severe_complication = ifelse(severe_complication_no_poa == "N/A (no var)", NA, severe_complication_no_poa),
         severe_complication = as.numeric(severe_complication))


f = formula(paste("severe_complication ~ 1", paste(covariates, collapse = ' + '),
                  "(1 | procedure)", "(1 | npi)", "(1|id_hospital)",
                  sep = " + "))

cmp_model_bin = glmmTMB(formula = f,
                        data = medicare_abs_model_ready_no_na,
                        family = binomial)

summary(cmp_model_bin)

save(cmp_model_bin, file = "X:\\George_Surgeon_Projects/MOC_vs_Outcome/model/cmp_model_bin_3_cert_cat.rdata")
#core procedure
save(cmp_model_bin, file = "X:\\George_Surgeon_Projects/MOC_vs_Outcome/model/core_proc/cmp_model_bin_3_cert_cat.rdata")
