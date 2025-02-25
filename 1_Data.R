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

############ Prepare data ----

###### Load all .csv files from data_dir
files <- list.files(paste0(DATA_PATH, "/_Julian/LUGA-expo-DATA"), full.names = TRUE, pattern="*.csv")
mdata <- do.call(rbind, lapply(files, function(x) read.csv(x, encoding="latin1"))) #4.5min

###### Keep only observations with species ID and coordinates
mdata <- mdata[complete.cases(mdata$Lat),]
mdata <- mdata[complete.cases(mdata$Long),]
mdata <- mdata[complete.cases(mdata$preferred),]

############ Select only data from 01/01/2005 ----

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

############ Make them an sf objects and clean up ----

### Switch to sf class
post04_sf <- st_as_sf(post04, coords = c("Long", "Lat"), crs = 4326)

### Limit to Luxembourg centroids
# Download boundary
country_borders <- geoboundaries("Luxembourg", adm_lvl = 0)
# Change the CRS
country_borders_2169 <- st_transform(country_borders, 2169)
# Remove areas outside Luxembourg
post04_sf <- st_intersection(post04_sf, country_borders)

# Change CRS
post04_sf <- st_transform(post04_sf, 2169)

############ Select only birds ----
post04_birds_sf <- post04_sf[post04_sf$Taxon_Class=="Aves",]

############ Select only vascular plants ----
post04_vasc_sf <- post04_sf[post04_sf$Taxon_Phylum%in%c("Lycopodiophyta", "Magnoliophyta",
                                               "Pinophyta", "Pteridophyta", "Tracheophyta"),]
############ Select only invertebrates ----
animals <- post04_sf[post04_sf$Taxon_Kingdom=="Animalia",]
post04_inver_sf <- animals[!(animals$Taxon_Class%in%c("Mammalia", "Aves", "Amphibia",
                                                 "Actinopterygii", "Agnatha",
                                                 "Osteichthyes", "Reptilia")),]
############ Neobiota ----
####### Load list
neobiota <- read.csv(paste0(DATA_PATH,"/_ENV_DATA_LUX/neobiota_recorder_list.csv"), encoding="latin1")
####### Keep only rows of original dataset that have their species name in list
post04_neo_sf <- post04_sf[post04_sf$preferred%in%neobiota$ITEM_NAME,]

############ Save ready-to-use spatial objects ----
save(post04_sf, post04_birds_sf, post04_vasc_sf, post04_inver_sf, post04_neo_sf , country_borders_2169, file=paste0(DATA_PATH, "/_Julian/LUGA-expo-DATA/OriginalData.RData"))

beep(4)

