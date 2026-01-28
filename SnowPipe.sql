-- Create the storage integration
CREATE OR REPLACE STORAGE INTEGRATION S3_role_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = "REDACTED"
  STORAGE_ALLOWED_LOCATIONS = ("REDACTED");

-- Describe the storage integration to get data for completing set up on AWS
DESCRIBE INTEGRATION S3_role_integration;

-- Create the new database to house S3 data
CREATE OR REPLACE DATABASE S3_db;

-- Create the new table
CREATE OR REPLACE TABLE S3_table(item_name STRING, count INT);

USE SCHEMA S3_db.public;

-- Create stage with the link to the S3 bucket and info on the associated storage integration
CREATE OR REPLACE STAGE S3_stage
  url = ('REDACTED')
  storage_integration = S3_role_integration;

SHOW STAGES;

-- List the files in the stage
LIST @S3_stage;

-- Select the first two columns from the stage
SELECT $1, $2 FROM @S3_stage;

USE WAREHOUSE COMPUTE_WH;

-- Create the snowpipe, copying from S3_stage into S3_table
CREATE PIPE S3_db.public.S3_pipe AUTO_INGEST=TRUE AS
  COPY INTO S3_db.public.S3_table
  FROM @S3_db.public.S3_stage;

SELECT * FROM S3_db.public.S3_table;

-- See a list of all the pipes
SHOW PIPES;

-- Describe the pipe
DESCRIBE PIPE S3_db.public.S3_pipe;

-- Pause the pipe
ALTER PIPE S3_db.public.S3_pipe SET PIPE_EXECUTION_PAUSED = TRUE;

-- Drop the pipe
DROP PIPE S3_pipe;

SHOW PIPES;
