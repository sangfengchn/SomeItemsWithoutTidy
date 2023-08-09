library(conflicted)
library(tidyverse)
library(segmented)
library(readxl)

df <- read_excel('wmh_withlg.xlsx') %>% 
  as_tibble()
df

meas <- c('lg_volume', 'lg_wmh_tiv', 'wmh_tiv_100000_lg')
res.tab <- tibble()
for (mea in meas) {
  # mea <- meas[1]
  tmp.df <- df %>% 
    dplyr::select(Gender, Age, EDUTotal, x = all_of('JHTSCourseNew'), y = all_of(mea)) %>% 
    drop_na() %>% 
    mutate(x = as.numeric(x), Gender = as.factor(Gender)) %>% 
    dplyr::mutate(Age = scale(Age)[,1], EDUTotal = scale(EDUTotal)[,1], xz = scale(x)[,1], y = scale(y)[,1])
  
  # linear model, 0 break point
  # 0 break point
  tmp.model.linear <- lm(y ~ Age + EDUTotal + xz, data=tmp.df)
  tmp.res.model.linear <- summary(tmp.model.linear)
  
  # 1 break point
  tmp.model.1point <- segmented(tmp.model.linear, seg.Z = ~xz, npsi = 1)
  tmp.res.model.1point <- summary(tmp.model.1point)
  
  # 2 break point
  tmp.model.2point <- segmented::segmented(tmp.model.linear, seg.Z = ~xz, npsi = 2)
  tmp.res.model.2point <- summary(tmp.model.2point)
  
  res.tab <- res.tab %>% 
    bind_rows(., 
              list(
                Measure = mea,
                Point0_AdjRSquared=tmp.res.model.linear$adj.r.squared,
                Point0_P=pf(tmp.res.model.linear$fstatistic[1], tmp.res.model.linear$fstatistic[2], tmp.res.model.linear$fstatistic[3], lower.tail = FALSE),
                Point1_AdjRSquared=tmp.res.model.1point$adj.r.squared,
                Point1_P=pf(tmp.res.model.1point$fstatistic[1], tmp.res.model.1point$fstatistic[2], tmp.res.model.1point$fstatistic[3], lower.tail = FALSE),
                # Point1_Value=tmp.res.model.1point$psi[2],
                Point1_OrigValue=tmp.res.model.1point$psi[2] * sd(tmp.df$x) + mean(tmp.df$x),
                Point2_AdjRSquared=tmp.res.model.2point$adj.r.squared,
                Point2_P=pf(tmp.res.model.2point$fstatistic[1], tmp.res.model.2point$fstatistic[2], tmp.res.model.2point$fstatistic[3], lower.tail = FALSE),
                Point2_OrigValue1=tmp.res.model.2point$psi[1, 2] * sd(tmp.df$x) + mean(tmp.df$x),
                # Point2_Value2=tmp.res.model.2point$psi[2, 2],
                Point2_OrigValue2=tmp.res.model.2point$psi[2, 2] * sd(tmp.df$x) + mean(tmp.df$x)
              )
    )
}
res.tab
writexl::write_xlsx(res.tab, 'ResStat-SegmentedLinear_wmh.xlsx')
