CREATE TABLE B_PBLC_INST_INFO(
ACCTG_DT VARCHAR(8),           --报表日期
INST_ID VARCHAR(12),           --机构编号
INST_NME VARCHAR(100),         --机构名称
DOMN_INST_ID VARCHAR(12),      --辖行编号
DOMN_INST_NME VARCHAR(100),    --辖行名称
PROV_INST_ID VARCHAR(12),      --省行编号
PROV_INST_NME VARCHAR(100)     --省行名称
);

CREATE TABLE B_ECIF_CUST_INFO_C(--客户表
ACCTG_DT VARCHAR(8),            --报表日期
ACTOPE_INST_ID VARCHAR(12),     --开户机构
CUST_ID VARCHAR(20),            --客户号
CUST_NME VARCHAR(200),          --客户名称
HOLD_SHARE VARCHAR(10),         --控股方式
ENTP_SCAL_CD VARCHAR(10),       --企业规模：01-微型,02-小型,03-中型,04-大型，00-其他
BLON_INDS VARCHAR(50),          --客户行业
RSDT_FLG VARCHAR(1),            --居民标志：1-居民,0-非居民
LGL_RPRS_PRS_FLG VARCHAR(1),    --法人标志：1-法人,0-非法人
LGL_RPRS_CUST_ID VARCHAR(20)    --法人客户号
);

CREATE TABLE B_GEMS_LOAN_INFO(  --贷款基础表
ACCTG_DT VARCHAR(8),            --报表日期
UNVS_AGM_NO VARCHAR(30),        --贷款协议号
AGM_MODIF VARCHAR(10),          --贷款序号
LOAN_CUST_FLG VARCHAR(1),       --贷款客户类型
CUST_ACCT_NO VARCHAR(20),       --客户账号
CUST_ID VARCHAR(20),            --客户号
CCY VARCHAR(3),                 --币种
ACCTG_SBJEC_ID VARCHAR(20),     --科目号
ACTOPE_INST_ID VARCHAR(12),     --开户机构
LOAN_BGN_DT DATE,               --贷款协议开始日
LOAN_END_DT DATE,               --贷款协议结束日
BAL NUMERIC(18,2),              --余额
LOAN_TP_CD VARCHAR(10)          --贷款类型代码
);

CREATE TABLE B_GEMS_LOAN_CONTRACT_INFO(  --贷款合同表
ACCTG_DT VARCHAR(8),            --报表日期
UNVS_AGM_NO VARCHAR(30),        --贷款协议号
AGM_MODIF VARCHAR(10),          --贷款序号
CONTRACT_NO VARCHAR(30),        --贷款合同号
CONTRACT_CCY VARCHAR(3),        --币种
CONTRACT_AMT NUMERIC(18,2),     --贷款合同金额
CONTRACT_STS VARCHAR(3),        
--贷款合同状态：01-正常,02-待生效,03-终止,04-撤销,05-无效,00-其他
CONTRACT_GUAR_TP VARCHAR(3),    
--贷款合同担保方式：01-保证,02-抵押,03-质押,04-现金保证,05-信用,06-其他
CONTRACT_BGN_DT DATE,           --贷款合同开始日
CONTRACT_END_DT DATE,           --贷款合同结束日
CONTRACT_TYPE VARCHAR(100)
--合同大类：对公业务，对私业务，转贴现，公转商，贸易融资，财资贷款
);

CREATE TABLE CCY_RATE(--币种汇率表
CCY_OLD VARCHAR(3),             --折算前币种
CCY_NEW VARCHAR(3),             --折算后币种
RATE NUMERIC(10,6),             --汇率
BGN_DT DATE,                    --开始日期
END_DT DATE,                    --结束日期
COUNT_FLG VARCHAR(2)            --境内标志：00-境内，99-境外
);

CREATE TABLE CDE_INF(--码值表:可取科目名称、贷款类型中文
CDE_TP VARCHAR(20),        --码值类型：KN-科目名称,LT-贷款类型,
CDE VARCHAR(20),           --码值
CDE_NME VARCHAR(100),      --码值名称
UPDATE_DT DATE             --更新日期
);


CREATE TABLE B_RISK_LOAN_FIVE_CLASS(  --贷款五级分类表
ACCTG_DT VARCHAR(8),            --报表日期
UNVS_AGM_NO VARCHAR(30),        --贷款协议号
AGM_MODIF VARCHAR(10),          --贷款序号
BAL NUMERIC(18,2),              --余额
FIVE_CLASS VARCHAR(1),          --五级分类 1-正常 2-关注 3-次级 4-可疑 5-损失
FINAL_FIVE_CLASS VARCHAR(1)     --授信部最终五级分类（每个月自然日3号更新，常用于月末报送的数据）
);

CREATE TABLE B_ECIF_CUST_LMT(  --客户授信额度表
ACCTG_DT VARCHAR(8),           --报表日期
CUST_ID VARCHAR(30),           --客户号
LOAN_USED_LMT NUMERIC(18,2),   --贷款已用额度
TOTAL_USED_LMT NUMERIC(18,2),  --已用额度汇总
CREDIT_LMT NUMERIC(18,2)       --授信额度
);