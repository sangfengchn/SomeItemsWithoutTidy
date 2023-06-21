# dat <- matrix(c(1476, 1504, 623, 435), nrow = 2)
# colnames(dat) <- c("GDS+", "GDS-")
# rownames(dat) <- c("HTN+", "HTN-")
# dat
# chisq.test(dat)
# 
# mosaicplot(
#   dat,
#   main = "GDS & HTN",
#   ylab = "GDS",
#   xlab = "HTN",
#   las = 0,
#   shade = TRUE)

library(tidyverse)
library(ggsci)
library(ggpubr)
library(showtext)

dat <- tibble(HTN = c("HTN+", "HTN+", "HTN-", "HTN-"), GDS = c("GDS-", "GDS+", "GDS-", "GDS+"), Count = c(1476, 623, 1504, 435)) %>%
  mutate(GDS = if_else(GDS == "GDS+", "Yes", "No"), HTN = if_else(HTN == "HTN+", "Yes", "No")) %>%
  group_by(GDS) %>% 
  reframe(HTN, GDS, Count, a = sum(Count)) %>%
  ungroup() %>%
  mutate(Rate = Count / a) %>% 
  mutate(RateStr = sprintf("%.3f", Rate)) %>%
  group_by(GDS) %>%
  reframe(HTN, GDS, Count, Rate, RateStr, ResStrLocation = cumsum(Rate))
dat

font_add("Times New Roman", file.path("fonts", "Times New Roman.ttf"))
showtext_auto()
dat %>%
  ggplot(aes(x = GDS, y = Rate, fill = HTN)) +
  geom_bar(stat = "identity") +
  # geom_text(aes(y = ResStrLocation, label = RateStr), vjust = 2, color = "white", size = 5, family = "Times New Roman") +
  labs(y = "Prevalence", x = "LDS", fill = "HTN") +
  theme_classic2(base_size = 30) +
  theme(
    axis.line = element_line(lineend = "square", color = "black", linewidth = 1.5),
    axis.ticks = element_line(color = "black", linewidth = 1.5),
    axis.text = element_text(color = "black", family = "Times New Roman"),
    axis.title = element_text(color = "black", family = "Times New Roman"),
    legend.text = element_text(color = "black", family = "Times New Roman"),
    legend.title = element_text(color = "black", family = "Times New Roman"),
    axis.ticks.length = unit(-0.3, "cm"),
    legend.position = "right"
  )
ggsave("Plot_desc-PrevalenceGDSwithHTN_v2.pdf", width = 7, height = 6)




dat <- tibble(HTN = c("HTN+", "HTN+", "HTN-", "HTN-"), GDS = c("GDS-", "GDS+", "GDS-", "GDS+"), Count = c(1476, 623, 1504, 435)) %>%
  mutate(GDS = if_else(GDS == "GDS+", "Yes", "No"), HTN = if_else(HTN == "HTN+", "Yes", "No")) %>%
  group_by(HTN) %>% 
  reframe(HTN, GDS, Count, a = sum(Count)) %>%
  ungroup() %>%
  mutate(Rate = Count / a) %>% 
  mutate(RateStr = sprintf("%.3f", Rate)) %>%
  group_by(HTN) %>%
  reframe(HTN, GDS, Count, Rate, RateStr, ResStrLocation = cumsum(Rate))
dat

font_add("Times New Roman", file.path("fonts", "Times New Roman.ttf"))
showtext_auto()
dat %>%
  ggplot(aes(x = HTN, y = Rate, fill = GDS)) +
  geom_bar(stat = "identity") +
  # geom_text(aes(y = 1 - ResStrLocation, label = RateStr), vjust = -2, color = "white", size = 5, family = "Times New Roman") +
  labs(y = "Prevalence", x = "HTN", fill = "LDS") +
  theme_classic2(base_size = 30) +
  theme(
    axis.line = element_line(lineend = "square", color = "black", linewidth = 1.5),
    axis.ticks = element_line(color = "black", linewidth = 1.5),
    axis.text = element_text(color = "black", family = "Times New Roman"),
    axis.title = element_text(color = "black", family = "Times New Roman"),
    legend.text = element_text(color = "black", family = "Times New Roman"),
    legend.title = element_text(color = "black", family = "Times New Roman"),
    axis.ticks.length = unit(-0.3, "cm"),
    legend.position = "right"
  )
ggsave("Plot_desc-PrevalenceHTNwithGDS_v2.pdf", width = 7, height = 6)