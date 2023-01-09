library(this.path)
library(readr)
library(sf)
library(dplyr)

# Ideally, I would use the BAG dataset to assign a precise home. However, the households generation produced more households than the ones in BAG. Hence, I am using the centroid of the PC6.

# Load household
setwd(this.dir())
setwd('../../../DHZW_synthetic-population/output/synthetic-population-households/4_car_2022-12-26_15-50')

df_households <- read.csv('df_households_DHZW_2019.csv')

# Load PC6
setwd(this.dir())
setwd('../../../DHZW_synthetic-population/data/shapefiles/processed')
df_PC6 <- st_read('DHZW_PC6_shapefiles')

# Transform into WGS84
df_PC6 <- st_transform(df_PC6, "+proj=longlat +datum=WGS84")

# compute the centroid

df_centroid_PC6 <- st_centroid(df_PC6)
df_coordinates <- data.frame(st_coordinates(df_centroid_PC6))
colnames(df_coordinates) <- c('longitude', 'latitude')
df_PC6 = cbind(df_PC6, df_coordinates)
df_PC6 <- data.frame(df_PC6)
df_PC6 = subset(df_PC6, select = -c(geometry))

# Manually add missing PC6
unique(df_households[! df_households$PC6 %in% df_PC6$PC6,]$PC6)

df_PC6[nrow(df_PC6) + 1,] = c("2542RK", 4.2777, 52.0391)
df_PC6[nrow(df_PC6) + 1,] = c("2543SH", 4.2609, 52.0432)
df_PC6[nrow(df_PC6) + 1,] = c("2545XJ", 4.2677, 52.0515)

unique(df_households[! df_households$PC6 %in% df_PC6$PC6,]$PC6)

# assign coordinates to households
df_households <- merge(df_households, df_PC6, by = 'PC6')

# Save dataset
setwd(this.dir())
setwd('data')

write.csv(df_households, 'df_households_coordinates.csv')

df_households$type <- 'home'
df_households$lid <- paste0('home_', seq.int(nrow(df_households)))
df_households <- df_households %>%
  select(hh_ID, lid, PC6, type, longitude, latitude)

write.csv(df_households, 'df_households_locations.csv')