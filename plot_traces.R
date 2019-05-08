library(ggplot2)

animal_name = 'Necab_M3'
exp_name = 'Atr'
filtered.all.data %>%
  filter(animal == animal_name) %>%
  filter(exp == exp_name) -> dat

selected.cells = unique(dat$cell_id)[c(1:6, 15, 16, 24, 23)]


dat %>%
  filter(cell_id %in% selected.cells) %>%
  ggplot() +
  geom_line(mapping=aes(x=frame/3, y=trace)) +
  facet_grid(cell_id ~ .) +
  gtheme +
  xlab('Time (sec)') +
  ylab('dF/F') +
  xlim(c(0,400))

ggsave('/tmp/trace.svg', units='cm',
       width=20,
       height=10)
