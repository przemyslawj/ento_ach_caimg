library(dplyr)

#ncells = 4
#df = data.frame(my.clust = c(1, 1, 2, 1, 
#                             1, 2, 1, 1, 
#                             1, 1, 2, 2),
#                cell_id = rep(1:ncells, 3),
#                exp = c(rep('Ctrl', ncells), rep('ACh', ncells), rep('Atr', ncells)))

calc.ok.changes = function(df) {
  df = select(df, exp, cell_id, my.clust)
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
    mutate(changed.ctrl2ach = my.clust.ctrl != my.clust.ach,
           changed.ach2atr = my.clust.ach != my.clust,
           changed.ctrl2atr = my.clust.ctrl != my.clust,
           correct.change = changed.ctrl2ach & !changed.ctrl2atr,
           correct.nochange = !changed.ctrl2atr & !changed.ctrl2ach,
           incorrect.change = !correct.change & !correct.nochange)
  
  df.prob.change = df.change %>%
    dplyr::summarise(ncells=n(), 
              prob.ctrl2atr=sum(changed.ctrl2ach) / ncells,
              prob.ctrl2ach=sum(changed.ctrl2ach) / ncells,
              prob.ach2atr=sum(changed.ach2atr) / ncells,
              nchanges.correct = sum(correct.change),
              nchanges.nochange = sum(correct.nochange),
              nchanges.incorrect = sum(incorrect.change))
  
  return(df.prob.change)
}


simulate.changes = function(id, df, df.probs) {
  df = select(df, exp, cell_id, my.clust)
  df.ctrl = subset(df, exp == 'Ctrl')
  ncells = nrow(df.ctrl)
  ach.clus.changed = rbinom(ncells, 1, df.probs$prob.ctrl2ach)
  atr.clus.changed = rbinom(ncells, 1, df.probs$prob.ach2atr)
  
  df.ach = df.ctrl
  df.ach$exp = rep('ACh', ncells)
  df.ach$my.clust = (df.ctrl$my.clust + ach.clus.changed) %% 2
  
  df.atr = df.ctrl
  df.atr$exp = rep('Atr', ncells)
  df.atr$my.clust = (df.ach$my.clust + atr.clus.changed) %% 2
  
  calc.ok.changes(bind_rows(df.ctrl, df.ach, df.atr))
}

calc.reassigment.percentile = function(animal.df) {
  df.prob.change = calc.ok.changes(animal.df)
  df.simulated.correct = lapply(1:100, FUN=simulate.changes, df.probs=df.prob.change, df=animal.df) %>% bind_rows
  
  df.simulated.correct %>%
    dplyr::mutate(is.better = nchanges.incorrect <= df.prob.change$nchanges.incorrect) %>%
    dplyr::summarise(percentile = sum(is.better) / n())
}
