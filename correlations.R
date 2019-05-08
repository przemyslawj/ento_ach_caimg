library(dplyr)
library(tidyr)

spread.df = function(data) {
  max.frame = max(data$frame)
  trace.data.df = data %>%
    mutate(tot_frame = (as.numeric(exp) - 1) * max.frame + frame) %>%
    select(cell_id, tot_frame, ztrace) %>%
    dplyr::rename(frame=tot_frame)
  df = spread(trace.data.df, cell_id, ztrace) 
  return(df)
}

get.cor = function(data, cond=NA) {
  if (!is.na(cond)) {
    data = filter(data, exp == cond)
  }
  df = spread.df(data)
  
  cor.data = cor(df[,2:ncol(df)])
  cor.data[is.na(cor.data)] = 0
  return(cor.data)
}

# Circularly shifts timestamps for each cell
shuffle.data = function(data, min.shuffle=10) {
  df = spread.df(data)
  df.double = bind_rows(df, df)
  
  nframes = nrow(df)
  for (i in 2:ncol(df)) {
    shift_i = runif(1, min=min.shuffle, max=nframes-1) %>% floor
    df[,i] = df.double[shift_i:(shift_i+nframes-1),i]
  }
  return(df)
}


create.cor.values.df = function(cor.matrix, index) {
  ncells = nrow(cor.matrix)
  cor.vals = rep(0,  ncells * (ncells-1) / 2)
  total_i = 0
  for (i in 2:ncells) {
    vals = cor.matrix[i,1:(i-1)]
    cor.vals[(total_i + 1) : (total_i + length(vals))] = vals
    total_i = total_i + length(vals)
  }
  cor.df = data.frame(shuffle_i = rep(index, length(cor.vals)), vals=cor.vals)
  
  return(cor.df)
}

create.shuffles = function(d, nshuffles=100) {
  hist.df = data.frame()
  for (i in 1:nshuffles) {
    d.shuffled = shuffle.data(d)
    cor.data = cor(d.shuffled[,2:ncol(d.shuffled)])
    cor.df = create.cor.values.df(cor.data, i)
    hist.df = bind_rows(hist.df, cor.df)
  }
  
  return(hist.df)
}

get.corr.change = function(data) {
  X=rep(0,2)
  for (i in 1:2) {
    cond = levels(data$exp)[i]
    d = filter(data, exp==cond)
    cor.data = get.cor(d)
    X[i] = create.cor.values.df(cor.data, 0)$vals %>% quantile(0.75)
  }
  
  X[2] - X[1]   
}

plot.shuffled.cors = function(data, cond) {
  d = filter(data, exp==cond)
  cor.data = get.cor(d)
  cor.df.org = create.cor.values.df(cor.data, 0)
  
  hist.df = create.shuffles(d)
  
  ggplot() + 
    geom_density(data=hist.df, aes(x=vals, y=..scaled.., group=shuffle_i), alpha=0.6) +
    geom_density(data=cor.df.org, mapping=aes(x=vals, y=..scaled.., group=shuffle_i),colour='red') +
    #stat_bin(aes(x=vals, group=shuffle_i), hist.df, geom='line', alpha=0.5, binwidth=0.05) +
    #stat_bin(aes(x=vals), cor.df.org, colour='red', geom='line', binwidth=0.05) +
    xlim(c(-0.2, 1.0)) +
    xlab('Correlation') + ylab('Density')
}


