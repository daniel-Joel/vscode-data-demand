/*  
--建表语句
CREATE TABLE B_GEMS_LOAN_BAL_SUM_OF_LMSM(
ACCTG_DT DATE,
INST_ID VARCHAR(100),
INST_NME VARCHAR(100),
INST_LEVEL VARCHAR(100),
INDEX_CODE VARCHAR(100),
INDEX_VALUE NUMBER(18,2)
);
 */

--删除当月数据/重跑
DELETE FROM
    B_GEMS_LOAN_BAL_SUM_OF_LMSM
WHERE
    ACCTG_DT = TO_DATE ('2024-10-31', 'YYYY-MM-DD');

/*
SELECT * FROM B_GEMS_LOAN_BAL_SUM_OF_LMSM;
 */

INSERT INTO
    B_GEMS_LOAN_BAL_SUM_OF_LMSM
    
--指标 12AA/22AA
SELECT
    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
    COALESCE(INST_ID, DOMN_INST_ID, PROV_INST_ID, DOME_INST_ID) INST_ID,
    COALESCE(
        INST_NME,
        DOMN_INST_NME,
        PROV_INST_NME,
        DOME_INST_NME
    ) INST_NME,
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) INST_LEVEL,
    INDEX_CODE,
    INDEX_VALUE
FROM
    (
        SELECT
            TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
            INST_ID,
            INST_NME,
            INST_LEVEL_4,
            DOMN_INST_ID,
            DOMN_INST_NME,
            INST_LEVEL_3,
            PROV_INST_ID,
            PROV_INST_NME,
            INST_LEVEL_2,
            DOME_INST_ID,
            DOME_INST_NME,
            INST_LEVEL_1,
            INDEX_CODE,
            SUM(INDEX_VALUE) INDEX_VALUE
        FROM
            (
                SELECT
                    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
                    T2.INST_ID,
                    T2.INST_NME,
                    T2.INST_LEVEL_4,
                    COALESCE(T2.INST_LEVEL_3, T2_1.INST_LEVEL_3) INST_LEVEL_3,
                    COALESCE(T2.DOMN_INST_ID, T2_1.DOMN_INST_ID) DOMN_INST_ID,
                    COALESCE(T2.DOMN_INST_NME, T2_1.DOMN_INST_NME) DOMN_INST_NME,
                    COALESCE(T2.INST_LEVEL_2, T2_1.INST_LEVEL_2) INST_LEVEL_2,
                    COALESCE(T2.PROV_INST_ID, T2_1.PROV_INST_ID) PROV_INST_ID,
                    COALESCE(T2.PROV_INST_NME, T2_1.PROV_INST_NME) PROV_INST_NME,
                    COALESCE(T2.INST_LEVEL_1, T2_1.INST_LEVEL_1) INST_LEVEL_1,
                    COALESCE(T2.DOME_INST_ID, T2_1.DOME_INST_ID) DOME_INST_ID,
                    COALESCE(T2.DOME_INST_NME, T2_1.DOME_INST_NME) DOME_INST_NME,
                    (
                        CASE
                            WHEN T1.ACCTG_SBJEC_ID LIKE '121%' THEN '12AA'
                            WHEN T1.ACCTG_SBJEC_ID LIKE '123%' THEN '22AA'
                        END
                    ) AS INDEX_CODE,
                    T1.BAL * NVL (T3.RATE, 1) AS INDEX_VALUE
                FROM
                    B_GEMS_LOAN_INFO T1
                    
					--基础表连接机构表 入账机构在4级机构
                    LEFT JOIN (
                        SELECT
                            '4' AS INST_LEVEL_4,
                            INST_ID,
                            INST_NME,
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            INST_ID,
                            INST_NME,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2 ON T1.ACTOPE_INST_ID = T2.INST_ID
                    
					--基础表连接机构表 入账机构在3级机构
                    LEFT JOIN (
                        SELECT
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2_1 ON T1.ACTOPE_INST_ID = T2_1.DOMN_INST_ID
					
                    --基础表连接汇率表，余额转人民币
                    LEFT JOIN CCY_RATE T3 ON T1.CCY = T3.CCY_OLD
                    AND T3.CCY_NEW = 'CNY'
                    AND T3.COUNT_FLG = '00'
                    AND T3.BGN_DT <= TO_DATE ('20241031', 'YYYYMMDD')
                    AND T3.END_DT > TO_DATE ('20241031', 'YYYYMMDD')
					
                    --过滤当月余额大于0
                WHERE
                    T1.ACCTG_DT = '20241031'
                    AND T1.BAL > 0
            )
            
			--按机构层级分组   
        GROUP BY
            GROUPING SETS (
                (INST_ID, INST_NME, INST_LEVEL_4, INDEX_CODE),
                (
                    DOMN_INST_ID,
                    DOMN_INST_NME,
                    INST_LEVEL_3,
                    INDEX_CODE
                ),
                (
                    PROV_INST_ID,
                    PROV_INST_NME,
                    INST_LEVEL_2,
                    INDEX_CODE
                ),
                (
                    DOME_INST_ID,
                    DOME_INST_NME,
                    INST_LEVEL_1,
                    INDEX_CODE
                )
            )
    )
	
    --直接在3级机构入账的记录在4级机构分组中为空 需要过滤掉
WHERE
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) IS NOT NULL

--拼接下一个指标	
UNION ALL

--指标 12AB/12AC/12AD
SELECT
    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
    COALESCE(INST_ID, DOMN_INST_ID, PROV_INST_ID, DOME_INST_ID) INST_ID,
    COALESCE(
        INST_NME,
        DOMN_INST_NME,
        PROV_INST_NME,
        DOME_INST_NME
    ) INST_NME,
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) INST_LEVEL,
    INDEX_CODE,
    INDEX_VALUE
