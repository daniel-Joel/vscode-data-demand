--删除当月数据
DELETE FROM DGDKJJB WHERE ACCTG_DT = TO_DATE('2024-10-31','YYYY-MM-DD');

--插入当月数据
INSERT INTO DGDKJJB(
    ACCTG_DT                                 --报表日期
   ,PROV_INST_ID                             --省分行号
   ,PROV_INST_NME                            --省分行名称
   ,DOMN_INST_ID                             --辖行号
   ,DOMN_INST_NME                            --辖行名称
   ,INST_ID                                  --机构编号
   ,INST_NME                                 --机构名称
   ,UNVS_AGM_NO                              --协议号
   ,AGM_MODIF                                --协议修饰符
   ,CONTRACT_NO                              --合同号
   ,CONTRACT_STS                             --合同状态
   ,CUST_ID                                  --客户号
   ,CUST_NME                                 --客户名称
   ,BLON_INDS                                --客户行业
   ,ENTP_SCAL_CD                             --企业规模
   ,TOT_LMT                                  --授信额度
   ,RSDT_FLG                                 --居民标志
   ,ACCTG_SBJEC_ID                           --科目号
   ,ACCTG_SBJEC_NME                          --科目名称
   ,LOAN_TP_NME                              --贷款产品类别
   ,LOAN_BGN_DT                              --贷款发放日
   ,LOAN_END_DT                              --协议到期日
   ,LOAN_SETTLE_DT                           --贷款结清日
   ,CCY                                      --币种
   ,BAL                                      --余额
   ,BAL_CNY                                  --余额折人民币
   ,BAL_USD                                  --余额折美元
   ,LGL_RPRS_PRS_FLG                         --法人标志
   ,LGL_RPRS_CUST_ID                         --法人客户号
   ,LGL_RPRS_CUST_NME                        --法人客户名称
   ,LGL_ENTP_SCAL_CD                         --法人客户企业规模
)
SELECT TO_DATE('2024-10-31','YYYY-MM-DD')                             AS ACCTG_DT
      ,COALESCE(T2.PROV_INST_ID,T2.DOMN_INST_ID,T2_1.PROV_INST_ID)    AS PROV_INST_ID
	  ,COALESCE(T2.PROV_INST_NME,T2.DOMN_INST_NME,T2_1.PROV_INST_NME) AS PROV_INST_NME
	  ,COALESCE(T2.DOMN_INST_ID,T2_1.DOMN_INST_ID)                    AS DOMN_INST_ID
	  ,COALESCE(T2.DOMN_INST_NME,T2_1.DOMN_INST_NME)                  AS DOMN_INST_NME
	  ,T1.ACTOPE_INST_ID                                              AS INST_ID
	  ,COALESCE(T2.INST_NME,T2_1.DOMN_INST_NME)                       AS INST_NME
	  ,T1.UNVS_AGM_NO                                                 AS UNVS_AGM_NO
	  ,T1.AGM_MODIF                                                   AS AGM_MODIF
	  ,T3.CONTRACT_NO                                                 AS CONTRACT_NO
	  ,CASE WHEN T3.CONTRACT_STS = '01' THEN '正常'
            WHEN T3.CONTRACT_STS = '02' THEN '待生效'
            WHEN T3.CONTRACT_STS = '03' THEN '终止'
			WHEN T3.CONTRACT_STS = '04' THEN '撤销'
			WHEN T3.CONTRACT_STS = '05' THEN '无效'
			WHEN T3.CONTRACT_STS = '00' THEN '其他' END  	          AS CONTRACT_STS
	  ,T4.CUST_ID                                                     AS CUST_ID
	  ,T4.CUST_NME                                                    AS CUST_NME
	  ,T4.BLON_INDS                                                   AS BLON_INDS
	  ,CASE WHEN T4.ENTP_SCAL_CD IN ('01','02') THEN 'CS01'
			WHEN T4.ENTP_SCAL_CD = '03' THEN 'CS02'
			WHEN T4.ENTP_SCAL_CD = '04' THEN 'CS03'
			WHEN T4.ENTP_SCAL_CD = '00' THEN 'CS04' END               AS ENTP_SCAL_CD
	  ,T9.CREDIT_LMT                                                  AS TOT_LMT
	  ,CASE WHEN T4.RSDT_FLG = '是' THEN '1' ELSE '0' END             AS RSDT_FLG
	  ,T1.ACCTG_SBJEC_ID                                              AS ACCTG_SBJEC_ID
	  ,T5.CDE_NME                                                     AS ACCTG_SBJEC_NME
	  ,T5_1.CDE_NME                                                   AS LOAN_TP_NME
	  ,T1.LOAN_BGN_DT                                                 AS LOAN_BGN_DT
	  ,T1.LOAN_END_DT                                                 AS LOAN_END_DT
	  ,TO_DATE(T6.ACCTG_DT,'YYYY-MM-DD')                              AS LOAN_SETTLE_DT
	  ,T1.CCY                                                         AS CCY
	  ,T1.BAL                                                         AS BAL
	  ,CASE WHEN T1.CCY <> 'CNY' THEN T1.BAL*T8.RATE ELSE T1.BAL END  AS BAL_CNY
	  ,CASE WHEN T1.CCY <> 'USD' THEN T1.BAL*T8_1.RATE
	   ELSE T1.BAL END                                                AS BAL_USD
	  ,T4.LGL_RPRS_PRS_FLG                                            AS LGL_RPRS_PRS_FLG
	  ,COALESCE(T7.CUST_ID,T4.CUST_ID)                                AS LGL_RPRS_CUST_ID
	  ,COALESCE(T7.CUST_NME,T4.CUST_NME)                              AS LGL_RPRS_CUST_NME
	  ,CASE WHEN COALESCE(T7.ENTP_SCAL_CD,T4.ENTP_SCAL_CD) IN ('01','02') THEN 'CS01'
			WHEN COALESCE(T7.ENTP_SCAL_CD,T4.ENTP_SCAL_CD) = '03' THEN 'CS02'
			WHEN COALESCE(T7.ENTP_SCAL_CD,T4.ENTP_SCAL_CD) = '04' THEN 'CS03'
			WHEN COALESCE(T7.ENTP_SCAL_CD,T4.ENTP_SCAL_CD) = '00' THEN 'CS04' 
	   END                                                            AS LGL_ENTP_SCAL_CD
	  
