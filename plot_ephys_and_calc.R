library(dplyr)
library(ggplot2)
library(tidyr)

source('data_import.R')


dat_file = '/mnt/DATA/Audrey/ca_img_result/data/dat_Sim_S2_1.csv'
data = import.trace(dat_file) %>%
  mutate(timestamp = frame * 350/900) 
  #mutate(timestamp = frame* 0.36289)

cell.data = filter(data, cell_id == 118)
#cell.data = filter(data, cell_id == 46)
#cell.data = filter(data, cell_id == 102)

vm.df = read.csv('/mnt/DATA/Audrey/ca_img_result/sim_recordings/2016-09-28-s2/ctrl-1_Vm.csv')
vm.df$frame = 1:nrow(vm.df)
vm.df = vm.df %>%
  mutate(timestamp= frame * 0.00012375) %>%
  filter(frame %% 10 == 1)

cell.data$src = rep('caimg', nrow(cell.data))
vm.df$src = rep('ephys', nrow(vm.df))

vm.df = mutate(vm.df, Vm_clipped = ifelse(Vm < -0.04, Vm, -0.04))

sim.df = bind_rows(dplyr::rename(cell.data, val=trace) %>% select(timestamp, val, src), 
                   dplyr::rename(vm.df, val=Vm_clipped))
sim.df$src = as.factor(sim.df$src)

sim.df %>%
  #filter(timestamp > 190, timestamp < 205) %>%
  filter(timestamp > 320, timestamp < 340) %>%
  #filter(timestamp > 332, timestamp < 350) %>%
  #filter(timestamp > 10, timestamp < 20) %>%
  ggplot() +
  geom_line(aes(x=timestamp, y=val, group=src)) +
  facet_grid(src ~ ., scales = 'free_y') +
  gtheme +
  ylab('') + xlab('Time (sec)')

#cell.data %>%
#  ggplot() +
#  geom_line(aes(x=timestamp, y=trace)) +
#  gtheme
