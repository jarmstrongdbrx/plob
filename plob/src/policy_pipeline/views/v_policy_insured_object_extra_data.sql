CREATE OR REPLACE VIEW V_POLICY_INSURED_OBJECT_EXTRA_DATA AS

WITH CTE_LOAD_DATE AS (
    SELECT current_timestamp() AS LOAD_DATE
)

SELECT DISTINCT 
    TRIM(COALESCE(InsuredObjectExtraData.PolicyKey, '')) AS Policy_Key,
    TRIM(COALESCE(InsuredObjectExtraData.InsuredObjectKey, '')) AS Insured_Object_Key,
    COALESCE(CAST(InsuredObjectExtraData.StartDate AS TIMESTAMP), timestamp('1800-01-01')) AS Start_Date,
    TRIM(COALESCE(InsuredObjectExtraData.ColumnName, '')) AS Column_Name,
    TRIM(COALESCE(InsuredObjectExtraData.ColumnValue, '')) AS Column_Value,
    COALESCE(CAST(InsuredObjectExtraData.EffectiveDate AS TIMESTAMP), timestamp('1800-01-01')) AS Effective_Date,
    COALESCE(CAST(InsuredObjectExtraData.ExpirationDate AS TIMESTAMP), timestamp('1800-01-01')) AS Expiration_Date,
    current_timestamp() AS LOAD_DATE,
    COALESCE(CAST(InsuredObjectExtraData.LineageId AS BIGINT), -99) AS Lineage_Id,
    COALESCE(CAST(InsuredObjectExtraData.LoadDate AS TIMESTAMP), timestamp('1800-01-01')) AS POLICY_EXTRACT_LOAD_DATE
FROM bronze_policy
LATERAL VIEW OUTER explode(Policy.`Policy.InsuredObjectExtraData`) t AS InsuredObjectExtraData
WHERE SUBSTRING(TRIM(COALESCE(Policy.`Policy.Policy`.PolicyKey, '')), 1, 1) = 'P'