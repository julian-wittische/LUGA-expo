######################## PROJECT: LUGA expo analysis
# Author: Julian Wittische (Musée National d'Histoire Naturelle Luxembourg)
# Request: Laura Daco/Thierry Helminger
# Start: Spring 2025
# Data: MNHNL
# Script objective : Visualize biodiversity metrics

############ Loading metrics ----
source("2_Metrics.R")

############ Visualization of metrics ----

###### General visualisation function
mapviz <- function(metrics_df, metric){
  map <- ggplot(metrics_df) +
    geom_sf(aes(fill = {{metric}})) +
    scale_fill_viridis_c(na.value = "transparent") +
    theme_minimal()
  return(map)
}

######
mapviz(all, IMP)
mapviz(all, observations)
mapviz(all, species)
mapviz(all, speciesPobs)

######
mapviz(birds, IMP)
mapviz(birds, observations)
mapviz(birds, species)
mapviz(birds, speciesPobs)

######
mapviz(vasc, IMP)
mapviz(vasc, observations)
mapviz(vasc, species)
mapviz(vasc, speciesPobs)

######
mapviz(inver, IMP)
mapviz(inver, observations)
mapviz(inver, species)
mapviz(inver, speciesPobs)
