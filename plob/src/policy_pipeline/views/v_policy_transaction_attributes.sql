CREATE OR REPLACE VIEW V_POLICY_TRANSACTION_ATTRIBUTES AS

WITH CTE_LOAD_DATE AS (
    SELECT current_timestamp() AS LOAD_DATE
)

SELECT 
    Policy_Transaction_Attributes_Key,
    Column_Name,
    Column_Value,
    Load_Date,
    LineageId,
    Start_Date,
    POLICY_EXTRACT_LOAD_DATE,
    LINEAGEID AS LINEAGE_ID
FROM (
    SELECT DISTINCT 
        TRIM(COALESCE(PolicyTransactionAttributes.PolicyTransactionAttributesKey, '')) AS Policy_Transaction_Attributes_Key,
        TRIM(COALESCE(PolicyTransactionAttributes.ColumnName, '')) AS Column_Name,
        TRIM(COALESCE(PolicyTransactionAttributes.ColumnValue, '')) AS Column_Value,
        CTE_LOAD_DATE.LOAD_DATE AS Load_Date,
        COALESCE(CAST(PolicyTransactionAttributes.LineageId AS BIGINT), -99) AS LineageId,
        COALESCE(CAST(PolicyTransactionAttributes.LoadDate AS TIMESTAMP), timestamp('1800-01-01')) AS Start_Date,
        COALESCE(CAST(PolicyTransactionAttributes.LoadDate AS TIMESTAMP), timestamp('1800-01-01')) AS POLICY_EXTRACT_LOAD_DATE
    FROM bronze_policy
    CROSS JOIN CTE_LOAD_DATE
    LATERAL VIEW OUTER explode(Policy.`Policy.PolicyTransactionAttributes`) t AS PolicyTransactionAttributes
    WHERE SUBSTRING(TRIM(COALESCE(Policy.`Policy.Policy`.PolicyKey, '')), 1, 1) = 'P'
) T