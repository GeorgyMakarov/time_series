library(quantmod)

getSymbols(Symbols = "FB",
           src     = "yahoo",
           from    = "2015-01-01")

plot(FB)
fit <- auto.arima(FB$FB.Close, ic = "bic")
fit

plot(as.ts(FB$FB.Close))
lines(fitted(fit), col = "red")

# Predict future prices
fit_pred <- forecast(object = fit)
fit_pred
plot(fit_pred)


# Find distribution of performance of the stock
fb_return <- diff(FB$FB.Close) / lag(FB$FB.Close, k = 1) * 100
hist(fb_return)
