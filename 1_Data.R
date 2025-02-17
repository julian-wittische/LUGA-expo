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

###### Keep only observations with species ID and coordinates
mdata <- mdata[complete.cases(mdata$Lat),]
mdata <- mdata[complete.cases(mdata$Long),]
mdata <- mdata[complete.cases(mdata$preferred),]

############ Laura's wishlist ----

###### Select only data from 01/01/2005

post04 <- mdata
### Try parsing based on the two formats present in the dataset
post04$date_end <- parse_date_time(post04$date_end, orders = c("d/m/Y", "Y-m-d"))
table(is.na(post04$date_end))

### Identify rows where parsing failed and replace them by the first date in the Sample_Date column
post04[is.na(post04$date_end), "date_end"] <- parse_date_time(str_sub(post04[is.na(post04$date_end), "Sample_Date"], -10, -1), orders = c("Y-m-d"))
# Checkpoint
which(is.na(post04$date_end))
### Subset by date
post04 <- subset(post04, date_end >= as.Date("01/01/2005", "%d/%m/%Y"))

###### Select only birds
post04_birds <- post04[post04$Taxon_Class=="Aves",]
# Checkpoint
dim(post04_birds)

###### Select only vascular plants
plants <- post04[post04$Taxon_Kingdom=="Plantae",]
table(plants$Taxon_Phylum)
### Choose the right ones
post04_vasc <- post04[post04$Taxon_Phylum%in%c("Lycopodiophyta", "Magnoliophyta",
                                               "Pinophyta", "Pteridophyta", "Tracheophyta"),]
# Checkpoint
dim(post04_vascu)

###### Select only invertebrates
animals <- post04[post04$Taxon_Kingdom=="Animalia",]
post04_inver <- post04[!(animals$Taxon_Class%in%c("Mammalia", "Aves", "Amphibia",
                                                 "Actinopterygii", "Agnatha",
                                                 "Osteichthyes", "Reptilia")),]
# Checkpoint
dim(post04_inver)

###### Make them an sf objects
post04_sf <- st_as_sf(post04, coords = c("Long", "Lat"), crs = 4326)
post04_birds_sf <- st_as_sf(post04_birds, coords = c("Long", "Lat"), crs = 4326)
post04_vasc_sf <- st_as_sf(post04_vasc, coords = c("Long", "Lat"), crs = 4326)
post04_inver_sf <- st_as_sf(post04_inver, coords = c("Long", "Lat"), crs = 4326)

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

