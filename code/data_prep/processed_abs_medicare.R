# combine processed ABS data (redefined NA recertification) to medicare data

library(dplyr)
library(data.table)
library(brms)
library(lme4)

source("code/functions/prep_medicare_data.R")


# read data ---------------------------------------------------------------
# abs data was from abs_data_explore.rmd results
# redefined NA as "no record, failed"
# abs = fread("data/processed_abs/defined_gs1_yoe17_grandpa2000.csv")
abs = fread("data/processed_abs/defined_gs2_grandpa1976.csv")
medicare = fread("/Volumes/George_Surgeon_Projects/standardized_medicare_data_using_R/analysis_ready_data/analytic_selected_vars_5_procedure_upto2017.csv")

# abs %>% tidyext::cat_by(ReCeverPassed)

medicare_abs = inner_join(medicare %>% mutate(npi = as.integer(id_physician_npi)),
                          abs, by = "npi")

# how many surgeons from abs were matched with Medicare cases
medicare_abs %>% 
  distinct(npi, ReCeverPassed) %>% 
  tidyext::cat_by(ReCeverPassed)


medicare_abs_model_ready = prep_data_for_model(medicare_abs) %>% 
  mutate(re_cert_status = case_when(ReCeverPassed == 0 ~ "failed",
                                    ReCeverPassed == 1 ~ "passed",
                                    ReCeverPassed == "no record, failed" ~ "no record, failed"),
         re_cert_status = factor(re_cert_status, levels = c("failed", "passed", "no record, failed")),
         re_cert_bin = ifelse(re_cert_status == "passed", "passed", "no_pass_or_NA"),
         
         n_attempts_recert = ifelse(nAttemptsReCert >=3, "≥3", nAttemptsReCert),
         n_attempts_recert = factor(n_attempts_recert, levels = c("1", "2", "≥3")))

save(medicare_abs_model_ready, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready.rdata")

# medicare_abs_model_ready %>% 
#   select(re_cert_status, flg_death_30d, flg_cmp_po_severe_not_poa, flg_readmit_30d,
#          flg_util_reop,emergent_admit, flg_assistant_surgeon, flg_hosp_urban) %>% 
#   mutate(flg_cmp_po_severe_not_poa = as.numeric(flg_cmp_po_severe_not_poa)) %>% 
#   gtsummary::tbl_summary(by = re_cert_status) 


# model -------------------------------------------------------------------
# sample data
# set.seed(123)
# sample_surg = sample_frac(abs, 0.1) %>% pull(npi)
# medicare_abs = medicare_abs %>% filter(npi %in% sample_surg)

medicare_abs_model_ready %>% count(re_cert_status)

load("X:\\George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_17.rdata")
medicare_abs_model_ready = medicare_abs_model_ready_17

medicare_abs_model_ready %>% count(re_cert_status)

covariates = c(
  # cert status
  # choose one
  # 're_cert_status',
  're_cert_bin',
  # other
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
  death_model_bin_17 = glmer(formula = f,
      data = medicare_abs_model_ready,
      family = binomial)
})

# bayes -------------------------------------------------------------------


f = formula(paste("flg_death_30d | trials(1) ~ 1", paste(covariates, collapse = ' + '),
                  "(1 | id_physician_npi)", "(1 | e_proc_grp_lbl)",
        sep = " + "))

death_brms_model = brm(data = medicare_abs_model_ready, family = binomial,
    f,
    prior = c(prior(normal(0, 10), class = Intercept),
              prior(normal(0, 10), class = b),
              prior(cauchy(0, 1), class = sd)),
    iter = 5000, warmup = 1000, chains = 4, cores = 10,  
    control = list(adapt_delta = 0.95),
    seed = 12)
