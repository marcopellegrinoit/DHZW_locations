library(dplyr)
library(readr)
library(this.path)
library(sf)

setwd(this.dir())
setwd('data/raw')

df_retail <- st_read('BAG_retail')

# Transform into WGS84
df_retail <- st_transform(df_retail, 4326)

################################################################################
# retrieve coordinates from the geometry because the original ones are incomplete
df_retail$coordinate_y <- st_coordinates(df_retail)[, 2]
df_retail$coordinate_x <- st_coordinates(df_retail)[, 1]

df_retail <- data.frame(df_retail)

df_retail = subset(df_retail, select = -c(geometry))

################################################################################

df_retail <- df_retail %>%
  select(PC6, PC4, coordinate_y, coordinate_x)

df_retail$lid <- paste0('shopping_', seq.int(nrow(df_retail)))

setwd(this.dir())
setwd('data/output')

write.csv(df_retail, 'shopping_DHZW.csv', row.names = FALSE)