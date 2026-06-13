--机构表join客户表join客户授信额度表
select * 
from B_PBLC_INST_INFO bpi join B_ECIF_CUST_INFO_C bci 
on bpi.acctg_dt=bci.acctg_dt and bpi.inst_id=bci.actope_inst_id
join B_ECIF_CUST_LMT bec on bci.cust_id=bec.cust_id

select * from B_PBLC_INST_INFO；
select * from B_ECIF_CUST_INFO_C；
select * from B_ECIF_CUST_LMT;

select * from B_GEMS_LOAN_CONTRACT_INFO;
select * from B_GEMS_LOAN_INFO;
--贷款合同表join贷款基础表
select * 
from B_GEMS_LOAN_CONTRACT_INFO blc join B_GEMS_LOAN_INFO bgl
on blc.unvs_agm_no=bgl.unvs_agm_no and blc.agm_modif=bgl.agm_modif

--机构表join客户表join客户授信额度表join贷款基础表join贷款合同表join码值表join币种汇率表

select 
from(
select * 
from B_PBLC_INST_INFO bpi join B_ECIF_CUST_INFO_C bci 
on bpi.acctg_dt=bci.acctg_dt and bpi.inst_id=bci.actope_inst_id
join B_ECIF_CUST_LMT bec on bci.cust_id=bec.cust_id
join B_GEMS_LOAN_INFO bgl 
on bci.cust_id=bgl.cust_id and bci.actope_inst_id=bgl.actope_inst_id and bci.acctg_dt=bgl.acctg_dt
join B_GEMS_LOAN_CONTRACT_INFO blc 
on blc.unvs_agm_no=bgl.unvs_agm_no and blc.agm_modif=bgl.agm_modif
join CDE_INF cdi on cdi.cde=bgl.loan_tp_cd
join CCY_RATE cr on cr.ccy_old=bgl.ccy and (cr.bgn_dt<=to_date(bgl.acctg_dt,'yyyy-mm-dd')
and to_date(bgl.acctg_dt,'yyyy-mm-dd')<cr.end_dt);
select 报表日期,省分行号,省分行名称,辖行编号 辖行号,辖行名称,机构编号,机构名称,贷款协议号 协议号,
       贷款序号 协议修饰符,贷款合同号 合同号,
       case when 贷款合同状态=1 then '正常'
            when 贷款合同状态=2 then '待生效'
            when 贷款合同状态=3 then '终止'
            when 贷款合同状态=4 then '撤销'
            when 贷款合同状态=5 then '无效' else '其他' end 合同状态,
            客户号,客户名称,客户行业,
       case when 企业规模=1 then '微小型企业'
            when 企业规模=2 then '中型企业'
            when 企业规模=3 then '大型企业'
            else '其他企业'end
       企业规模,授信额度,居民标志,科目号,
       case 码值类型 when 'KN' then 码值名称 end 科目名称,
       case 码值类型 when 'LT' then 码值名称 end 贷款产品类别,              
       贷款协议开始日 贷款发放日,贷款协议结束日 协议到期日,
       case 余额 when 0 then 报表日期3 else null end 贷款结清日,
       币种,余额,
       余额 *  (case when 折算前币种='EUR' and 折算后币种='CNY' then 汇率
                     when 折算前币种='USD' and 折算后币种='CNY' then 汇率
                     else 1 end) 余额折人民币,
       余额 *  (case when 折算前币种='CNY' and 折算后币种='USD' then 汇率
                     when 折算前币种='EUR' and 折算后币种='USD' then 汇率
                     else 1 end) 余额折美元,
       case when 法人标志=1 then '是' else '否' end 法人标志       
from(
      select *
      from(
      select acctg_dt 报表日期,
             inst_id 机构编号,
             inst_nme 机构名称,
             domn_inst_id 辖行编号,
             domn_inst_nme 辖行名称,
             prov_inst_id 省分行号,
             prov_inst_nme 省分行名称
      from B_PBLC_INST_INFO) bpi
      join(
      select acctg_dt 报表日期1,
             actope_inst_id 开户机构,
             cust_id 客户号,
             cust_nme 客户名称,
             hold_share 控股方式,
             entp_scal_cd 企业规模,
             blon_inds 客户行业,
             rsdt_flg 居民标志,
             lgl_rprs_prs_flg 法人标志,
             lgl_rprs_cust_id 法人客户号
      from B_ECIF_CUST_INFO_C) bci
      on bpi.报表日期=bci.报表日期1 and bpi.机构编号=bci.开户机构 or bpi.辖行编号=bci.开户机构
      join(
      select acctg_dt 报表日期2,
             cust_id 客户号,
             loan_used_lmt 贷款已用额度,
             total_used_lmt 已用额度汇总,
             credit_lmt 授信额度
      from B_ECIF_CUST_LMT) bec
      on bci.客户号=bec.客户号
      join(
      select acctg_dt 报表日期3,
             unvs_agm_no 贷款协议号,
             agm_modif 贷款序号,
             loan_cust_flg 贷款客户类型,
             cust_acct_no 客户账号,
             cust_id 客户号,
             ccy 币种,
             acctg_sbjec_id 科目号,
             actope_inst_id 开户机构,
             loan_bgn_dt 贷款协议开始日,
             loan_end_dt 贷款协议结束日,
             bal 余额,
             loan_tp_cd 贷款类型代码
      from B_GEMS_LOAN_INFO) bgl
      on bci.客户号=bgl.客户号 and (bpi.机构编号=bgl.开户机构 or bpi.辖行编号=bci.开户机构)
      and bpi.报表日期=bgl.报表日期3 
      join(
      select acctg_dt 报表日期4,
             unvs_agm_no 贷款协议号1,
             agm_modif 贷款序号1,
             contract_no 贷款合同号,
             contract_ccy 币种1,
             contract_amt 贷款合同金额,
             contract_sts 贷款合同状态,
             contract_guar_tp 贷款合同担保方式,
             contract_bgn_dt 贷款合同开始日,
             contract_end_dt 贷款合B同结束日,
             contract_type 合同大类
      from B_GEMS_LOAN_CONTRACT_INFO) blc
      on blc.贷款协议号1=bgl.贷款协议号 and blc.贷款序号1=bgl.贷款序号
      join(
      select cde_tp 码值类型,
             cde 码值,
             cde_nme 码值名称,
             update_dt 更新日期,ROW_NUMBER() OVER(PARTITION BY CDE ORDER BY UPDATE_DT DESC) RN
      from CDE_INF) cdi
      on cdi.码值=bgl.贷款类型代码 and rn=1   
      --where bci.法人客户号 is not null and blc.贷款序号=1
      join(
      select ccy_old 折算前币种,
             ccy_new 折算后币种,
             rate 汇率,
             bgn_dt 开始日期,
             end_dt 结束日期,
             count_flg 境内标志
      from CCY_RATE) cr 
      on bgl.币种=cr.折算前币种 and (cr.开始日期<=to_date(bgl.报表日期3,'yyyy-mm-dd')
      and to_date(bgl.报表日期3,'yyyy-mm-dd')<cr.结束日期) and 境内标志=00)
      
