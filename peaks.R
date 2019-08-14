get.maxima = function(trace) {
  local.max = c(0, diff(sign(diff(trace)))==-2, 0)
  threshold=0.1
  crossesThreshold = FALSE
  prevLocalMax = NA
  
  res = rep(FALSE, length(local.max))
  for (i in 2:length(local.max)) {
    
    if (trace[i] < threshold) {
      crossesThreshold = TRUE
      prevLocalMax = NA
    }
    
    if (local.max[i]) {
      if (is.na(prevLocalMax)) {
        res[i] = crossesThreshold
        prevLocalMax = i
        crossesThreshold = FALSE
      } else {
        if (!crossesThreshold & trace[i] > trace[prevLocalMax]) {
          res[prevLocalMax] = FALSE
          res[i] = TRUE
          prevLocalMax = i
          crossesThreshold = FALSE
        }
      }
    }
  }
  
  peak.durs = rep(0, length(res))
  peak.starts = rep(0, length(res))
  peak.ends = rep(0, length(res))
  for (peak in which(res)) {
    peak.thresh  = trace[peak] * 0.3
    left_i = peak - 1
    while (left_i > 1 & trace[left_i] >= peak.thresh ) {
      left_i = left_i - 1
    }
    right_i = peak + 1
    while (right_i < length(trace) & trace[right_i] >= peak.thresh) {
      right_i = right_i + 1
    }
    peak.durs[peak] = right_i - left_i - 1
    peak.starts[peak] = left_i + 1
    peak.ends[peak] = right_i - 1
  }
  
  return(list(ispeak=res, peak.durs=peak.durs, 
              peak.starts=peak.starts, peak.ends=peak.ends))
}