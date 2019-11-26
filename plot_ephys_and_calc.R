library(dplyr)
library(ggplot2)
library(tidyr)

source('data_import.R')


dat_file = '/mnt/DATA/Audrey/ca_img_result/data/dat_001.csv'
#dat_file = '/mnt/DATA/Audrey/ca_img_result/data/dat_Sim_S2_2.csv'
data = import.trace(dat_file) %>%
  mutate(timestamp = frame * 0.09268)
  #mutate(timestamp = frame* 0.36289)

cell.data = data
cell.data = filter(data, cell_id == 31)
#cell.data = filter(data, cell_id == 46)
#cell.data = filter(data, cell_id == 102)

#vm.df = read.csv('/mnt/DATA/Audrey/ca_img_result/sim_recordings/2016-09-28-s2/ctrl-2_Vm.csv')
vm.df = read.csv('/mnt/DATA/Audrey/ca_img_result/sim_recordings/001/ephy001_GCaMP6ftest_0_Vm.txt')
vm.df$frame = 1:nrow(vm.df)
dt = 0.00012375
vm.df = vm.df %>%
  mutate(timestamp= frame * dt) %>%
  filter(frame %% 10 == 1)

cell.data$src = rep('caimg', nrow(cell.data))
vm.df$src = rep('ephys', nrow(vm.df))

vm.df = mutate(vm.df, Vm_clipped = ifelse(Vm < -0.04, Vm, -0.04))

sim.df = bind_rows(dplyr::rename(cell.data, val=trace) %>% select(timestamp, val, src),
                   dplyr::rename(vm.df, val=Vm_clipped))
sim.df$src = as.factor(sim.df$src)

sim.df %>%
  #filter(timestamp > 185, timestamp < 195) %>%
  #filter(timestamp > 320, timestamp < 340) %>%
  #filter(timestamp > 332, timestamp < 350) %>%
  #filter(timestamp >= 1, timestamp < 5) %>%
  #filter(timestamp >= 15, timestamp < 18) %>%
  ggplot() +
  geom_line(aes(x=timestamp, y=val, group=src)) +
  facet_grid(src ~ ., scales = 'free_y') +
  gtheme +
  ylab('') + xlab('Time (sec)')

#cell.data %>%
#  ggplot() +
#  geom_line(aes(x=timestamp, y=trace)) +
#  gtheme

ggsave(paste0(gen_imgs_dir, '3-dual-recording.pdf'),
       device=cairo_pdf,
       units='cm',
       width=7,
       height=5)
