library(dplyr)
library(readr)
library(this.path)
library(sf)

setwd(this.dir())
setwd('data/raw')

df_retail <- st_read('BAG_retail')
df_office <- st_read('BAG_office')

df_work <- rbind(df_retail, df_office)

df_work <- st_transform(df_work, 4326)

################################################################################
# retrieve coordinates from the geometry because the original ones are incomplete

df_work$coordinate_y <- st_coordinates(df_work)[, 2]
df_work$coordinate_x <- st_coordinates(df_work)[, 1]

df_work <- data.frame(df_work)

df_work = subset(df_work, select = -c(geometry))

df_work <- df_work %>%
  select(PC6, PC4, coordinate_y, coordinate_x)

df_work$lid <- paste0('work_', seq.int(nrow(df_work)))

setwd(this.dir())
setwd('data/output')
write.csv(df_work, 'work_DHZW.csv', row.names = FALSE)