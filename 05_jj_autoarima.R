# This is a simple ARIMA stock price predicting model. The purpose of this is
# to show how to forecast time series data and how to roughly tune a model.

library(MASS)
library(tseries)
library(forecast)
library(quantmod)


# Loading the data from `Yahoo Finance`
getSymbols(Symbols = "JNJ",
           src     = "yahoo",
           from    = "2019-01-01")

head(JNJ)
summary(JNJ)


# Prepare the data. We use closing price for this script. We're going to use
# 80% of the data as training, the rest -- for testing purposes. Log-transform
# the data to smooth price deviations.
index    <- 1:round(0.8 * nrow(JNJ), 0)
training <- JNJ$JNJ.Close[index] 
testing  <- JNJ$JNJ.Close[-index]
ln_train <- log(training)


# ACF, PACF, Dickey-Fuller tests. These tests tell us if the time series is
# stationary. Stationary is a requirement for building ARIMA model. If `ACF` 
# shows gradual descent in lags, the time series is stationary. If `PACF` shows
# immediate drop in auto-correlation, time series is stationary. 
acf(ln_train,  lag.max = 200)
pacf(ln_train, lag.max = 200)

diff_ln_train <- diff(ln_train, 1)
diff_ln_train <- diff_ln_train[-1]

if (sum(is.na(diff_ln_train)) == 0){
  adf.test(ln_train)      ## this is non-stationary -> p-value > 0.05
  adf.test(diff_ln_train) ## this is stationary     -> p-value < 0.05
} else {
  print("Check NA values in diff")
}


# Fit auto-arima model on training data. Get forecast values from the model.
ln_fit <- auto.arima(y = ln_train, test = "kpss", ic = "bic")
ln_fit
ln_fc  <- forecast(ln_fit, h = length(testing))
fc_exp <- exp(ln_fc$mean)
plot(ln_fc)

# Compute performance of the model by estimating the percentage error on the
# testing data.
temp_df <- data.frame(actual = as.numeric(testing$JNJ.Close), 
                      fc     = as.numeric(fc_exp))
perc_er <- ((temp_df$actual - temp_df$fc)) / temp_df$actual
mean(perc_er)


# Run Ljung-Box test to find out if the residuals are random now. We can run the
# test on many lags -- this is an arbitriary decision. The values greater than
# 0.05 tell us that we can't reject the null hypothesis that our residuals are
# random.
as.numeric(
  lapply(
    X   = 1:20, 
    FUN = function(x){
      test <- Box.test(ln_fit$residuals, lag = x, type = "Ljung-Box")$p.value 
      return(round(test, 2))}))
