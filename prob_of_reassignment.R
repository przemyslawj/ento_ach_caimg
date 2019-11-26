library(dplyr)

#ncells = 4
#df = data.frame(my.clust = c(1, 1, 2, 1, 
#                             1, 2, 1, 1, 
#                             1, 1, 2, 2),
#                cell_id = rep(1:ncells, 3),
#                exp = c(rep('Ctrl', ncells), rep('ACh', ncells), rep('Atr', ncells)))

calc.ok.changes = function(df) {
  #df = select(df, exp, cell_id, my.clust)
  df.ctrl = subset(df, exp == 'Ctrl')
  df.ach = subset(df, exp == 'ACh')
  df.atr = subset(df, exp == 'Atr')
  
  df.joined = left_join(df.ctrl, df.ach, 
                        by='cell_id', 
                        suffix=c('.ctrl', '.ach')) 
  df.joined2 = left_join(df.joined, df.atr, 
                        by=c('cell_id'), 
                        suffix=c('', '.atr'))
  
  df.change = df.joined2 %>%
    mutate(changed.ctrl2atr = my.clust.ctrl != my.clust,
           changed.ach2atr = my.clust.ach != my.clust,
           changed.ctrl2ach = my.clust.ctrl != my.clust.ach,
           changed.ctrl1_2_ach2 = (my.clust.ctrl == 1) & (my.clust.ach == 2),
           changed.ctrl2_2_ach1 = (my.clust.ctrl == 2) & (my.clust.ach == 1),
           changed.ach1_2_atr2 = (my.clust.ach == 1) & (my.clust == 2),
           changed.ach2_2_atr1 = (my.clust.ach == 2) & (my.clust == 1),
           correct.change = changed.ctrl2ach & !changed.ctrl2atr,
           correct.nochange = !changed.ctrl2atr & !changed.ctrl2ach,
           incorrect.change = !correct.change & !correct.nochange)
  return(df.change)
}

calc.change.probs = function(df) {
  df.change = calc.ok.changes(df)
  df.prob.change = df.change %>%
    dplyr::summarise(ncells=n(), 
              nclus.ctrl1 = sum(my.clust.ctrl == 1),
              nclus.ach1 = sum(my.clust.ach == 1),
              prob.ctrl2ach=sum(changed.ctrl2ach) / ncells,
              prob.ach2atr=sum(changed.ach2atr) / ncells,
              prob.ctrl1_2_ach2 = sum(changed.ctrl1_2_ach2) / nclus.ctrl1,
              prob.ctrl2_2_ach1 = sum(changed.ctrl2_2_ach1) / (ncells - nclus.ctrl1),
              prob.ach1_2_atr2 = sum(changed.ach1_2_atr2) / nclus.ach1,
              prob.ach2_2_atr1 = sum(changed.ach2_2_atr1) / (ncells - nclus.ach1),
              nchanges.correct = sum(correct.change),
              nchanges.nochange = sum(correct.nochange),
              nchanges.incorrect = sum(incorrect.change))
  
  return(df.prob.change)
}


simulate.changes = function(id, df, df.probs) {
  df = select(df, exp, cell_id, my.clust)
  df.ctrl = subset(df, exp == 'Ctrl')
  ncells = nrow(df.ctrl)
  df.ctrl$exp = rep('Ctrl', ncells)
  
  ach.clus.changed = rbinom(ncells, 1, df.probs$prob.ctrl2ach)
  atr.clus.changed = rbinom(ncells, 1, df.probs$prob.ach2atr)
  
  df.ach = df.ctrl
  #df.ach$changed2_1 = rbinom(ncells, 1, df.probs$prob.ctrl2_2_ach1)
  #df.ach$changed1_2 = rbinom(ncells, 1, df.probs$prob.ctrl1_2_ach2)
  #df.ach = df.ach %>% 
  #  mutate(new.clust = ifelse(my.clust == 1, ifelse(changed1_2, 2, 1),
  #                                           ifelse(changed2_1, 1, 2)),
  #         exp = 'ACh') %>%
  #  select(-my.clust) %>%
  #  dplyr::rename(my.clust=new.clust)
  
  df.ach$exp = rep('ACh', ncells)
  df.ach$my.clust = pmax(1, (df.ctrl$my.clust + ach.clus.changed) %% 3)
  
  df.atr = df.ach
  #df.atr$changed2_1 = rbinom(ncells, 1, df.probs$prob.ach2_2_atr1)
  #df.atr$changed1_2 = rbinom(ncells, 1, df.probs$prob.ach1_2_atr2)
  #df.atr = df.atr %>% 
  #  mutate(new.clust = ifelse(my.clust == 1,
  #                            ifelse(changed1_2, 2, 1),
  #                            ifelse(changed2_1, 1, 2)),
  #         exp = 'Atr') %>%
  #  select(-my.clust) %>%
  #  dplyr::rename(my.clust=new.clust)
  df.atr$exp = rep('Atr', ncells)
  df.atr$my.clust = pmax(1, (df.ach$my.clust + atr.clus.changed) %% 3)
  
  calc.change.probs(bind_rows(df.ctrl, df.ach, df.atr))
}

calc.reassigment.percentile = function(animal.df) {
  df.change.probs = calc.change.probs(animal.df)
  df.simulated.correct = lapply(1:1000, FUN=simulate.changes, df.probs=df.change.probs, df=animal.df) %>% bind_rows
  
  df.simulated.correct %>%
    dplyr::mutate(is.better = nchanges.incorrect <= df.change.probs$nchanges.incorrect) %>%
    dplyr::summarise(percentile = sum(is.better) / n())
}
