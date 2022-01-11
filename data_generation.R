pkgs <- c("dplyr", "lubridate")
deps <- lapply(pkgs, library, character.only = T)

# Compute time related parameters -- this is required to compute the sines
n2019 <- 365 ## normal year
n2020 <- 366 ## leap year
n2021 <- 365 ## normal year


n_mins  <- 24 * 60 / 15    ## daily number of intervals
freq7   <- n_mins * 7      ## frequency of weekly pattern (sundays)
freq_1m <- n_mins * 30     ## frequency of monthly pattern (maintenance)

# Prepare sine equation: y = a * sin(b * t)
# Seq along values of b to find proper b value for each frequency
# Use periodgram to compute frequency
b_seq <- seq(from = 78, to = 80, by = 0.1)
for (i in b_seq){
  t <- seq(from = 0, to = 4 * pi, length.out = n_mins * (n2019 + n2020 + n2021))
  b <- i              ## width of interval, more = narrow
  y <- sin(b * t)     ## sine computation
  p_gram <- TSA::periodogram(y, plot = F)
  p_gram <- data.frame(freq = p_gram$freq, spec = p_gram$spec)
  p_gram <- p_gram %>% arrange(desc(spec)) %>% head(2)
  p_gram <- round(1 / p_gram$freq[1], 0)
  print(p_gram)
  if (p_gram <= freq7){
    cat(paste("Achieved frequency:", p_gram, "\n"))
    cat(paste("Achieved b-value:", b, "\n"))
    rm(i, y, p_gram)
    return(b)
  }
  rm(i, b, y, p_gram)
}


b7 <- 78.2 ## width of intervals for weeks
b1 <- 19.0 ## width of intervals for month


# Compute all sines
set.seed(123)
sine1 <- jitter(30 * sin(b1 * t),     factor = 200) / 200 ## sine for month
sine7 <- jitter(20 * sin(b7 * t + 2), factor = 200) / 200 ## sine for weeks

sines <- sine1 + sine7
rm(sine1, sine7, b1, b7, b_seq, b, freq_1m, freq7, pkgs, deps)

plot(sines, type = "l")


# Add linear trend to the data. Use piece wise linear trends:
# slope 5e4 -- 2019
# slope 1e5 -- 2020
# slope 2e5 -- 2021
xt <- 1:length(t)
l1 <- (0.50000 + xt / 5e4) * 2
l2 <- (0.85088 + xt / 1e5) * 2
l3 <- (1.20176 + xt / 2e5) * 2

plot(l1, type = "l", col = "blue")
lines(l2, col = "red")
lines(l3, col = "green")

l1 <- l1[1:35088]
l2 <- l2[35089:70176]
l3 <- l3[70177:length(t)]

line_up <- c(l1, l2, l3)

plot(line_up, type = "l")


# Add external regressor -- warehouse stock
# The warehouse report is available on a daily basis
# The production volume has linear relationship with warehouse stock
ws <- rep(1000, length(xt))
set.seed(123)
ws <- jitter(ws, factor = 10) ## add random jitter to warehouse stock
plot(ws, type = "l")

xreg_ws <- 0.001 * ws / 10

rm(l1, l2, l3, t)


# Aggregate by days to see how this is going to look like when grouped by
i15 <- seq(from = ymd_hm('2019-01-01 00:00'),
           to   = ymd_hm('2021-12-31 23:45'), 
           by   = '15 mins')

df <- data.frame(date_time = i15, 
                 sines     = sines,
                 trend     = line_up,
                 xregs     = xreg_ws)

rm(line_up, n_mins, n2019, n2020, n2021, sines, xreg_ws, xt)


# Add holidays -- calendar holidays do not play important roles in the process
# Company has its own calendar of holidays, which impact production volume:
# Jan 01 -- Jan 03 - 50%
# Dec 31           - 70%
# May 01 -- May 03 - 50%
# Feb 23           - 70%
df <- 
  df %>% 
  mutate(day       = as_date(date_time), 
         prod_base = sines + trend - xregs)

df$mnth   <- month(df$day)
df$dd     <- day(df$day)
df$prod_h <- df$prod_base

df$prod_h[df$mnth %in% c(1, 5) & df$dd %in% c(1, 2, 3)] <- 
  0.5 * df$prod_h[df$mnth %in% c(1, 5) & df$dd %in% c(1, 2, 3)]

df$prod_h[df$mnth == 2 & df$dd == 23] <- 
  0.7 * df$prod_h[df$mnth == 2 & df$dd == 23]

df$prod_h[df$mnth == 12 & df$dd == 31] <- 
  0.7 * df$prod_h[df$mnth == 12 & df$dd == 31]


# Add repair days -- the production drops down to 10% of average rate of the
# current year
r3 <- which(df$mnth == 3 & df$dd == 31) ## repair at March 31
r6 <- which(df$mnth == 6 & df$dd == 30) ## repair at June 30
r9 <- which(df$mnth == 9 & df$dd == 30) ## repair at September 30
rt <- c(r3, r6, r9)                     ## total repair

df$prod_h[rt] <- 0.1 * df$prod_h[rt]


# Check how the daily data will look like
df_daily <-
  df %>% 
  group_by(day) %>% 
  summarise(prod = sum(prod_h))

plot(x = df_daily$day, y = df_daily$prod, type = "l")
rm(r3, r6, r9, rt)
rm(df_daily)

# Outputs that we need for data base design
prod_tbl <- df %>% select(date_time, prod_h)  ## 15-mins production reports
prod_tbl <- prod_tbl %>% mutate(day = as_date(date_time))
prod_tbl <- prod_tbl %>% select(date_time, day, prod_h)
ws_tbl   <- 
  data.frame(date_time = i15,
             stock     = ws) %>% 
  mutate(day = as_date(date_time)) %>% 
  group_by(day) %>% 
  summarise(stock = sum(stock))               ## daily stock reports

i365   <- seq(from = ymd('2019-01-01'), to = ymd('2021-12-31'), by = "day")
rp_tbl <- data.frame(day = i365, rep_day = 0) ## daily repair calendar
rp_tbl$rep_day[month(rp_tbl$day) == 3 & day(rp_tbl$day) == 31] <- 1
rp_tbl$rep_day[month(rp_tbl$day) == 6 & day(rp_tbl$day) == 30] <- 1
rp_tbl$rep_day[month(rp_tbl$day) == 9 & day(rp_tbl$day) == 30] <- 1


# Make holiday calendar
hl_tbl <- data.frame(day     = i365, 
                     mnth    = month(i365),
                     dd      = day(i365),
                     holiday = 0)

hl_tbl$holiday[hl_tbl$mnth == 1 & hl_tbl$dd %in% c(1:8)]  <- 1
hl_tbl$holiday[hl_tbl$mnth == 2 & hl_tbl$dd == 23]        <- 1
hl_tbl$holiday[hl_tbl$mnth == 3 & hl_tbl$dd == 8]         <- 1
hl_tbl$holiday[hl_tbl$mnth == 5 & hl_tbl$dd %in% c(1, 9)] <- 1
hl_tbl$holiday[hl_tbl$mnth == 6 & hl_tbl$dd == 12]        <- 1
hl_tbl$holiday[hl_tbl$mnth == 11 & hl_tbl$dd == 4]        <- 1


# Write output tables
write.csv(hl_tbl, "holidays_calendar.csv", row.names = F)
write.csv(prod_tbl, "production_reports.csv", row.names = F)
write.csv(rp_tbl, "repair_calendar.csv", row.names = F)
write.csv(ws_tbl, "inventory_reports.csv", row.names = F)

