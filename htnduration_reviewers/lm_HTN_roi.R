library(tidyverse)
library(readxl)
library(writexl)

# load data
data <- read_xlsx('Activation_WMnetwork_Combined.xlsx') %>%
  as_tibble()

# cognition and roi need to statistic
HTN <- c('MeanActivation')
rois <- c('FA_globalmetrics_smallworld','FA_globalmetrics_normalized clustering coefficient','FA_globalmetrics_Density','FA_nodaldegree_Frontal_Inf_Orb_L','FA_nodalefficiency_Frontal_Inf_Orb_L','FA_nodallocalefficiency_Frontal_Inf_Orb_L')
#HTN <- c('JHTSCourseNew')

res.tab <- data.frame() %>% as_tibble()

for (roi in rois) {
    # HTN <- 'MeanActivation'
    # roi <- 'MMSE'
    # tidy data
    tmp.data <- data %>%
      select(y=roi, x=HTN, GROUP, Age, Gender, EDUTotal) %>%
      mutate(GROUP = as.factor(GROUP), x = as.numeric(x), y = as.numeric(y)) %>%
      drop_na()
   
    # linear model and summary of model
    # whole
    tmp.model <- lm(scale(y)~scale(Age)+Gender+scale(EDUTotal)+scale(x), data=tmp.data)
    tmp.model.res <- summary(tmp.model)
    res.tab <- res.tab %>%
      rbind(., c(roi, HTN, tmp.model.res$coefficients[5, 1], tmp.model.res$coefficients[5, 3], tmp.model.res$coefficients[5, 4]))
}     
    # Group 1
    #tmp.data.group <- tmp.data %>% filter(GROUP == '1')
    #tmp.model <- lm(scale(y)~scale(Age)+Gender+scale(EDUTotal)+BS5+JDiabetes+JHLP+JCVD+scale(x), data=tmp.data.group)
    #tmp.model.res <- summary(tmp.model)
    #res.tab <- res.tab %>%
     # rbind(., c(cog, roi, 'G1', tmp.model.res$coefficients[9, 1], tmp.model.res$coefficients[9, 3], tmp.model.res$coefficients[9, 4]))
    
    # Group 2
    #tmp.data.group <- tmp.data %>% filter(GROUP == '2')
    #tmp.model <- lm(scale(y)~scale(Age)+Gender+scale(EDUTotal)+BS5+JDiabetes+JHLP+JCVD+scale(x), data=tmp.data.group)
    #tmp.model.res <- summary(tmp.model)
    #res.tab <- res.tab %>%
     # rbind(., c(cog, roi, 'G2', tmp.model.res$coefficients[9, 1], tmp.model.res$coefficients[9, 3], tmp.model.res$coefficients[9, 4]))
    
    # Group 3
    #tmp.data.group <- tmp.data %>% filter(GROUP == '3')
    #tmp.model <- lm(scale(y)~scale(Age)+Gender+scale(EDUTotal)+BS5+JDiabetes+JHLP+JCVD+scale(x), data=tmp.data.group)
    #tmp.model.res <- summary(tmp.model)
    #res.tab <- res.tab %>%
     # rbind(., c(cog, roi, 'G3', tmp.model.res$coefficients[9, 1], tmp.model.res$coefficients[9, 3], tmp.model.res$coefficients[9, 4]))

# tidy result table
colnames(res.tab) <- c('Region', 'HTN', 'beta', 't', 'p')
res.tab <- res.tab %>%
  as_tibble() %>%
  mutate(HTN = as.factor(HTN), Region = as.factor(Region), beta = as.numeric(beta), t = as.numeric(t), p = as.numeric(p))

res.tab$p_adj <- p.adjust(res.tab$p, method = 'BH')
# save results
write_xlsx(res.tab, 'Res_activation_WMnetwork.xlsx')