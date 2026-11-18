## Monthly revenue forecasting: ARIMA vs ETS vs simple benchmarks
## Run from the project root (open the .Rproj or setwd() to the repository folder).
## Input : data/processed/monthly_revenue.csv  (columns: date, revenue) - produced by the Python notebook
## Output: assets/r_*.png, data/processed/model_metrics.csv, data/processed/r_output.txt

## packages: readr, dplyr, ggplot2, forecast, tseries
library(readr)
library(dplyr)
library(ggplot2)
library(forecast)
library(tseries)

dir.create("assets", showWarnings = FALSE)
sink("data/processed/r_output.txt", split = TRUE)

## ---------------------------------------------------------------------------
## 1. Data
## ---------------------------------------------------------------------------
## The marketplace effectively starts in January 2017: Sep-Dec 2016 are a test
## period (November 2016 has no orders at all, December 2016 has one order).
## These months are excluded so the series is complete and consecutive.

monthly_revenue <- read_csv("data/processed/monthly_revenue.csv", show_col_types = FALSE) %>%
  mutate(date = as.Date(date)) %>%
  filter(date >= as.Date("2017-01-01")) %>%
  arrange(date)

## check that months are consecutive (ts() assumes no gaps)
stopifnot(all(diff(as.numeric(format(monthly_revenue$date, "%Y")) * 12 +
                   as.numeric(format(monthly_revenue$date, "%m"))) == 1))

ts_revenue <- ts(
  monthly_revenue$revenue,
  start = c(as.numeric(format(min(monthly_revenue$date), "%Y")),
            as.numeric(format(min(monthly_revenue$date), "%m"))),
  frequency = 12
)
cat("Observations:", length(ts_revenue), "| from", format(min(monthly_revenue$date)),
    "to", format(max(monthly_revenue$date)), "\n")

## With 20 monthly points there are fewer than two full years, so annual
## seasonality cannot be estimated. All models below are non-seasonal.

## ---------------------------------------------------------------------------
## 2. Stationarity
## ---------------------------------------------------------------------------
print(adf.test(ts_revenue))
ts_diff <- diff(ts_revenue)
print(adf.test(ts_diff))
## Note: with ~20 observations the ADF test has low power; the level series
## is treated as non-stationary (clear trend), the first difference as stationary.

png("assets/r_acf_pacf.png", width = 1100, height = 450)
par(mfrow = c(1, 2))
acf(ts_diff, lag.max = 10, main = "ACF of differenced revenue")
pacf(ts_diff, lag.max = 10, main = "PACF of differenced revenue")
dev.off()

## ---------------------------------------------------------------------------
## 3. Models on the full series
## ---------------------------------------------------------------------------
arima_model <- auto.arima(ts_revenue, seasonal = FALSE, stepwise = FALSE, approximation = FALSE)
ets_model   <- ets(ts_revenue)
print(summary(arima_model))
print(summary(ets_model))

png("assets/r_arima_residuals.png", width = 1000, height = 600)
checkresiduals(arima_model)
dev.off()
png("assets/r_ets_residuals.png", width = 1000, height = 600)
checkresiduals(ets_model)
dev.off()

fc_arima <- forecast(arima_model, h = 6)
p <- autoplot(fc_arima) +
  ggtitle(paste("6-month revenue forecast:", as.character(arima_model))) +
  xlab("Time") + ylab("Revenue")
ggsave("assets/r_arima_forecast.png", p, width = 9, height = 5, dpi = 110)

## ---------------------------------------------------------------------------
## 4. Backtesting (out-of-sample)
## ---------------------------------------------------------------------------
## In-sample accuracy (accuracy(model)) only measures fit on the training data.
## Model choice is based on errors on data the model has NOT seen.

h <- 6
n <- length(ts_revenue)
train <- window(ts_revenue, end = time(ts_revenue)[n - h])
test  <- window(ts_revenue, start = time(ts_revenue)[n - h + 1])

## re-select the model on the training window only (no look-ahead)
arima_bt <- auto.arima(train, seasonal = FALSE, stepwise = FALSE, approximation = FALSE)
ets_bt   <- ets(train)

fcs <- list(
  "Naive (last value)" = naive(train, h = h),
  "Random walk + drift" = rwf(train, h = h, drift = TRUE),
  "ARIMA" = forecast(arima_bt, h = h),
  "ETS" = forecast(ets_bt, h = h)
)

holdout <- bind_rows(lapply(names(fcs), function(m) {
  a <- accuracy(fcs[[m]], test)["Test set", ]
  data.frame(model = m, evaluation = "6-month holdout",
             RMSE = a["RMSE"], MAE = a["MAE"], MAPE = a["MAPE"],
             bias = mean(fcs[[m]]$mean - test))
}))
holdout$model[holdout$model == "ARIMA"] <- paste("ARIMA:", as.character(arima_bt))
holdout$model[holdout$model == "ETS"]   <- paste("ETS:", ets_bt$method)

## rolling-origin one-step-ahead errors over the same 6 months
f_arima <- function(x, h) forecast(auto.arima(x, seasonal = FALSE), h = h)
f_ets   <- function(x, h) forecast(ets(x), h = h)
f_naive <- function(x, h) naive(x, h = h)
f_drift <- function(x, h) rwf(x, h = h, drift = TRUE)
roll <- function(f) {
  e <- tsCV(ts_revenue, f, h = 1, initial = n - h - 1)
  e <- e[!is.na(e)]
  c(RMSE = sqrt(mean(e^2)), MAE = mean(abs(e)))
}
rolling <- data.frame(
  model = c("Naive (last value)", "Random walk + drift", "ARIMA (re-selected each month)", "ETS (re-selected each month)"),
  evaluation = "rolling 1-step, last 6 months",
  rbind(roll(f_naive), roll(f_drift), roll(f_arima), roll(f_ets)),
  MAPE = NA, bias = NA
)

metrics <- bind_rows(holdout, rolling)
rownames(metrics) <- NULL
print(metrics, digits = 6)
write_csv(metrics, "data/processed/model_metrics.csv")

p <- autoplot(window(ts_revenue, start = c(2017, 7))) +
  autolayer(fcs[["Naive (last value)"]]$mean, series = "Naive") +
  autolayer(fcs[["ARIMA"]]$mean, series = "ARIMA") +
  autolayer(fcs[["ETS"]]$mean, series = "ETS") +
  ggtitle("Backtest: 6-month forecasts from Feb 2018 vs actual revenue") +
  xlab("Time") + ylab("Revenue") + labs(colour = "Forecast")
ggsave("assets/r_backtest.png", p, width = 9, height = 5, dpi = 110)

## ---------------------------------------------------------------------------
## 5. Interpretation (see README for the final numbers)
## ---------------------------------------------------------------------------
## Revenue grew fast through 2017 and flattened in 2018 (about 1.0-1.1M per month).
## Trend-following models (ARIMA with drift, ETS with trend) trained up to
## February 2018 extrapolate the 2017 growth and overestimate March-August 2018.
## A naive forecast is the hardest benchmark to beat after such a regime change.
## Practical implication: use rolling re-forecasting and compare every model
## against a naive benchmark before trusting it for budgeting.

sink()
