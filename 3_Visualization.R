######################## PROJECT: LUGA expo analysis
# Author: Julian Wittische (Musée National d'Histoire Naturelle Luxembourg)
# Request: Laura Daco/Thierry Helminger
# Start: Spring 2025
# Data: MNHNL
# Script objective : Visualize biodiversity metrics

############ Loading metrics ----
# This comes from 2_Metrics.R
load(paste0(DATA_PATH, "/_Julian/LUGA-expo-DATA/Metrics.RData"))

############ Visualization of metrics ----

###### Spatial environment
mapviz(all, IMP)

###### All taxa
mapviz(all, observations)
mapviz(all, species)
mapviz(all, speciesPobs)
all2 <- all
all2[all2$speciesPobs=="NaN","speciesPobs"] <- 0
mapviz(all2, speciesPobs)

###### Birds
mapviz(birds, observations)
mapviz(birds, species)
mapviz(birds, speciesPobs)

###### Vascular plants
mapviz(vasc, observations)
mapviz(vasc, species)
mapviz(vasc, speciesPobs)

###### Invertebrates
mapviz(inver, observations)
mapviz(inver, species)
mapviz(inver, speciesPobs)

###### Neobiota
mapviz(neo, observations)
mapviz(neo, species)
mapviz(neo, speciesPobs)