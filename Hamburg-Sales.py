# Start Snowflake Session
from snowflake.snowpark.functions import col, max as sp_max, year, month
from snowflake.snowpark.context import get_active_session

session = get_active_session()

# Load Daily Weather from the view in Snowflake
daily_weather = session.table("tasty_bytes.harmonized.daily_weather_v")

filtered_weather = daily_weather.filter(
    (col("country_desc") == "Germany") &
    (col("city_name") == "Hamburg") &
    (year(col("date_valid_std")) == 2022) &
    (month(col("date_valid_std")) == 2)
)

# Filter, Aggregate, and Sort the results
aggregated_weather = filtered_weather.groupBy(
    "country_desc", "city_name", "date_valid_std"
).agg(
    sp_max("max_wind_speed_100m_mph").alias("max_wind_speed_100m_mph")
)

sorted_weather = aggregated_weather.sort(col("date_valid_std").desc())

# Show the results
sorted_weather.show(30)

# Create a view using the Data Frame
sorted_weather.create_or_replace_view("tasty_bytes.harmonized.windspeed_hamburg_snowpark")