library(dplyr)
library(readr)
library(this.path)
library(sf)

setwd(this.dir())
setwd('data')

df_retail <- st_read('buildings_retail')
df_office <- st_read('buildings_office')

df_work <- rbind(df_retail, df_office)

df_work <- st_transform(df_work, "+proj=longlat +datum=WGS84")

################################################################################
# retrieve coordinates from the geometry because the original ones are incomplete
df_coordinates <- data.frame(st_coordinates(df_work))
colnames(df_coordinates) <- c('longitude', 'latitude')
df_work = cbind(df_work, df_coordinates)
df_work <- data.frame(df_work)
df_work = subset(df_work, select = -c(geometry))

df_work <- df_work %>%
  select(PC6, PC4, longitude, latitude)

df_work$type <- 'work'
df_work$lid <- paste0('work_', seq.int(nrow(df_work)))

write.csv(df_work, 'work_DHZW.csv', row.names = FALSE)