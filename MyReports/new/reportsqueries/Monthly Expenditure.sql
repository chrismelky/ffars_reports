select
    case when fs.code in ('80E','10A', '10B', '10E', '80D','80A','30C', '80C') then 'Own Source' else 'Grant' end as fund,
    gc.code as gfs_code,
    gc.name as gfs_description,
    TO_CHAR(('2023-03-30')::DATE, 'Month') as currentMonth,
    'July' || '-' || to_char((DATE_TRUNC('MONTH', ('2023-03-30')::DATE) - INTERVAL '0 MONTH + 1 day')::DATE, 'Month') as previousMonths ,
    sum(pr.amount) as budget,
    sum(coalesce(lc.previous2Amount,0)) as previous2Amount,
    sum(coalesce(mc.currentAmount,0)) as currentAmount
from activity_costings as pr
    join funding_sources fs on fs.id = pr.funding_source_id
         join gfs_codes gc on pr.gfs_code_id = gc.id
         left join (
    select
        gc.id as gfs_id,
        sum(ge.dr_amount - ge.cr_amount) as currentAmount
    from  gl_entry_groups geg
              join gl_entries ge on geg.id = ge.gl_entry_group_id
              join gl_accounts ga on ge.account = ga.code
              join gfs_codes gc on gc.code = ga.gfs_code
    where ga.gl_account_type =  'EXPENDITURE'
      and geg.apply_date >=(DATE_TRUNC('MONTH', ('2023-03-30')::DATE) - INTERVAL '0 MONTH')::DATE
      and geg.apply_date <=(DATE_TRUNC('MONTH', ('2023-03-30')::DATE) + INTERVAL '1 MONTH - 1 day')::DATE
      and geg.facility_id = 5597
    group by  gc.id
) as mc on mc.gfs_id = gc.id
         left join (
    select
        gc.id as gfs_id,
        sum(ge.dr_amount - ge.cr_amount) as previous2Amount
    from  gl_entry_groups geg
              join gl_entries ge on geg.id = ge.gl_entry_group_id
              join gl_accounts ga on ge.account = ga.code
              join gfs_codes gc on gc.code = ga.gfs_code
    where ga.gl_account_type =  'EXPENDITURE'
      and geg.apply_date <= (DATE_TRUNC('MONTH', ('2023-03-30')::DATE) - INTERVAL '0 MONTH + 1 day')::DATE
    and geg.facility_id = 5597
    and geg.financial_year_id = 1
group by  gc.id
    ) as lc on lc.gfs_id = gc.id
where pr.financial_year_id= 1
  and pr.facility_id = 5597
group by fs.code, gc.id
order by fund desc
