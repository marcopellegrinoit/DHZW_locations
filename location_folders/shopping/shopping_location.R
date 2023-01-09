library(dplyr)
library(readr)
library(this.path)
library(sf)

setwd(this.dir())
setwd('data')

df_retail <- st_read('BAG_retail')

################################################################################
# retrieve coordinates from the geometry because the original ones are incomplete
df_coordinates <- data.frame(st_coordinates(df_retail))
colnames(df_coordinates) <- c('longitude', 'latitude')
df_retail = cbind(df_retail, df_coordinates)
df_retail <- data.frame(df_retail)
df_retail = subset(df_retail, select = -c(geometry))

df_retail <- df_retail %>%
  select(PC6, PC4, longitude, latitude)

write.csv(df_retail, 'shopping_DHZW.csv', row.names = FALSE)