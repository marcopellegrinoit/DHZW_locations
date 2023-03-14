library(dplyr)
library(readr)
library(this.path)
library(sf)

setwd(this.dir())
setwd('data/raw')

df_sport <- st_read('BAG_sport')

df_sport <- st_transform(df_sport, 4326)

################################################################################
# retrieve coordinates from the geometry because the original ones are incomplete
df_sport$coordinate_y <- st_coordinates(df_sport)[, 2]
df_sport$coordinate_x <- st_coordinates(df_sport)[, 1]

df_sport <- data.frame(df_sport)

df_sport = subset(df_sport, select = -c(geometry))

df_sport <- df_sport %>%
  select(PC6, PC4, coordinate_y, coordinate_x)

df_sport$lid <- paste0('sport_', seq.int(nrow(df_sport)))

setwd(this.dir())
setwd('data/output')

write.csv(df_sport, 'sport_DHZW.csv', row.names = FALSE)