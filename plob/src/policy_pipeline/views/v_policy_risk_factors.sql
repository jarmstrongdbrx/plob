CREATE OR REPLACE VIEW V_POLICY_RISK_FACTORS AS

WITH CTE_LOAD_DATE AS (
    SELECT current_timestamp() AS LOAD_DATE
)

SELECT DISTINCT 
    sha2(concat(
        COALESCE(UPPER(TRIM(POLICY_KEY)),''),
        '||', '',  -- LAYER_KEY doesn't exist
        '||', COALESCE(UPPER(TRIM(INSURED_OBJECT_KEY)),''),
        '||', COALESCE(UPPER(TRIM(COVERAGE_KEY)),''),
        '||', COALESCE(UPPER(TRIM(LINE_KEY)),''),
        '||', '',  -- PERIL_KEY doesn't exist
        '||', ''   -- POLICY_VARIABLE_LEVEL_KEY doesn't exist
    ), 256) AS POLICY_LEVELS_COMPOUND_ID,
    
    CAST(sha2(concat(
        COALESCE(UPPER(TRIM(POLICY_KEY)),''),
        '||', COALESCE(UPPER(TRIM(RISK_FACTOR_TYPE)),''),
        '||', COALESCE(UPPER(TRIM(RISK_FACTOR_NAME)),''),
        '||', '',  -- LAYER_KEY doesn't exist
        '||', COALESCE(UPPER(TRIM(INSURED_OBJECT_KEY)),''),
        '||', COALESCE(UPPER(TRIM(COVERAGE_KEY)),''),
        '||', COALESCE(UPPER(TRIM(LINE_KEY)),''),
        '||', '',  -- PERIL_KEY doesn't exist
        '||', ''   -- POLICY_VARIABLE_LEVEL_KEY doesn't exist
    ), 256) AS VARCHAR(500)) AS RISK_FACTOR_KEY,
    
    '' AS ORIGINAL_CURRENCY_KEY,  -- Field doesn't exist
    LINK_LEVEL_NAME,
    '' AS RISK_FACTOR_CODE,  -- Field doesn't exist
    RISK_FACTOR_TYPE,
    POLICY_KEY,
    COVERAGE_KEY,
    INSURED_OBJECT_KEY,
    '' AS LAYER_KEY,  -- Field doesn't exist
    '' AS PERIL_KEY,  -- Field doesn't exist
    '' AS POLICY_VARIABLE_LEVEL_KEY,  -- Field doesn't exist
    RISK_FACTOR_NAME,
    RISK_FACTOR_VALUE,
    Source_System_Date_Created,
    Source_System_Date_Modified,
    START_DATE,
    LOAD_DATE,
    EFFECTIVE_DATE,
    EXPIRATION_DATE,
    DELETED_IND,
    LINEAGE_ID,
    '' AS DATA_VAR_IND,  -- Field doesn't exist
    timestamp('1800-01-01') AS DATA_VAR_IND_DATE,  -- Field doesn't exist
    LINE_KEY,
    POLICY_EXTRACT_LOAD_DATE

FROM (
    SELECT DISTINCT
        TRIM(COALESCE(RiskFactors.LinkLevelName, '')) AS Link_Level_Name,
        TRIM(COALESCE(RiskFactors.RiskFactorType, '')) AS Risk_Factor_Type,
        TRIM(COALESCE(RiskFactors.PolicyKey, '')) AS Policy_Key,
        TRIM(COALESCE(RiskFactors.CoverageKey, '')) AS Coverage_Key,
        TRIM(COALESCE(RiskFactors.InsuredObjectKey, '')) AS Insured_Object_Key,
        COALESCE(CAST(RiskFactors.StartDate AS TIMESTAMP), timestamp('1800-01-01')) AS Start_Date,
        TRIM(COALESCE(RiskFactors.RiskFactorName, '')) AS Risk_Factor_Name,
        TRIM(COALESCE(RiskFactors.RiskFactorValue, '')) AS Risk_Factor_Value,
        COALESCE(CAST(RiskFactors.SourceSystemDateCreated AS TIMESTAMP), timestamp('1800-01-01')) AS Source_System_Date_Created,
        COALESCE(CAST(RiskFactors.SourceSystemDateModified AS TIMESTAMP), timestamp('1800-01-01')) AS Source_System_Date_Modified,
        COALESCE(CAST(RiskFactors.EffectiveDate AS TIMESTAMP), timestamp('1800-01-01')) AS Effective_Date,
        COALESCE(CAST(RiskFactors.ExpirationDate AS TIMESTAMP), timestamp('1800-01-01')) AS Expiration_Date,
        TRIM(COALESCE(RiskFactors.DeletedInd, '0')) AS Deleted_Ind,
        COALESCE(CAST(RiskFactors.LineageId AS BIGINT), 0) AS Lineage_Id,
        TRIM(COALESCE(RiskFactors.LineKey, '')) AS Line_Key,
        COALESCE(CAST(RiskFactors.LoadDate AS TIMESTAMP), timestamp('1800-01-01')) AS POLICY_EXTRACT_LOAD_DATE
    FROM bronze_policy
    LATERAL VIEW OUTER explode(Policy.`Policy.RiskFactors`) t AS RiskFactors
    WHERE SUBSTRING(TRIM(COALESCE(Policy.`Policy.Policy`.PolicyKey, '')), 1, 1) = 'P'
        AND TRIM(COALESCE(RiskFactors.RiskFactorType, '')) NOT ILIKE 'STATCODE'
) TT
CROSS JOIN CTE_LOAD_DATE