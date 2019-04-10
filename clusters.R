library(cluster)
library(factoextra)
library(tidyr)

get.cor = function(data, cond=NA) {
  if (!is.na(cond)) {
    data = filter(data, exp == cond)
  }
  
  max.frame = max(data$frame)
  trace.data.df = data %>%
    mutate(tot_frame = (as.numeric(exp) - 1) * max.frame + frame) %>%
    select(cell_id, tot_frame, ztrace) %>%
    dplyr::rename(frame=tot_frame)
  df = spread(trace.data.df, cell_id, ztrace) 
  cor.data = cor(df[,2:ncol(df)])
  cor.data[is.na(cor.data)] = 0
  return(cor.data)
}

add.cluster2 = function(data, clust.res) {
  clust.order = 1:length(clust.res$cluster)
  names(clust.order) = rownames(clust.res$silinfo$widths)
  data.ordered = data %>%
    mutate(cluster=clust.res$cluster[as.character(cell_id)],
           cluster_order=clust.order[as.character(cell_id)])
  data.ordered$cluster = as.factor(data.ordered$cluster)
  
  data.ordered$cell_id = factor(data.ordered$cell_id, levels = names(sort(clust.order)))
  
  return(data.ordered)
  
}

add.cluster = function(data, cond=NA, plot.silhouette=FALSE, k=2) {
  cor.data = get.cor(data, cond)
  dissim.dist = as.dist(1 - cor.data)
  kclust = kmeans(dissim.dist, k, iter.max=20)
  sh = silhouette(kclust$cluster, dissim.dist)
  if (plot.silhouette) {
    plot(sh)
  }
  sh.sorted = sortSilhouette(sh)
  clust.order = 1:length(kclust$cluster)
  names(clust.order) = names(kclust$cluster)[attr(sh.sorted,'iOrd')]

  data.ordered = data %>%
    mutate(cluster=kclust$cluster[as.character(cell_id)],
           cluster_order=clust.order[as.character(cell_id)])
  data.ordered$cluster = as.factor(data.ordered$cluster)
  #data.ordered$cluster_order = as.factor(data.ordered$cluster_order)
  
  data.ordered$cell_id = factor(data.ordered$cell_id, levels = names(sort(clust.order)))
  
  return(data.ordered)
}

plot.cluster.traces = function(data) {
  cluster.data = data %>%
    group_by(date, animal, exp, cluster,frame) %>%
    dplyr::summarise(m.trace = median(ztrace))
  summary.data = data %>%
    group_by(date, animal, exp, frame) %>%
    dplyr::summarise(m.trace = median(ztrace))
  
  ggplot() +
    geom_line(data=cluster.data, aes(x=frame/frame.rate.hz , y=m.trace, color=cluster), alpha=0.7)  +
    geom_line(data=summary.data, aes(x=frame/frame.rate.hz , y=m.trace), color='black', alpha=0.7)  +
    facet_grid(exp ~ .) +
    gtheme +
    xlab('Time (sec)') +
    ylab('z-scored dF/F') +
    theme(legend.position='none')
}

plot.activity.raster = function(data) {
 cluster.data = data %>%
    group_by(exp, cluster) %>%
    dplyr::summarise(order.max = max(cluster_order))
 
  data %>%
    mutate(maxed.ztrace=pmax(-2,pmin(6,ztrace))) %>%
    #filter(exp=='Ach') %>%
    ggplot(aes(x=frame / frame.rate.hz, y=cluster_order)) +
    geom_raster(aes(fill=maxed.ztrace), interpolate = FALSE)  +
    geom_hline(data=cluster.data, mapping=aes(yintercept=order.max+0.5), color='red')+
    facet_grid(. ~ exp) +
    gtheme +
    labs(fill='zscored dF/F') +
    theme(legend.position = 'top') +
    #      axis.text.y=element_blank(),
    #      axis.ticks.y=element_blank()) +
    ylab('Cell') +
    xlab('Time (sec)')
}