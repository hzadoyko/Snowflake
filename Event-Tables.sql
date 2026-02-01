
USE DATABASE staging_tasty_bytes;
CREATE OR REPLACE SCHEMA telemetry;
CREATE OR REPLACE EVENT TABLE pipeline_events;

DESCRIBE TABLE pipeline_events;

ALTER ACCOUNT SET EVENT_TABLE = staging_tasty_bytes.telemetry.pipeline_events;