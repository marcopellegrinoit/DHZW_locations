library("this.path")
library(dplyr)
library (readr)
library(sf)

################################################################################
# This script filters the municipality school dataset (source) and prepare it for the simulation

################################################################################
# Load and filter DHZW

# https://livingatlas-dcdev.opendata.arcgis.com/datasets/esrinl-content::onderwijslocaties-adres/explore?filters=eyJQUk9WSU5DSUUiOlsiWnVpZC1Ib2xsYW5kIl0sIkdFTUVFTlRFTkFBTSI6WyJTIEdSQVZFTkhBR0UiXX0%3D&location=52.053199%2C4.316303%2C14.58

# Load PC4 DHZW
setwd(this.path::this.dir())
setwd('../../codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv",
           sep = ";" ,
           header = F)$V1

# Load municipality schools
setwd(this.path::this.dir())
setwd('data/')
df_schools_esri <- st_read('DUO_Onderwijslocaties')
df_schools_municipality <- st_read('schoolgebouwen')

df_schools_esri <- df_schools_esri %>%
  select(ONDERWIJS,
         INSTELLING,
         POSTCODE) %>%
  rename(level = ONDERWIJS,
         name = INSTELLING,
         PC6 = POSTCODE) %>%
  mutate(PC6 = gsub(' ', '', PC6)) %>%
  mutate(PC4 = gsub('.{2}$', '', PC6)) %>%
  filter(PC4 %in% DHZW_PC4_codes)

df_schools_municipality <- df_schools_municipality %>%
  select(bestemming,
         school,
         postcode) %>%
  rename(level = bestemming,
         name = school,
         PC6 = postcode) %>%
  mutate(PC6 = gsub(' ', '', PC6)) %>%
  mutate(PC4 = gsub('.{2}$', '', PC6)) %>%
  filter(PC4 %in% DHZW_PC4_codes)

################################################################################
# Filter and sssign categories

# Use the municipality dataset for daycare
df_schools_municipality <- df_schools_municipality[df_schools_municipality$level=='BO-Voorschool',]
df_schools_municipality <- st_transform(df_schools_municipality, "+proj=longlat +datum=WGS84")

# Use the ESRI living atlas for primary and highschool
df_schools_esri <- df_schools_esri[df_schools_esri$level=='BO' | df_schools_esri$level=='VBO/MAVO',]
df_schools_esri <- st_transform(df_schools_esri, "+proj=longlat +datum=WGS84")
df_schools_esri <- st_zm (df_schools_esri)

# Put dataset together and reformat school labels
df_schools <- rbind(df_schools_municipality, df_schools_esri)
df_schools$category <- NA
df_schools[df_schools$level == 'BO-Voorschool',]$category <- 'daycare'
df_schools[df_schools$level == 'BO',]$category <- 'primary_school'
df_schools[df_schools$level == 'VBO/MAVO',]$category <- 'highschool'

df_schools <- df_schools %>%
  subset(select = -c(level))

df_schools$type <- 'school'
df_schools$lid <- paste0('school_', seq.int(nrow(df_schools)))

################################################################################
# retrieve coordinates from the geometry

df_coordinates <- data.frame(st_coordinates(df_schools))
colnames(df_coordinates) <- c('longitude', 'latitude')
df_schools = cbind(df_schools, df_coordinates)
df_schools <- data.frame(df_schools)

plot(df_schools$geometry)

################################################################################
# Save
st_write(df_schools, 'schools_DHZW/schools_DHZW.shp')