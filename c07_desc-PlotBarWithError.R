library(tidyverse)
library(readxl)
library(ggpointdensity)
library(ggsci)
library(showtext)
# 加载各个包
font_add('lzlfont', 'fonts/times.ttf')
font_add('lzlfontbd', 'fonts/timesbd.ttf')

data.plot <- read_xlsx("节点参数值.xlsx", sheet = "节点最短路径") %>%
  # pivot_longer(c("IFGoperc.L", "ORBinf.L", "ROL.L", "FFG.R", "HES.L", "STG.L", "STG.R"), names_to = "Region", values_to = "Value")
  # pivot_longer(c("ORBinf.L", "HIP.R", "PHG.R", "PCG.L", "PCG.R", "MFG.L"), names_to = "Region", values_to = "Value")
  # pivot_longer(c("PHG.R", "CAL.L", "CAL.R", "PCG.L", "PCG.R", "MFG.L"), names_to = "Region", values_to = "Value")
  pivot_longer(c("PCG.L", "AMYG.R", "TPOsup.L"), names_to = "Region", values_to = "Value")

#把times字体导入
font_add('lzlfont', 'fonts/times.ttf')
font_add('lzlfontbd', 'fonts/timesbd.ttf')
showtext_opts(dpi = 600)
showtext.auto()
data.plot %>%
  select(Group1, Region, Value) %>%
  mutate(Group1 = factor(Group1, levels = c('Control', 'AB', 'AB_CAA', 'AB_MIX'))) %>%
  drop_na() %>%
  group_by(Group1, Region) %>%
  #按照group进行分组
  summarise(val = mean(Value), std = sd(Value), n = n()) %>%
  #summarise描述性统计
  mutate(se = std / sqrt(n)) %>%
  ungroup() %>%
  mutate(Region = as.factor(Region)) %>%
  #计算标准误
  ggplot(aes(x = Region, y = val, fill = Group1)) +
  #fill即legend
  geom_bar(stat = 'identity', color = 'black', size = 1, width = 0.5, position = position_dodge()) +
  #identity即确值，color指定框的颜色，fill指定柱体颜色
  geom_pointrange(aes(y = val, x = Region, ymin = val - se, ymax = val + se), linewidth = 1, position=position_dodge(0.5)) +
  #指定标准误的范围，及线的宽度
  # scale_fill_manual(values = c('#C98474', '#F2D388', '#A7D2CB')) +
  # scale_fill_aaas() +
  #通过此函数指定bar的颜色
  labs(x = 'Group', y = 'Value', fill = '') +
  #命名x和y轴，fill给定图例的title
  theme_minimal(
    base_size = 25
  ) +
  theme(
    legend.position = 'right',
    axis.title = element_text(family = 'lzlfontbd', color = 'black'),
    axis.text = element_text(family = 'lzlfont', color = 'black'),
    legend.text = element_text(family = 'lzlfont', color = 'black'),
    legend.title = element_text(family = 'lzlfontbd', color = 'black'),
    axis.ticks.y = element_blank(),
    axis.ticks.x = element_blank()
  )
ggsave('Nodal_Lp.tiff', dpi = 600, width = 8, height = 6.18)