FROM
    (
        SELECT
            TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
            INST_ID,
            INST_NME,
            INST_LEVEL_4,
            DOMN_INST_ID,
            DOMN_INST_NME,
            INST_LEVEL_3,
            PROV_INST_ID,
            PROV_INST_NME,
            INST_LEVEL_2,
            DOME_INST_ID,
            DOME_INST_NME,
            INST_LEVEL_1,
            INDEX_CODE,
            SUM(INDEX_VALUE) INDEX_VALUE
        FROM
            (
                SELECT
                    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
                    T2.INST_ID,
                    T2.INST_NME,
                    T2.INST_LEVEL_4,
                    COALESCE(T2.INST_LEVEL_3, T2_1.INST_LEVEL_3) INST_LEVEL_3,
                    COALESCE(T2.DOMN_INST_ID, T2_1.DOMN_INST_ID) DOMN_INST_ID,
                    COALESCE(T2.DOMN_INST_NME, T2_1.DOMN_INST_NME) DOMN_INST_NME,
                    COALESCE(T2.INST_LEVEL_2, T2_1.INST_LEVEL_2) INST_LEVEL_2,
                    COALESCE(T2.PROV_INST_ID, T2_1.PROV_INST_ID) PROV_INST_ID,
                    COALESCE(T2.PROV_INST_NME, T2_1.PROV_INST_NME) PROV_INST_NME,
                    COALESCE(T2.INST_LEVEL_1, T2_1.INST_LEVEL_1) INST_LEVEL_1,
                    COALESCE(T2.DOME_INST_ID, T2_1.DOME_INST_ID) DOME_INST_ID,
                    COALESCE(T2.DOME_INST_NME, T2_1.DOME_INST_NME) DOME_INST_NME,
                    (
                        CASE
                            WHEN T4.ENTP_SCAL_CD IN ('01', '02') THEN '12AB'
                            WHEN T4.ENTP_SCAL_CD = '03' THEN '12AC'
                            WHEN T4.ENTP_SCAL_CD = '04' THEN '12AD'
                        END
                    ) AS INDEX_CODE,
                    T1.BAL * NVL (T3.RATE, 1) AS INDEX_VALUE
                FROM
                    B_GEMS_LOAN_INFO T1
					
                    --基础表连接机构表 入账机构在4级机构
                    LEFT JOIN (
                        SELECT
                            '4' AS INST_LEVEL_4,
                            INST_ID,
                            INST_NME,
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            INST_ID,
                            INST_NME,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2 ON T1.ACTOPE_INST_ID = T2.INST_ID
					
                    --基础表连接机构表 入账机构在3级机构
                    LEFT JOIN (
                        SELECT
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2_1 ON T1.ACTOPE_INST_ID = T2_1.DOMN_INST_ID
					
                    --基础表连接汇率表，余额转人民币
                    LEFT JOIN CCY_RATE T3 ON T1.CCY = T3.CCY_OLD
                    AND T3.CCY_NEW = 'CNY'
                    AND T3.COUNT_FLG = '00'
                    AND T3.BGN_DT <= TO_DATE ('20241031', 'YYYYMMDD')
                    AND T3.END_DT > TO_DATE ('20241031', 'YYYYMMDD')
					
                    --基础表连接客户表，获取企业规模
                    LEFT JOIN B_ECIF_CUST_INFO_C T4 ON T1.CUST_ID = T4.CUST_ID
                    AND T4.ACCTG_DT = '20241031'
					
                    --过滤当月余额大于0
                WHERE
                    T1.ACCTG_DT = '20241031'
                    AND T1.BAL > 0
					
                    --且属于121/123类
                    AND (
                        T1.ACCTG_SBJEC_ID LIKE '123%'
                        OR T1.ACCTG_SBJEC_ID LIKE '121%'
                    )
            )
			
            --按机构层级分组   
        GROUP BY
            GROUPING SETS (
                (INST_ID, INST_NME, INST_LEVEL_4, INDEX_CODE),
                (
                    DOMN_INST_ID,
                    DOMN_INST_NME,
                    INST_LEVEL_3,
                    INDEX_CODE
                ),
                (
                    PROV_INST_ID,
                    PROV_INST_NME,
                    INST_LEVEL_2,
                    INDEX_CODE
                ),
                (
                    DOME_INST_ID,
                    DOME_INST_NME,
                    INST_LEVEL_1,
                    INDEX_CODE
                )
            )
    )
	
    --直接在3级机构入账的记录在4级机构分组中为空 需要过滤掉
WHERE
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) IS NOT NULL

--拼接下一个指标
UNION ALL

--指标 12AB/12AC/12AD 带数字
SELECT
    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
    COALESCE(INST_ID, DOMN_INST_ID, PROV_INST_ID, DOME_INST_ID) INST_ID,
    COALESCE(
        INST_NME,
        DOMN_INST_NME,
        PROV_INST_NME,
        DOME_INST_NME
    ) INST_NME,
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) INST_LEVEL,
    INDEX_CODE,
    INDEX_VALUE
FROM
    (
        SELECT
            TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
            INST_ID,
            INST_NME,
            INST_LEVEL_4,
            DOMN_INST_ID,
            DOMN_INST_NME,
            INST_LEVEL_3,
            PROV_INST_ID,
            PROV_INST_NME,
            INST_LEVEL_2,
            DOME_INST_ID,
            DOME_INST_NME,
            INST_LEVEL_1,
            INDEX_CODE,
            SUM(INDEX_VALUE) INDEX_VALUE
        FROM
            (
                SELECT
                    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
                    T2.INST_ID,
                    T2.INST_NME,
                    T2.INST_LEVEL_4,
                    COALESCE(T2.INST_LEVEL_3, T2_1.INST_LEVEL_3) INST_LEVEL_3,
                    COALESCE(T2.DOMN_INST_ID, T2_1.DOMN_INST_ID) DOMN_INST_ID,
                    COALESCE(T2.DOMN_INST_NME, T2_1.DOMN_INST_NME) DOMN_INST_NME,
                    COALESCE(T2.INST_LEVEL_2, T2_1.INST_LEVEL_2) INST_LEVEL_2,
                    COALESCE(T2.PROV_INST_ID, T2_1.PROV_INST_ID) PROV_INST_ID,
                    COALESCE(T2.PROV_INST_NME, T2_1.PROV_INST_NME) PROV_INST_NME,
                    COALESCE(T2.INST_LEVEL_1, T2_1.INST_LEVEL_1) INST_LEVEL_1,
                    COALESCE(T2.DOME_INST_ID, T2_1.DOME_INST_ID) DOME_INST_ID,
                    COALESCE(T2.DOME_INST_NME, T2_1.DOME_INST_NME) DOME_INST_NME,
                    (
                        CASE
                            WHEN T4.ENTP_SCAL_CD IN ('01', '02')
                            AND T5.CREDIT_LMT < 5000000 THEN '12AB1'
                            WHEN T4.ENTP_SCAL_CD IN ('01', '02')
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12AB2'
                            WHEN T4.ENTP_SCAL_CD IN ('01', '02')
                            AND T5.CREDIT_LMT >= 10000000 THEN '12AB3'
                            WHEN T4.ENTP_SCAL_CD = '03'
                            AND T5.CREDIT_LMT < 5000000 THEN '12AC1'
                            WHEN T4.ENTP_SCAL_CD = '03'
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12AC2'
                            WHEN T4.ENTP_SCAL_CD = '03'
                            AND T5.CREDIT_LMT >= 10000000 THEN '12AC3'
                            WHEN T4.ENTP_SCAL_CD = '04'
                            AND T5.CREDIT_LMT < 5000000 THEN '12AD1'
                            WHEN T4.ENTP_SCAL_CD = '04'
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12AD2'
                            WHEN T4.ENTP_SCAL_CD = '04'
                            AND T5.CREDIT_LMT >= 10000000 THEN '12AD3'
                        END
                    ) AS INDEX_CODE,
                    T1.BAL * NVL (T3.RATE, 1) AS INDEX_VALUE
                FROM
                    B_GEMS_LOAN_INFO T1
					
                    --基础表连接机构表 入账机构在4级机构
                    LEFT JOIN (
                        SELECT
                            '4' AS INST_LEVEL_4,
                            INST_ID,
                            INST_NME,
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            INST_ID,
                            INST_NME,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2 ON T1.ACTOPE_INST_ID = T2.INST_ID
					
                    --基础表连接机构表 入账机构在3级机构
                    LEFT JOIN (
                        SELECT
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2_1 ON T1.ACTOPE_INST_ID = T2_1.DOMN_INST_ID
					
                    --基础表连接汇率表，余额转人民币
                    LEFT JOIN CCY_RATE T3 ON T1.CCY = T3.CCY_OLD
                    AND T3.CCY_NEW = 'CNY'
                    AND T3.COUNT_FLG = '00'
                    AND T3.BGN_DT <= TO_DATE ('20241031', 'YYYYMMDD')
                    AND T3.END_DT > TO_DATE ('20241031', 'YYYYMMDD')
					
                    --基础表连接客户表，获取企业规模
                    LEFT JOIN B_ECIF_CUST_INFO_C T4 ON T1.CUST_ID = T4.CUST_ID
                    AND T4.ACCTG_DT = '20241031'
					
                    --基础表连接授信表，获取授信额度
                    LEFT JOIN B_ECIF_CUST_LMT T5 ON T1.CUST_ID = T5.CUST_ID
                    AND T5.ACCTG_DT = '20241031'
					
                    --过滤当月余额大于0
                WHERE
                    T1.ACCTG_DT = '20241031'
                    AND T1.BAL > 0
					
                    --且属于121/123类
                    AND (
                        T1.ACCTG_SBJEC_ID LIKE '123%'
                        OR T1.ACCTG_SBJEC_ID LIKE '121%'
                    )
            )
			
            --按机构层级分组   
        GROUP BY
            GROUPING SETS (
                (INST_ID, INST_NME, INST_LEVEL_4, INDEX_CODE),
                (
                    DOMN_INST_ID,
                    DOMN_INST_NME,
                    INST_LEVEL_3,
                    INDEX_CODE
                ),
                (
                    PROV_INST_ID,
                    PROV_INST_NME,
                    INST_LEVEL_2,
                    INDEX_CODE
                ),
                (
                    DOME_INST_ID,
                    DOME_INST_NME,
                    INST_LEVEL_1,
                    INDEX_CODE
                )
            )
    )
	
    --直接在3级机构入账的记录在4级机构分组中为空 需要过滤掉
WHERE
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) IS NOT NULL
--拼接下一个指标
UNION ALL

--指标 12BA/BB/BC/BD/BE
SELECT
    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
    COALESCE(INST_ID, DOMN_INST_ID, PROV_INST_ID, DOME_INST_ID) INST_ID,
    COALESCE(
        INST_NME,
        DOMN_INST_NME,
        PROV_INST_NME,
        DOME_INST_NME
    ) INST_NME,
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) INST_LEVEL,
    INDEX_CODE,
    INDEX_VALUE
