# create table1
library(tidyverse)
library(gtsummary)
library(flextable)
library(patchwork)

# load dt
load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/data/medicare_abs_model_ready_no_na.rdata")

covariates = c(
  # choose one cert status--
  # 're_cert_status',
  're_cert_bin',
  # other--
  'flg_male',
  'age_at_admit',
  'AHRQ_score',
  'race_white',
  'ses',
  'emergent_admit',
  'year',
  'surgeon_yearly_load',
  'years_after_initial_certification',
  "had_assist_surg",
  # hospital--
  'hospital_icu',
  'hospital_urban',
  'hospital_beds_gt_350',
  'hospital_icu',
  'hospital_rn2bed_ratio',
  'hospital_mcday2inptday_ratio'
)

# case level ----------------------------------
medicare_abs_model_ready_no_na %>% 
  select(!!covariates, -year) %>% 
  tbl_summary(by = re_cert_bin) %>% 
  add_p() %>% 
  as_flex_table() %>% 
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
  

