library(dplyr)
library(readr)
library(this.path)
library(sf)

setwd(this.dir())
setwd('data')

df_sport <- st_read('BAG_sport')

################################################################################
# retrieve coordinates from the geometry because the original ones are incomplete
df_coordinates <- data.frame(st_coordinates(df_sport))
colnames(df_coordinates) <- c('longitude', 'latitude')
df_sport = cbind(df_sport, df_coordinates)
df_sport <- data.frame(df_sport)
df_sport = subset(df_sport, select = -c(geometry))

df_sport <- df_sport %>%
  select(PC6, PC4, longitude, latitude)

write.csv(df_sport, 'sport_DHZW.csv', row.names = FALSE)