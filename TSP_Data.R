
TSP_DATA_FILE <- '~/Dropbox/Development/LearningR/Economy/TSPshareprices.csv'


TSPSharePrices <- read.csv(file=TSP_DATA_FILE,head=TRUE,sep=",")
TSPSharePrices$date <- as.Date(TSPSharePrices$date, "%Y-%m-%d")

plot(x=TSPSharePrices$date, y=TSPSharePrices$S.Fund, ylim=c(0,1.1*max(TSPSharePrices$S.Fund)), type="l", ann=FALSE, xlab='Date', col='black')
points(x=TSPSharePrices$date, y=TSPSharePrices$C.Fund, col='blue', type='l', lwd=2)
points(x=TSPSharePrices$date, y=TSPSharePrices$G.Fund, col='purple', type='l', lwd=2)
points(x=TSPSharePrices$date, y=TSPSharePrices$L.2050, col='red', type='l', lwd=2)

legend("topleft", 40, c("S-Fund","C-Fund", "G-Fund", "L-2050"), lty=c(1,1,1,1), lwd=c(2,2,2,2), col=c("black","blue","purple", "red"))
title(ylab="Share Prices ($)")

datesOfInterest <- as.Date(seq(as.Date("2010-01-01"), length=24, by="1 month") - 1, "%Y-%m-%d")
