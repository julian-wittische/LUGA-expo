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
load(paste0(DATA_PATH, "/_Julian/LUGA-expo-DATA/ready.RData"))

###### Imperviousness
# This must be done every time
IMP <- rast(paste0(DATA_PATH,"/_ENV_DATA_LUX/RastersLuxHighestResolution/LUX_IMP_10m.grd"))

### Use a mask with a reformatted sf object
IMP_lux <- mask(IMP, vect(country_borders_2169), touches = TRUE) #inclusive

############ General function to be used on whatever species group ----
bio_metrics <- function(df){
  
###### "Sampling unit" ----
### Create hexagonal grid
grid <- st_make_grid(df, what = "polygons", cellsize = 800, square = FALSE)
grid_sf <- st_sf(geometry = grid)
grid_sf

### Add dummy variable
grid_sf$hex_id <- 1:nrow(grid_sf)
#### Add IMP average per hexagon  
grid_sf$IMP <- exact_extract(IMP_lux, grid_sf, 'mean')

### Filter out empty hexagons
grid_sf <- grid_sf %>% 
  filter(!is.na(IMP))

###### Number of observations ----

### Count points in each hexagon
grid_sf$observations <- lengths(st_intersects(grid_sf, df))

### Filter out empty hexagons
grid_sf <- grid_sf %>% 
  filter(!is.na(IMP))

###### Number of species ----

### Assign points to hexagons (spatial join)
df <- st_join(df, grid_sf, join = st_intersects)

### Count the number of unique species per hexagon
species <- df %>%
  st_drop_geometry() %>% 
  group_by(hex_id = df$hex_id) %>% # Replace 'id' with your grid_sf identifier field
  summarize(species = n_distinct(preferred))

### Add the counts to the hexagonal grid
grid_sf <- grid_sf %>%
  left_join(species, by = c("hex_id" = "hex_id"))

### Set NAs as 0 (0 observation lead to NA)
grid_sf$species[is.na(grid_sf$species)] <- 0

###### Species / Observations ratio ----

### Create ratio and add it to variable
grid_sf$speciesPobs <- grid_sf$species/grid_sf$observations
return(grid_sf)

}

all <- bio_metrics(post04_sf)
birds <- bio_metrics(post04_birds_sf)
vasc <- bio_metrics(post04_vasc_sf)
inver <- bio_metrics(post04_inver_sf)
