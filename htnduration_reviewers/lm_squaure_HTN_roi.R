library(tidyverse)
library(readxl)
library(writexl)

# load data
data <- read_xlsx('AAL90_nodalLp.xlsx') %>%
  as_tibble()

rois <- tail(colnames(data), 90)

data <- data %>%
  mutate(GROUPNEW = if_else(JHTSCourseNew <= 5, '1', if_else(JHTSCourseNew <= 20, '2', '3')))

data %>%
  ggplot(aes(x = JHTSCourseNew, color = GROUPNEW)) +
  geom_histogram(fill="white", alpha=0.5, position="identity")

# cognition and roi need to statistic
HTN <- 'JHTSCourseNew'
#rois <- c('Globalefficiency',	'localefficiency',	'clustringcoeffiency',	'Lp',	'smallworld', 'normalizedclusteringcoefficient', 'normalizedLp',	'MeanStrength',	'Density')

res.tab <- data.frame() %>% as_tibble()

for (roi in rois) {
  # cog <- 'N1.N5'
  roi <- 'Postcentral_L'
  # tidy dat    
  tmp.data <- data %>%
    select(y=roi, x=HTN, GROUPNEW, Age, Gender, EDUTotal) %>%
    mutate(GROUP = as.factor(GROUPNEW), y = as.numeric(y), x2 = x^2) %>%
    drop_na() %>%
    filter(!is.infinite(y))
 
  # linear model and summary of model
  # whole
  # tmp.model <- lm(scale(y)~scale(Age)+Gender+scale(EDUTotal)+scale(x), data=tmp.data)
  tmp.model <- lm(scale(y)~scale(Age)+Gender+scale(EDUTotal)+scale(x)+scale(x2), data=tmp.data)
  
  tmp.model.res <- summary(tmp.model)
  res.tab <- res.tab %>%
    rbind(., c(roi, HTN, "Whole_x", tmp.model.res$coefficients[5, 1], tmp.model.res$coefficients[5, 3], tmp.model.res$coefficients[5, 4])) %>%
    rbind(., c(roi, HTN, "Whole_x2", tmp.model.res$coefficients[6, 1], tmp.model.res$coefficients[6, 3], tmp.model.res$coefficients[6, 4]))
  
  # Group 1
  tmp.data.group <- tmp.data %>% filter(GROUPNEW == '1')
  tmp.model <- lm(scale(y)~scale(Age)+Gender+scale(EDUTotal)+scale(x), data=tmp.data.group)
  tmp.model.res <- summary(tmp.model)
  res.tab <- res.tab %>%
    rbind(., c(roi, HTN, 'G1', tmp.model.res$coefficients[5, 1], tmp.model.res$coefficients[5, 3], tmp.model.res$coefficients[5, 4]))
  
  # Group 2
  tmp.data.group <- tmp.data %>% filter(GROUPNEW == '2')
  tmp.model <- lm(scale(y)~scale(Age)+Gender+scale(EDUTotal)+scale(x), data=tmp.data.group)
  tmp.model.res <- summary(tmp.model)
  res.tab <- res.tab %>%
    rbind(., c(roi, HTN, 'G2', tmp.model.res$coefficients[5, 1], tmp.model.res$coefficients[5, 3], tmp.model.res$coefficients[5, 4]))
  
  # Group 3
  tmp.data.group <- tmp.data %>% filter(GROUPNEW == '3')
  tmp.model <- lm(scale(y)~scale(Age)+Gender+scale(EDUTotal)+scale(x), data=tmp.data.group)
  tmp.model.res <- summary(tmp.model)
  res.tab <- res.tab %>%
    rbind(., c(roi, HTN, 'G3', tmp.model.res$coefficients[5, 1], tmp.model.res$coefficients[5, 3], tmp.model.res$coefficients[5, 4]))
}


# tidy result table
colnames(res.tab) <- c('Region', 'HTN', 'Group', 'beta', 't', 'p')
res.tab <- res.tab %>%
  as_tibble() %>%
  mutate(HTN = as.factor(HTN), Region = as.factor(Region), beta = as.numeric(beta), t = as.numeric(t), p = as.numeric(p))
# res.tab$p_adj <- p.adjust(res.tab$p, method = 'BH')
res.tab <- res.tab %>%
  group_by(Group) %>%
  mutate(p_adj = p.adjust(p, method = 'BH')) %>%
  ungroup()

# save results
write_xlsx(res.tab, 'Res_HTN_nodalLp_3groups.xlsx')