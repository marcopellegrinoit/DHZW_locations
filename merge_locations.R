library(this.path)
library(readr)

################################################################################
# Load

# Load home locations
setwd(paste0(this.dir(), '/data/home'))
df_home$type <- 'home'

# Load school locations
setwd(paste0(this.dir(), '/data/schools'))
df_school <- read.csv('schools_DHZW.csv')
df_school$type <- 'home'

# Load shopping locations
setwd(paste0(this.dir(), '/data/shopping'))
df_shopping$type <- 'shopping'

# Load work locations
setwd(paste0(this.dir(), '/data/work'))
df_work$type <- 'work'

# Load sport locations
setwd(paste0(this.dir(), '/data/sport'))
df_sport$type <- 'sport'

################################################################################
# Merge and add location ID

df <- rbind(df_school, df_shopping, df_work, df_sport)

df$lid <- seq.int(nrow(df))

write.csv(df, 'locations_DHZW.csv')