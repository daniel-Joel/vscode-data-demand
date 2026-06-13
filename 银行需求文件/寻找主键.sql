select * from B_GEMS_LOAN_CONTRACT_INFO;
select unvs_agm_no,count(*)
from B_GEMS_LOAN_CONTRACT_INFO
group by unvs_agm_no,agm_modif

select * from B_PBLC_INST_INFO;
select inst_id,domn_inst_id,count(*)
from B_PBLC_INST_INFO
where acctg_dt=20241031
group by inst_id,domn_inst_id

select * from B_ECIF_CUST_INFO_C ;
select cust_id,count(*)
from B_ECIF_CUST_INFO_C
group by cust_id

select * from B_GEMS_LOAN_INFO where acctg_dt=20241031;
select unvs_agm_no,agm_modif,count(*) 
from B_GEMS_LOAN_INFO
where acctg_dt=20241031
group by unvs_agm_no,agm_modif

select * from CCY_RATE where to_char(bgn_dt,'yyyy-mm-dd')='2024-10-31';
 
select * from CDE_INF where to_char(update_dt,'yyyy-mm-dd')='2024-08-31'

select * from B_RISK_LOAN_FIVE_CLASS where acctg_dt=20241031

select * from B_ECIF_CUST_LMT
select cust_id,count(*)
from B_ECIF_CUST_LMT
group by cust_id


