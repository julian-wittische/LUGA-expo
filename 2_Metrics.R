######################## PROJECT: LUGA expo analysis
# Author: Julian Wittische (Musée National d'Histoire Naturelle Luxembourg)
# Request: Laura Daco/Thierry Helminger
# Start: Spring 2025
# Data: MNHNL
# Script objective : Calculate biodiversity metrics

############ Local configuration ----
source("config.R")

############ Loading libraries ----
source("0_Libraries.R")

############ Loading data ----

###### Biodiversity data
# This comes from 1_Data.R
load(paste0(DATA_PATH, "/_Julian/LUGA-expo-DATA/OriginalData.RData"))

###### Imperviousness
# This must be done every time
IMP <- rast(paste0(DATA_PATH,"/_ENV_DATA_LUX/RastersLuxHighestResolution/LUX_IMP_10m.grd"))

### Use a mask with a reformatted sf object
IMP_lux <- mask(IMP, vect(country_borders_2169), touches = TRUE) #inclusive

############ Calculating metrics ----
all <- bio_metrics(post04_sf)
birds <- bio_metrics(post04_birds_sf)
vasc <- bio_metrics(post04_vasc_sf)
inver <- bio_metrics(post04_inver_sf)
neo <- bio_metrics(post04_neo_sf)

############ Save ready-to-use spatial objects ----
save(all, birds, vasc, inver, neo, file=paste0(DATA_PATH, "/_Julian/LUGA-expo-DATA/Metrics.RData"))
