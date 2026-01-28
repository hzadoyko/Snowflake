/* Sentiment from column */
SELECT SNOWFLAKE.CORTEX.SENTIMENT(content)
FROM reviews;

/* Extract Answer from a JSON column */
SELECT SNOWFLAKE.CORTEX.EXTRACT_ANSWER(menu_item_health_metrics_obj, 'What ingredients are in this item?')
FROM menu;

/* Translate a column */
SELECT SNOWFLAKE.CORTEX.TRANSLATE(item_category, 'en', 'es')
FROM menu;

/*****************************************
  Using the minstral-7b model, ask Cortex 
  to summarize the answer to a question
******************************************/
SELECT SNOWFLAKE.CORTEX.SUMMARIZE(SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b', 'What are three reasons that Snowflake is positioned to become the go-to data platform?'));

/****************************************
  Query to retrieve the items that 
  will be used in the Complete below
*****************************************/
SELECT CONCAT('Tell me why this food is tasty: ', menu_item_name)
FROM TASTY_BYTES.RAW_POS.MENU LIMIT 5;

/* Using Complete on multiple rows */
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b',
        CONCAT('Tell me why this food is tasty: ', menu_item_name)
) FROM TASTY_BYTES.RAW_POS.MENU LIMIT 5;

/************************************* 
  Examples of prompts with history
  using Complete with Cortex
**************************************/
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b',
    [
        {'role': 'system', 
        'content': 'Analyze this Snowflake review and determine the overall sentiment. Answer with just \"Positive\", \"Negative\", or \"Neutral\"' },
        {'role': 'user',
        'content': 'I love Snowflake because it is so simple to use.'}
    ],
    {}
) AS response;

SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-7b',
    [
        {'role': 'system', 
        'content': 'Analyze this Snowflake review and determine the overall sentiment. Answer with just \"Positive\", \"Negative\", or \"Neutral\"' },
        {'role': 'user',
        'content': 'I love Snowflake because it is so simple to use.'},
        {'role': 'assistant',
        'content': 'Positive. The review expresses a positive sentiment towards Snowflake, specifically mentioning that it is \"so simple to use.\'"'},
        {'role': 'user',
        'content': 'Based on other information you know about Snowflake, explain why the reviewer might feel they way they do.'}
    ],
    {}
) AS response;
