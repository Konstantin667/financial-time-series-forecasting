# Financial Time Series Forecasting (ARIMA / SARIMA / ETS)

This project demonstrates an end-to-end time series forecasting pipeline for business revenue data, combining **Python for data preprocessing** and **R for statistical time series modeling**.

The goal is to simulate a realistic analytics workflow where raw transactional data is transformed into a clean time series and then used for forecasting with classical econometric models.

---

## Project Overview

**Key objectives:**
- Build a clean monthly revenue time series from transactional data
- Test stationarity and apply differencing
- Compare multiple forecasting models:
  - ARIMA
  - SARIMA
  - ETS (Exponential Smoothing)
- Perform backtesting and model comparison
- Produce interpretable forecasts suitable for business decision-making

---

## Tools & Technologies

- **Python**: pandas, numpy, statsmodels, matplotlib  
- **R**: forecast, tseries, ggplot2  
- **Methods**: ADF test, ARIMA, SARIMA, ETS, backtesting  
- **Data source**: Brazilian E-Commerce Public Dataset (Olist)

---

## Data Source

Raw transactional data is based on the **Olist Brazilian E-Commerce Dataset**.

Due to file size limitations, raw CSV files are not stored directly in this repository.

**Raw datasets (Google Drive):**  
https://drive.google.com/drive/folders/1FeDjNPot8-LrITfVb58msrz1AUJUPZaT?usp=sharing

Processed data used for modeling:
- `data/processed/monthly_revenue.csv`

---

## Workflow Summary

1. **Python (Preprocessing)**
   - Merge multiple transactional tables
   - Calculate revenue
   - Aggregate revenue at monthly level
   - Stationarity testing (ADF)
   - Baseline ARIMA exploration

2. **R (Forecasting & Validation)**
   - Convert data to time series object
   - auto.arima model selection
   - SARIMA modeling
   - ETS modeling
   - Residual diagnostics
   - Backtesting and model comparison

---

## Key Results

### Forecast Comparison (Backtesting)
- **SARIMA** achieved lower RMSE compared to ETS
- Both models captured trend but differed in variance handling
- SARIMA selected as the final model

### Example Outputs

**Monthly Revenue Forecast (auto.arima):**  
*(insert image here)*

**Residual Diagnostics (SARIMA):**  
*(insert image here)*

---

## Key Learnings

- Importance of stationarity in time series modeling
- Differences between ARIMA-family models and ETS
- Model selection based on error metrics, not visual fit
- Practical integration of Python + R in analytics workflows

---

## Author

Konstantin Rudnev  
Aspiring Data Analyst / Business Analyst
Open to opportunities across Europe  
