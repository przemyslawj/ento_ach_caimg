library(ggplot2)

animal_name = 'Necab_M13'
exp_name = 'Ctrl'
filtered.all.data %>%
  filter(animal == animal_name) %>%
  filter(exp == exp_name) -> dat

selected.cells = c(24, 29, 95, 84, 55, 65, 146, 47, 63, 31, 89)
selected.cells = c(24, 29, 31, 47, 55, 65, 146, 84, 63, 89)
order = c(5, 8, 9, 4, 6, 1, 2, 3, 7, 10)
#selected.cells = 141:150
labels.df = data.frame(
  ordinal=1:length(selected.cells),
  cell_id=selected.cells)
labels.df$cell_id = as.factor(labels.df$cell_id)


dat.cells = dat %>%
  filter(cell_id %in% selected.cells)
dat.cells$cell_id = factor(dat.cells$cell_id, levels=labels.df$cell_id)

dat.cells %>%
  ggplot() +
  geom_line(mapping=aes(x=frame/2.3, y=trace)) +
  geom_text(data=labels.df, mapping=aes(x=-5, y=0.1, label=format(ordinal))) +
  facet_grid(cell_id ~ .) +
  gtheme +
  scale_y_continuous(breaks=c(0, 1.0)) +
  theme(strip.background = element_blank(),
        strip.text.x = element_blank(),
        strip.text.y = element_blank()) +
  xlab('Time (sec)') +
  ylab('dF/F') +
  xlim(c(-10,400))

ggsave('/tmp/trace.svg', units='cm',
       width=20,
       height=10)