FROM
    (
        SELECT
            TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
            INST_ID,
            INST_NME,
            INST_LEVEL_4,
            DOMN_INST_ID,
            DOMN_INST_NME,
            INST_LEVEL_3,
            PROV_INST_ID,
            PROV_INST_NME,
            INST_LEVEL_2,
            DOME_INST_ID,
            DOME_INST_NME,
            INST_LEVEL_1,
            INDEX_CODE,
            SUM(INDEX_VALUE) INDEX_VALUE
        FROM
            (
                SELECT
                    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
                    T2.INST_ID,
                    T2.INST_NME,
                    T2.INST_LEVEL_4,
                    COALESCE(T2.INST_LEVEL_3, T2_1.INST_LEVEL_3) INST_LEVEL_3,
                    COALESCE(T2.DOMN_INST_ID, T2_1.DOMN_INST_ID) DOMN_INST_ID,
                    COALESCE(T2.DOMN_INST_NME, T2_1.DOMN_INST_NME) DOMN_INST_NME,
                    COALESCE(T2.INST_LEVEL_2, T2_1.INST_LEVEL_2) INST_LEVEL_2,
                    COALESCE(T2.PROV_INST_ID, T2_1.PROV_INST_ID) PROV_INST_ID,
                    COALESCE(T2.PROV_INST_NME, T2_1.PROV_INST_NME) PROV_INST_NME,
                    COALESCE(T2.INST_LEVEL_1, T2_1.INST_LEVEL_1) INST_LEVEL_1,
                    COALESCE(T2.DOME_INST_ID, T2_1.DOME_INST_ID) DOME_INST_ID,
                    COALESCE(T2.DOME_INST_NME, T2_1.DOME_INST_NME) DOME_INST_NME,
                    (
                        CASE
                            WHEN T4.FIVE_CLASS = '1' THEN '12BA'
                            WHEN T4.FIVE_CLASS = '2' THEN '12BB'
                            WHEN T4.FIVE_CLASS = '3' THEN '12BC'
                            WHEN T4.FIVE_CLASS = '4' THEN '12BD'
                            WHEN T4.FIVE_CLASS = '5' THEN '12BE'
                        END
                    ) AS INDEX_CODE,
                    T1.BAL * NVL (T3.RATE, 1) AS INDEX_VALUE
                FROM
                    B_GEMS_LOAN_INFO T1
					
                    --基础表连接机构表 入账机构在4级机构
                    LEFT JOIN (
                        SELECT
                            '4' AS INST_LEVEL_4,
                            INST_ID,
                            INST_NME,
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            INST_ID,
                            INST_NME,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2 ON T1.ACTOPE_INST_ID = T2.INST_ID
					
                    --基础表连接机构表 入账机构在3级机构
                    LEFT JOIN (
                        SELECT
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2_1 ON T1.ACTOPE_INST_ID = T2_1.DOMN_INST_ID
					
                    --基础表连接汇率表，余额转人民币
                    LEFT JOIN CCY_RATE T3 ON T1.CCY = T3.CCY_OLD
                    AND T3.CCY_NEW = 'CNY'
                    AND T3.COUNT_FLG = '00'
                    AND T3.BGN_DT <= TO_DATE ('20241031', 'YYYYMMDD')
                    AND T3.END_DT > TO_DATE ('20241031', 'YYYYMMDD')
					
                    --基础表连接五级分类表，获取分类
                    LEFT JOIN B_RISK_LOAN_FIVE_CLASS T4 ON T1.UNVS_AGM_NO = T4.UNVS_AGM_NO
                    AND T1.AGM_MODIF = T4.AGM_MODIF
                    AND T4.ACCTG_DT = '20241031'
					
                    --过滤当月余额大于0
                WHERE
                    T1.ACCTG_DT = '20241031'
                    AND T1.BAL > 0
					
                    --且属于121/123类
                    AND (
                        T1.ACCTG_SBJEC_ID LIKE '123%'
                        OR T1.ACCTG_SBJEC_ID LIKE '121%'
                    )
            )
			
            --按机构层级分组   
        GROUP BY
            GROUPING SETS (
                (INST_ID, INST_NME, INST_LEVEL_4, INDEX_CODE),
                (
                    DOMN_INST_ID,
                    DOMN_INST_NME,
                    INST_LEVEL_3,
                    INDEX_CODE
                ),
                (
                    PROV_INST_ID,
                    PROV_INST_NME,
                    INST_LEVEL_2,
                    INDEX_CODE
                ),
                (
                    DOME_INST_ID,
                    DOME_INST_NME,
                    INST_LEVEL_1,
                    INDEX_CODE
                )
            )
    )
	
    --直接在3级机构入账的记录在4级机构分组中为空 需要过滤掉
WHERE
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) IS NOT NULL

--拼接下一个指标
UNION ALL

--指标 12BF
SELECT
    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
    COALESCE(INST_ID, DOMN_INST_ID, PROV_INST_ID, DOME_INST_ID) INST_ID,
    COALESCE(
        INST_NME,
        DOMN_INST_NME,
        PROV_INST_NME,
        DOME_INST_NME
    ) INST_NME,
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) INST_LEVEL,
    INDEX_CODE,
    INDEX_VALUE
