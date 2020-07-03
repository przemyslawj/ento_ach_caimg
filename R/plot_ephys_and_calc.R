library(dplyr)
library(ggplot2)
library(tidyr)

source('data_import.R')


#dat_file = '/mnt/DATA/Audrey/ca_img_result/data/dat_001.csv'
dat_file = '/mnt/DATA/Audrey/ca_img_sim/20200618/dat_20200618cell4.csv'
data = import.trace(dat_file,  exp.levels = c('Ctrl', 'ACh', 'Firing')) %>%
  #mutate(timestamp = frame * 0.09268)
  #mutate(timestamp = frame* 0.36289)
  mutate(timestamp = frame* 0.32768)

cell.data = data 
  #filter(exp == 'Ctrl')
#cell.data = filter(data, cell_id == 31)
#cell.data = filter(data, cell_id == 46)
#cell.data = filter(data, cell_id == 102)

vm.df.ach = read.csv('/mnt/DATA/Audrey/ca_img_sim/20200618/20200618cell4/20200618cell4ACh.csv')
vm.df.ach$frame = 1:nrow(vm.df.ach)
colnames(vm.df.ach)[1] = 'Vm'
vm.df.ctrl = read.csv('/mnt/DATA/Audrey/ca_img_sim/20200618/20200618cell4/20200618cell4Base.csv')
vm.df.ctrl$frame = 1:nrow(vm.df.ctrl)
colnames(vm.df.ctrl)[1] = 'Vm'
vm.df.firing = read.csv('/mnt/DATA/Audrey/ca_img_sim/20200618/20200618cell4/20200618cell4Firing1.csv')
vm.df.firing$frame = 1:nrow(vm.df.firing)
colnames(vm.df.firing)[1] = 'Vm'

dt = 1/8080.80
vm.df = bind_rows(mutate(vm.df.ach, exp='ACh', timestamp=frame * dt), 
                  mutate(vm.df.ctrl, exp='Ctrl', timestamp=frame * dt), 
                  mutate(vm.df.firing, exp='Firing', timestamp=frame * 1/8000))

vm.df = vm.df %>%
  filter(frame %% 10 == 1)

cell.data$src = 'caimg'
vm.df$src = 'ephys'

vm.df = mutate(vm.df, Vm_clipped = ifelse(Vm < -0.04, Vm, -0.04))
vm.df$cell_id = factor(rep(0, nrow(vm.df)))

sim.df = bind_rows(dplyr::rename(cell.data, val=trace) %>% select(timestamp, val, src, cell_id, exp),
                   dplyr::rename(vm.df, val=Vm ))
sim.df$src = as.factor(sim.df$src)

sim.df %>%
  filter(cell_id %in% c(0, 6, 8, 16, 19, 10, 23,1)) %>%
  filter((exp == 'ACh' & timestamp > 96 & timestamp <= 196) |
         (exp == 'Ctrl'& timestamp > 0 & timestamp < 100) |
         (exp == 'Firing')) %>%
  filter(exp=='Firing') %>%
  #filter(timestamp > 332, timestamp < 350) %>%
  #filter(timestamp >= 1, timestamp < 5) %>%
  #filter(timestamp >= 15, timestamp < 18) %>%
  ggplot() +
  geom_line(aes(x=timestamp, y=val, group=src)) +
  #facet_grid(src + cell_id ~ exp, scales='free_x') +
  facet_grid(src + cell_id ~ exp, scales = 'free') +
  gtheme +
  ylab('') + xlab('Time (sec)')

  #cell.data %>%
#  ggplot() +
#  geom_line(aes(x=timestamp, y=trace)) +
#  gtheme

gen_imgs_dir = '/home/prez/tmp/ach_caimg/'
ggsave(paste0(gen_imgs_dir, '3-dual-recording-caimg.pdf'),
       device=cairo_pdf,
       units='cm',
       width=19,
       height=25)



dat_file = '/mnt/DATA/Audrey/ca_img_sim/20200618/20200618cell4/20200618cell4Firing1_ephyscell.csv'
cell_caimg.df=read.csv(dat_file)
cell_caimg.df = mutate(cell_caimg.df,
                       timestamp=X* 0.32768,
                       F0=mean(Mean1),
                       val=(Mean1-F0)/F0,
                       exp='Firing',
                       src='caimg',
                       cell_id='0')

bind_rows(dplyr::select(cell_caimg.df, timestamp, val, exp, src, cell_id),
          filter(sim.df, exp=='Firing')) %>%
          #sim.df) %>%
  filter(cell_id %in% c(0, 1)) %>%
  ggplot() +
  geom_line(aes(x=timestamp,y=val)) +
  facet_grid(src + cell_id ~ exp, scales='free') +
  gtheme
