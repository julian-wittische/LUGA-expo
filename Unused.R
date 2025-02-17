### Keep only strict minimum columns
mini <- mdata[,c("Lat", "Long", "date_start", "preferred",
                 "Taxon_Kingdom", "Taxon_Phylum",
                 "Taxon_Class", "Taxon_Order",
                 "Taxon_Family", "Taxon_Genus")]