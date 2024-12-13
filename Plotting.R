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

############ Libraries
library(sf)
library(terra)
library(exactextractr)
library(ggplot2)

plants_sf <- readRDS("./PlantDivLuxExpo/plants_sf.RDS")
IMP_terra <- readRDS("./PlantDivLuxExpo/IMP_lux.RDS")
# Create hexagonal grid
grid <- st_make_grid(plants_sf, what = "polygons", cellsize = 1000, square = FALSE)
grid_sf <- st_sf(geometry = grid)

# Count points in each hexagon
grid_sf$count <- lengths(st_intersects(grid_sf, plants_sf))
grid_sf$count[grid_sf$count==0] <- NA

# Visualize
ggplot() +
  geom_sf(data = grid_sf, aes(fill = count), color = NA) +
  scale_fill_viridis_c(na.value = "transparent") +
  theme_minimal()

# 
grid_sf$IMP <- exact_extract(IMP_lux, grid_sf, 'mean')
#grid_sf$IMP[grid_sf$IMP==0] <- NA

# Visualize
ggplot() +
  geom_sf(data = grid_sf, aes(fill = IMP), color = NA) +
  scale_fill_viridis_c(na.value = "transparent") +
  theme_minimal()

plot(grid_sf$count, grid_sf$IMP)
mod <- lm(grid_sf$count ~ grid_sf$IMP)
summary(mod)
plot(grid_sf$IMP, grid_sf$count)
abline(mod, col="red")

# Assign points to hexagons (spatial join)
joined <- st_join(points, grid_sf)

# Count unique "preferred" values in each hexagon
unique_counts <- joined %>%
  st_drop_geometry() %>%
  group_by(geometry) %>%
  summarize(unique_preferred = n_distinct(preferred))

# Add the counts to the hexagonal grid
grid_sf <- left_join(grid_sf, unique_counts, by = c("geometry" = "geometry"))

