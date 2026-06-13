create table detailed_statement_loans(--对公贷款明细表
report_date date,                     --报表日期
Provincial_branch_number varchar2(100),--省分行号
provincial_branch_name varchar2(20),--省分行名称
Jurisdictional_number varchar2(20),--辖行号
jurisdiction_name varchar2(20),--辖行名称
Institution_number varchar2(20),--机构编号
institution_name varchar2(20),--机构名称
Protocol_number varchar2(20),--协议号
Protocol_modifiers varchar2(20),--协议修饰符
Contract_number varchar2(20),--合同号
Contract_status varchar2(20),--合同状态
Customer_number varchar2(20),--客户号
customer_name varchar2(20),--客户名称
Customer_industry varchar2(20),--客户行业
enterprise_size varchar2(20),--企业规模
credit_line number,--授信额度
Resident_signs varchar2(20),--居民标志
Account_number varchar2(20),--科目号
Account_name varchar2(20),--科目名称
Loan_product_category varchar2(20),--贷款产品类别
loan_was_disbursed_date date,--贷款发放日
Agreement_expiration_date date,--协议到期日
loan_settled_date date,--贷款结清日
Currency varchar2(20),--币种
balance number,--余额
converted_into_RMB number,--余额折人民币
converted_to_US_dollars number,--余额折美元
Corporate_logo varchar2(20),--法人标志
Corporate_customer_number varchar2(20),--法人客户号
corporate_customer_name varchar2(20),--法人客户名称
corporate_customer_en_size varchar2(20))--法人客户企业规模
select * from detailed_statement_loans;


