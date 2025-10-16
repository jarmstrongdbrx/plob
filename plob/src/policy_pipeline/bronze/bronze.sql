CREATE OR REFRESH STREAMING TABLE bronze_policy
(
  CONSTRAINT safe_schema EXPECT (_rescued_data IS NULL)
)
AS SELECT * FROM 
cloud_files(
  '/Volumes/prod_lakehouse/${source_schema}/raw_landing_zone/policy/raw/',
  'json',
  map('multiLine', 'true', 'cloudFiles.inferColumnTypes', 'true')
)