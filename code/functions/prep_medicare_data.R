#' Prepare data for analysis with a statistical model
#'

prep_data_for_model <- function(
  data
) {
  
  # package requirements ----------------------------------------------------
  if(!requireNamespace('tidyverse'))
    stop('tidyverse required.')
  
  
  # cohort selection -------------------------------------------------------
  
  # if only want physicians with minimum number of obs
  # data = data %>% 
  #   group_by(npi, facility_clm_yr) %>% 
  #   mutate(surgeon_yearly_load = n()) %>% 
  #   ungroup()
  
  
  # redefine categorical ------------------------------------------------------
  # race
  # emergency status
  # facility claim year
  # add surgeon yearly volume---
  
  data = data %>% 
    mutate(
      # race; wbho = 1234
      race_white = ifelse(e_race_wbho == 1, 1, 0),
      # e_admit_type 1- emergency 2 urgent 3 elective 4 other 9 UK/missing
      # Given that 'other' is indistinguishable from unknown, which was lumped with
      # missing, other will be given NA as well.  It has very few values anyway.  This was checked for appropriate NA
      emergent_admit = case_when(e_admit_type %in% c("1_Emergency","2_Urgent") ~ 1, 
                                 e_admit_type == "3_Elective" ~ 0,
                                 TRUE ~ NA_real_),
      # ses divide to 5 groups
      ses_binary = case_when(e_ses_5grp > 3 ~ "high_ses",
                                         e_ses_5grp <=3 ~ "low_ses",
                                         TRUE ~ NA_character_),
      # hospital bed
      hosp_beds_2grp = ifelse(e_hosp_beds_4grp == 1 | e_hosp_beds_4grp == 2, 
                              "≤350", 
                              ">350"),
      # facility claim year center
      year = facility_clm_yr - 2007) %>%
    
      # add surgeon yearly volume
    group_by(npi, facility_clm_yr) %>%
    mutate(surgeon_yearly_load = n()) %>% 
    ungroup()
  
  # standardize numeric -----------------------------------------------------
  std_var = data %>% 
    select(surgeon_yearly_load, age_at_admit, AHRQ_score, val_hosp_rn2bed_ratio, val_hosp_rn2inptday_ratio, val_hosp_rn2inptday_ratio, val_hosp_mcday2inptday_ratio) %>% 
    mutate_at(vars(c("surgeon_yearly_load", "age_at_admit", "AHRQ_score", "val_hosp_rn2bed_ratio", "val_hosp_rn2inptday_ratio", "val_hosp_rn2inptday_ratio", "val_hosp_mcday2inptday_ratio")), function(x) scale(x)[,1]) %>% 
    rename_at(vars(c("surgeon_yearly_load", "age_at_admit", "AHRQ_score", "val_hosp_rn2bed_ratio", "val_hosp_rn2inptday_ratio", "val_hosp_rn2inptday_ratio", "val_hosp_mcday2inptday_ratio")), function(x) paste0(x, '_std'))
  
  data = cbind(data, std_var)
  
  # convert logical to integers ---------------------------------------------
  data = mutate_if(data, is.logical, as.integer)
}
