library(pracma)

get.maxima = function(trace, min.peak.height) {
  peak.matrix = findpeaks(trace, minpeakheight = min.peak.height)  
  peak.durs = rep(0, length(trace))
  peak.starts = rep(0, length(trace))
  peak.ends = rep(0, length(trace))
  peak.vals = rep(0, length(trace))
  ispeak = rep(FALSE, length(trace))
  
  if (is.null(peak.matrix)) {
    return(list(ispeak=ispeak, 
                peak.durs=peak.durs, 
                peak.starts=peak.starts, 
                peak.ends=peak.ends,
                peak.vals=peak.vals))
  } 
  npeaks = nrow(peak.matrix)
  
  # Adjust the duration of the peak to cross the threshold, and merge neigbouring peaks
  right_i = 0
  for (peak.row in 1:npeaks) {
    peak = peak.matrix[peak.row,2]
    if (peak <= right_i) {
      next
    }
    peak.lowthresh  = trace[peak] * 0.5
    left_i = peak - 1
    while (left_i > 1 & trace[left_i] >= peak.lowthresh ) {
      left_i = left_i - 1
    }
    right_i = peak + 1
    while (right_i < length(trace) & trace[right_i] >= peak.lowthresh) {
      right_i = right_i + 1
    }
    
    left_i = left_i + 1
    right_i = right_i - 1
    peak.durs[left_i:right_i] = right_i - left_i + 1
    peak.starts[left_i:right_i] = left_i
    peak.ends[left_i:right_i] = right_i
    peak.vals[left_i:right_i] = max(trace[left_i:right_i])
    ispeak[left_i + which.max(trace[left_i:right_i]) - 1] = TRUE
  }
  
  return(list(ispeak=ispeak, 
              peak.durs=peak.durs, 
              peak.starts=peak.starts, 
              peak.ends=peak.ends,
              peak.vals=peak.vals))
}
