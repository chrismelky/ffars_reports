select * from (
select cname as council, fwv.name as facility, fwv.ftype as type,'01-01-2023' as date, 'opening balance' as description ,
       '-' as reference, 0.0 as dr, sum(cr_amount - dr_amount) as cr  from gl_entries  ge
                                                                                                                                                                           join gl_accounts ga on ge.account = ga.code
                                                                                                                                                                           join gl_entry_groups geg on geg.id = ge.gl_entry_group_id
                                                                                                                                                                           join facility_ward_view fwv on fwv.id = geg.facility_id
where gl_account_type = 'DEPOSIT' and apply_date < '01-01-2023'
  and  ge.facility_id = 21100 group by cname, fwv.name, fwv.ftype, ge.facility_id

UNION ALL

select cname as council, fwv.name as facility, fwv.ftype as type,geg.apply_date as date, geg.description, reference, dr_amount as dr, cr_amount as cr  from gl_entries  ge
join gl_accounts ga on ge.account = ga.code
join gl_entry_groups geg on geg.id = ge.gl_entry_group_id
join facility_ward_view fwv on fwv.id = geg.facility_id
where gl_account_type = 'DEPOSIT'
and  ge.facility_id = 21100 and geg.apply_date >= '01-01-2023'

    and geg.apply_date <= '01-06-2023'
    )sub
order by date asc

