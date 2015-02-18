#Install
#install.packages("jsonlite", repos="http://cran.r-project.org")
#install.packages("httr")

#load
require(jsonlite)
require(httr)
require(RCurl)

START_YEAR <- '2006'
#END_YEAR <- '2015'
END_YEAR <- as.numeric(format(Sys.Date(), "%Y"))
UNEMPLOYMENT_SERIES_ID <- c('LNS14000000')
BLS_API_KEY <- '9ec4fb8261624813883cc86a80847310'

# Use the current date as the end time for analysis 
curDate <- Sys.Date()

# Dates to represent 30, 60, 90 days from the end Time. 
minus30 <- curDate - 30
minus60 <- curDate - 60
minus90 <- curDate - 90
minus180 <- curDate - 180
minus365 <- curDate - 365


# if unemploymentData has not been initialized, make it null
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
  
}else{
  print("Skipping BLS query")
  cat('Start Year: ', START_YEAR, '\n')
  cat('End Year: ', END_YEAR, '\n')
}

# sorted in ascending order for the purpose of plotting
unEmploymentSorted <- unEmploymentSubData[order(unEmploymentSubData$date, decreasing = FALSE), ]

# sorted decreasing to make it easier on finding periodic info
unEmploymentSortedDecreasing <- unEmploymentSubData[order(unEmploymentSubData$date, decreasing = TRUE), ]

# Logical vector to grab the quarterly dates
#qrtMonths = format(unEmploymentSorted$date, '%m') %in% c('01', '04', '07', '10') & format(unEmploymentSorted$date, '%d') == '01'
qrtMonths = format(unEmploymentSorted$date, '%m') %in% c('01', '07') & format(unEmploymentSorted$date, '%d') == '01'

unemploymentRatePlot <- function(periodStartDate, periodEndDate, plotTitle){
  
  #reset any layout settings, etc.
  dev.off()
  
  #plot(unEmploymentSorted$value, type="o", ann=FALSE, xlab='Date', yaxt='n', xaxt='n', col=2)
  plot(x=unEmploymentSorted$date, y=unEmploymentSorted$value, type="l", ann=FALSE, xlab='Date', yaxt='n', xaxt='n', col=2,
       xlim=c(periodStartDate,periodEndDate))
  
  title(ylab="Unemployment Rate (%)", main = plotTitle)
  
  #axis(1, at=unEmploymentSorted$date[qrtMonths], labels=format(unEmploymentSorted$date[qrtMonths], '%b-%y'))
  axis(1, at=unEmploymentSorted$date[qrtMonths], labels=format(unEmploymentSorted$date[qrtMonths], '%b-%y'),  srt=45, las=2)
  axis(2, las=1)
  abline(v=unEmploymentSorted$date[qrtMonths], col='grey', lwd=0.5)
  
  box()
}

employmentRateChange <- function(periodStartDate, periodEndDate){
  
  periodStartRate <- unEmploymentSortedDecreasing[which.max(unEmploymentSortedDecreasing$date <= as.Date(periodStartDate)), ]
  periodEndRate <- unEmploymentSortedDecreasing[which.max(unEmploymentSortedDecreasing$date <= as.Date(periodEndDate)), ]
  
  periodPercentChange <- periodEndRate$value - periodStartRate$value
  
  print(paste0("Returns for the period of ", periodStartRate$date, " - ", periodEndRate$date, ":"))
  print(periodPercentChange)
  
  return(periodPercentChange)
}

#this one doesn't make sense. It will usually be the same month == 0
#minus30Rate <- employmentRateChange(minus30, curDate)
minus60Rate <- employmentRateChange(minus60, curDate)
minus90Rate <- employmentRateChange(minus90, curDate)
minus180Rate <- employmentRateChange(minus180, curDate)
minus365Rate <- employmentRateChange(minus365, curDate)

unemploymentRatePlot(minus365, endTime, "365 Day Unemployment")