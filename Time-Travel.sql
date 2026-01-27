CREATE TABLE tasty_bytes.raw_pos.truck_dev
    CLONE tasty_bytes.raw_pos.truck;

SELECT * FROM tasty_bytes.raw_pos.truck_dev;

SET saved_query_id = LAST_QUERY_ID();
SET saved_timestamp = CURRENT_TIMESTAMP;

UPDATE tasty_bytes.raw_pos.truck_dev t
    SET t.year = (YEAR(CURRENT_DATE()) -1000);

SHOW VARIABLES;

-- Retrieve using saved timestamp
SELECT * FROM tasty_bytes.raw_pos.truck_dev
AT (TIMESTAMP => $saved_timestamp);

-- Retrieve using saved query id
SELECT * FROM tasty_bytes.raw_pos.truck_dev
BEFORE (STATEMENT => $saved_query_id);

-- Retrieve using offset of seconds
SELECT * FROM tasty_bytes.raw_pos.truck_dev
AT (OFFSET => -200);
