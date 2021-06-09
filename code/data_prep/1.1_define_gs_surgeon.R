# explore number of type of procedures done by surgeons

library(dplyr)
library(purrr)
# read abs with medicare data from 1_define_cohort results
load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr.rdata")


# descriptive ------------------------------------------------------------

# add yearly n
abs_medicare_10_20yr = abs_medicare_10_20yr %>% 
  group_by(npi, facility_clm_yr) %>%
  mutate(surgeon_yearly_load = n()) %>% 
  ungroup()

# mean and median of yearly n
abs_medicare_10_20yr %>% 
  distinct(npi, facility_clm_yr, surgeon_yearly_load) %>% 
  summarise(mean = mean(surgeon_yearly_load),
            med = median(surgeon_yearly_load))

# mean   med
# <dbl> <int>
# 16.4    11

# exclude at least 20 cases
npi_lt_20_per_yr = abs_medicare_10_20yr %>% 
  filter(surgeon_yearly_load<20) %>% 
  distinct(npi) %>% pull

length(npi_lt_20_per_yr) #10388

n_distinct(abs_medicare_10_20yr$npi) # 11444

npi_gt_20_per_yr = abs_medicare_10_20yr %>% 
  filter(!npi %in% npi_lt_20_per_yr) %>% 
  distinct(npi) %>% 
  pull(npi)


abs_medicare_10_20yr %>%
  filter(npi %in% npi_gt_20_per_yr) %>% 
  distinct(npi, Recert_status) %>% 
  count(Recert_status)



# not medicare GS surgeons ------------------------------------------------
abs_medicare_10_20yr %>% 
  distinct(npi, gs_specialty_cms) %>% 
  count(gs_specialty_cms)

abs_medicare_10_20yr %>% 
  distinct(npi, gs_specialty_cms, Recert_status) %>% 
  filter(gs_specialty_cms == FALSE) %>% 
  count(Recert_status)



# use types of procedures to exclude ---------------------------------------
excluded_cms_npi_w_n_type = abs_medicare_10_20yr %>% 
  filter(gs_specialty_cms == FALSE) %>% 
  group_by(npi) %>% 
  mutate(n_type = length(unique(e_proc_grp_lbl))) %>% 
  select(npi, n_type, Recert_status) %>% 
  distinct() %>% 
  ungroup()


excluded_cms_npi_w_n_type %>% 
  group_by(Recert_status) %>% 
  summarise(n_surgon = n(),
            mean_n_type_proc = mean(n_type),
            median = median(n_type))

cutoff_n = c(2, 5,10,15)

map_df(cutoff_n,
       ~excluded_cms_npi_w_n_type %>% 
         filter(n_type >= .x) %>% 
         count(Recert_status, name = "n_surg") %>% 
         mutate(cutoff_n_type = .x, n_tot_surg = sum(n_surg)) %>% 
         select(cutoff_n_type, everything()))


