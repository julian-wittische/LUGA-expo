######################## PROJECT: LUGA expo analysis
# Author: Julian Wittische (Musée National d'Histoire Naturelle Luxembourg)
# Request: Laura Daco/Thierry Helminger
# Start: Spring 2025
# Data: MNHNL
# Script objective : Load and clean up data

############ Local configuration ----
source("config.R")

############ Loading libraries ----
source("0_Libraries.R")

############ Loading data ----

###### Load all .csv files from data_dir
files <- list.files(DATA_PATH, full.names = TRUE, pattern="*.csv")
mdata <- do.call(rbind, lapply(files, function(x) read.csv(x, encoding="latin1"))) #4.5min
beep(4)

############ Laura's wishlist ----

###### Select only data from 01/01/2005

post2004 <- mdata
### Try parsing based on the two formats present in the dataset
post2004$date_end <- parse_date_time(post2004$date_end, orders = c("d/m/Y", "Y-m-d"))
table(is.na(post2004$date_end))

### Identify rows where parsing failed and replace them by the first date in the Sample_Date column
post2004[is.na(post2004$date_end), "date_end"] <- parse_date_time(str_sub(post2004[is.na(post2004$date_end), "Sample_Date"], -10, -1), orders = c("Y-m-d"))
# Checkpoint
which(is.na(post2004$date_end))
### Subset by date
post2004 <- subset(post2004, date_end >= as.Date("01/01/2005", "%d/%m/%Y"))





### Keep only strict minimum columns
mini <- mdata[,c("Lat", "Long", "date_start", "preferred",
                 "Taxon_Kingdom", "Taxon_Phylum",
                 "Taxon_Class", "Taxon_Order",
                 "Taxon_Family", "Taxon_Genus")]

### Keep only observations with species ID and coordinates
mini <- mini[complete.cases(mini$Lat),]
mini <- mini[complete.cases(mini$Long),]
mini <- mini[complete.cases(mini$preferred),]

### Keep only plants
plants <- mini[mini$Taxon_Kingdom=="Plantae",]

### Make it an sf object
plants_sf <- st_as_sf(plants, coords = c("Long", "Lat"), crs = 4326)

### Limit to Luxembourg centroids
# Download boundary
country_borders <- geoboundaries("Luxembourg", adm_lvl = 0)
# Check CRS
st_crs(country_borders)
plants_sf <- st_intersection(plants_sf, country_borders)
country_borders_2169 <- st_transform(country_borders, 2169)
plants_sf <- st_transform(plants_sf, 2169)
plants_sf <- st_intersection(plants_sf, country_borders_2169)

# Export in a GIS friendly format
saveRDS(plants_sf, file="W:/01_Services/SCR_Informations Patrimoine Naturel/_Julian/PlantDivLuxExpo/plants_sf.RDS")
#FOR ESRI: write_sf(plants_sf, "LUX_PLANTS.shp")

############ Loading of ready-to-use spatial objects

IMP <- rast("./_ENV_DATA_EUROPE/RastersLuxHighestResolution/LUX_IMP_10m.grd")
### Use a mask with a reformatted sf object

IMP_lux <- mask(IMP, vect(country_borders_2169), touches = TRUE) #inclusive
saveRDS(IMP_lux, file="W:/01_Services/SCR_Informations Patrimoine Naturel/_Julian/PlantDivLuxExpo/IMP_lux.RDS")

beep(11)

