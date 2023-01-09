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
setwd('codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv",
           sep = ";" ,
           header = F)$V1

# Load municipality schools
setwd(this.path::this.dir())
setwd('data/schools/')
df_schools <- st_read('schoolgebouwen')

df_schools <- df_schools %>%
  select(bestemming,
         school,
         postcode) %>%
  rename(type = bestemming,
         name = school,
         PC6 = postcode) %>%
  mutate(PC6 = gsub(' ', '', PC6)) %>%
  mutate(PC4 = gsub('.{2}$', '', PC6)) %>%
  filter(PC4 %in% DHZW_PC4_codes)

################################################################################
# retrieve coordinates from the geometry because the original ones are incomplete
df_coordinates <- data.frame(st_coordinates(df_schools))
colnames(df_coordinates) <- c('longitude', 'latitude')
df_schools = cbind(df_schools, df_coordinates)
df_schools <- data.frame(df_schools)
df_schools = subset(df_schools, select = -c(geometry))

################################################################################
# Manually assign the categories

#df_schools$category = ''
#df_schools[df_schools$type == 'SO/VSO' | df_schools$type == 'BO' | df_schools$type == 'BO-Voorschool', ]$category = 'primary school'
#df_schools[df_schools$type == 'VO' | df_schools$type == 'GYM' | df_schools$type == 'Sport', ]$category = 'secondary school'

#df_schools = df_schools %>%
#  select(-c(type)) %>%
#  distinct(name, PC4, category, .keep_all = TRUE)

write.csv(df_schools, 'schools_DHZW.csv', row.names = FALSE)