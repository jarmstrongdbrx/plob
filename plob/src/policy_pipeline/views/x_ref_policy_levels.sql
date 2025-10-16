CREATE OR REPLACE VIEW v_xref_policy_levels(
	POLICY_LEVELS_COMPOUND_ID,
	POLICY_KEY,
	POLICY_START_DATE,
	INSURED_OBJECT_KEY,
	INSURED_OBJECT_START_DATE,
	COVERAGE_KEY,
	COVERAGE_START_DATE,
	LAYER_KEY,
	LAYER_START_DATE,
	PERIL_KEY,
	PERIL_START_DATE,
	POLICY_VARIABLE_LEVEL_KEY,
	POLICY_VARIABLE_LEVEL_START_DATE,
	REPORTING_LINE_OF_INSURANCE_KEY,
	REPORTING_LINE_OF_INSURANCE_DESC,
	AS_LOB_KEY,
	SUBLINE_KEY,
	SUB_LINE_DESC,
	LINE_OF_INSURANCE_KEY,
	LINE_OF_INSURANCE_DESC,
	PRODUCT_KEY,
	GRAN_LEVEL_HASH,
	END_DATE,
	START_DATE,
	TRANSACTION_EFFECTIVE_DATE,
	LOAD_DATE,
	LINE_KEY,
	LINEAGE_ID,
	POLICY_EXTRACT_LOAD_DATE
) as

with 
CTE_LOAD_DATE  
 AS
 (
 SELECT
 current_timestamp() AS LOAD_DATE
 )   

  SELECT POLICY_LEVELS_COMPOUND_ID,
	POLICY_KEY,Policy_Start_Date,
	INSURED_OBJECT_KEY,Insured_Object_Start_Date,
	COVERAGE_KEY,Coverage_Start_Date,
	LAYER_KEY,Layer_Start_Date,
	PERIL_KEY,Peril_Start_Date,
	POLICY_VARIABLE_LEVEL_KEY,POLICY_VARIABLE_LEVEL_START_DATE,
	REPORTING_LINE_OF_INSURANCE_KEY,
	REPORTING_LINE_OF_INSURANCE_KEY AS REPORTING_LINE_OF_INSURANCE_DESC,
	AS_LOB_KEY,
	SUB_LINE_KEY AS SUBLINE_KEY,
	trim(coalesce(cast(null as string), '')) AS Sub_line_Desc,
	LINE_OF_INSURANCE_KEY,
	LINE_OF_INSURANCE_KEY AS LINE_OF_INSURANCE_DESC,
	PRODUCT_KEY,
	GRAN_LEVEL_HASH,
    cast(null as timestamp) AS END_DATE,
	START_DATE,Transaction_Effective_Date
,LOAD_DATE
,Line_Key,Lineage_Id 
,POLICY_EXTRACT_LOAD_DATE
    FROM (
        SELECT  
		sha2(concat_ws('||',
			upper(trim(coalesce(POLICY_KEY, ''))),
			upper(trim(coalesce(LAYER_KEY, ''))),
			upper(trim(coalesce(INSURED_OBJECT_KEY, ''))),
			upper(trim(coalesce(COVERAGE_KEY, ''))),
			upper(trim(coalesce(LINE_KEY, ''))),
			upper(trim(coalesce(PERIL_KEY, ''))),
			upper(trim(coalesce(POLICY_VARIABLE_LEVEL_KEY, '')))
		), 256) AS POLICY_LEVELS_COMPOUND_ID   
   
		,POLICY_KEY,POLICY_START_DATE
		,INSURED_OBJECT_KEY,INSURED_OBJECT_START_DATE
		,COVERAGE_KEY,COVERAGE_START_DATE
		,LAYER_KEY,LAYER_START_DATE
		,PERIL_KEY,PERIL_START_DATE
		,POLICY_VARIABLE_LEVEL_KEY,POLICY_VARIABLE_LEVEL_START_DATE
		,REPORTING_LINE_OF_INSURANCE_KEY
		,AS_LOB_KEY
		,SUB_LINE_KEY
		,LINE_OF_INSURANCE_KEY
		,PRODUCT_KEY
		,GRAN_LEVEL_HASH
		 ,cast( null as timestamp) AS END_DATE
		,START_DATE,TRANSACTION_EFFECTIVE_DATE 
		,LINE_KEY
		,LINEAGE_ID
        ,POLICY_EXTRACT_LOAD_DATE
   

      FROM (
       SELECT     DISTINCT      
		(trim(coalesce(xref.PolicyKey, ''))) AS POLICY_KEY,
		to_timestamp(coalesce(xref.PolicyStartDate, '1800-01-01')) AS POLICY_START_DATE,
		(trim(coalesce(xref.InsuredObjectKey, ''))) AS INSURED_OBJECT_KEY,
		to_timestamp(coalesce(xref.InsuredObjectStartDate, '1800-01-01')) AS INSURED_OBJECT_START_DATE,
		(trim(coalesce(xref.CoverageKey, ''))) AS COVERAGE_KEY,
		to_timestamp(coalesce(xref.CoverageStartDate, '1800-01-01')) AS COVERAGE_START_DATE,
		(trim(coalesce(cast(null as string), ''))) AS LAYER_KEY,
		to_timestamp(coalesce(cast(null as string), '1800-01-01')) AS LAYER_START_DATE,
		(trim(coalesce(cast(null as string), ''))) AS PERIL_KEY,
		to_timestamp(coalesce(cast(null as string), '1800-01-01')) AS PERIL_START_DATE,
		(trim(coalesce(cast(null as string), ''))) AS POLICY_VARIABLE_LEVEL_KEY,
		to_timestamp(coalesce(cast(null as string), '1800-01-01')) AS POLICY_VARIABLE_LEVEL_START_DATE,
		(trim(coalesce(cast(null as string), ''))) AS REPORTING_LINE_OF_INSURANCE_KEY,
		(trim(coalesce(xref.ASLOBKey, ''))) AS AS_LOB_KEY,
		(trim(coalesce(xref.SublineKey, ''))) AS SUB_LINE_KEY,
		(trim(coalesce(xref.LineOfInsuranceKey, ''))) AS LINE_OF_INSURANCE_KEY,
		(trim(coalesce(xref.ProductKey, ''))) AS PRODUCT_KEY,
		to_timestamp(coalesce(xref.StartDate, '1800-01-01')) AS START_DATE,
		to_timestamp(coalesce(xref.TransactionEffectiveDate, '1800-01-01')) AS TRANSACTION_EFFECTIVE_DATE,
		(trim(coalesce(cast(null as string), ''))) AS GRAN_LEVEL_HASH,
		(trim(coalesce(xref.LineKey, ''))) AS LINE_KEY,
		cast(coalesce(xref.LineageId, '-99') as bigint) AS LINEAGE_ID,
		to_timestamp(coalesce(xref.LoadDate, '1800-01-01')) AS POLICY_EXTRACT_LOAD_DATE
	FROM bronze_policy
	LATERAL VIEW EXPLODE(Policy.`Policy.XrefPolicyLevels`) xref_table AS xref
	WHERE substring(trim(coalesce(xref.PolicyKey, '')), 1, 1) = 'P'
	 )T
    )
	CROSS JOIN CTE_LOAD_DATE;