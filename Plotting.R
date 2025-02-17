################################################################################
# GOAL: explore plant diversity in Luxembourg and relate it to human footprint #
################################################################################
# Author: Julian Wittische (Musée National d'Histoire Naturelle Luxembourg)
# Request: Laura Daco/Thierry Helminger
# Start: Winter 2024
# Data: MDATA
################################################################################
# Script purpose: plotting of plant and environmental spatial data
################################################################################

############ RUN ONCE (CHANGE DATA PATHS)
#source("Preprocessing.R")

############ Libraries
library(sf) # keep: vector GIS
library(terra) # keep: raster GIS
library(exactextractr) # keep: extract at locations

############ Preprocessed data
IMP_terra <- readRDS("./LUGA-expo-DATA/IMP_lux.RDS")
plants_sf1 <- readRDS("./LUGA-expo-DATA/plants_sf.RDS")



################################################################################
plants_sf <- plants_sf1
############ "Sampling unit"

### Create hexagonal grid
grid <- st_make_grid(plants_sf, what = "polygons", cellsize = 2500, square = FALSE)
grid_sf <- st_sf(geometry = grid)
### Add dummy variable
grid_sf$hex_id <- 1:nrow(grid_sf)
#### Add IMP average per hexagon  
grid_sf$IMP <- exact_extract(IMP_terra, grid_sf, 'mean')

### Filter out empty hexagons
grid_sf <- grid_sf %>% 
  filter(!is.na(IMP))

############ Visualize impervious surface
ggplot() +
  geom_sf(data = grid_sf, aes(fill = IMP), color = NA) +
  scale_fill_viridis_c(na.value = "transparent") +
  theme_minimal()

############ Number of observations

### Count points in each hexagon
grid_sf$observations <- lengths(st_intersects(grid_sf, plants_sf))

### Filter out empty hexagons
grid_sf <- grid_sf %>% 
  filter(!is.na(IMP))

# ### Count the number of unique species per hexagon
# observations <- plants_sf %>%
#   st_drop_geometry() %>% 
#   group_by(hex_id = plants_sf$hex_id) %>% # Replace 'id' with your grid_sf identifier field
#   summarize(observations = n_distinct(preferred))

### Visualize observations
ggplot() +
  geom_sf(data = grid_sf, aes(fill = observations), color = NA) +
  scale_fill_viridis_c(na.value = "transparent") +
  theme_minimal() # there are a few hexagons with 0 observations (cellsize=1000)

############ Number of species

### Assign points to hexagons (spatial join)
plants_sf <- st_join(plants_sf, grid_sf, join = st_intersects)

### Count the number of unique species per hexagon
species <- plants_sf %>%
  st_drop_geometry() %>% 
  group_by(hex_id = plants_sf$hex_id) %>% # Replace 'id' with your grid_sf identifier field
  summarize(species = n_distinct(preferred))

### Add the counts to the hexagonal grid
grid_sf <- grid_sf %>%
  left_join(species, by = c("hex_id" = "hex_id"))

### Set NAs as 0 (0 observation lead to NA)
grid_sf$species[is.na(grid_sf$species)] <- 0

### Visualize species
ggplot(grid_sf) +
  geom_sf(aes(fill = species)) +
  scale_fill_viridis_c(na.value = "transparent") +
  theme_minimal()

############ Species / Observations ratio

### Create ratio and add it to variable
grid_sf$speciesPobs <- grid_sf$species/grid_sf$observations

### Visualize species/obs ratio
ggplot(grid_sf) +
  geom_sf(aes(fill = speciesPobs)) +
  scale_fill_viridis_c(na.value = "transparent") +
  theme_minimal()

mod <- lm(speciesPobs ~ IMP, data= grid_sf)
summary(mod)

ggplot(grid_sf, aes(x = IMP, y = observations)) + 
  geom_point() +
  stat_smooth(method = "loess", col = "red")

ggplot(grid_sf, aes(x = IMP, y = species)) + 
  geom_point() +
  stat_smooth(method = "loess", col = "red")

ggplot(grid_sf, aes(x = IMP, y = speciesPobs)) + 
  geom_point() +
  stat_smooth(method = "loess", col = "red")

# 
grid_sf_50 <- grid_sf %>% 
  filter(IMP<10)

ggplot(grid_sf_50, aes(x = IMP, y = observations)) + 
  geom_point() +
  stat_smooth(method = "loess", col = "red")

ggplot(grid_sf_50, aes(x = IMP, y = species)) + 
  geom_point() +
  stat_smooth(method = "loess", col = "red")

ggplot(grid_sf_50, aes(x = IMP, y = speciesPobs)) + 
  geom_point() +
  stat_smooth(method = "lm", col = "red")

mod <- lm(speciesPobs ~ IMP, data= grid_sf_50)
summary(mod)
