library(tidyverse)
library(sampling)

data <- readxl::read_xlsx("FA_globalmetrics.xlsx") %>%
  as_tibble() %>%
  select(x = JHTSCourseNew, y = Lp) %>%
  mutate(group = if_else(x <= 5, 1, if_else(x <= 10, 2, if_else(x <= 15, 3, if_else(x <= 20, 4, 5))))) %>%
  mutate(group = as.factor(group))
data

# write.csv(data, file = "FA_globalmetrics.csv", row.names = FALSE)
# 
# subData <- strata(data, stratanames = ("group"), rep(50, 5), method="srswor")
# subData$ID_unit
# subData <- data[subData$ID_unit,]
# write.csv(subData, "subData_FA_globalmetrics.csv", row.names = FALSE)
# 
# data %>%
#   ggplot(aes(x = x, y = y)) +
#   geom_point() +
#   geom_smooth()

width <- 5
step <- 1
# the number of sampling
nResample <- 100
# ratio of sampling
nSubResample <- 50
xRange <- range(data$x)
curMin <- xRange[1]
resSlidingWindow <- tibble(window_lower = numeric(), window_upper = numeric(), x_mean = numeric(), x_se = numeric(), y_mean = numeric(), y_se = numeric())
while (curMin < xRange[2]) {
  logging::loginfo(sprintf("Window %f-%f", curMin, curMin + width))
  tmpData <- data %>%
    filter((x >= curMin) & (x < curMin + width))
  # tmpRes <- tibble(sampling = numeric(), x_mean = numeric(), x_sd = numeric(), y_mean = numeric(), y_sd = numeric())
  # for (idxResample in 1:nResample) {
  #   tmpResData <- tmpData %>%
  #     sample_n(nSubResample, replace = TRUE)
  #   tmpRes <- tmpRes %>%
  #     add_row(sampling = idxResample, x_mean = mean(tmpResData$x), x_sd = sd(tmpResData$x), y_mean = mean(tmpResData$y), y_sd = sd(tmpResData$y))
  # }
  # resSlidingWindow <- resSlidingWindow %>%
  #   add_row(window_lower = curMin, window_upper = curMin + width, x_mean = mean(tmpRes$x_mean), x_se = sd(tmpRes$x_mean), y_mean = mean(tmpRes$y_mean), y_se = sd(tmpRes$y_mean))
  resSlidingWindow <- resSlidingWindow %>%
    add_row(window_lower = curMin, window_upper = curMin + width, x_mean = mean(tmpData$x), x_se = sd(tmpData$x) / nrow(tmpData), y_mean = mean(tmpData$y), y_se = sd(tmpData$y) / nrow(tmpData))
  if ((curMin + width) > xRange[2]) {
    break
  }
  curMin <- curMin + step
}

resSlidingWindow <- resSlidingWindow %>%
  mutate(y_lower = y_mean - y_se, y_upper = y_mean + y_se)

resSlidingWindow %>%
  ggplot(aes(x = x_mean, y = y_mean)) +
  geom_line() +
  geom_point()