FROM B_GEMS_LOAN_INFO                       T1

LEFT JOIN B_GEMS_LOAN_INFO					T1_1
     ON T1.UNVS_AGM_NO = T1_1.UNVS_AGM_NO
	 AND T1.AGM_MODIF = T1_1.AGM_MODIF
	 AND T1_1.ACCTG_DT = '20240930'
	 
LEFT JOIN B_PBLC_INST_INFO                  T2
     ON T1.ACTOPE_INST_ID = T2.INST_ID
	 AND T2.ACCTG_DT = '20241031'

LEFT JOIN (SELECT DOMN_INST_ID, DOMN_INST_NME, PROV_INST_ID, PROV_INST_NME
           FROM B_PBLC_INST_INFO
           WHERE ACCTG_DT = '20241031'
           GROUP BY DOMN_INST_ID, DOMN_INST_NME, PROV_INST_ID, PROV_INST_NME)	T2_1
     ON T1.ACTOPE_INST_ID = T2_1.DOMN_INST_ID

LEFT JOIN B_GEMS_LOAN_CONTRACT_INFO         T3
     ON T1.UNVS_AGM_NO = T3.UNVS_AGM_NO
	 AND T1.AGM_MODIF = T3.AGM_MODIF
	 AND T3.ACCTG_DT = '20241031'

LEFT JOIN B_ECIF_CUST_INFO_C                T4
     ON T1.CUST_ID = T4.CUST_ID 
	 AND T4.ACCTG_DT = '20241031'
	 
LEFT JOIN (SELECT CDE, CDE_NME, ROW_NUMBER() OVER(PARTITION BY CDE ORDER BY UPDATE_DT DESC) RN
           FROM CDE_INF WHERE CDE_TP = 'KN') T5
     ON T1.ACCTG_SBJEC_ID = T5.CDE
	 AND T5.RN = 1

LEFT JOIN (SELECT CDE, CDE_NME, ROW_NUMBER() OVER(PARTITION BY CDE ORDER BY UPDATE_DT DESC) RN
           FROM CDE_INF WHERE CDE_TP = 'LT'
		   ) T5_1
     ON T1.LOAN_TP_CD = T5_1.CDE
	 AND T5_1.RN = 1

LEFT JOIN (SELECT ACCTG_DT, UNVS_AGM_NO, AGM_MODIF, ROW_NUMBER() OVER(PARTITION BY UNVS_AGM_NO,AGM_MODIF ORDER BY ACCTG_DT ASC) RN
           FROM B_GEMS_LOAN_INFO
		   WHERE ACCTG_DT LIKE '202410%' 
		   AND BAL=0)                        T6
	 ON T1.UNVS_AGM_NO = T6.UNVS_AGM_NO
	 AND T1.AGM_MODIF = T6.AGM_MODIF
	 AND T6.RN = 1

LEFT JOIN B_ECIF_CUST_INFO_C                 T7
     ON T4.LGL_RPRS_CUST_ID = T7.CUST_ID 
	 AND T7.ACCTG_DT = '20241031'

LEFT JOIN CCY_RATE                           T8
     ON T1.CCY = T8.CCY_OLD
	 AND T8.CCY_NEW = 'CNY'
	 AND T8.BGN_DT <= DATE'2024-10-31'
	 AND T8.END_DT >  DATE'2024-10-31'
	 AND T8.COUNT_FLG = '00'
	 
LEFT JOIN CCY_RATE                           T8_1
     ON T1.CCY = T8_1.CCY_OLD
	 AND T8_1.CCY_NEW = 'USD'
	 AND T8_1.BGN_DT <= DATE'2024-10-31'
	 AND T8_1.END_DT >  DATE'2024-10-31'
	 AND T8_1.COUNT_FLG = '00'

LEFT JOIN B_ECIF_CUST_LMT                    T9
     ON T4.CUST_ID = T9.CUST_ID
	 AND T9.ACCTG_DT = '20241031'
	 
WHERE T1.ACCTG_DT = '20241031'
AND (T1.BAL<>0 OR NVL(T1_1.BAL,0)<>0 OR TO_CHAR(T1.LOAN_BGN_DT,'YYYY-MM') = '2024-10');

--AND 月末余额不为0或者结清日>上月末

1、T1.BAL<>0 月底尚未结清
2、T1_1.BAL<>0 上月末未结清
3、TO_CHAR(T1.LOAN_BGN_DT,'YYYY-MM') = '2024-10' 当月发放当月结清的数据
