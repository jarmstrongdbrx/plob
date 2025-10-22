CREATE OR REPLACE VIEW v_policy_coverage_code AS (
  SELECT DISTINCT
    TRIM(COALESCE(cov.CoverageCodeKey, '')) AS COVERAGE_CODE_KEY,
    TRIM(COALESCE(cov.CoverageCode, '')) AS COVERAGE_CODE,
    TRIM(COALESCE(cov.CoverageCodeName, '')) AS COVERAGE_CODE_NAME,
    TRIM(COALESCE(cov.CoverageCodeDesc, '')) AS COVERAGE_CODE_DESC
  FROM bronze_policy bp
  LATERAL VIEW EXPLODE(bp.Policy.`Policy.CoverageCode`) AS cov
);