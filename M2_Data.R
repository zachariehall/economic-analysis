require(httr)
require(RCurl)

#TODO: Use one common start and end date when combining all of the stats
#START_YEAR <- '1/1/2006'
#END_YEAR <- '2/5/2014'

# TODO: PUll the CSV off the Fed Reserve site automatically with the 
# start and end date 
#http://www.federalreserve.gov/datadownload/Output.aspx?rel=H6&series=7e7b91c6d830d9ca24348e0f88c1ba1b&lastObs=&from=01/01/2006&to=02/05/2015&filetype=csv&label=omit&layout=seriescolumn

#In the mean time, just use the CSV downloaded manually
M2_DATA_FILE <- './resources/FRB_H6.csv'

moneySupplyData <- read.csv(file=M2_DATA_FILE, head=TRUE, sep=",", skip = 1)
moneySupplyData$Time.Period <- as.Date(moneySupplyData$Time.Period, "%Y-%m-%d")

plot(x=moneySupplyData$Time.Period, y=moneySupplyData$M2.WM, 
     main="Seasonally Adjusted Money Supply (M2)", type="l", ylab="Money ($1e+09)", 
     xlab='Date', ylim = c(0,1.1*max(moneySupplyData$M2.WM)), col='black')

#The non-seasonally adjusted money supply
#points(x=moneySupplyData$Time.Period, y=moneySupplyData$M2_N.WM, col='red', type='l', lwd=2)

