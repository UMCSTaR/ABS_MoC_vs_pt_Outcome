# QA surgeons using ABS fellowship vs. medicare splty definition

library(tidyverse)

load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr_medicare_splty.rdata")
abs_medicare_10_20_yr_splty = abs_medicare_10_20yr
rm(abs_medicare_10_20_yr)
load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/abs_medicare_10_20yr.rdata")

medicare_gs = data.table::fread("/Volumes/George_Surgeon_Projects/Other/NPPES_Data_Dissemination_January_2020/npi_md_spty_gs.csv")

# difference between using medicare specialty code vs. not
medicare_splty_gs_npi = abs_medicare_10_20yr %>% 
  filter(!npi %in% abs_medicare_10_20_yr_splty$npi) %>% 
  distinct(npi) %>% 
  pull(npi)

# percentage NPPES general surgery surgeons among excluded surgeons based on medicare specialty code
sum(medicare_splty_gs_npi %in% medicare_gs$NPI)/length(medicare_splty_gs_npi) #0.342111

set.seed(123)
sample(filtered_gs_npi,5)
# [1] "1215967682" GS
# "1063498855" Vascular surgeon
# "1457457764" GS
# "1396731485" GS
# "1750321857" GS
set.seed(12)
sample(filtered_gs_npi,5)
# "1144257882" Colon & Rectal Surgery
# "1780687996" GS
# "1588661664" surgical oncology surgery 
# "1912976218" GS 
# "1275596629" Transplant Surgery



