CREATE OR REPLACE VIEW V_POLICY_INSURED_OBJECT AS

WITH CTE_LOAD_DATE AS (
    SELECT current_timestamp() AS LOAD_DATE
)

SELECT 
    CONCAT(
        POLICY_KEY,
        INSURED_OBJECT_KEY,
        INSURED_OBJECT_PARENT_KEY,
        '', -- INSURABLE_ITEM_KEY doesn't exist
        '', -- INSURED_OBJECT_REVISION doesn't exist
        '', -- REVISION_ISSUE_DATE doesn't exist
        '', -- REVISION_EFFECTIVE_DATE doesn't exist
        '', -- REVISION_EXPIRATION_DATE doesn't exist
        ADDRESS_KEY,
        RISK_STATE,
        RISK_ADDRESS_KEY,
        INSURED_OBJECT_DESC,
        INSURED_OBJECT_NUMBER,
        INSURED_OBJECT_TYPE,
        '', -- LATTER_DATE doesn't exist
        '', -- SCHEDULED_IND doesn't exist
        '', -- STATUS_KEY doesn't exist
        '', -- STATUS_REASON_KEY doesn't exist
        '', -- STATUS_EFFECTIVE_DATE doesn't exist
        STATUS_ACTIVE_IND,
        '', -- TERMINATION_DATE doesn't exist
        '', -- TERMINATION_REASON_KEY doesn't exist
        EFFECTIVE_DATE,
        EXPIRATION_DATE,
        '' -- DELETED_IND doesn't exist
    ) AS INSURED_OBJECT_HASH_KEY,
    
    POLICY_KEY,
    INSURED_OBJECT_KEY,
    INSURED_OBJECT_PARENT_KEY,
    '' AS INSURABLE_ITEM_KEY,
    '' AS INSURED_OBJECT_REVISION,
    timestamp('1800-01-01') AS REVISION_ISSUE_DATE,
    timestamp('1800-01-01') AS REVISION_EFFECTIVE_DATE,
    timestamp('1800-01-01') AS REVISION_EXPIRATION_DATE,
    ADDRESS_KEY,
    RISK_STATE,
    RISK_ADDRESS_KEY,
    INSURED_OBJECT_DESC,
    INSURED_OBJECT_NUMBER,
    INSURED_OBJECT_TYPE,
    timestamp('1800-01-01') AS LATTER_DATE,
    '' AS SCHEDULED_IND,
    SOURCE_SYSTEM_DATE_CREATED,
    SOURCE_SYSTEM_DATE_MODIFIED,
    CAST(NULL AS TIMESTAMP) AS END_DATE,
    START_DATE,
    '' AS STATUS_KEY,
    '' AS STATUS_REASON_KEY,
    timestamp('1800-01-01') AS STATUS_EFFECTIVE_DATE,
    STATUS_ACTIVE_IND,
    timestamp('1800-01-01') AS TERMINATION_DATE,
    '' AS TERMINATION_REASON_KEY,
    EFFECTIVE_DATE,
    EXPIRATION_DATE,
    '' AS DELETED_IND,
    LOAD_DATE,
    LINEAGE_ID,
    POLICY_EXTRACT_LOAD_DATE
    
FROM (
    SELECT DISTINCT
        TRIM(COALESCE(InsuredObject.PolicyKey, '')) AS Policy_Key,
        TRIM(COALESCE(InsuredObject.InsuredObjectKey, '')) AS Insured_Object_Key,
        TRIM(COALESCE(InsuredObject.InsuredObjectParentKey, '')) AS Insured_Object_Parent_Key,
        TRIM(COALESCE(InsuredObject.AddressKey, '')) AS Address_Key,
        TRIM(COALESCE(InsuredObject.RiskState, '')) AS Risk_State,
        TRIM(COALESCE(InsuredObject.RiskAddressKey, '')) AS Risk_Address_Key,
        TRIM(COALESCE(InsuredObject.InsuredObjectDesc, '')) AS Insured_Object_Desc,
        TRIM(COALESCE(InsuredObject.InsuredObjectNumber, '')) AS Insured_Object_Number,
        TRIM(COALESCE(InsuredObject.InsuredObjectType, '')) AS Insured_Object_Type,
        COALESCE(CAST(InsuredObject.SourceSystemDateCreated AS TIMESTAMP), timestamp('1800-01-01')) AS Source_System_Date_Created,
        COALESCE(CAST(InsuredObject.SourceSystemDateModified AS TIMESTAMP), timestamp('1800-01-01')) AS Source_System_Date_Modified,
        COALESCE(CAST(InsuredObject.StartDate AS TIMESTAMP), timestamp('1800-01-01')) AS Start_Date,
        TRIM(COALESCE(InsuredObject.StatusActiveInd, '')) AS Status_Active_Ind,
        COALESCE(CAST(InsuredObject.EffectiveDate AS TIMESTAMP), timestamp('1800-01-01')) AS Effective_Date,
        COALESCE(CAST(InsuredObject.ExpirationDate AS TIMESTAMP), timestamp('1800-01-01')) AS Expiration_Date,
        COALESCE(CAST(InsuredObject.LineageId AS BIGINT), -99) AS Lineage_Id,
        COALESCE(CAST(InsuredObject.LoadDate AS TIMESTAMP), timestamp('1800-01-01')) AS POLICY_EXTRACT_LOAD_DATE
    FROM bronze_policy
    LATERAL VIEW OUTER explode(Policy.`Policy.InsuredObject`) t AS InsuredObject
) T
CROSS JOIN CTE_LOAD_DATE
WHERE SUBSTRING(POLICY_KEY, 1, 1) = 'P'