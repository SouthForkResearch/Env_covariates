#This script processes NOAA environmental data to be merged with stream temperature data and other coavariates 
#for modeling (https://gis.ncdc.noaa.gov/maps/ncei/summaries/daily).  The most central site 
#to the watershed contianing variables of interest is chosen. At times, multiple sites must 
#be used to find all variables. 

#12/21/2017
#Version 1
#Jared siegel

#designate correct working directory
setwd("C:/Users/deraj/Documents/South Fork/Temperature models/Snoqualmie/")
getwd()

#READING NOAA CLIMATE DATA INTO R######################################################################

#Data should be downloaded in metric units.  CSV files downloaded should have the following 
#headers before uploading to r:
#STATION	NAME	LATITUDE	LONGITUDE	ELEVATION DATE	PRCP	SNOW	SNWD	TAVG	TMAX	TMIN	TOBS	WESD

#Key of variable definitions
  #PRCP - precipiation (mm)
  #SNOW - Snow depth (mm)
  #SNWD - snow water equivalent (mm)
  #TAVG - average daily temp (C)
  #TMAX - max daily temp (c)
  #TMIN - min daily temp (c)
  #TOBS - Temperature at the time of observation (c)
  #WESD - Water equivalent of snow on the ground (mm)


#uploading discharge data from working directory.   
Ev.in.all <-read.csv("USS0021B55S.csv")
head(Ev.in.all)


#Create 8 day averages of variables
library(zoo)
Ev.in.all$PRCP_8D <- rollapply(Ev.in.all$PRCP, width = 8, FUN = mean, na.rm = T, fill = NA, align = c("left"))
Ev.in.all$SNOW_8D <- rollapply(Ev.in.all$SNOW, width = 8, FUN = mean, na.rm = T, fill = NA, align = c("left"))
Ev.in.all$SNWD_8D <- rollapply(Ev.in.all$SNWD, width = 8, FUN = mean, na.rm = T, fill = NA, align = c("left"))
Ev.in.all$TAVG_8D <- rollapply(Ev.in.all$TAVG, width = 8, FUN = mean, na.rm = T, fill = NA, align = c("left"))
Ev.in.all$TMAX_8D <- rollapply(Ev.in.all$TMAX, width = 8, FUN = mean, na.rm = T, fill = NA, align = c("left"))
Ev.in.all$TMIN_8D <- rollapply(Ev.in.all$TMIN, width = 8, FUN = mean, na.rm = T, fill = NA, align = c("left"))
Ev.in.all$WESD_8D <- rollapply(Ev.in.all$WESD, width = 8, FUN = mean, na.rm = T, fill = NA, align = c("left"))
head(Ev.in.all)

#create  year, month and Julian day columns
Ev.in.all$DATE <-  as.Date(Ev.in.all$DATE,'%m/%d/%Y')
Ev.in.all$year <- as.numeric(format(Ev.in.all$DATE,'%Y'))
Ev.in.all$month <- as.numeric(format(Ev.in.all$DATE,'%m'))
Ev.in.all$Julian <- as.numeric(strftime(Ev.in.all$DATE, format = "%j"))
#create unique identifier by combining year and Julian
Ev.in.all$year_day <- paste(Ev.in.all$year,"_",Ev.in.all$Julian, sep = "")

#check file
head(Ev.in.all) 

#write csv file back to directory, change name as appropriate
write.csv(Ev.in.all, paste0("Snoq_env_8d.csv"), row.names = FALSE)

#note, file will be subsequently be merged with stream temperature data and covariate data based off of 
#Julian day column for a single year model, or the unique year_day column for a model spanning multiple 
#years.  The merge function will be used for this.    

