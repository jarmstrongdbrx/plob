CREATE OR REPLACE VIEW V_POLICY_EXPOSURE AS

WITH CTE_LOAD_DATE AS (
    SELECT current_timestamp() AS LOAD_DATE
)

SELECT 
    sha2(concat(
        COALESCE(UPPER(TRIM(POLICY_KEY)),''),
        '||', COALESCE(UPPER(TRIM(LAYER_KEY)),''),
        '||', COALESCE(UPPER(TRIM(INSURED_OBJECT_KEY)),''),
        '||', COALESCE(UPPER(TRIM(COVERAGE_KEY)),''),
        '||', COALESCE(UPPER(TRIM(LINE_KEY)),''),
        '||', COALESCE(UPPER(TRIM(PERIL_KEY)),''),
        '||', COALESCE(UPPER(TRIM(POLICY_VARIABLE_LEVEL_KEY)),'')
    ), 256) AS POLICY_LEVELS_COMPOUND_ID,
    
    hash(
        LINK_LEVEL_NAME,
        POLICY_KEY,
        LAYER_KEY,
        INSURED_OBJECT_KEY,
        EXPOSURE_KEY,
        PERIL_KEY,
        POLICY_VARIABLE_LEVEL_KEY,
        EXPOSURE_TYPE,
        RISK_STATE,
        RISK_ADDRESS_KEY,
        EXPOSURE_NAME,
        CLASS_CODE_QUAL,
        EXPOSURE_CLASS_CODE,
        CLASS_CODE_DESCRIPTION,
        EXPOSURE_VALUE,
        EXPOSURE_AMOUNT,
        EXPOSURE_AMOUNT_OC,
        GOVERNING_IND,
        EFFECTIVE_DATE,
        EXPIRATION_DATE,
        ORIGINAL_CURRENCY_KEY,
        TRANSACTION_EFFECTIVE_DATE,
        DATA_VAR_IND,
        DATA_VAR_IND_DATE,
        LINE_KEY,
        coverage_key
    ) AS HASH_ROW,
    
    LINK_LEVEL_NAME,
    POLICY_KEY,
    LAYER_KEY,
    INSURED_OBJECT_KEY,
    EXPOSURE_KEY,
    PERIL_KEY,
    POLICY_VARIABLE_LEVEL_KEY,
    EXPOSURE_TYPE,
    RISK_STATE,
    RISK_ADDRESS_KEY,
    EXPOSURE_NAME,
    CLASS_CODE_QUAL,
    EXPOSURE_CLASS_CODE,
    CLASS_CODE_DESCRIPTION,
    EXPOSURE_VALUE,
    EXPOSURE_AMOUNT,
    EXPOSURE_AMOUNT_OC,
    GOVERNING_IND,
    EFFECTIVE_DATE,
    EXPIRATION_DATE,
    SOURCE_SYSTEM_DATE_CREATED,
    SOURCE_SYSTEM_DATE_MODIFIED,
    START_DATE,
    ORIGINAL_CURRENCY_KEY,
    TRANSACTION_EFFECTIVE_DATE,
    LOAD_DATE,
    DATA_VAR_IND,
    DATA_VAR_IND_DATE,
    LINE_KEY,
    coverage_key,
    SUBSTRING(POLICY_KEY, 1, 1) AS Entity_Type,
    Lineage_Id,
    POLICY_EXTRACT_LOAD_DATE