FROM
    (
        SELECT
            TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
            INST_ID,
            INST_NME,
            INST_LEVEL_4,
            DOMN_INST_ID,
            DOMN_INST_NME,
            INST_LEVEL_3,
            PROV_INST_ID,
            PROV_INST_NME,
            INST_LEVEL_2,
            DOME_INST_ID,
            DOME_INST_NME,
            INST_LEVEL_1,
            INDEX_CODE,
            SUM(INDEX_VALUE) INDEX_VALUE
        FROM
            (
                SELECT
                    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
                    T2.INST_ID,
                    T2.INST_NME,
                    T2.INST_LEVEL_4,
                    COALESCE(T2.INST_LEVEL_3, T2_1.INST_LEVEL_3) INST_LEVEL_3,
                    COALESCE(T2.DOMN_INST_ID, T2_1.DOMN_INST_ID) DOMN_INST_ID,
                    COALESCE(T2.DOMN_INST_NME, T2_1.DOMN_INST_NME) DOMN_INST_NME,
                    COALESCE(T2.INST_LEVEL_2, T2_1.INST_LEVEL_2) INST_LEVEL_2,
                    COALESCE(T2.PROV_INST_ID, T2_1.PROV_INST_ID) PROV_INST_ID,
                    COALESCE(T2.PROV_INST_NME, T2_1.PROV_INST_NME) PROV_INST_NME,
                    COALESCE(T2.INST_LEVEL_1, T2_1.INST_LEVEL_1) INST_LEVEL_1,
                    COALESCE(T2.DOME_INST_ID, T2_1.DOME_INST_ID) DOME_INST_ID,
                    COALESCE(T2.DOME_INST_NME, T2_1.DOME_INST_NME) DOME_INST_NME,
                    (
                        CASE
                            WHEN T4.FIVE_CLASS IN ('3', '4', '5') THEN '12BF'
                        END
                    ) AS INDEX_CODE,
                    T1.BAL * NVL (T3.RATE, 1) AS INDEX_VALUE
                FROM
                    B_GEMS_LOAN_INFO T1
                    
					--基础表连接机构表 入账机构在4级机构
                    LEFT JOIN (
                        SELECT
                            '4' AS INST_LEVEL_4,
                            INST_ID,
                            INST_NME,
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            INST_ID,
                            INST_NME,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2 ON T1.ACTOPE_INST_ID = T2.INST_ID
                    
					--基础表连接机构表 入账机构在3级机构
                    LEFT JOIN (
                        SELECT
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2_1 ON T1.ACTOPE_INST_ID = T2_1.DOMN_INST_ID
                    
					--基础表连接汇率表，余额转人民币
                    LEFT JOIN CCY_RATE T3 ON T1.CCY = T3.CCY_OLD
                    AND T3.CCY_NEW = 'CNY'
                    AND T3.COUNT_FLG = '00'
                    AND T3.BGN_DT <= TO_DATE ('20241031', 'YYYYMMDD')
                    AND T3.END_DT > TO_DATE ('20241031', 'YYYYMMDD')
                    
					--基础表连接五级分类表，获取分类
                    LEFT JOIN B_RISK_LOAN_FIVE_CLASS T4 ON T1.UNVS_AGM_NO = T4.UNVS_AGM_NO
                    AND T1.AGM_MODIF = T4.AGM_MODIF
                    AND T4.ACCTG_DT = '20241031'
                    
					--过滤当月余额大于0
                WHERE
                    T1.ACCTG_DT = '20241031'
                    AND T1.BAL > 0
                    
					--且属于121/123类
                    AND (
                        T1.ACCTG_SBJEC_ID LIKE '123%'
                        OR T1.ACCTG_SBJEC_ID LIKE '121%'
                    )
            )
			
        --过滤掉非不良贷款      
        WHERE
            INDEX_CODE IS NOT NULL
			
        --按机构层级分组   
        GROUP BY
            GROUPING SETS (
                (INST_ID, INST_NME, INST_LEVEL_4, INDEX_CODE),
                (
                    DOMN_INST_ID,
                    DOMN_INST_NME,
                    INST_LEVEL_3,
                    INDEX_CODE
                ),
                (
                    PROV_INST_ID,
                    PROV_INST_NME,
                    INST_LEVEL_2,
                    INDEX_CODE
                ),
                (
                    DOME_INST_ID,
                    DOME_INST_NME,
                    INST_LEVEL_1,
                    INDEX_CODE
                )
            )
    )

--直接在3级机构入账的记录在4级机构分组中为空 需要过滤掉
WHERE
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) IS NOT NULL

--拼接下一个指标	
UNION ALL

--指标 12BA/BB/BC/BD/BE带数字
SELECT
    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
    COALESCE(INST_ID, DOMN_INST_ID, PROV_INST_ID, DOME_INST_ID) INST_ID,
    COALESCE(
        INST_NME,
        DOMN_INST_NME,
        PROV_INST_NME,
        DOME_INST_NME
    ) INST_NME,
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) INST_LEVEL,
    INDEX_CODE,
    INDEX_VALUE
FROM
    (
        SELECT
            TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
            INST_ID,
            INST_NME,
            INST_LEVEL_4,
            DOMN_INST_ID,
            DOMN_INST_NME,
            INST_LEVEL_3,
            PROV_INST_ID,
            PROV_INST_NME,
            INST_LEVEL_2,
            DOME_INST_ID,
            DOME_INST_NME,
            INST_LEVEL_1,
            INDEX_CODE,
            SUM(INDEX_VALUE) INDEX_VALUE
        FROM
            (
                SELECT
                    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
                    T2.INST_ID,
                    T2.INST_NME,
                    T2.INST_LEVEL_4,
                    COALESCE(T2.INST_LEVEL_3, T2_1.INST_LEVEL_3) INST_LEVEL_3,
                    COALESCE(T2.DOMN_INST_ID, T2_1.DOMN_INST_ID) DOMN_INST_ID,
                    COALESCE(T2.DOMN_INST_NME, T2_1.DOMN_INST_NME) DOMN_INST_NME,
                    COALESCE(T2.INST_LEVEL_2, T2_1.INST_LEVEL_2) INST_LEVEL_2,
                    COALESCE(T2.PROV_INST_ID, T2_1.PROV_INST_ID) PROV_INST_ID,
                    COALESCE(T2.PROV_INST_NME, T2_1.PROV_INST_NME) PROV_INST_NME,
                    COALESCE(T2.INST_LEVEL_1, T2_1.INST_LEVEL_1) INST_LEVEL_1,
                    COALESCE(T2.DOME_INST_ID, T2_1.DOME_INST_ID) DOME_INST_ID,
                    COALESCE(T2.DOME_INST_NME, T2_1.DOME_INST_NME) DOME_INST_NME,
                    (
                        CASE
                            WHEN T4.FIVE_CLASS = '1'
                            AND T5.CREDIT_LMT < 5000000 THEN '12BA1'
                            WHEN T4.FIVE_CLASS = '1'
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12BA2'
                            WHEN T4.FIVE_CLASS = '1'
                            AND T5.CREDIT_LMT >= 10000000 THEN '12BA3'
                            WHEN T4.FIVE_CLASS = '2'
                            AND T5.CREDIT_LMT < 5000000 THEN '12BB1'
                            WHEN T4.FIVE_CLASS = '2'
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12BB2'
                            WHEN T4.FIVE_CLASS = '2'
                            AND T5.CREDIT_LMT >= 10000000 THEN '12BB3'
                            WHEN T4.FIVE_CLASS = '3'
                            AND T5.CREDIT_LMT < 5000000 THEN '12BC1'
                            WHEN T4.FIVE_CLASS = '3'
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12BC2'
                            WHEN T4.FIVE_CLASS = '3'
                            AND T5.CREDIT_LMT >= 10000000 THEN '12BC3'
                            WHEN T4.FIVE_CLASS = '4'
                            AND T5.CREDIT_LMT < 5000000 THEN '12BD1'
                            WHEN T4.FIVE_CLASS = '4'
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12BD2'
                            WHEN T4.FIVE_CLASS = '4'
                            AND T5.CREDIT_LMT >= 10000000 THEN '12BD3'
                            WHEN T4.FIVE_CLASS = '5'
                            AND T5.CREDIT_LMT < 5000000 THEN '12BE1'
                            WHEN T4.FIVE_CLASS = '5'
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12BE2'
                            WHEN T4.FIVE_CLASS = '5'
                            AND T5.CREDIT_LMT >= 10000000 THEN '12BE3'
                        END
                    ) AS INDEX_CODE,
                    T1.BAL * NVL (T3.RATE, 1) AS INDEX_VALUE
                FROM
                    B_GEMS_LOAN_INFO T1
					
                    --基础表连接机构表 入账机构在4级机构
                    LEFT JOIN (
                        SELECT
                            '4' AS INST_LEVEL_4,
                            INST_ID,
                            INST_NME,
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            INST_ID,
                            INST_NME,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2 ON T1.ACTOPE_INST_ID = T2.INST_ID
					
                    --基础表连接机构表 入账机构在3级机构
                    LEFT JOIN (
                        SELECT
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2_1 ON T1.ACTOPE_INST_ID = T2_1.DOMN_INST_ID
					
                    --基础表连接汇率表，余额转人民币
                    LEFT JOIN CCY_RATE T3 ON T1.CCY = T3.CCY_OLD
                    AND T3.CCY_NEW = 'CNY'
                    AND T3.COUNT_FLG = '00'
                    AND T3.BGN_DT <= TO_DATE ('20241031', 'YYYYMMDD')
                    AND T3.END_DT > TO_DATE ('20241031', 'YYYYMMDD')
					
                    --基础表连接五级分类表，获取分类
                    LEFT JOIN B_RISK_LOAN_FIVE_CLASS T4 ON T1.UNVS_AGM_NO = T4.UNVS_AGM_NO
                    AND T1.AGM_MODIF = T4.AGM_MODIF
                    AND T4.ACCTG_DT = '20241031'
					
                    --基础表连接授信表，获取授信额度
                    LEFT JOIN B_ECIF_CUST_LMT T5 ON T1.CUST_ID = T5.CUST_ID
                    AND T5.ACCTG_DT = '20241031'
					
                    --过滤当月余额大于0
                WHERE
                    T1.ACCTG_DT = '20241031'
                    AND T1.BAL > 0
					
                    --且属于121/123类
                    AND (
                        T1.ACCTG_SBJEC_ID LIKE '123%'
                        OR T1.ACCTG_SBJEC_ID LIKE '121%'
                    )
            )
			
            --按机构层级分组   
        GROUP BY
            GROUPING SETS (
                (INST_ID, INST_NME, INST_LEVEL_4, INDEX_CODE),
                (
                    DOMN_INST_ID,
                    DOMN_INST_NME,
                    INST_LEVEL_3,
                    INDEX_CODE
                ),
                (
                    PROV_INST_ID,
                    PROV_INST_NME,
                    INST_LEVEL_2,
                    INDEX_CODE
                ),
                (
                    DOME_INST_ID,
                    DOME_INST_NME,
                    INST_LEVEL_1,
                    INDEX_CODE
                )
            )
    )
	
    --直接在3级机构入账的记录在4级机构分组中为空 需要过滤掉
WHERE
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) IS NOT NULL

--拼接下一个指标	
UNION ALL

--指标 12BF带数字
SELECT
    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
    COALESCE(INST_ID, DOMN_INST_ID, PROV_INST_ID, DOME_INST_ID) INST_ID,
    COALESCE(
        INST_NME,
        DOMN_INST_NME,
        PROV_INST_NME,
        DOME_INST_NME
    ) INST_NME,
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) INST_LEVEL,
    INDEX_CODE,
    INDEX_VALUE
