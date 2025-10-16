CREATE OR REFRESH MATERIALIZED VIEW clarity_bronze
SELECT * FROM read_files(
  '/Volumes/prod_lakehouse/${source_schema}/raw_landing_zone/policy/CLARITY_BRONZE.csv',
  format => 'csv',
  header => true,
  mode => 'PERMISSIVE');

CREATE OR REFRESH MATERIALIZED VIEW ods_plob_mapping
SELECT * FROM read_files(
  '/Volumes/prod_lakehouse/${source_schema}/raw_landing_zone/policy/ODS_PLOB_MAPPING.csv',
  format => 'csv',
  header => true,
  mode => 'PERMISSIVE');

CREATE OR REFRESH MATERIALIZED VIEW test_policies
SELECT * FROM read_files(
  '/Volumes/prod_lakehouse/${source_schema}/raw_landing_zone/policy/Test_Policies.csv',
  format => 'csv',
  header => true,
  mode => 'PERMISSIVE');

CREATE OR REFRESH MATERIALIZED VIEW test_policies_clarity_bronze
SELECT * FROM read_files(
  '/Volumes/prod_lakehouse/${source_schema}/raw_landing_zone/policy/Test_Policies_CLARITY_BRONZE.csv',
  format => 'csv',
  header => true,
  mode => 'PERMISSIVE');