######################## PROJECT: LUGA expo analysis
# Author: Julian Wittische (Musée National d'Histoire Naturelle Luxembourg)
# Request: Laura Daco/Thierry Helminger
# Start: Spring 2025
# Data: MNHNL
# Script objective : Model the relationship between imperviousness and biodiv metrics

############ Loading metrics ----
# This comes from 2_Metrics.R
load(paste0(DATA_PATH, "/_Julian/LUGA-expo-DATA/Metrics.RData"))

############ All
mod <- lm(observations ~ IMP, data=all)
summary(mod)

mod <- lm(species ~ IMP, data=all)
summary(mod)

mod <- lm(speciesPobs ~ IMP, data=all)
summary(mod)

ggplot(all, aes(x = IMP, y = speciesPobs)) + 
  geom_point() +
  stat_smooth(method = "loess", col = "red")

ggplot(all, aes(x = IMP, y = speciesPobs)) + 
  geom_point() +
  stat_smooth(method = "lm", col = "red")

ggplot(all2, aes(x = IMP, y = speciesPobs)) + 
  geom_point() +
  stat_smooth(method = "lm", col = "red")


############ Birds
mod <- lm(observations ~ IMP, data=birds)
summary(mod)

mod <- lm(species ~ IMP, data=birds)
summary(mod)

mod <- lm(speciesPobs ~ IMP, data=birds)
summary(mod)

ggplot(birds, aes(x = IMP, y = speciesPobs)) + 
  geom_point() +
  stat_smooth(method = "loess", col = "red")

ggplot(birds, aes(x = IMP, y = speciesPobs)) + 
  geom_point() +
  stat_smooth(method = "lm", col = "red")

############ Vascular plants
mod <- lm(observations ~ IMP, data=vasc)
summary(mod)

mod <- lm(species ~ IMP, data=vasc)
summary(mod)

mod <- lm(speciesPobs ~ IMP, data=vasc)
summary(mod)

ggplot(vasc, aes(x = IMP, y = speciesPobs)) + 
  geom_point() +
  stat_smooth(method = "loess", col = "red")

ggplot(vasc, aes(x = IMP, y = speciesPobs)) + 
  geom_point() +
  stat_smooth(method = "lm", col = "red")

############ Invertebrates 
mod <- lm(observations ~ IMP, data=inver)
summary(mod)

mod <- lm(species ~ IMP, data=inver)
summary(mod)

mod <- lm(speciesPobs ~ IMP, data=inver)
summary(mod)

ggplot(inver, aes(x = IMP, y = speciesPobs)) + 
  geom_point() +
  stat_smooth(method = "loess", col = "red")

ggplot(inver, aes(x = IMP, y = speciesPobs)) + 
  geom_point() +
  stat_smooth(method = "lm", col = "red")




