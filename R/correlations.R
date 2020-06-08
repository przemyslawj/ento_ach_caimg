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
  for (i in 1:nrow(cor.data)) {
    cor.data[i,i] = 1.0
  }
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

get.corr.vals = function(M) {
  df = melt(M)
  (filter(df, Var1 != Var2))$value 
}

get.shuffled.cors = function(data, cond, nshuffles=100) {
  d = filter(data, exp==cond)
  shuffled.df = create.shuffles(d, nshuffles = nshuffles)
  shuffled.df$exp = rep(cond, nrow(shuffled.df))
  return(shuffled.df)
}

signif.shuffled.cors = function(shuffled.df, cors.df) {
  
  run.ks.test = function(i) {
    ks.test.res = ks.test(cors.df$vals, subset(shuffled.df, shuffle_i == i)$vals)
    ks.test.res$p.value
  }
  pvals = sapply(unique(shuffled.df$shuffle_i), run.ks.test)
  pvals.adjusted = p.adjust(pvals, method = 'bonferroni')
  
  return(pvals.adjusted)
}

get.cors.df = function(data, cond) {
  d = filter(data, exp==cond)
  x = get.cor(d) 
  df = create.cor.values.df(x, 1)
  df$exp = rep(cond, nrow(df))
  return (df)
}

plot.shuffled.cors = function(shuffled.df, cors.df, includePval=FALSE) {
  library(grid)
  
  g = ggplot() + 
    stat_ecdf(data=shuffled.df, aes(x=vals, group=shuffle_i), geom='step', alpha=0.6) +
    stat_ecdf(data=cors.df, mapping=aes(x=vals), colour='red', geom='step') +
    scale_y_continuous(breaks=c(0.0, 0.5, 1.0)) +
    scale_x_continuous(breaks=c(-1.0, 0.0, 1.0), limits = c(-1,1)) +
    xlab('Correlation') + ylab('Probability')
  
  if (includePval) {
    pvals = signif.shuffled.cors(shuffled.df, cors.df)
    pvaltext = sprintf('max p-val=%.2f',max(pvals))
    g = g + ggtitle(pvaltext)
  }
  return(g)
}



