library(tidyverse)
library(emmeans)

load("/Volumes/George_Surgeon_Projects/MOC_vs_Outcome/model/death_model_bin.rdata")

summary(death_model_bin)

probs_cert = emmeans(death_model_bin, "re_cert_bin", weights = "cell", type = "response") %>% 
  as.data.frame()
  
ggplot(data = probs_cert,
       aes(x = re_cert_bin,
           y = prob)) +
  geom_col(width = 0.5, fill = "gray60") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), limits = c(0,0.08)) +
  geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL), width = 0.2) +
  labs(x = "Recertification Status", y = "Adjusted Outcome Rates") +
  # geom_point(size = 5) +
  theme_classic() +
  theme(axis.title = element_text(size = 20),
        axis.text = element_text(size = 15))

ggsave("images/adjusted_outcome_rates.png")
