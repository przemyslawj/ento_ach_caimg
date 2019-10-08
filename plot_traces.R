library(ggplot2)

animal_name = 'Necab_M13'
exp_name = 'Ctrl'
dat = filtered.all.data %>%
#dat = all.data %>%
  filter(animal == animal_name) 
  #filter(exp == exp_name) 

#selected.cells = c(24, 29, 31, 47, 55, 65, 146, 84, 63, 89)
selected.cells = c(146, 84, 63)
labels.df = data.frame(
  ordinal=1:length(selected.cells),
  cell_id=selected.cells)
labels.df$cell_id = as.factor(labels.df$cell_id)


dat.cells = dat %>%
  filter(cell_id %in% selected.cells)
dat.cells$cell_id = factor(dat.cells$cell_id, levels=labels.df$cell_id)

dat.cells %>%
  ggplot() +
  geom_line(mapping=aes(x=frame/2.3, y=trace), size=0.5) +
  geom_text(data=labels.df, mapping=aes(x=-15, y=0.4, label=format(ordinal))) +
  facet_grid(cell_id ~ exp ) +
  gtheme +
  scale_y_continuous(breaks=c(0, 2.0)) +
  theme(strip.background = element_blank(),
        strip.text.x = element_blank(),
        strip.text.y = element_blank()) +
  xlab('Time (sec)') +
  ylab('dF/F') +
  xlim(c(-15,400))

ggsave(paste0(gen_imgs_dir, 'trace.pdf'), units='cm',
       device=cairo_pdf,
       width=width_2col,
       height=5)