FROM
    (
        SELECT
            TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
            INST_ID,
            INST_NME,
            INST_LEVEL_4,
            DOMN_INST_ID,
            DOMN_INST_NME,
            INST_LEVEL_3,
            PROV_INST_ID,
            PROV_INST_NME,
            INST_LEVEL_2,
            DOME_INST_ID,
            DOME_INST_NME,
            INST_LEVEL_1,
            INDEX_CODE,
            SUM(INDEX_VALUE) INDEX_VALUE
        FROM
            (
                SELECT
                    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
                    T2.INST_ID,
                    T2.INST_NME,
                    T2.INST_LEVEL_4,
                    COALESCE(T2.INST_LEVEL_3, T2_1.INST_LEVEL_3) INST_LEVEL_3,
                    COALESCE(T2.DOMN_INST_ID, T2_1.DOMN_INST_ID) DOMN_INST_ID,
                    COALESCE(T2.DOMN_INST_NME, T2_1.DOMN_INST_NME) DOMN_INST_NME,
                    COALESCE(T2.INST_LEVEL_2, T2_1.INST_LEVEL_2) INST_LEVEL_2,
                    COALESCE(T2.PROV_INST_ID, T2_1.PROV_INST_ID) PROV_INST_ID,
                    COALESCE(T2.PROV_INST_NME, T2_1.PROV_INST_NME) PROV_INST_NME,
                    COALESCE(T2.INST_LEVEL_1, T2_1.INST_LEVEL_1) INST_LEVEL_1,
                    COALESCE(T2.DOME_INST_ID, T2_1.DOME_INST_ID) DOME_INST_ID,
                    COALESCE(T2.DOME_INST_NME, T2_1.DOME_INST_NME) DOME_INST_NME,
                    (
                        CASE
                            WHEN T4.FIVE_CLASS IN ('3', '4', '5')
                            AND T5.CREDIT_LMT < 5000000 THEN '12BF1'
                            WHEN T4.FIVE_CLASS IN ('3', '4', '5')
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12BF2'
                            WHEN T4.FIVE_CLASS IN ('3', '4', '5')
                            AND T5.CREDIT_LMT >= 10000000 THEN '12BF3'
                        END
                    ) AS INDEX_CODE,
                    T1.BAL * NVL (T3.RATE, 1) AS INDEX_VALUE
                FROM
                    B_GEMS_LOAN_INFO T1
					
                    --基础表连接机构表 入账机构在4级机构
                    LEFT JOIN (
                        SELECT
                            '4' AS INST_LEVEL_4,
                            INST_ID,
                            INST_NME,
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            INST_ID,
                            INST_NME,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2 ON T1.ACTOPE_INST_ID = T2.INST_ID
					
                    --基础表连接机构表 入账机构在3级机构
                    LEFT JOIN (
                        SELECT
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2_1 ON T1.ACTOPE_INST_ID = T2_1.DOMN_INST_ID
					
                    --基础表连接汇率表，余额转人民币
                    LEFT JOIN CCY_RATE T3 ON T1.CCY = T3.CCY_OLD
                    AND T3.CCY_NEW = 'CNY'
                    AND T3.COUNT_FLG = '00'
                    AND T3.BGN_DT <= TO_DATE ('20241031', 'YYYYMMDD')
                    AND T3.END_DT > TO_DATE ('20241031', 'YYYYMMDD')
					
                    --基础表连接五级分类表，获取分类
                    LEFT JOIN B_RISK_LOAN_FIVE_CLASS T4 ON T1.UNVS_AGM_NO = T4.UNVS_AGM_NO
                    AND T1.AGM_MODIF = T4.AGM_MODIF
                    AND T4.ACCTG_DT = '20241031'
					
                    --基础表连接授信表，获取授信额度
                    LEFT JOIN B_ECIF_CUST_LMT T5 ON T1.CUST_ID = T5.CUST_ID
                    AND T5.ACCTG_DT = '20241031'
					
                    --过滤当月余额大于0
                WHERE
                    T1.ACCTG_DT = '20241031'
                    AND T1.BAL > 0
					
                    --且属于121/123类
                    AND (
                        T1.ACCTG_SBJEC_ID LIKE '123%'
                        OR T1.ACCTG_SBJEC_ID LIKE '121%'
                    )
            )
			
            --过滤掉非不良贷款      
        WHERE
            INDEX_CODE IS NOT NULL
			
            --按机构层级分组   
        GROUP BY
            GROUPING SETS (
                (INST_ID, INST_NME, INST_LEVEL_4, INDEX_CODE),
                (
                    DOMN_INST_ID,
                    DOMN_INST_NME,
                    INST_LEVEL_3,
                    INDEX_CODE
                ),
                (
                    PROV_INST_ID,
                    PROV_INST_NME,
                    INST_LEVEL_2,
                    INDEX_CODE
                ),
                (
                    DOME_INST_ID,
                    DOME_INST_NME,
                    INST_LEVEL_1,
                    INDEX_CODE
                )
            )
    )
	
    --直接在3级机构入账的记录在4级机构分组中为空 需要过滤掉
WHERE
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) IS NOT NULL

--拼接下一个指标
UNION ALL

--指标 12CA/CB/CC/CD/CE
SELECT
    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
    COALESCE(INST_ID, DOMN_INST_ID, PROV_INST_ID, DOME_INST_ID) INST_ID,
    COALESCE(
        INST_NME,
        DOMN_INST_NME,
        PROV_INST_NME,
        DOME_INST_NME
    ) INST_NME,
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) INST_LEVEL,
    INDEX_CODE,
    INDEX_VALUE