FROM (
    SELECT DISTINCT 
        TRIM(COALESCE(Exposure.LinkLevelName, '')) AS Link_Level_Name,
        TRIM(COALESCE(Exposure.PolicyKey, '')) AS Policy_Key,
        '' AS Layer_Key,  -- Field doesn't exist
        TRIM(COALESCE(Exposure.InsuredObjectKey, '')) AS Insured_Object_Key,
        CAST(TRIM(COALESCE(concat(
            TRIM(COALESCE(Exposure.ExposureType, '')), '||',
            TRIM(COALESCE(Exposure.ExposureName, '')), '||',
            TRIM(COALESCE(Exposure.ClassCodeQual, '')), '||',
            TRIM(COALESCE(Exposure.PolicyKey, '')), '||',
            TRIM(COALESCE(Exposure.InsuredObjectKey, '')), '||',
            '', '||',  -- LayerKey doesn't exist
            TRIM(COALESCE(Exposure.CoverageKey, '')), '||',
            TRIM(COALESCE(Exposure.LineKey, '')), '||',
            '', '||',  -- PolicyVariableLevelKey doesn't exist
            '', '||',  -- PerilKey doesn't exist
            TRIM(COALESCE(Exposure.ExposureClassCode, ''))
        ), '')) AS VARCHAR(500)) AS EXPOSURE_KEY,
        COALESCE(CAST(Exposure.StartDate AS TIMESTAMP), timestamp('1800-01-01')) AS Start_Date,
        '' AS Peril_Key,  -- Field doesn't exist
        '' AS Policy_Variable_Level_Key,  -- Field doesn't exist
        TRIM(COALESCE(Exposure.ExposureType, '')) AS Exposure_Type,
        TRIM(COALESCE(Exposure.RiskState, '')) AS Risk_State,
        '' AS Risk_Address_Key,  -- Field doesn't exist
        TRIM(COALESCE(Exposure.ExposureName, '')) AS Exposure_Name,
        TRIM(COALESCE(Exposure.ClassCodeQual, '')) AS Class_Code_Qual,
        TRIM(COALESCE(Exposure.ExposureClassCode, '')) AS Exposure_Class_Code,
        TRIM(COALESCE(Exposure.ClassCodeDescription, '')) AS Class_Code_Description,
        TRIM(COALESCE(Exposure.ExposureValue, '')) AS Exposure_Value,
        0 AS Exposure_Amount,  -- Field doesn't exist
        0 AS Exposure_Amount_OC,  -- Field doesn't exist
        '' AS Governing_Ind,  -- Field doesn't exist
        COALESCE(CAST(Exposure.EffectiveDate AS TIMESTAMP), timestamp('1800-01-01')) AS Effective_Date,
        COALESCE(CAST(Exposure.ExpirationDate AS TIMESTAMP), timestamp('1800-01-01')) AS Expiration_Date,
        COALESCE(CAST(Exposure.SourceSystemDateCreated AS TIMESTAMP), timestamp('1800-01-01')) AS Source_System_Date_Created,
        COALESCE(CAST(Exposure.SourceSystemDateModified AS TIMESTAMP), timestamp('1800-01-01')) AS Source_System_Date_Modified,
        '' AS Original_Currency_Key,  -- Field doesn't exist
        COALESCE(CAST(Exposure.TransactionEffectiveDate AS TIMESTAMP), timestamp('1800-01-01')) AS Transaction_Effective_Date,
        '0' AS DATA_VAR_IND,  -- Field doesn't exist
        timestamp('1800-01-01') AS Data_Var_Ind_Date,  -- Field doesn't exist
        TRIM(COALESCE(Exposure.LineKey, '')) AS Line_Key,
        TRIM(COALESCE(Exposure.CoverageKey, '')) AS Coverage_Key,
        COALESCE(CAST(Exposure.LineageId AS BIGINT), -99) AS Lineage_Id,
        COALESCE(CAST(Exposure.LoadDate AS TIMESTAMP), timestamp('1800-01-01')) AS POLICY_EXTRACT_LOAD_DATE
    FROM bronze_policy
    LATERAL VIEW OUTER explode(Policy.`Policy.Exposure`) t AS Exposure
    WHERE SUBSTRING(TRIM(COALESCE(Policy.`Policy.Policy`.PolicyKey, '')), 1, 1) = 'P'
) TT
CROSS JOIN CTE_LOAD_DATE