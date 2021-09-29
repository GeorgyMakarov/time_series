library(forecast)


# Generate ARIMA data
set.seed(123)
ts_sim <- arima.sim(model = list(order = c(1, 1, 0), ar = 0.7), n = 100)
plot(ts_sim)


# Plot difference of time series
ts_sim_diff <- diff(ts_sim)
plot(ts_sim_diff)


# Make auto-correlation plot
acf(ts_sim_diff)


# Create ARIMA model
fit <- Arima(ts_sim, order = c(1, 1, 0))
fit
accuracy(fit)


# We can use auto arima to fit the optimal model
auto.arima(ts_sim, ic = "bic")


# Forecast using arima
fit_pred <- forecast(fit)
plot(fit_pred)
acf(fit_pred$residuals)
Box.test(fit_pred$residuals)
tsdiag(fit)