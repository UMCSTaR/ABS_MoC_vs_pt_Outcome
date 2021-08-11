# Define cohort by combining 4 criteria 
# This cohort definition is defined after the comparison of the 4 definitions doc at
# [overlap_cohort_definitions](other_docs/lab_notebooks/Overlap_cohort_definitions.pdf)

# summary
# Step1: Using ABS and fellowship council data to exclude fellowship trained surgeons.
# 
# Step2: Using medicare general surgery code to flag GS surgeons who can't be defined in step1. 
# 
# step3: using practice patterns to flag GS that can't be defined in step1 or 2. 
# We can use the median number of types cases performed by the defined GS surgeons 
# from step1 and 2 to define the threshold of number of types cases for GS surgeons.

library(tidyverse)

# filtered ABS and fellowship council ---------------------------------------------------------------------
# Filtered out abs and fellowship council specialty training surgeons
# dataset creation can be found at code/data_prep/create_medicare_10_20yr_dt.R
load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr.rdata")

## Keep medicare GS specialty ----
abs_medicare_10_20yr_medicare = abs_medicare_10_20yr %>% 
  filter(gs_specialty_cms)

abs_medicare_10_20yr %>% 
  distinct(npi, gs_specialty_cms) %>% 
  count(gs_specialty_cms)

# case
abs_medicare_10_20yr %>% 
  count(gs_specialty_cms)

## practice patterns ----
# number of types of procedures
# 1. using medicare specialty
npi_procedure_type = abs_medicare_10_20yr_medicare %>%
  group_by(npi) %>%
  mutate(n_type = length(unique(e_proc_grp_lbl))) %>%
  select(npi, n_type, Recert_status) %>%
  distinct() %>%
  ungroup()

npi_procedure_type_summary = npi_procedure_type %>% 
  summarise(n_surgeon = n(),
            mean_n_type_proc = mean(n_type),
            median = median(n_type))

quantile(npi_procedure_type$n_type)
npi_procedure_type_summary
# n_surgeon mean_n_type_proc median
# <int>            <dbl>  <dbl>
# 6636             29.8     28

# not qualified medicare general surgery surgeons
# and n_type; number of types of procedures
npi_not_medicare_gs = abs_medicare_10_20yr %>% 
  filter(!gs_specialty_cms) %>% 
  group_by(npi) %>%
  mutate(n_type = length(unique(e_proc_grp_lbl))) %>%
  select(npi, n_type, Recert_status) %>%
  distinct() %>%
  ungroup()
  
# filter surgeon have >median
npi_qualified_pp = npi_not_medicare_gs %>% 
  filter(n_type>npi_procedure_type_summary$median)

nrow(npi_not_medicare_gs) - nrow(npi_qualified_pp)


## Union medicare gs and pp qualified  --------
abs_medicare_union = abs_medicare_10_20yr %>% 
  filter(gs_specialty_cms |
           npi %in% npi_qualified_pp$npi)

n_distinct(abs_medicare_union$npi) #7644
nrow(abs_medicare_union) # 892045


abs_medicare_union %>% 
  distinct(npi, Recert_status) %>% 
  count(Recert_status)

save(abs_medicare_union, file = "/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr_union_4_def.rdata")
