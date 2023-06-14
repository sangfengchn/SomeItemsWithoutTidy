library(tidyverse)
library(readxl)
library(writexl)

# load data
x <- 'JHTSCourseNew'
metrics <- "smallworld"

dat <- read_xlsx('FA_globalmetrics.xlsx') %>%
  as_tibble() %>%
  dplyr::select(y = all_of(metrics), x = all_of(x), Age, Gender, EDUTotal) %>%
  drop_na() %>% 
  dplyr::mutate(y=as.numeric(y), Age=as.numeric(Age), Gender=as.factor(Gender), EDUTotal=as.numeric(EDUTotal), x=as.numeric(x)) %>%
  dplyr::mutate(scale_y = scale(y)[,1], scale_Age = scale(Age)[,1], scale_EDUTotal = scale(EDUTotal)[,1], scale_x = scale(x)[,1])

# 0 break point
model.linear <- lm(scale_y~scale_Age+scale_EDUTotal+Gender+scale_x, data=dat)
res.model.linear <- summary(model.linear)
res.model.linear$adj.r.squared

# 1 break point
model.1point <- segmented::segmented(model.linear, seg.Z = ~scale_x, npsi = 1)
res.model.1point <- summary(model.1point)

# 显示adjust r2
res.model.1point$adj.r.squared
# 显示断点，这里显示的是标准化后的值
res.model.1point$psi[2]
# 显示断点，这里显示的是原始值
res.model.1point$psi[2] * sd(dat$x) + mean(dat$x)
# 画图
plot(model.1point)

# 显示斜率和置信区间
segmented::slope(model.1point)

# 2 break point
model.2point <- segmented::segmented(model.linear, seg.Z = ~x, npsi = 2)
res.model.2point <- summary(model.2point)
res.model.2point$adj.r.squared
