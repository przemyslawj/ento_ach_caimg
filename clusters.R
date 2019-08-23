library(cluster)
library(dplyr)
library(factoextra)
library(viridis)
library(tidyr)
library(tibble)

add.cluster.tsne = function(data) {
  cor.data = get.cor(data, cond='ACh')
  tsne.vals = tsne::tsne(cor.data, k=1)
  cell_ids = unique(data$cell_id)
  tsne.df = data.frame(cell_id=cell_ids, tsne.val=tsne.vals) %>%
    arrange(tsne.val) %>%
    mutate(cluster_order = row_number())
  
  data = data %>% 
    left_join(tsne.df, by='cell_id') %>%
    mutate(clust.order_value = tsne.val,
           cluster=1) %>%
    arrange(cluster_order) 
  
  return(data)
}

add.cluster2 = function(data, clust.res) {
  max.cluster.index = which.max(clust.res$silinfo$clus.avg.widths)
  swidths = clust.res$silinfo$widths %>%
    rownames_to_column('cell_id') %>%
    mutate(my.clust = if_else(cluster==max.cluster.index, 1, 2)) %>%
    arrange(my.clust, desc(sil_width)) %>%
    mutate(row.id = row_number(my.clust)) %>%
    mutate(clust.order_value = ifelse(my.clust == 1, row.id, max(row.id) + max(row.id)-row.id)) %>%
    arrange(clust.order_value) %>%
    mutate(cluster_order = row_number(clust.order_value)) %>%
    select(-c('neighbor','sil_width', 'row.id', 'cluster', 'clust.order_value')) %>%
    dplyr::rename(cluster=my.clust)
  
  clust.order = 1:length(clust.res$cluster)
  names(clust.order) = swidths$cell_id
  
  data.ordered = data %>%
    left_join(swidths, by=c('cell_id'='cell_id'))  %>%
    arrange(cluster_order)
  data.ordered$cluster = as.factor(data.ordered$cluster)
  
  data.ordered$cell_id = factor(data.ordered$cell_id, levels = names(sort(clust.order)))
  
  return(data.ordered)
  
}

plot.cluster.traces = function(data) {
  cluster.data = data %>%
    group_by(date, animal, exp, cluster,frame) %>%
    dplyr::summarise(m.trace = median(ztrace), frame.rate = frame.rate[1])
  summary.data = data %>%
    group_by(date, animal, exp, frame) %>%
    dplyr::summarise(m.trace = median(ztrace), frame.rate = frame.rate[1])
  
  ggplot() +
    geom_line(data=cluster.data, aes(x=frame/frame.rate , y=m.trace, color=cluster), alpha=0.7)  +
    geom_line(data=summary.data, aes(x=frame/frame.rate , y=m.trace), color='black', alpha=0.7)  +
    facet_grid(exp ~ .) +
    gtheme +
    xlab('Time (sec)') +
    ylab('z-scored dF/F') +
    theme(legend.position='none')
}

plot.activity.raster = function(data, bin.width) {
  cluster.data = data %>%
    group_by(exp, cluster) %>%
    dplyr::summarise(order.max = max(cluster_order))
 
  data %>%
    mutate(maxed.ztrace=pmax(-2,pmin(6,ztrace))) %>%
    ggplot(aes(x=frame / frame.rate, y=cluster_order)) +
    geom_tile(aes(fill=maxed.ztrace), interpolate = FALSE, width=bin.width)  +
    #geom_hline(data=cluster.data, mapping=aes(yintercept=order.max+0.5), color='red')+
    facet_grid(. ~ exp) +
    gtheme +
    labs(fill='z-scored dF/F') +
    #scale_y_reverse() +
    scale_fill_viridis(breaks=c(0, 5)) +
    ylab('Cell') +
    xlab('Time (sec)')
}
