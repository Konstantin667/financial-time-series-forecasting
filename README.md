# Financial Time Series Forecasting (ARIMA / SARIMA / ETS)

This project demonstrates an end-to-end time series forecasting pipeline for business revenue data, combining Python for data preprocessing and R for statistical time series modeling.

The goal is to simulate a realistic analytics workflow, where raw transactional data is transformed into a clean time series and used for forecasting with classical econometric models commonly applied in business and finance.

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
- **R**: ggplot2, dplyr, readr, lubridate, forecast, tseries 
- **Methods**: ADF test, ARIMA, SARIMA, ETS, backtesting  
- **Data source**: Brazilian E-Commerce Public Dataset (Olist)

---

## Dataset Overview

The project uses the **Olist Brazilian E-Commerce Public Dataset**, which represents real transactional data from a large online marketplace.

The dataset includes:

- ~100,000 orders
- Customer, seller, product, and geolocation data
- Order lifecycle timestamps (purchase, approval, delivery)
- Payment values and installment information
- Product categories (translated to English)

For this project, the dataset was used to **reconstruct historical revenue**, reflecting how raw operational data is typically handled in real companies rather than working with a pre-aggregated time series.

**Original dataset (Kaggle):**  
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

---

## Data Availability

Due to file size limitations, raw CSV files are not stored directly in this repository.

**Raw datasets (Google Drive):**  
https://drive.google.com/drive/folders/1FeDjNPot8-LrITfVb58msrz1AUJUPZaT

**Processed dataset used for modeling:**
data/processed/monthly_revenue.csv
This file contains a clean, ordered monthly revenue time series and serves as the input for all forecasting models.

## Workflow Summary

### Python (Data Preparation & Baseline Modeling)

- Merge multiple transactional tables
- Calculate order-level revenue
- Aggregate revenue to monthly frequency
- Construct a time index
- Test stationarity using the **ADF test**
- Apply differencing to achieve stationarity
- Explore a baseline ARIMA model

### R (Forecasting & Validation)

- Import processed monthly revenue data
- Convert data into a time series object
- Automatically select model parameters using `auto.arima`
- Fit **SARIMA** and **ETS** models
- Analyze residuals (ACF, distribution, independence)
- Perform backtesting and compare model accuracy

---

### Forecast Model Comparison

| Model   | RMSE     | MAE      |
|--------|----------|----------|
| SARIMA | **114,822** | **81,631** |
| ETS    | 120,492  | 91,425  |

**Key insights:**

- Both models successfully captured the **overall revenue trend**
- **SARIMA achieved lower error metrics**, indicating better predictive accuracy
- ETS produced smoother forecasts but handled variance less effectively
- SARIMA was selected as the **final model** due to stronger backtesting performance

---

## Example Outputs

### Monthly Revenue Forecast (auto.arima)
*(insert image here)*

### Residual Diagnostics (SARIMA)
*(insert image here)*

---

## Key Learnings

- Stationarity is critical for reliable time series modeling
- Seasonal components significantly improve forecast accuracy
- Visual fit alone is insufficient — **error metrics matter**
- Python and R can be effectively combined in a single analytical workflow
- Classical models remain highly relevant in real business forecasting tasks

---

## Author

**Konstantin Rudnev**  
Aspiring Data Analyst / Business Analyst  
Open to opportunities across Europe

🔗 GitHub: https://github.com/Konstantin667
