library(dplyr)
library(data.table)
library(brms)
library(lme4)

source("code/functions/prep_medicare_data.R")


# read data ---------------------------------------------------------------
abs = fread("data/processed_abs/defined_gs1_yoe17_grandpa2000.csv")
medicare = fread("/Volumes/George_Surgeon_Projects/standardized_medicare_data_using_R/analysis_ready_data/analytic_selected_vars_5_procedure_upto2017.csv")

medicare_abs = inner_join(medicare %>% mutate(npi = as.integer(id_physician_npi)),
                          abs, by = "npi")

abs %>% 
  tidyext::cat_by(ReCeverPassed)

medicare_abs %>% 
  distinct(npi, ReCeverPassed) %>% 
  tidyext::cat_by(ReCeverPassed)


medicare_abs_model_ready = prep_data_for_model(medicare_abs) %>% 
  mutate(ce_cert_status = case_when(ReCeverPassed == 0 ~ "failed",
                                    ReCeverPassed == 1 ~ "passed",
                                    ReCeverPassed == "no record" ~ "no_record"),
         ce_cert_status = factor(ce_cert_status, levels = c("failed", "passed", "no_record")))

save(medicare_abs_model_ready, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready.rdata")

medicare_abs_model_ready %>% 
  select(ce_cert_status, flg_death_30d, flg_cmp_po_severe_not_poa, flg_readmit_30d,
         flg_util_reop,emergent_admit, flg_assistant_surgeon, flg_hosp_urban) %>% 
  mutate(flg_cmp_po_severe_not_poa = as.numeric(flg_cmp_po_severe_not_poa)) %>% 
  gtsummary::tbl_summary(by = ce_cert_status) 


# model -------------------------------------------------------------------
# sample data
set.seed(123)
sample_surg = sample_frac(abs, 0.1) %>% pull(npi)
medicare_abs = medicare_abs %>% filter(npi %in% sample_surg)



medicare_abs_model_ready %>% count(ce_cert_status)

covariates = c(
  'ce_cert_status',
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
                  "(1 | id_physician_npi)", "(1 | e_proc_grp_lbl)",
                  sep = " + "))

death_model = glmer(formula = f,
      data = medicare_abs_model_ready,
      family = binomial)

# bayes -------------------------------------------------------------------


f = formula(paste("flg_death_30d | trials(1) ~ 1", paste(covariates, collapse = ' + '), "(1 | id_physician_npi)",
        sep = " + "))

test = brm(data = medicare_abs_model_ready, family = binomial,
    f,
    prior = c(prior(normal(0, 10), class = Intercept),
              prior(normal(0, 10), class = b),
              prior(cauchy(0, 1), class = sd)),
    iter = 5000, warmup = 1000, chains = 4, cores = 4,  
    control = list(adapt_delta = 0.95),
    seed = 12)
