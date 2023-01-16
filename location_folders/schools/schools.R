library("this.path")
library(dplyr)
library (readr)
library(sf)

################################################################################
# This script filters the municipality school dataset (source) and prepare it for the simulation

################################################################################
# Load and filter DHZW

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
df_schools <- st_read('schoolgebouwen')

df_schools <- df_schools %>%
  select(bestemming,
         school,
         postcode) %>%
  rename(level = bestemming,
         name = school,
         PC6 = postcode) %>%
  mutate(PC6 = gsub(' ', '', PC6)) %>%
  mutate(PC4 = gsub('.{2}$', '', PC6)) %>%
  filter(PC4 %in% DHZW_PC4_codes)

# Transform into WGS84
df_schools <- st_transform(df_schools, "+proj=longlat +datum=WGS84")

################################################################################
# retrieve coordinates from the geometry because the original ones are incomplete
df_coordinates <- data.frame(st_coordinates(df_schools))
colnames(df_coordinates) <- c('longitude', 'latitude')
df_schools = cbind(df_schools, df_coordinates)
df_schools <- data.frame(df_schools)
df_schools = subset(df_schools, select = -c(geometry))

df_schools$type <- 'school'
df_schools$lid <- paste0('school_', seq.int(nrow(df_schools)))

################################################################################
# Manually assign the categories

df_schools$category <- NA
df_schools[df_schools$level == 'BO',]$category <- 'primary_school'
df_schools[df_schools$level == 'VO' | df_schools$level == 'GYM',]$category <- 'highschool'
df_schools[df_schools$level == 'BO-Voorschool',]$category <- 'daycare'

df_schools <- df_schools %>%
  filter(!is.na(category)) %>%
  subset(select = -c(type))

write.csv(df_schools, 'schools_DHZW.csv', row.names = FALSE)