FROM
    (
        SELECT
            TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
            INST_ID,
            INST_NME,
            INST_LEVEL_4,
            DOMN_INST_ID,
            DOMN_INST_NME,
            INST_LEVEL_3,
            PROV_INST_ID,
            PROV_INST_NME,
            INST_LEVEL_2,
            DOME_INST_ID,
            DOME_INST_NME,
            INST_LEVEL_1,
            INDEX_CODE,
            SUM(INDEX_VALUE) INDEX_VALUE
        FROM
            (
                SELECT
                    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
                    T2.INST_ID,
                    T2.INST_NME,
                    T2.INST_LEVEL_4,
                    COALESCE(T2.INST_LEVEL_3, T2_1.INST_LEVEL_3) INST_LEVEL_3,
                    COALESCE(T2.DOMN_INST_ID, T2_1.DOMN_INST_ID) DOMN_INST_ID,
                    COALESCE(T2.DOMN_INST_NME, T2_1.DOMN_INST_NME) DOMN_INST_NME,
                    COALESCE(T2.INST_LEVEL_2, T2_1.INST_LEVEL_2) INST_LEVEL_2,
                    COALESCE(T2.PROV_INST_ID, T2_1.PROV_INST_ID) PROV_INST_ID,
                    COALESCE(T2.PROV_INST_NME, T2_1.PROV_INST_NME) PROV_INST_NME,
                    COALESCE(T2.INST_LEVEL_1, T2_1.INST_LEVEL_1) INST_LEVEL_1,
                    COALESCE(T2.DOME_INST_ID, T2_1.DOME_INST_ID) DOME_INST_ID,
                    COALESCE(T2.DOME_INST_NME, T2_1.DOME_INST_NME) DOME_INST_NME,
                    (
                        CASE
                            WHEN T6.CDE_NME = '集体控股' THEN '12CA1'
                            WHEN T6.CDE_NME = '私人控股' THEN '12CB1'
                            WHEN T6.CDE_NME = '港澳台控股' THEN '12CC1'
                            WHEN T6.CDE_NME = '外商控股' THEN '12CD1'
                            WHEN T6.CDE_NME = '国有控股' THEN '12CE1'
                        END
                    ) AS INDEX_CODE,
                    T1.BAL * NVL (T3.RATE, 1) AS INDEX_VALUE
                FROM
                    B_GEMS_LOAN_INFO T1
					
                    --基础表连接机构表 入账机构在4级机构
                    LEFT JOIN (
                        SELECT
                            '4' AS INST_LEVEL_4,
                            INST_ID,
                            INST_NME,
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            INST_ID,
                            INST_NME,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2 ON T1.ACTOPE_INST_ID = T2.INST_ID
					
                    --基础表连接机构表 入账机构在3级机构
                    LEFT JOIN (
                        SELECT
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2_1 ON T1.ACTOPE_INST_ID = T2_1.DOMN_INST_ID
					
                    --基础表连接汇率表，余额转人民币
                    LEFT JOIN CCY_RATE T3 ON T1.CCY = T3.CCY_OLD
                    AND T3.CCY_NEW = 'CNY'
                    AND T3.COUNT_FLG = '00'
                    AND T3.BGN_DT <= TO_DATE ('20241031', 'YYYYMMDD')
                    AND T3.END_DT > TO_DATE ('20241031', 'YYYYMMDD')
					
                    --基础表连接客户表，获取控股方式（码）
                    LEFT JOIN B_ECIF_CUST_INFO_C T5 ON T1.CUST_ID = T5.CUST_ID
                    AND T5.ACCTG_DT = '20241031'
					
                    --基础表连接码值表，解析控股方式（值）HS
                    LEFT JOIN (
                        SELECT
                            CDE,
                            CDE_NME,
                            ROW_NUMBER() OVER (
                                PARTITION BY
                                    CDE
                                ORDER BY
                                    UPDATE_DT DESC
                            ) RN
                        FROM
                            CDE_INF
                        WHERE
                            CDE_TP = 'HS'
                    ) T6 ON T6.CDE = T5.HOLD_SHARE
                    AND T6.RN = 1
					
                    --过滤当月余额大于0
                WHERE
                    T1.ACCTG_DT = '20241031'
                    AND T1.BAL > 0
					
                    --且属于121/123类
                    AND (
                        T1.ACCTG_SBJEC_ID LIKE '123%'
                        OR T1.ACCTG_SBJEC_ID LIKE '121%'
                    )
            )
			
            --按机构层级分组   
        GROUP BY
            GROUPING SETS (
                (INST_ID, INST_NME, INST_LEVEL_4, INDEX_CODE),
                (
                    DOMN_INST_ID,
                    DOMN_INST_NME,
                    INST_LEVEL_3,
                    INDEX_CODE
                ),
                (
                    PROV_INST_ID,
                    PROV_INST_NME,
                    INST_LEVEL_2,
                    INDEX_CODE
                ),
                (
                    DOME_INST_ID,
                    DOME_INST_NME,
                    INST_LEVEL_1,
                    INDEX_CODE
                )
            )
    )
	
    --直接在3级机构入账的记录在4级机构分组中为空 需要过滤掉
WHERE
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) IS NOT NULL

--拼接下一个指标
UNION ALL

--指标 12CA/CB/CC/CD/CE带数字
SELECT
    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
    COALESCE(INST_ID, DOMN_INST_ID, PROV_INST_ID, DOME_INST_ID) INST_ID,
    COALESCE(
        INST_NME,
        DOMN_INST_NME,
        PROV_INST_NME,
        DOME_INST_NME
    ) INST_NME,
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) INST_LEVEL,
    INDEX_CODE,
    INDEX_VALUE
FROM
    (
        SELECT
            TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
            INST_ID,
            INST_NME,
            INST_LEVEL_4,
            DOMN_INST_ID,
            DOMN_INST_NME,
            INST_LEVEL_3,
            PROV_INST_ID,
            PROV_INST_NME,
            INST_LEVEL_2,
            DOME_INST_ID,
            DOME_INST_NME,
            INST_LEVEL_1,
            INDEX_CODE,
            SUM(INDEX_VALUE) INDEX_VALUE
        FROM
            (
                SELECT
                    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
                    T2.INST_ID,
                    T2.INST_NME,
                    T2.INST_LEVEL_4,
                    COALESCE(T2.INST_LEVEL_3, T2_1.INST_LEVEL_3) INST_LEVEL_3,
                    COALESCE(T2.DOMN_INST_ID, T2_1.DOMN_INST_ID) DOMN_INST_ID,
                    COALESCE(T2.DOMN_INST_NME, T2_1.DOMN_INST_NME) DOMN_INST_NME,
                    COALESCE(T2.INST_LEVEL_2, T2_1.INST_LEVEL_2) INST_LEVEL_2,
                    COALESCE(T2.PROV_INST_ID, T2_1.PROV_INST_ID) PROV_INST_ID,
                    COALESCE(T2.PROV_INST_NME, T2_1.PROV_INST_NME) PROV_INST_NME,
                    COALESCE(T2.INST_LEVEL_1, T2_1.INST_LEVEL_1) INST_LEVEL_1,
                    COALESCE(T2.DOME_INST_ID, T2_1.DOME_INST_ID) DOME_INST_ID,
                    COALESCE(T2.DOME_INST_NME, T2_1.DOME_INST_NME) DOME_INST_NME,
                    (
                        CASE
                            WHEN T4.FIVE_CLASS IN ('3', '4', '5')
                            AND T6.CDE_NME = '集体控股' THEN '12CA1'
                            WHEN T4.FIVE_CLASS IN ('3', '4', '5')
                            AND T6.CDE_NME = '私人控股' THEN '12CB1'
                            WHEN T4.FIVE_CLASS IN ('3', '4', '5')
                            AND T6.CDE_NME = '港澳台控股' THEN '12CC1'
                            WHEN T4.FIVE_CLASS IN ('3', '4', '5')
                            AND T6.CDE_NME = '外商控股' THEN '12CD1'
                            WHEN T4.FIVE_CLASS IN ('3', '4', '5')
                            AND T6.CDE_NME = '国有控股' THEN '12CE1'
                        END
                    ) AS INDEX_CODE,
                    T1.BAL * NVL (T3.RATE, 1) AS INDEX_VALUE
                FROM
                    B_GEMS_LOAN_INFO T1
					
                    --基础表连接机构表 入账机构在4级机构
                    LEFT JOIN (
                        SELECT
                            '4' AS INST_LEVEL_4,
                            INST_ID,
                            INST_NME,
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            INST_ID,
                            INST_NME,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2 ON T1.ACTOPE_INST_ID = T2.INST_ID
					
                    --基础表连接机构表 入账机构在3级机构
                    LEFT JOIN (
                        SELECT
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2_1 ON T1.ACTOPE_INST_ID = T2_1.DOMN_INST_ID
					
                    --基础表连接汇率表，余额转人民币
                    LEFT JOIN CCY_RATE T3 ON T1.CCY = T3.CCY_OLD
                    AND T3.CCY_NEW = 'CNY'
                    AND T3.COUNT_FLG = '00'
                    AND T3.BGN_DT <= TO_DATE ('20241031', 'YYYYMMDD')
                    AND T3.END_DT > TO_DATE ('20241031', 'YYYYMMDD')
					
                    --基础表连接五级分类表，获取分类
                    LEFT JOIN B_RISK_LOAN_FIVE_CLASS T4 ON T1.UNVS_AGM_NO = T4.UNVS_AGM_NO
                    AND T1.AGM_MODIF = T4.AGM_MODIF
                    AND T4.ACCTG_DT = '20241031'
					
                    --基础表连接客户表，获取控股方式（码）
                    LEFT JOIN B_ECIF_CUST_INFO_C T5 ON T1.CUST_ID = T5.CUST_ID
                    AND T5.ACCTG_DT = '20241031'
					
                    --基础表连接码值表，解析控股方式（值）HS
                    LEFT JOIN (
                        SELECT
                            CDE,
                            CDE_NME,
                            ROW_NUMBER() OVER (
                                PARTITION BY
                                    CDE
                                ORDER BY
                                    UPDATE_DT DESC
                            ) RN
                        FROM
                            CDE_INF
                        WHERE
                            CDE_TP = 'HS'
                    ) T6 ON T6.CDE = T5.HOLD_SHARE
                    AND T6.RN = 1
					
                    --过滤当月余额大于0
                WHERE
                    T1.ACCTG_DT = '20241031'
                    AND T1.BAL > 0
					
                    --且属于121/123类
                    AND (
                        T1.ACCTG_SBJEC_ID LIKE '123%'
                        OR T1.ACCTG_SBJEC_ID LIKE '121%'
                    )
            )
			
            --过滤掉非不良贷款      
        WHERE
            INDEX_CODE IS NOT NULL
			
            --按机构层级分组   
        GROUP BY
            GROUPING SETS (
                (INST_ID, INST_NME, INST_LEVEL_4, INDEX_CODE),
                (
                    DOMN_INST_ID,
                    DOMN_INST_NME,
                    INST_LEVEL_3,
                    INDEX_CODE
                ),
                (
                    PROV_INST_ID,
                    PROV_INST_NME,
                    INST_LEVEL_2,
                    INDEX_CODE
                ),
                (
                    DOME_INST_ID,
                    DOME_INST_NME,
                    INST_LEVEL_1,
                    INDEX_CODE
                )
            )
    )
	
    --直接在3级机构入账的记录在4级机构分组中为空 需要过滤掉
WHERE
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) IS NOT NULL

--拼接下一个指标
UNION ALL

--指标 12DA/DB/DC/DD/DE
SELECT
    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
    COALESCE(INST_ID, DOMN_INST_ID, PROV_INST_ID, DOME_INST_ID) INST_ID,
    COALESCE(
        INST_NME,
        DOMN_INST_NME,
        PROV_INST_NME,
        DOME_INST_NME
    ) INST_NME,
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) INST_LEVEL,
    INDEX_CODE,
    INDEX_VALUE
