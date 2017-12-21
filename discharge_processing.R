#This script processes USGS stream gage data to be merged with stream temperature data and coavariates 
#for modelling (https://waterdata.usgs.gov/nwis/rt).  The most downstream gage is generally 
#chosen to provide information for discharge in a watershed.  Care should be taken to ensure that discharge  at other locations in watershed correlates 
#with chosen gae before utilizing gage to represent whole watershed.    

#12/21/2017
#Version 1
#Jared siegel

#designate correct working directory
setwd("C:/Users/deraj/Documents/South Fork/Modis/Wenatchee/")
getwd()

#READING USGS DISCHARGE DATA INTO R######################################################################

#before uploading into r, headers should be added to the downloaded dicharge data and it should be saved
#as a csv file.  Below is an example of the format of the data required for uploading.  Discharge data should 
#include entire time series of available data at this point

  #example for formatting:

#Organization	  gage	    date	    dailymean
#USGS	        12462500	10/1/1962	     894
#USGS	        12462500	10/2/1962	     876
#USGS	        12462500	10/3/1962	     876

#uploading discharge data from working directory.   
Dv.in.all <-read.csv("Wen_discharge_all.csv")
head(Dv.in.all)

#define gage used

#USGS files are in CFS.  Convert CFS to CMS and create new discharge column
Dv.in.all$DV1D <-(Dv.in.all$dailymean)*0.028316846592
head(Dv.in.all)

#Create 8 day averages of discharge
library(zoo)
Dv.in.all$Dv8D <- rollapply(Dv.in.all$DV1D, width = 8, FUN = mean, na.rm = T, fill = NA, align = c("left"))

#create  year, month and Julian day columns
Dv.in.all$date <-  as.Date(Dv.in.all$date,'%m/%d/%Y')
Dv.in.all$year <- as.numeric(format(Dv.in.all$date,'%Y'))
Dv.in.all$month <- as.numeric(format(Dv.in.all$date,'%m'))
Dv.in.all$Julian <- as.numeric(strftime(Dv.in.all$date, format = "%j"))
#create unique identifier by combining year and Julian
Dv.in.all$year_day <- paste(Dv.in.all$year,"_",Dv.in.all$Julian, sep = "")

#check file
head(Dv.in.all) 

#write csv file back to directory
write.csv(Dv.in.all, paste0("Wen_discharge_8d.csv"), row.names = FALSE)

#note, file will be subsequently be merged with stream temperature data and covariate data based off of 
#Julian day column for a single year model, or the unique year_day column for a model spanning multiple 
#years.  The merge function will be used for this.    




