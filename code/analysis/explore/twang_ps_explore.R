library(twang)
library(tidyverse)

# core procedure cohort
load("x:\\George_Surgeon_Projects/MOC_vs_Outcome/data/ECV_data/medicare_abs_model_ready_no_na.rdata") 

medicare_abs_model_ready_no_na = medicare_abs_model_ready_no_na %>% 
  mutate(ses = as.factor(ses),
         hospital_beds_gt_350 = as.factor(hospital_beds_gt_350),
         re_cert_pass = ifelse(re_cert_bin == "Passed", 1, 0)) 

covariates = c(
  # choose one cert status--
  # 're_cert_bin',
  # other--
  'flg_male',
  'age_at_admit_std',
  'AHRQ_score_std',
  'race_white',
  'ses',
  'emergent_admit',
  'year',
  "had_assist_surg",
  # hospital--
  'hospital_urban',
  'hospital_beds_gt_350',
  'hospital_rn2bed_ratio_std',
  'hospital_mcday2inptday_ratio_std'
)

# GLM --------------------------------------------------------------------

f = paste("re_cert_pass ~ ", paste(covariates, collapse = ' + '))

ps.lalonde.gbm = ps(re_cert_pass ~  flg_male + age_at_admit_std + AHRQ_score_std + race_white + ses + emergent_admit + year + had_assist_surg + hospital_urban + hospital_beds_gt_350 + hospital_rn2bed_ratio_std + hospital_mcday2inptday_ratio_std,
                    data = medicare_abs_model_ready_no_na,
                    n.trees=5000,
                    interaction.depth=2,
                    shrinkage=0.01,
                    estimand = "ATT",
                    stop.method=c("es.mean","ks.max"),
                    n.minobsinnode = 10,
                    n.keep = 1,
                    n.grid = 25,
                    ks.exact = NULL,
                    verbose=FALSE)

plot(ps.lalonde.gbm)
plot(ps.lalonde.gbm, plots=2)

ggsave("images/ps_twang.png")