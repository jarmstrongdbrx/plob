CREATE OR REPLACE VIEW V_POLICY_TRANSACTION AS

WITH CTE_LOAD_DATE AS (
    SELECT current_timestamp() AS LOAD_DATE
)

SELECT DISTINCT 
    sha2(concat(
        COALESCE(UPPER(TRIM(POLICY_KEY)),''),
        '||', '',  -- LAYER_KEY doesn't exist, using empty string
        '||', COALESCE(UPPER(TRIM(INSURED_OBJECT_KEY)),''),
        '||', COALESCE(UPPER(TRIM(COVERAGE_KEY)),''),
        '||', COALESCE(UPPER(TRIM(LINE_KEY)),''),
        '||', '',  -- PERIL_KEY doesn't exist, using empty string
        '||', ''   -- POLICY_VARIABLE_LEVEL_KEY doesn't exist, using empty string
    ), 256) AS POLICY_LEVELS_COMPOUND_ID,
    
    hash(
        LINK_LEVEL_NAME,
        MEASURE_DETAIL_CODE,
        MEASURE_NAME,
        ORIGINAL_CURRENCY_KEY,
        POLICY_TRANSACTION_ATTRIBUTES_KEY,
        POLICY_TRANSACTION_KEY,
        SNAPSHOT_MEASURE_IND,
        TRANSACTION_AMOUNT_OC,
        TRANSACTION_COMMENT,
        TRANSACTION_TYPE_KEY,
        TRANSACTION_DATE,
        TRANSACTION_EFFECTIVE_DATE,
        POLICY_KEY,
        '', -- layer_key
        COVERAGE_KEY,
        '', -- peril_key
        ''  -- POLICY_VARIABLE_LEVEL_KEY
    ) AS HASH_ROW,
    
    Link_Level_Name,
    MEASURE_DETAIL_CODE,
    MEASURE_NAME,
    ORIGINAL_CURRENCY_KEY,
    POLICY_TRANSACTION_ATTRIBUTES_KEY,
    POLICY_TRANSACTION_KEY,
    SNAPSHOT_MEASURE_IND,
    TRANSACTION_AMOUNT_OC,
    TRANSACTION_COMMENT,
    TRANSACTION_TYPE_KEY,
    TRANSACTION_DATE,
    TRANSACTION_EFFECTIVE_DATE,
    INSURED_OBJECT_KEY,
    LOAD_DATE,
    POLICY_KEY,
    '' AS LAYER_KEY,  -- Field doesn't exist
    COVERAGE_KEY,
    '' AS PERIL_KEY,  -- Field doesn't exist
    '' AS VARIABLE_LEVEL_KEY,  -- Field doesn't exist
    START_DATE,
    LINE_KEY,
    LINEAGE_ID,
    '' AS Transaction_Reason_Key,  -- Field doesn't exist
    POLICY_EXTRACT_LOAD_DATE,
    TRANSACTION_DATE AS TRANSACTION_ISSUE_DATE  -- Using TRANSACTION_DATE since TRANSACTION_ISSUE_DATE doesn't exist

FROM (
    SELECT DISTINCT
        TRIM(COALESCE(transaction.LinkLevelName, '')) AS Link_Level_Name,
        TRIM(COALESCE(transaction.MeasureDetailCode, '')) AS Measure_Detail_Code,
        TRIM(COALESCE(transaction.MeasureName, '')) AS Measure_Name,
        TRIM(COALESCE(transaction.OriginalCurrencyKey, '')) AS Original_Currency_Key,
        TRIM(COALESCE(transaction.PolicyTransactionAttributesKey, '')) AS Policy_Transaction_Attributes_Key,
        TRIM(COALESCE(transaction.PolicyTransactionKey, '')) AS Policy_Transaction_Key,
        TRIM(COALESCE(transaction.SnapshotMeasureInd, '')) AS Snapshot_Measure_Ind,
        COALESCE(CAST(transaction.TransactionAmount_OC AS DECIMAL(38,8)), 0) AS Transaction_Amount_OC,
        TRIM(COALESCE(transaction.TransactionComment, '')) AS Transaction_Comment,
        TRIM(COALESCE(transaction.TransactionTypeKey, '')) AS Transaction_Type_Key,
        COALESCE(CAST(transaction.TransactionDate AS TIMESTAMP), timestamp('1800-01-01')) AS Transaction_Date,
        COALESCE(CAST(transaction.TransactionEffectiveDate AS TIMESTAMP), timestamp('1800-01-01')) AS Transaction_Effective_Date,
        TRIM(COALESCE(transaction.InsuredObjectKey, '')) AS Insured_Object_Key,
        TRIM(COALESCE(transaction.PolicyKey, '')) AS POLICY_KEY,
        TRIM(COALESCE(transaction.CoverageKey, '')) AS COVERAGE_KEY,
        COALESCE(CAST(transaction.StartDate AS TIMESTAMP), timestamp('1800-01-01')) AS START_DATE,
        TRIM(COALESCE(transaction.LineKey, '')) AS Line_Key,
        COALESCE(CAST(transaction.LineageId AS BIGINT), -99) AS Lineage_Id,
        COALESCE(CAST(transaction.LoadDate AS TIMESTAMP), timestamp('1800-01-01')) AS POLICY_EXTRACT_LOAD_DATE
    FROM bronze_policy
    LATERAL VIEW OUTER explode(Policy.`Transactions.PolicyTransaction`) t AS transaction
    WHERE SUBSTRING(TRIM(COALESCE(Policy.`Policy.Policy`.PolicyKey, '')), 1, 1) = 'P'
) T
CROSS JOIN CTE_LOAD_DATE
-- WHERE TRANSACTION_AMOUNT_OC != 0.000