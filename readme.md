# Power Demand Forecasting Work (`Untitled.ipynb`)

## 1) Weather dataset processing
- Loaded `weather_data.xlsx`
- Separated metadata and actual weather table
- Converted `time` into datetime
- Converted weather columns to numeric type
- Checked minute values and confirmed records are aligned
- Created EDA profile report: `output.html`

## 2) PGCB dataset processing
- Loaded `PGCB_date_power_demand.xlsx`
- Created EDA profile report: `output_PGCB.html`
- Removed duplicate datetime rows by keeping row with less missing values
- Checked mismatch between `generation_mw` and `demand_mw`
- Checked mismatch between `generation_mw` and source-wise total
- Reviewed rows where `wind` and `solar` were missing
- Calculated average contribution of each power source

## 3) Outlier detection and handling
- Used IQR method on `demand_mw`
- Calculated Q1, Q3 and IQR
- Defined lower and upper bounds using `1.5 * IQR`
- Instead of deleting outlier rows, capped values using `clip()`
- This kept time-series continuity and avoided losing timeline data

## 4) Feature engineering
- Resampled weather data to `30min` and did time-based interpolation
- Merged weather data with power data on datetime
- Added time features:
- `year`, `month`, `day`, `hour`, `minute`, `day_of_week`, `is_weekend`
- Added lag features:
- `lag_1`, `lag_2`, `lag_24`
- Added rolling stats:
- `rolling_mean_3`, `rolling_mean_24`, `rolling_std_24`
- Created `other` feature by combining lower-impact source columns
- Removed leakage-prone source columns before training

## 5) Economics dataset check
- Loaded `economic_full_1.csv`
- Filtered years 2015 to 2025
- Decided to skip this dataset because frequency is too low for hourly forecasting and many indicators were not useful

## 6) Target and train-test split
- Created target:
- `target_next_hour = demand_mw.shift(-1)`
- Dropped NA rows after shifting and rolling operations
- Used year-based split:
- Train: all years except `2023`
- Test: only `2023`
- Final shapes:
- `X_train`: `(82275, 23)`
- `X_test`: `(9054, 23)`

## 7) Transformation and scaling trials
- Tried `PowerTransformer(method="yeo-johnson")` on feature set
- Also tried `StandardScaler`
- Observed that scaling/transformation did not improve final performance in this setup
- Kept focus on tree-based models, which generally handle unscaled features well

## 8) Models trained and results
- Linear Regression: R2 `0.8106`, RMSE `1003.09`, MAPE `0.0639`
- Random Forest Regressor: R2 `0.9231`, RMSE `639.20`, MAPE `0.0373`
- XGBoost Regressor: R2 `0.9254`, RMSE `629.53`, MAPE `0.0364`
- LightGBM Regressor: R2 `0.9253`, RMSE `629.99`, MAPE `0.0362`
- ExtraTrees Regressor: R2 `0.9253`, RMSE `629.83`, MAPE `0.0367`

## 9) Final summary
- Final processed dataframe: `91,329` rows and `25` columns
- Test set (year 2023): `9,054` rows and `23` features
- Best overall results came from XGBoost/LightGBM range, with very close scores
