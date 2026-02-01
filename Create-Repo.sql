USE ROLE accountadmin;
CREATE DATABASE github_repo;
USE SCHEMA public;

-- Create credentials
CREATE OR REPLACE SECRET github_repo.public.github_pat
  TYPE = password
  USERNAME = 'redacted'
  PASSWORD = 'redacted';

-- Create the API integration
CREATE OR REPLACE API INTEGRATION
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('insert url here')
  ALLOWED_AUTHENTICATION_SECRETS = (github_pat)
  ENABLED = TRUE;

-- Create the git repository object
CREATE OR REPLACE GIT REPOSITORY github_repo.public.snowflake
  API_INTEGRATION = git_api_integration
  ORIGIN = 'insert url to repo here'
  GIT_CREDENTIALS = github_repo.public.github_pat;

-- List the git repositories
SHOW GIT REPOSITORIES;