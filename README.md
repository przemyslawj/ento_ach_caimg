# ento_ach_caimg
Cholinergic modulation of UP-DOWN states in the medial entorhinal cortex - calcium imaging analysis

This is a repository with the code used in the publication (TODO: add ref to publication)

The analysis was performed in three stages:
1. The calcium imaging movies were analysed with Suite2P [https://github.com/MouseLand/suite2p] and the cells were manually reviewed.
2. The calcium traces were processed to produce .csv files with the extracted traces of the reviewed cells.
3. Statistical analysis and generation of the figures and statistics from the publication.

This repository contains the code for stages 2. and 3.

Stage 2. is performed by Matlab code, and the script convertdir2table.m is the starting point. We can share the data on resonable requests.
Stage 3. is performed in R, the network_effects.Rmd notebook script is the starting point.
