library(tidyverse)
library(gtsummary)


# ABS data prep -----------------------------------------------------------
abs = read_csv("/Volumes/George_Surgeon_Projects/Surgeon Profile data/abs_npi_us_med_gs.csv",
               col_types = cols(.default = "c"))

selected_abs = abs %>% 
  mutate(residency_graduation_year = ifelse(!is.na(residency_yog),
                                            residency_yog, yot)) %>% 
  select(npi, sex, residency_graduation_year, Gcompyear, ReCeverPassed,
         PFfirstCE, QEeverPassed, nAttemptsReCert, PFfirstR) %>% 
  mutate(npi = as.character(npi))

# Ever passed cert
# how to use NA?
# Candidate has passed at least one ReCert exam (1), or attempted but never passed (0)
selected_abs %>% 
  count(ReCeverPassed)

passed_recert_surgons = selected_abs %>% 
  filter(ReCeverPassed) %>% 
  pull(npi)

failed_recert_surgons = selected_abs %>% 
  filter(!ReCeverPassed) %>% 
  pull(npi)

# not enough time to pass
young_surgeon_not_enough_time_to_pass = selected_abs %>% 
  filter(is.na(ReCeverPassed),
         (2019-residency_graduation_year) <17) %>% pull(npi)

# passed CE exam
passed_CE_surgeons = selected_abs %>% 
  filter(!is.na(Gcompyear), Gcompyear!=0 | PFfirstCE== "P") %>% pull(npi)

# had 17 years, passed CE but never recertified
never_attempted_recert = selected_abs %>%
  filter(
    is.na(ReCeverPassed), # No recertified recort
    !npi %in% young_surgeon_not_enough_time_to_pass, # had 17 years after graduation
    npi %in% passed_CE_surgeons # Passed CE exam
  ) %>% pull(npi)



# link with medicare ------------------------------------------------------
# total: 20747 surgeons
passed_recert_surgons
failed_recert_surgons
never_attempted_recert

library(data.table)
medicare = fread("/Volumes/George_Surgeon_Projects/standardized_medicare_data_using_R/analysis_ready_data/analytic_selected_vars_5_procedure_upto2017.csv")

medicare_abs = medicare[id_physician_npi %in% c(passed_recert_surgons,
                                 failed_recert_surgons,
                                 never_attempted_recert)]


medicare_abs = medicare_abs %>%
  mutate(
    recert_status = case_when(
      id_physician_npi %in% passed_recert_surgons ~ "passed_recert",
      id_physician_npi %in% failed_recert_surgons ~ "failed_recert",
      id_physician_npi %in% never_attempted_recert ~ "never_attempted"
    )
  )

# descriptive for recert status and outcomes
summary_recert_medicare = medicare_abs %>%
  group_by(recert_status) %>%
  summarise(
    n_case = n(),
    n_surg = length(unique(id_physician_npi)),
    death  = mean(flg_death_30d),
    complication  = mean(flg_cmp_po_severe),
    readmission  = mean(flg_readmit_30d),
    reop  = mean(flg_util_reop)
  ) %>% 
  mutate_if(is.numeric, ~round(., digits = 2))

summary_recert_medicare


# medicare ABS ------------------------------------------------------------
# graduation year and certification
medicare_abs %>%
  distinct(id_physician_npi, dt_gs_comp, recert_status) %>%
  mutate(graduation_year = lubridate::year(dt_gs_comp)) %>% 
  ggplot() +
  facet_grid(~recert_status) +
  geom_line(aes(x = graduation_year), stat = "count") +
  theme_classic()




# table1
medicare_abs_score =
  inner_join(medicare_abs, selected_abs, by = c("id_physician_npi" = "npi"))

medicare_abs_score %>% count(recert_status, ReCeverPassed)

# table1 surgeon level
medicare_abs_score %>% 
  distinct(id_physician_npi, recert_status, nAttemptsReCert, PFfirstCE,
           sex) %>% 
  select(recert_status, nAttemptsReCert, PFfirstCE,
         sex) %>% 
  mutate(nAttemptsReCert = as.factor(nAttemptsReCert)) %>% 
  tbl_summary(by = recert_status) %>% 
  as_gt() %>% 
  gt::gtsave("data/tab1_surgeon.pdf")
  
#table1 case level

medicare_abs_score %>% 
  select(recert_status, flg_death_30d, flg_cmp_po_severe_not_poa, flg_readmit_30d,
         flg_util_reop,e_admit_type, flg_assistant_surgeon, flg_hosp_urban, AHRQ_score) %>% 
  mutate(flg_cmp_po_severe_not_poa = as.numeric(flg_cmp_po_severe_not_poa)) %>% 
  tbl_summary(by = recert_status) %>% 
  as_gt() %>% 
  gt::gtsave("data/tab1_cases.pdf")





