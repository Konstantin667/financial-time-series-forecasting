## packages: ggplot2, dplyr, readr, lubridate, forecast, tseries
library(ggplot2)
library(dplyr)
library(readr)
library(lubridate)
library(forecast)
library(tseries)

## Data Overview

## The analysis is based on monthly aggregated revenue data derived from
## e-commerce transactional records (Olist dataset).
## - Frequency: Monthly
## - Time span: October 2016 – August 2018
## - Number of observations: 23
## - Target variable: Total monthly revenue

monthly_revenue <- read_csv("data/processed/monthly_revenue.csv")
head(monthly_revenue)
str(monthly_revenue)

monthly_revenue <- monthly_revenue %>%
  mutate(order_month = as.Date(order_month))

summary(monthly_revenue)

## Creating time series
ts_revenue <- ts(
  monthly_revenue$revenue,
  start = c(
    year(min(monthly_revenue$order_month)),
    month(min(monthly_revenue$order_month))
  ),
  frequency = 12
)
ts_revenue

## Visualization
autoplot(ts_revenue) +
  ggtitle("Monthly Revenue Time Series") +
  xlab("Year") +
  ylab("Revenue")

## ADF 
adf.test(ts_revenue)

##Differentiation (p-value > 0.05)
ts_diff <- diff(ts_revenue)
adf.test(ts_diff)

## Visualization
autoplot(ts_diff) +
  ggtitle("Differenced Revenue Series")

## ACF/PACF
ggAcf(ts_diff, lag.max = 12)
ggPacf(ts_diff, lag.max = 12)

## Stationarity Analysis

## An Augmented Dickey-Fuller (ADF) test was applied to assess stationarity.
## - Original series: non-stationary (p-value > 0.05)
## - First difference: stationary (p-value < 0.01)
## Conclusion: First-order differencing (d = 1) is required.

## AutoArima
model_arima <- auto.arima(
  ts_revenue,
  seasonal = TRUE,
  stepwise = FALSE,
  approximation = FALSE
)
summary(model_arima)

## Forecast
forecast_6 <- forecast(model_arima, h = 6)
autoplot(forecast_6) +
  ggtitle("6-Month Revenue Forecast (auto.arima)") +
  ylab("Revenue")
## The model forecasts a continued moderate growth in revenue over the next 6 months, with increasing uncertainty over the forecast horizon.


## Diagnostic
checkresiduals(model_arima)
## Residual diagnostics indicate no significant autocorrelation and approximately normal residuals, suggesting a good model fit.

## Monthly revenue time series
## Frequency is set to 12 to capture potential annual seasonality
ts_revenue <- ts(
  monthly_revenue$revenue,
  start = c(2016, 10),
  frequency = 12
)

## Visual inspection of trend and potential seasonality
plot(ts_revenue, main = "Monthly Revenue Time Series", ylab = "Revenue")

## Seasonal ARIMA model selection using auto.arima
sarima_model <- auto.arima(
  ts_revenue,
  seasonal = TRUE,
  stepwise = FALSE,
  approximation = FALSE
)
summary(sarima_model)


## Diagnostic checks for SARIMA residuals
checkresiduals(sarima_model)

## 6-month revenue forecast using SARIMA
sarima_forecast <- forecast(sarima_model, h = 6)
autoplot(sarima_forecast) +
  ggtitle("6-Month Revenue Forecast (SARIMA)") +
  ylab("Revenue") +
  xlab("Time")

## Exponential Smoothing State Space model (ETS)
ets_model <- ets(ts_revenue)
summary(ets_model)

checkresiduals(ets_model)

# Model comparison based on accuracy metrics
accuracy(sarima_model)
accuracy(ets_model)

comparison <- data.frame(
  Model = c("SARIMA", "ETS"),
  RMSE = c(
    accuracy(sarima_model)[1, "RMSE"],
    accuracy(ets_model)[1, "RMSE"]
  ),
  MAE = c(
    accuracy(sarima_model)[1, "MAE"],
    accuracy(ets_model)[1, "MAE"]
  )
)
comparison

## Model Performance Comparison

##   | Model  | RMSE     | MAE      |
##   |--------|----------|----------|
##   | SARIMA | 114822.6 | 81630.7  |
##   | ETS    | 120491.0 | 91425.0  |
  
## SARIMA outperformed ETS in both RMSE and MAE metrics and demonstrated
## well-behaved residuals with no significant autocorrelation.


# Train-test split for backtesting (last 6 months as test set)
train <- window(ts_revenue, end = c(2018, 2))
test  <- window(ts_revenue, start = c(2018, 3))

sarima_bt <- auto.arima(train, seasonal = TRUE)
ets_bt <- ets(train)

sarima_fc <- forecast(sarima_bt, h = length(test))
ets_fc <- forecast(ets_bt, h = length(test))

accuracy(sarima_fc, test)
accuracy(ets_fc, test)

autoplot(test) +
  autolayer(sarima_fc$mean, series = "SARIMA Forecast") +
  autolayer(ets_fc$mean, series = "ETS Forecast") +
  ggtitle("Backtesting: Forecast vs Actual") +
  ylab("Revenue") +
  xlab("Time")


## Structural break analysis

## The backtesting results reveal a consistent overestimation
## of revenue by both SARIMA and ETS models.

## This suggests the presence of a structural break in the time
## series, where historical growth dynamics no longer hold.

## Possible explanations:
## - Market saturation
## - Changes in customer behavior
## - External economic factors

## Implication:
## Forecasting models trained on historical growth patterns
## should be used with caution under changing regimes.

## Final Conclusion
## The SARIMA model was selected as the final forecasting approach due to
## its superior predictive accuracy and robust residual diagnostics.
## ETS tended to overestimate future revenue levels, while SARIMA provided
## more conservative and stable forecasts aligned with historical patterns.
