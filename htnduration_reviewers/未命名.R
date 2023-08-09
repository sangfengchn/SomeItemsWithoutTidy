library(conflicted)
library(tidyverse)
library(readxl)
library(writexl)


# TMTB - TMTA
df <- read_excel('behavioural_sample_label.xlsx') %>% 
  as_tibble() %>% 
  dplyr::select(BH, GROUP, Gender, Age, EDUTotal, TMT.A, TMT.B, `冠心病BS5`, JDiabetes, JHLP, JCVD) %>% 
  mutate(GROUP = as.factor(GROUP), Gender = as.factor(Gender), Age = as.numeric(Age), EDUTotal = as.numeric(EDUTotal), BS5 = as.factor(`冠心病BS5`), JDiabetes = as.factor(JDiabetes), JHLP = as.factor(JHLP), JCVD = as.factor(JCVD)) %>% 
  drop_na() %>% 
  dplyr::filter((TMT.A < 300) & (TMT.B < 300)) %>%
  # mutate(TMTAz = scale(TMT.A)[,1], TMTBz = scale(TMT.B)[,1]) %>% 
  # select(-c(TMT.A, TMT.B, `冠心病BS5`)) %>% 
  mutate(TMTBA = TMT.B - TMT.A) %>% 
  dplyr::filter(TMTBA > 0) %>% 
  mutate(TMTBA = log(TMTBA))
df

mod <- lm(scale(TMTBA)~scale(Age)+Gender+scale(EDUTotal)+BS5+JHLP+JDiabetes+JCVD+GROUP, data = df)
res <- summary(aov(mod))
res

mod <- lm(scale(TMTBA)~scale(Age)+Gender+scale(EDUTotal)+GROUP, data = df)
res <- summary(aov(mod))
res
# TMTBA在GROUP上无效应
