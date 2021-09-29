library(xts)
library(fpp)
library(forecast)

# Create time series
tw2330 <- read.csv("02_ts_example1.csv")
class(tw2330)

m <- ts(tw2330$Total.Income, frequency = 4, start = c(2008, 1))
class(m)

m2 <- window(m, start = c(2012, 2), end = c(2014, 2))
class(m2)

m_ts <- ts(tw2330[, -1], frequency = 4, start = c(2008, 1))
head(m_ts)
head(m_ts[, "EPS"])


m_xts <- as.xts(m)
head(m_xts)
sub_xts <- window(m_xts, start = "2012 Q2", end = "2012 Q4")


# Plotting time series object
plot.ts(m)
plot.ts(m_ts, plot.type = "multiple")
plot.ts(m_ts, plot.type = "single", col = c("red", "blue", "green", "orange"))
plot.xts(m_xts)


# Decomposing time series
m_sub <- window(m, start = c(2012, 1), end = c(2014, 4))
m_sub
plot(m_sub)
components <- decompose(m_sub)
names(components)
components$seasonal


# Using LOWESS and LOESS to fit the polynomial regression line to components
# in order to localize them in time series. Using `stl` function allows us to
# apply LOESS method to decompose periodic time series.
plot(components)
comp1 <- stl(x = m_sub, s.window = "periodic")
names(comp1)
plot(comp1)


# Smoothing time series allows us to forecast future events using time series
# data. At most basic level the smoothing uses moving average to smooth the
# time series. We can use `holtwinters` function to smooth the time series.
# Simple exponential smoothing is performed when data has no seasonal or trend
# patterns. Use Holt smoothing if your data has trend but do not have seasonal
# components. Use Winters smoothing if your data has trend and seasonal comps.
plot(m)
m_pre <- HoltWinters(m)
m_pre
plot(m_pre)
m_pre$SSE

fit <- hw(m, seasonal = "additive")
summary(fit)
plot.ts(m)
lines(fitted(fit), col = "red")


# Forecasting time series
income_pre <- forecast(m_pre, h = 4)
summary(income_pre)
plot(income_pre)


# To measure our model we use ACF function
acf(income_pre$x)
Box.test(income_pre$x)
fit <- hw(m, seasonal = "additive")
plot(fit)