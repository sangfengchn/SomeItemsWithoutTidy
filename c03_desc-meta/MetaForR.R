library(conflicted)
library(readxl)
library(tidyverse)
library(meta)
library(dmetar)

data <- read_xlsx('analysis-1.xlsx') %>% 
  as_tibble()
res.meta <- metacor(data$r, data$n, sm = "ZCOR", studlab = data$study, data = data)
res.meta

eggers.test(res.meta)

# pdf("analysis-1.pdf", width = 10, height = 4)
jpeg("analysis-4.jpg", width = 10, height = 4, units = 'in', res = 2000)
forest(res.meta)
dev.off()

# r <- c(0.35, 0.18, 0.51)
# 0.5 * log((1 + r) / (1 - r))
