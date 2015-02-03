#Install
#install.packages("jsonlite", repos="http://cran.r-project.org")
#install.packages("httr")

#load
library(jsonlite)
library(httr)
library(RCurl)

START_YEAR <- '2000'
END_YEAR <- '2014'
UNEMPLOYMENT_SERIES_ID <- c('LNS14000000')
BLS_API_KEY <- '9ec4fb8261624813883cc86a80847310'

if(!exists("unemploymentData"))
  unemploymentData <- NULL

#If unemploymentData is null or the year range goes from start year to end year, do not query the BLS
# ---- can run out of daily allowed requests for a given API
if(is.null(unemploymentData) || START_YEAR != min(unEmploymentSubData$year) || END_YEAR != max(unEmploymentSubData$year)){
  # Query the Bureau of Labor Statistcs for Unemployment Data
  payload <- list('seriesid'=UNEMPLOYMENT_SERIES_ID, 'startyear'=unbox(START_YEAR), 
                  'endyear'=unbox(END_YEAR), 'registrationKey'=unbox(BLS_API_KEY))
  
  h = basicTextGatherer()
  h$reset()
  curlPerform(url='http://api.bls.gov/publicAPI/v2/timeseries/data/', 
              httpheader=c('Content-Type' = "application/json;"),
              postfields=toJSON(payload),   
              writefunction = h$update,
              verbose = TRUE)
  
  response <- h$value()
  
  # TODO: Support multiple series - currently only working with unemployment rates, without the ability
  # to filter or organize for other data
  
  #Collection and getting right to the data we care about
  unemploymentData <- fromJSON(response)
  unemploymentData <- unemploymentData$Results$series[2][1,1]
  unemploymentData <- unemploymentData[[1]] 
  
  #subset we care about (year, month, value)
  unEmploymentSubData <- unemploymentData[c("year", "periodName", "value")]
  unEmploymentSubData$value <- as.numeric(unEmploymentSubData$value)
  unEmploymentSubData$date <- as.Date(paste("1", unEmploymentSubData$periodName, unEmploymentSubData$year, sep=" "), format = "%d %B %Y")
  
  #orderRate <- order(unEmploymentSubData$date)
  unEmploymentSorted <- unEmploymentSubData[order(unEmploymentSubData$date, decreasing = FALSE), ]
  #reverse it - not good enough... need to sort by date
  #r_unEmploymentSubData <- unEmploymentSubData[rev(seq_len(nrow(unEmploymentSubData))), ]
}else{
  print("Skipping BLS query")
  cat('Start Year: ', START_YEAR, '\n')
  cat('End Year: ', END_YEAR, '\n')
}

# Logical vector to grab the quarterly dates
#qrtMonths = format(unEmploymentSorted$date, '%m') %in% c('01', '04', '07', '10') & format(unEmploymentSorted$date, '%d') == '01'
qrtMonths = format(unEmploymentSorted$date, '%m') %in% c('01', '07') & format(unEmploymentSorted$date, '%d') == '01'

#plot(unEmploymentSorted$value, type="o", ann=FALSE, xlab='Date', yaxt='n', xaxt='n', col=2)
plot(x=unEmploymentSorted$date, y=unEmploymentSorted$value, type="l", ann=FALSE, xlab='Date', yaxt='n', xaxt='n', col=2)
title(ylab="Unemployment Rate (%)")

#axis(1, at=unEmploymentSorted$date[qrtMonths], labels=format(unEmploymentSorted$date[qrtMonths], '%b-%y'))
axis(1, at=unEmploymentSorted$date[qrtMonths], labels=format(unEmploymentSorted$date[qrtMonths], '%b-%y'),  srt=45, las=2)
axis(2, las=1)
abline(v=unEmploymentSorted$date[qrtMonths], col='grey', lwd=0.5)

box()


