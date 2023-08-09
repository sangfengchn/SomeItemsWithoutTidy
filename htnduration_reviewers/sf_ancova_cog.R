library(tidyverse)
library(readxl)
library(writexl)
library(emmeans)

data <- read_xlsx('all_beh_641.xlsx') %>%
  as_tibble()
cognitions <- c('MMSE', 'N5','N1N5', 'ROdelay', 'TMTB', 'TMTA', 'StroopCTime', 'VFT', 'BNT', 'SDMT')

res.tab <- data.frame() %>% as_tibble()
for (cognition in cognitions) {
  # cognition <- 'MMSE'
  tmp.data <- data %>%
    dplyr::select(GROUP, Age, Gender, EDUTotal, y = all_of(cognition)) %>%
    mutate(GROUP=as.factor(GROUP), Age=as.numeric(Age), Gender=as.factor(Gender), EDUTotal=as.numeric(EDUTotal), y=as.numeric(y)) %>%
    drop_na()
  
  # anova
  tmp.model <- lm(y~Age+Gender+EDUTotal+GROUP, data=tmp.data)
  tmp.model.res <- summary(aov(tmp.model))
  
  # Post-hoc: LSD without adjustment
  tmp.posthoc <- emmeans(tmp.model, specs = pairwise ~ GROUP, adjust = 'none')
  tmp.posthoc.res <- tmp.posthoc$contrasts %>% as_tibble() %>% arrange(contrast)
  
  # mean & sd of each group
  tmp.data <- tmp.data %>%
    group_by(GROUP) %>%
    summarise(Mean=mean(y), Sd=sd(y)) %>%
    ungroup() %>%
    arrange(GROUP)
  
  res.tab <- rbind(res.tab, c(cognition, 
               tmp.model.res[[1]]$`F value`[4], 
               tmp.model.res[[1]]$`Pr(>F)`[4],
               tmp.data$Mean,
               tmp.data$Sd,
               tmp.posthoc.res$estimate,
               tmp.posthoc.res$t.ratio,
               tmp.posthoc.res$p.value
               ))
}
colnames(res.tab) <- c('COG', 'AOV_F_GROUP', 'AOV_P_GROUP', 'Mean_G1', 'Mean_G2', 'Mean_G3', 'SD_G1', 'SD_G2', 'SD_G3', 'Posthoc_G1G2_difference', 'Posthoc_G1G3_difference', 'Posthoc_G2G3_difference', 'Posthoc_G1G2_t_ration', 'Posthoc_G1G3_t_ration', 'Posthoc_G2G3_t_ration', 'Posthoc_G1G2_p_value', 'Posthoc_G1G3_p_value', 'Posthoc_G2G3_p_value')

res.tab <- as_tibble(res.tab)
res.tab$AOV_P_GROUP_Adj <- p.adjust(res.tab$AOV_P_GROUP, method = 'BH')
res.tab <- res.tab %>% relocate(COG, AOV_F_GROUP, AOV_P_GROUP, AOV_P_GROUP_Adj)

write_xlsx(res.tab, 'R_results_group_cognition.xlsx')
