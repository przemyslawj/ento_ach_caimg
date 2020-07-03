library(dplyr)
library(readr)
library(stringr)
library(tidyr)

import.trace = function(traces_file, exp.levels = c('Ctrl', 'ACh', 'Atr')) {
  meta.cols = c("frame","animal","exp", "cell_id")
  data = read.csv(traces_file)
  
  trace.data = data %>%
    gather('cell_id', 'trace', starts_with('Trace_')) %>%
    select(one_of(c(meta.cols, 'trace')))
  trace.data$cell_id = str_replace(trace.data$cell_id,'^Trace_[.]?','')
  
  strace.data = data %>%
    gather('cell_id', 'strace', starts_with('STrace_')) %>%
    select(one_of(c(meta.cols, 'strace')))
  strace.data$cell_id = str_replace(strace.data$cell_id,'STrace_[.]?','')
  
  event.data = data %>%
    gather('cell_id', 'event', starts_with('Event_'))  %>%
    select(one_of(c(meta.cols, 'event')))
  event.data$cell_id = str_replace(event.data$cell_id,'^Event_[.]?','')
  
  sevent.data = data %>%
    gather('cell_id', 'sevent', starts_with('SEvent_'))  %>%
    select(one_of(c(meta.cols, 'sevent')))
  sevent.data$cell_id = str_replace(sevent.data$cell_id,'^SEvent_[.]?','')
  
  data = inner_join(trace.data, event.data, by=meta.cols) %>%
    inner_join(strace.data, by=meta.cols) %>%
    inner_join(sevent.data, by=meta.cols)
  data$cell_id = as.factor(data$cell_id)
  data$exp = str_replace(data$exp, 'Baseline', 'Ctrl')
  data$exp = str_replace(data$exp, 'Ach', 'ACh')
  data$exp = str_replace(data$exp, 'Atropine', 'Atr')
  data$exp = factor(data$exp, levels=exp.levels)
  
  return(data)
}