
require(mondate)
require(bizdays)
require(timeDate)

TSP_DATA_FILE <- './resources/TSPshareprices.csv'


TSPSharePrices <- read.csv(file=TSP_DATA_FILE,head=TRUE,sep=",")
#TSPSharePrices$date <- as.Date(TSPSharePrices$date, "%Y-%m-%d")
#TSPSharePrices$date <- as.POSIXlt(TSPSharePrices$date, "%Y-%m-%d")
TSPSharePrices$date <- as.Date(TSPSharePrices$date, "%Y-%m-%d")

plot(x=TSPSharePrices$date, y=TSPSharePrices$S.Fund, ylim=c(0,1.1*max(TSPSharePrices$S.Fund)),
      type="l", ann=TRUE, xlab='Date', col='black')
points(x=TSPSharePrices$date, y=TSPSharePrices$C.Fund, col='blue', type='l', lwd=2)
points(x=TSPSharePrices$date, y=TSPSharePrices$G.Fund, col='purple', type='l', lwd=2)
points(x=TSPSharePrices$date, y=TSPSharePrices$L.2050, col='red', type='l', lwd=2)

legend("topleft", 40, c("S-Fund","C-Fund", "G-Fund", "L-2050"), lty=c(1,1,1,1), lwd=c(2,2,2,2), col=c("black","blue","purple", "red"))
title(ylab="Share Prices ($)")

datesOfInterest <- as.Date(seq(as.Date("2010-01-01"), length=24, by="1 month") - 1, "%Y-%m-%d")


####### GENERATING TSP RETURNS ######

# Use the last day of the TSP Share Prices data as the end time for analysis 
endTime <- Sys.Date()

# Can confirm this works properly by manually setting the date to the end of Jan and comparing the 30 day returns
# to what is reported for Jan 2015 the TSP site https://www.tsp.gov/investmentfunds/returns/returnSummary.shtml
#endTime <- as.Date("2015-01-31")

# Dates to represent 30, 60, 90 days from the end Time. 
minus30 <- endTime - 30
minus60 <- endTime - 60
minus90 <- endTime - 90


tspPeriodReturn <- function(periodEndDate, periodStartDate) {
  ##### Calculatiing returns based on arbretary dates provided
  # Row that is closest to but not after the date provided  
  periodEndShares <- TSPSharePrices[which.min(TSPSharePrices$date >= as.Date(periodEndDate)), ]
  
  periodStartShares <- TSPSharePrices[which.min(TSPSharePrices$date >= as.Date(periodStartDate)), ]
 
  #### Alternatively - we could use the calendar months (maybe overload this function?)
  ### End of the previous month:
  #prevPerSharePrice <- head(TSPSharePrices[TSPSharePrices$date$year==114 & TSPSharePrices$date$mon==11, ],1)
  ### End of the current month:
  #curPerSharePrice <- head(TSPSharePrices[TSPSharePrices$date$year==115 & TSPSharePrices$date$mon==0, ],1)
  
  shareReturns <- ((periodEndShares[,2:11] - periodStartShares[,2:11])/periodStartShares[2:11])*100
  
  print(paste0("Returns for the period of ", periodStartShares$date, " - ", periodEndShares$date, ":"))
  print(shareReturns)
  
  ### Returns:
  return(shareReturns)
}


minus30Returns <- tspPeriodReturn(endTime, minus30)
minus60Returns <- tspPeriodReturn(endTime, minus60)
minus90Returns <- tspPeriodReturn(endTime, minus90)