FROM
    (
        SELECT
            TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
            INST_ID,
            INST_NME,
            INST_LEVEL_4,
            DOMN_INST_ID,
            DOMN_INST_NME,
            INST_LEVEL_3,
            PROV_INST_ID,
            PROV_INST_NME,
            INST_LEVEL_2,
            DOME_INST_ID,
            DOME_INST_NME,
            INST_LEVEL_1,
            INDEX_CODE,
            SUM(INDEX_VALUE) INDEX_VALUE
        FROM
            (
                SELECT
                    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
                    T2.INST_ID,
                    T2.INST_NME,
                    T2.INST_LEVEL_4,
                    COALESCE(T2.INST_LEVEL_3, T2_1.INST_LEVEL_3) INST_LEVEL_3,
                    COALESCE(T2.DOMN_INST_ID, T2_1.DOMN_INST_ID) DOMN_INST_ID,
                    COALESCE(T2.DOMN_INST_NME, T2_1.DOMN_INST_NME) DOMN_INST_NME,
                    COALESCE(T2.INST_LEVEL_2, T2_1.INST_LEVEL_2) INST_LEVEL_2,
                    COALESCE(T2.PROV_INST_ID, T2_1.PROV_INST_ID) PROV_INST_ID,
                    COALESCE(T2.PROV_INST_NME, T2_1.PROV_INST_NME) PROV_INST_NME,
                    COALESCE(T2.INST_LEVEL_1, T2_1.INST_LEVEL_1) INST_LEVEL_1,
                    COALESCE(T2.DOME_INST_ID, T2_1.DOME_INST_ID) DOME_INST_ID,
                    COALESCE(T2.DOME_INST_NME, T2_1.DOME_INST_NME) DOME_INST_NME,
                    (
                        CASE
                            WHEN T4.CONTRACT_GUAR_TP = '01' THEN '12DA'
                            WHEN T4.CONTRACT_GUAR_TP = '02' THEN '12DB'
                            WHEN T4.CONTRACT_GUAR_TP = '03' THEN '12DC'
                            WHEN T4.CONTRACT_GUAR_TP = '04' THEN '12DD'
                            WHEN T4.CONTRACT_GUAR_TP = '05' THEN '12DE'
                        END
                    ) AS INDEX_CODE,
                    T1.BAL * NVL (T3.RATE, 1) AS INDEX_VALUE
                FROM
                    B_GEMS_LOAN_INFO T1
					
                    --基础表连接机构表 入账机构在4级机构
                    LEFT JOIN (
                        SELECT
                            '4' AS INST_LEVEL_4,
                            INST_ID,
                            INST_NME,
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            INST_ID,
                            INST_NME,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2 ON T1.ACTOPE_INST_ID = T2.INST_ID
					
                    --基础表连接机构表 入账机构在3级机构
                    LEFT JOIN (
                        SELECT
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2_1 ON T1.ACTOPE_INST_ID = T2_1.DOMN_INST_ID
					
                    --基础表连接汇率表，余额转人民币
                    LEFT JOIN CCY_RATE T3 ON T1.CCY = T3.CCY_OLD
                    AND T3.CCY_NEW = 'CNY'
                    AND T3.COUNT_FLG = '00'
                    AND T3.BGN_DT <= TO_DATE ('20241031', 'YYYYMMDD')
                    AND T3.END_DT > TO_DATE ('20241031', 'YYYYMMDD')
					
                    --基础表连接合同表，获取担保方式
                    LEFT JOIN B_GEMS_LOAN_CONTRACT_INFO T4 ON T1.UNVS_AGM_NO = T4.UNVS_AGM_NO
                    AND T1.AGM_MODIF = T4.AGM_MODIF
                    AND T4.ACCTG_DT = '20241031'
					
                    --过滤当月余额大于0
                WHERE
                    T1.ACCTG_DT = '20241031'
                    AND T1.BAL > 0
					
                    --且属于121/123类
                    AND (
                        T1.ACCTG_SBJEC_ID LIKE '123%'
                        OR T1.ACCTG_SBJEC_ID LIKE '121%'
                    )
            )
			
            --按机构层级分组   
        GROUP BY
            GROUPING SETS (
                (INST_ID, INST_NME, INST_LEVEL_4, INDEX_CODE),
                (
                    DOMN_INST_ID,
                    DOMN_INST_NME,
                    INST_LEVEL_3,
                    INDEX_CODE
                ),
                (
                    PROV_INST_ID,
                    PROV_INST_NME,
                    INST_LEVEL_2,
                    INDEX_CODE
                ),
                (
                    DOME_INST_ID,
                    DOME_INST_NME,
                    INST_LEVEL_1,
                    INDEX_CODE
                )
            )
    )
	
    --直接在3级机构入账的记录在4级机构分组中为空 需要过滤掉
WHERE
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) IS NOT NULL

--拼接下一个指标
UNION ALL

--指标 12DA/DB/DC/DD/DE带数字
SELECT
    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
    COALESCE(INST_ID, DOMN_INST_ID, PROV_INST_ID, DOME_INST_ID) INST_ID,
    COALESCE(
        INST_NME,
        DOMN_INST_NME,
        PROV_INST_NME,
        DOME_INST_NME
    ) INST_NME,
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) INST_LEVEL,
    INDEX_CODE,
    INDEX_VALUE
