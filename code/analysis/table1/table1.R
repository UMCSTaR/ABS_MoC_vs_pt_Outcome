# create table1
library(tidyverse)
library(gtsummary)
library(flextable)
library(patchwork)

# load dt
medicare_abs_model_ready_no_na = readRDS("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na_remove_multi_proc.rds") 


covariates = c(
  # choose one cert status--
  're_cert_bin',
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

processed_data = medicare_abs_model_ready_no_na %>% 
  select(
    procedure, re_cert_bin,
    `Age (years)` = age_at_admit,     # pt
    `Sex` = sex,
    `Socioeconomic status` = ses,
    Race = race_white,
    `Comorbidity score` = AHRQ_score,
     # case
    `Emergency admission status` = emergent_admit,
    `Included assistant surgeon` = had_assist_surg,  # surg
    # `Years of practice at date of surgery` = val_yr_practice,
    `Hospital location`= hospital_urban,   # hosp
    `Hospital bedsize` = hospital_beds_gt_350,
    `Hospital nurse-to-bed ratio` = val_hosp_rn2bed_ratio,
    `Hospital medicaid/inpatient days ratio` = val_hosp_mcday2inptday_ratio,
    `30-day Deaths` = death_30d,         # outcomes
    `30-day Severe Complications` = severe_complication_no_poa
    # `30-day Readmissions` = readmission_30d,
    # `30-day Reoperations` = reoperation_30d,
  ) %>% 
  mutate(Race = ifelse(Race==1, "White", "Non-White"))

# case level ----------------------------------
processed_data %>% 
  select(-procedure) %>% 
  tbl_summary(by = re_cert_bin) %>% 
  add_p() %>% 
  add_overall() %>% 
  as_flex_table() 
  save_as_docx(path = "manuscripts/table1.docx")

medicare_abs_model_ready_no_na %>% 
  distinct(npi, re_cert_bin) %>% 
  count(re_cert_bin)
  

# procedures -------------------------------------
# top procedures
top_10_by_grp = medicare_abs_model_ready_no_na %>% 
  group_by(re_cert_bin) %>% 
  count(e_proc_grp_lbl) %>%
  rename(procedure = e_proc_grp_lbl) %>% 
  mutate(perc = round(n/sum(n), 2),
         percentage_in_pass_or_fail_grp = scales::percent(perc)) %>% 
  arrange(-n) %>% 
  slice(1:10)

top_10 = medicare_abs_model_ready_no_na %>% 
  count(e_proc_grp_lbl) %>% 
  rename(procedure = e_proc_grp_lbl) %>% 
  mutate(perc = round(n/sum(n), 2),
         percentage_in_pass_or_fail_grp = scales::percent(perc)) %>% 
  arrange(-n) %>% 
  slice(1:10)

write_csv(top_10_by_grp, "data/top_10_by_grp.csv")
write_csv(top_10, "data/top_10_all.csv")


# visual procedures ------
p_f = ggplot(
  top_10_by_grp %>% filter(re_cert_bin == "Failed"),
  aes(x = reorder(procedure, perc),
      y = perc)
) +
  geom_col() +
  scale_y_continuous(labels = scales::percent) +
  coord_flip() +
  labs(title = "Failed: Top 10 performed procedures",
       x = "") +
  theme_classic() 

p_p = ggplot(
  top_10_by_grp %>% filter(re_cert_bin == "Passed"),
  aes(x = reorder(procedure, perc),
      y = perc)
) +
  geom_col() +
  scale_y_continuous(labels = scales::percent) +
  coord_flip() +
  labs(title = "Passed: Top 10 performed procedures",
       x = "") +
  theme_classic() 


p_f / p_p 

ggsave("images/top10_performed_proc.png")
  

