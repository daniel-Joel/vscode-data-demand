create table 贷款需求表(
数据日期 date,
机构编号 varchar2(100),
机构名称 varchar2(100),
机构层级 varchar2(100),
指标编号 varchar2(100),
指标值 number)
select * from 贷款需求表
select * from B_GEMS_LOAN_INFO;

select ACCTG_SBJEC_ID,BAL 企业贷款非贸易融资贷款
from B_GEMS_LOAN_INFO
where ACCTG_SBJEC_ID like '121%'

select max(t2.acctg_dt),t2.inst_id,max(t2.inst_nme),'4' 机构层级,
       case when t1.acctg_sbjec_id like '121%' then '12AA' 
            when t1.acctg_sbjec_id like '123%' then '22AA' end 指标编号,
       sum(bal) 指标
from B_GEMS_LOAN_INFO t1 
join B_PBLC_INST_INFO t2
on t1.acctg_dt=t2.acctg_dt and t1.actope_inst_id=t2.inst_id and t1.acctg_dt='20241031'
group by t2.inst_id,case when t1.acctg_sbjec_id like '121%' then '12AA' 
                         when t1.acctg_sbjec_id like '123%' then '22AA' end
having sum(bal)<>0
union all
select max(t2.acctg_dt),max(t2.inst_id),max(t2.inst_nme),'3' 机构层级,
       case when t1.acctg_sbjec_id like '121%' then '12AA' 
            when t1.acctg_sbjec_id like '123%' then '22AA' end 指标编号,
       sum(bal) 指标
from B_GEMS_LOAN_INFO t1 
join B_PBLC_INST_INFO t2
on t1.acctg_dt=t2.acctg_dt and t1.actope_inst_id=t2.inst_id and t1.acctg_dt='20241031'
group by t2.domn_inst_id,case when t1.acctg_sbjec_id like '121%' then '12AA' 
                         when t1.acctg_sbjec_id like '123%' then '22AA' end
having sum(bal)<>0
union all
select max(t2.acctg_dt),max(t2.inst_id),max(t2.inst_nme),
       '4' 机构层级, 
       case when ENTP_SCAL_CD=1 or ENTP_SCAL_CD=2 then '12AB'
            when ENTP_SCAL_CD=3 then '12AC'
            when ENTP_SCAL_CD=4 then '12AD' end 指标编号,sum(bal) 指标
from B_GEMS_LOAN_INFO t1 
join B_PBLC_INST_INFO t2
on t1.acctg_dt=t2.acctg_dt and t1.actope_inst_id=t2.inst_id 
join B_ECIF_CUST_INFO_C t3
on t2.acctg_dt=t3.acctg_dt and t2.inst_id=t3.actope_inst_id and t1.acctg_dt='20241031'
group by t2.inst_id, case when ENTP_SCAL_CD=1 or ENTP_SCAL_CD=2 then '12AB'
            when ENTP_SCAL_CD=3 then '12AC'
            when ENTP_SCAL_CD=4 then '12AD' end
having sum(bal)>0
union all
select max(t2.acctg_dt),max(t2.inst_id),max(t2.inst_nme),
       '3' 机构层级, 
       case when ENTP_SCAL_CD=1 or ENTP_SCAL_CD=2 then '12AB'
            when ENTP_SCAL_CD=3 then '12AC'
            when ENTP_SCAL_CD=4 then '12AD' end 指标编号,sum(bal) 指标
from B_GEMS_LOAN_INFO t1 
join B_PBLC_INST_INFO t2
on t1.acctg_dt=t2.acctg_dt and t1.actope_inst_id=t2.inst_id 
join B_ECIF_CUST_INFO_C t3
on t2.acctg_dt=t3.acctg_dt and t2.inst_id=t3.actope_inst_id and t1.acctg_dt='20241031'
group by t2.domn_inst_id, case when ENTP_SCAL_CD=1 or ENTP_SCAL_CD=2 then '12AB'
            when ENTP_SCAL_CD=3 then '12AC'
            when ENTP_SCAL_CD=4 then '12AD' end
having sum(bal)>0


