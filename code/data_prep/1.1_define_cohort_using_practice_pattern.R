# option3: define cohort by practice patterns

# Exclude non-GS surgeons by practice pattern, 
# i.e. surgeon who don't act/perform like GS. using n types of procedures as threshold. 

library(tidyverse)

abs = data.table::fread("/Volumes/George_Surgeon_Projects/Surgeon Profile data/abs_with_npi.csv", colClasses = c('npi'='character'))

# add vars
selected_abs = abs %>% 
  mutate(npi = as.character(npi),
         # initial certification
         pass_CE = ifelse(PFfirstCE == "p" | !is.na(Gcertyear), "passed", "failed")
  ) %>% 
  select(npi, sex, gs_residency_yog, Gcertyear, Gcompyear, ReCeverPassed,
         pass_CE, nAttemptsReCert, PFfirstR, us_medschool, gs_specialty_cms, fellowship) 

# filter passed initial certification -----------------------------------------------------------
abs_cert = selected_abs %>% 
  filter(pass_CE == "passed")


# cutoff year 1976-2007 ---------------------------------------------------

abs_2017 = abs_cert %>% 
  mutate(cutoff_2007 = ifelse(Gcertyear+10>=2017, "exlcude", "include")) %>% 
  filter(cutoff_2007 == "include" | is.na(cutoff_2007))

# 1976 as the first year; So we we only include surgeons who pass their initial certification after 1976
abs_76_17 = abs_2017 %>%  
  filter(Gcertyear>1975)

abs_w_recert = abs_76_17 %>%
  mutate(
    npi = as.character(npi),
    Recert_status = case_when(
      ReCeverPassed == 0 ~ "failed",
      ReCeverPassed == 1 ~ "passed",
      is.na(ReCeverPassed) ~ "NA_failed"
    )
  ) 


# medicare data -----------------------------------------------------------
medicare = data.table::fread("/Volumes/George_Surgeon_Projects/standardized_medicare_data_using_R/analysis_ready_data/ecs_primary_surgeon_medicare2018.csv")


# link abs with medicare -----------------
abs_medicare = abs_w_recert %>%
  inner_join(medicare, by = c("npi" = "id_physician_npi"))

n_distinct(abs_medicare$npi) #20615


# 10-20 yes after initial certification -----------------------------------

abs_medicare_10_20yr = abs_medicare %>%
  filter(facility_clm_yr - Gcertyear>10,
         facility_clm_yr - Gcertyear<=20)

n_distinct(abs_medicare_10_20yr$npi) #14456


# types of procedures -----------------------------------------------------
npi_procedure_type = abs_medicare_10_20yr %>%
  group_by(npi) %>%
  mutate(n_type = length(unique(e_proc_grp_lbl))) %>%
  select(npi, n_type, Recert_status) %>%
  distinct() %>%
  ungroup()

npi_procedure_type %>% 
  group_by(Recert_status) %>% 
  summarise(n_surgon = n(),
            mean_n_type_proc = mean(n_type),
            median = median(n_type))

npi_procedure_type %>% 
  summarise(n_surgon = n(),
            mean_n_type_proc = mean(n_type),
            median = median(n_type))

# n_surgon mean_n_type_proc median
# <int>            <dbl>  <dbl>
#   1    14456             23.3     21


# at least performed n types of procedures --------------------------------
n_lst = 21

npi_list_procedure_type = npi_procedure_type %>% 
  filter(n_type>=n_lst) %>% 
  pull(npi)


abs_medicare_10_20yr_n_type = abs_medicare_10_20yr %>% 
  filter(npi %in% npi_list_procedure_type)

nrow(abs_medicare_10_20yr_n_type)
n_distinct(abs_medicare_10_20yr_n_type$npi)


abs_medicare_10_20yr_n_type %>%  
  group_by(Recert_status) %>% 
  distinct(npi, Recert_status) %>% 
  summarise(
  n_surgon = n()
)

save(abs_medicare_10_20yr_n_type, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr_21_types_procs.rdata")

