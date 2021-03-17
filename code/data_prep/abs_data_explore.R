library(tidyverse)

abs = read_csv("/Volumes/George_Surgeon_Projects/Surgeon Profile data/abs_npi_us_med_gs.csv")

selected_abs = abs %>% 
  select(npi, residency_yog, yot, Gcompyear, ReCeverPassed, PFfirstCE)

# Ever passed cert
# how to use NA?
# Candidate has passed at least one ReCert exam (1), or attempted but never passed (0)
selected_abs %>% 
  count(ReCeverPassed)

# not enough time to pass
young_surgeon_not_enough_time_to_pass = selected_abs %>% 
  filter(is.na(ReCeverPassed),
         (2019-yot) <17) %>% pull(npi)

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
medicare = data.table::fread("/Volumes/George_Surgeon_Projects/standardized_medicare_data_using_R/analysis_ready_data/analytic_selected_vars_5_procedure_upto2017.csv")

