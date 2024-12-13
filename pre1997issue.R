### Solve pre 1997 data loading problem

### Data directory
DATA_PATH <- "W:/01_Services/SCR_Informations Patrimoine Naturel/_Julian/PlantDivLuxExpo"

pre97 <- read.csv(paste0(DATA_PATH,"/-1997.csv"), encoding="Windows-1252")
# BIG PROBLEMS

# JW made four changes (see Notepad file for details):
# 1) Manual re-import with Windows 1252 encoding in Excel
# 2) Manual change of observation #317678
# 3) Manual change of observation #425796
# 4) Manual change of observation #426700

pre97 <- read.csv(paste0(DATA_PATH,"/-1997MODIF2.csv"), encoding="Windows-1252")
# WORKS

# Keep only strict minimum columns
mdata <- mdata[,c("Lat", "Long", "preferred",
                  "Taxon_Kingdom", "Taxon_Phylum",
                  "Taxon_Class", "Taxon_Order",
                  "Taxon_Family", "Taxon_Genus")]

mdata <- mdata[complete.cases(mdata$Lat),]
mdata <- mdata[complete.cases(mdata$Long),]
mdata <- mdata[complete.cases(mdata$preferred),]

all_points <- st_as_sf(mdata, coords = c("Long", "Lat"),
                       crs = 4326)
all_points <- st_transform(all_points, 2169)
all_points