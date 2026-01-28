-- Query to use Cortex to summarize the content of a column in a table
SELECT SNOWFLAKE.CORTEX.SUMMARIZE(content)
FROM reviews;

-- Query to use Cortex to extract sentiment of a column in a table
SELECT SNOWFLAKE.CORTEX.SENTIMENT(content)
FROM reviews;

--Query to use Cortex to extract answers from a column in a table
SELECT SNOWFLAKE.CORTEX.EXTRACT_ANSWER(menu_item_health_metrics_obj, 'What ingredients are in this item?')
FROM menu;

-- Query to use Cortex to translate a column
SELECT SNOWFLAKE.CORTEX.TRANSLATE(item_category, 'en', 'es')
FROM menu;
