
select wv.id,wv.rname  as region, wv.rcode as vote, wv.cname as council_name,
       wv.ccode as council_code,wv.ftype as facility_type_name,wv.code as facility_code,
       wv.name as facility_name, ga.fund_code as fundsourcecode,
       fs.description as  fundsourcename,ga.code as account,
       ga.gfs_code,gfs.code as gfscode_description,sum(ge.cr_amount - ge.dr_amount)
from gl_entries ge
    join gl_entry_groups geg on geg.id = ge.gl_entry_group_id
    join gl_accounts ga on ga.code = ge.account
    join facility_ward_view wv on wv.id = geg.facility_id
join funding_sources fs on ga.fund_code  = fs.code
join gfs_codes gfs on ga.gfs_code = gfs.code

    where ga.gl_account_type  = 'REVENUE'
      and geg.financial_year_id = 1 and geg.apply_date > '01-07-2021' and geg.apply_date < '01-07-2024'
      and geg.facility_id = 5593

group by wv.rname, wv.rcode, wv.cname, wv.ccode, wv.ftype, wv.code, wv.name, ga.fund_code, fs.description, ga.gfs_code, gfs.code,
         ga.code,wv.id


-- replace facility_id, start_date, end_date with respective parameters.