FROM
    (
        SELECT
            TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
            INST_ID,
            INST_NME,
            INST_LEVEL_4,
            DOMN_INST_ID,
            DOMN_INST_NME,
            INST_LEVEL_3,
            PROV_INST_ID,
            PROV_INST_NME,
            INST_LEVEL_2,
            DOME_INST_ID,
            DOME_INST_NME,
            INST_LEVEL_1,
            INDEX_CODE,
            SUM(INDEX_VALUE) INDEX_VALUE
        FROM
            (
                SELECT
                    TO_DATE ('20241031', 'YYYYMMDD') AS ACCTG_DT,
                    T2.INST_ID,
                    T2.INST_NME,
                    T2.INST_LEVEL_4,
                    COALESCE(T2.INST_LEVEL_3, T2_1.INST_LEVEL_3) INST_LEVEL_3,
                    COALESCE(T2.DOMN_INST_ID, T2_1.DOMN_INST_ID) DOMN_INST_ID,
                    COALESCE(T2.DOMN_INST_NME, T2_1.DOMN_INST_NME) DOMN_INST_NME,
                    COALESCE(T2.INST_LEVEL_2, T2_1.INST_LEVEL_2) INST_LEVEL_2,
                    COALESCE(T2.PROV_INST_ID, T2_1.PROV_INST_ID) PROV_INST_ID,
                    COALESCE(T2.PROV_INST_NME, T2_1.PROV_INST_NME) PROV_INST_NME,
                    COALESCE(T2.INST_LEVEL_1, T2_1.INST_LEVEL_1) INST_LEVEL_1,
                    COALESCE(T2.DOME_INST_ID, T2_1.DOME_INST_ID) DOME_INST_ID,
                    COALESCE(T2.DOME_INST_NME, T2_1.DOME_INST_NME) DOME_INST_NME,
                    (
                        CASE
                            WHEN T4.CONTRACT_GUAR_TP = '01'
                            AND T5.CREDIT_LMT < 5000000 THEN '12DA1'
                            WHEN T4.CONTRACT_GUAR_TP = '01'
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12DA2'
                            WHEN T4.CONTRACT_GUAR_TP = '01'
                            AND T5.CREDIT_LMT >= 10000000 THEN '12DA3'
                            WHEN T4.CONTRACT_GUAR_TP = '02'
                            AND T5.CREDIT_LMT < 5000000 THEN '12DB1'
                            WHEN T4.CONTRACT_GUAR_TP = '02'
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12DB2'
                            WHEN T4.CONTRACT_GUAR_TP = '02'
                            AND T5.CREDIT_LMT >= 10000000 THEN '12DB3'
                            WHEN T4.CONTRACT_GUAR_TP = '03'
                            AND T5.CREDIT_LMT < 5000000 THEN '12DC1'
                            WHEN T4.CONTRACT_GUAR_TP = '03'
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12DC2'
                            WHEN T4.CONTRACT_GUAR_TP = '03'
                            AND T5.CREDIT_LMT >= 10000000 THEN '12DC3'
                            WHEN T4.CONTRACT_GUAR_TP = '04'
                            AND T5.CREDIT_LMT < 5000000 THEN '12DD1'
                            WHEN T4.CONTRACT_GUAR_TP = '04'
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12DD2'
                            WHEN T4.CONTRACT_GUAR_TP = '04'
                            AND T5.CREDIT_LMT >= 10000000 THEN '12DD3'
                            WHEN T4.CONTRACT_GUAR_TP = '05'
                            AND T5.CREDIT_LMT < 5000000 THEN '12DE1'
                            WHEN T4.CONTRACT_GUAR_TP = '05'
                            AND T5.CREDIT_LMT < 10000000
                            AND T5.CREDIT_LMT >= 5000000 THEN '12DE2'
                            WHEN T4.CONTRACT_GUAR_TP = '05'
                            AND T5.CREDIT_LMT >= 10000000 THEN '12DE3'
                        END
                    ) AS INDEX_CODE,
                    T1.BAL * NVL (T3.RATE, 1) AS INDEX_VALUE
                FROM
                    B_GEMS_LOAN_INFO T1
					
                    --基础表连接机构表 入账机构在4级机构
                    LEFT JOIN (
                        SELECT
                            '4' AS INST_LEVEL_4,
                            INST_ID,
                            INST_NME,
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            INST_ID,
                            INST_NME,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2 ON T1.ACTOPE_INST_ID = T2.INST_ID
					
                    --基础表连接机构表 入账机构在3级机构
                    LEFT JOIN (
                        SELECT
                            '3' AS INST_LEVEL_3,
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            '2' AS INST_LEVEL_2,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID) AS PROV_INST_ID,
                            COALESCE(PROV_INST_NME, DOMN_INST_NME) AS PROV_INST_NME,
                            '1' AS INST_LEVEL_1,
                            '99999999999' AS DOME_INST_ID,
                            '境内汇总' AS DOME_INST_NME
                        FROM
                            B_PBLC_INST_INFO
                        WHERE
                            ACCTG_DT = '20241031'
                        GROUP BY
                            DOMN_INST_ID,
                            DOMN_INST_NME,
                            COALESCE(PROV_INST_ID, DOMN_INST_ID),
                            COALESCE(PROV_INST_NME, DOMN_INST_NME)
                    ) T2_1 ON T1.ACTOPE_INST_ID = T2_1.DOMN_INST_ID
					
                    --基础表连接汇率表，余额转人民币
                    LEFT JOIN CCY_RATE T3 ON T1.CCY = T3.CCY_OLD
                    AND T3.CCY_NEW = 'CNY'
                    AND T3.COUNT_FLG = '00'
                    AND T3.BGN_DT <= TO_DATE ('20241031', 'YYYYMMDD')
                    AND T3.END_DT > TO_DATE ('20241031', 'YYYYMMDD')
					
                    --基础表连接合同表，获取担保方式
                    LEFT JOIN B_GEMS_LOAN_CONTRACT_INFO T4 ON T1.UNVS_AGM_NO = T4.UNVS_AGM_NO
                    AND T1.AGM_MODIF = T4.AGM_MODIF
                    AND T4.ACCTG_DT = '20241031'
					
                    --基础表连接授信表，获取授信额度
                    LEFT JOIN B_ECIF_CUST_LMT T5 ON T1.CUST_ID = T5.CUST_ID
                    AND T5.ACCTG_DT = '20241031'
					
                    --过滤当月余额大于0
                WHERE
                    T1.ACCTG_DT = '20241031'
                    AND T1.BAL > 0
					
                    --且属于121/123类
                    AND (
                        T1.ACCTG_SBJEC_ID LIKE '123%'
                        OR T1.ACCTG_SBJEC_ID LIKE '121%'
                    )
            )
			
            --按机构层级分组   
        GROUP BY
            GROUPING SETS (
                (INST_ID, INST_NME, INST_LEVEL_4, INDEX_CODE),
                (
                    DOMN_INST_ID,
                    DOMN_INST_NME,
                    INST_LEVEL_3,
                    INDEX_CODE
                ),
                (
                    PROV_INST_ID,
                    PROV_INST_NME,
                    INST_LEVEL_2,
                    INDEX_CODE
                ),
                (
                    DOME_INST_ID,
                    DOME_INST_NME,
                    INST_LEVEL_1,
                    INDEX_CODE
                )
            )
    )
	
    --直接在3级机构入账的记录在4级机构分组中为空 需要过滤掉
WHERE
    COALESCE(
        INST_LEVEL_4,
        INST_LEVEL_3,
        INST_LEVEL_2,
        INST_LEVEL_1
    ) IS NOT NULL
ORDER BY
    INDEX_CODE,
    INST_LEVEL
;

--提交事务
COMMIT;

--展示结果
SELECT * FROM B_GEMS_LOAN_BAL_SUM_OF_LMSM;
