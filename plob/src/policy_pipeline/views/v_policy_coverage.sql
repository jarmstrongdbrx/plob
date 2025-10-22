CREATE OR REPLACE VIEW v_policy_coverage AS (
  WITH CTE_LOAD_DATE AS (
  SELECT current_timestamp() AS LOAD_DATE
  ),
  exploded_coverage AS (
    SELECT
      bp.Policy.`Policy.Policy`.PolicyKey AS PolicyKey,
      Coverage AS coverage
    FROM prod_lakehouse.policy.bronze_policy bp
    LATERAL VIEW explode(bp.Policy.`Policy.Coverage`) cov AS Coverage
    WHERE substr(trim(bp.Policy.`Policy.Policy`.PolicyKey), 1, 1) = 'P'
  )
  SELECT 
    hash(
      coverage.CoverageKey,
      coverage.CoverageCodeKey,
      coverage.IssueDate,
      coverage.EffectiveDate,
      coverage.ExpirationDate,
      coverage.TerminationDate,
      coverage.StartDate,
      coverage.StatusActiveInd,
      coverage.LineageId
    ) AS COVERAGE_HASH_KEY,
    coverage.CoverageKey AS COVERAGE_KEY,
    coverage.CoverageCodeKey AS COVERAGE_CODE_KEY,
    coverage.IssueDate AS ISSUE_DATE,
    coverage.EffectiveDate AS EFFECTIVE_DATE,
    coverage.ExpirationDate AS EXPIRATION_DATE,
    coverage.TerminationDate AS TERMINATION_DATE,
    coverage.StartDate AS START_DATE,
    coverage.StatusActiveInd AS STATUS_ACTIVE_IND,
    coverage.SourceSystemDateCreated AS SOURCE_SYSTEM_DATE_CREATED,
    coverage.SourceSystemDateModified AS SOURCE_SYSTEM_DATE_MODIFIED,
    cast(NULL as timestamp) AS END_DATE,
    coverage.LoadDate AS POLICY_EXTRACT_LOAD_DATE,
    coverage.LineageId AS LINEAGE_ID,
    (SELECT LOAD_DATE FROM CTE_LOAD_DATE) AS LOAD_DATE,
    CC.COVERAGE_CODE_NAME,
    CC.COVERAGE_CODE_DESC
  FROM exploded_coverage
  JOIN prod_lakehouse.dev_john_armstrong_policy.v_policy_coverage_code CC
    ON upper(exploded_coverage.coverage.CoverageCodeKey) = upper(CC.COVERAGE_CODE_KEY)
);