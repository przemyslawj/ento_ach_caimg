# ento_ach_caimg
Cholinergic modulation of UP-DOWN states in the medial entorhinal cortex -
calcium imaging analysis

This is a repository with the code used in the publication (TODO: add ref to
the publication)

The analysis was performed in three stages:
1. The calcium imaging movies were analysed with Suite2P
[https://github.com/MouseLand/suite2p] and the cells were manually reviewed.
2. The calcium traces were processed to produce .csv files with the extracted
traces for the reviewed cells and their calcium events.
3. Statistical analysis was performed on the extracted traces and calcium events.

This repository contains the code for the stage 2 under the matlab directory
and for the stage 3 under the R directory.

## Stage 2: dF/F signal extraction and calcium event detection
The script convertdir2table.m is the starting point for the processing of
calcium imaging data in *.dat* files extracted with Suite2P. For each recording
file, dat2table.m script extracts calcium traces and finds calcium events in the
signal. The output is saved in *.csv* format.


## Stage 3: statistical analysis
The statistical analysis can be found in the network_effects.Rmd notebook.
The code performs the statistical tests and generates the paper figures. The
other R files contain functions called by the notebook for the analysis.

