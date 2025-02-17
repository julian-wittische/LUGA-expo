######################## PROJECT: LUGA expo analysis
# Author: Julian Wittische (Musée National d'Histoire Naturelle Luxembourg)
# Request: Laura Daco/Thierry Helminger
# Start: Spring 2025
# Data: MNHNL
# Script objective : Load libraries

############ Data manipulation ----
library(tidyverse)
library(stringr)

############ GIS ----
library(sf) # load and manipulate GIS vector objects
library(rgeoboundaries) # administrative borders
library(terra) # deal with raster objects
library(exactextractr) # extract at locations

############ Plotting ----
library(ggplot2) # keep: plotting

############ Development help ---- 
library(beepr) # can be removed once complete