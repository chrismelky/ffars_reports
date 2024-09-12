SELECT wv.rname AS region,wv.rcode AS vote, wv.cname AS council,wv.ccode AS council_id,
       wv.name AS fname,facility_id,wv.ftype AS type,fs.description AS name,fs.code AS code,sum(carryover) AS carryover,
       sum(receipt) AS total_received,sum(payment) AS amount_spent,
       sum(receipt + carryover - payment) AS current_balance,sum(budget) AS budget
FROM (SELECT facility_id, funding_source_id, sum(amount) AS carryover, 0 AS receipt, 0 AS payment, 0 AS budget FROM fund_trackings
WHERE  date < '01-08-2022'
GROUP BY  facility_id, funding_source_id

UNION ALL

SELECT facility_id, funding_source_id,  0 AS caryover, sum(amount) as receipt, 0 AS payment, 0 AS budget   FROM fund_trackings
WHERE transaction_type <> 'App\Models\Payable'  AND date >= '01-08-2022' AND date <= '01-01-2024'
GROUP BY  facility_id, funding_source_id

UNION ALL

SELECT  facility_id, funding_source_id,  0 AS caryover,0 AS receipt, sum(amount) *-1  AS payment, 0 AS budget  FROM fund_trackings ftr
WHERE transaction_type = 'App\Models\Payable'  AND date >= '01-08-2022' AND date <= '01-01-2024'
GROUP BY facility_id, funding_source_id

UNION ALL

 SELECT  facility_id, funding_source_id,  0 AS caryover,0 AS receipt, 0 AS payment, sum(amount)  AS budget  FROM activity_costings ac
   WHERE  financial_year_id = 1
   GROUP BY  facility_id, funding_source_id
)sub
JOIN facility_ward_view wv ON wv.id = sub.facility_id
JOIN funding_sources fs ON fs.id = sub.funding_source_id
GROUP BY wv.rname, wv.rcode, wv.cname, wv.ccode, wv.name, facility_id, wv.ftype, fs.description, fs.code



--- '01-01-2024' end date 
--- '01-08-2022' start date


---- cosolidated fund source status
SELECT
    wv.rname AS region,
    wv.cname AS council,
    fs.code,fs.description,
    SUM(coalesce(carryover,0)) AS carryover,
    SUM(coalesce(receipt,0)) AS receipt,
    SUM(coalesce(expenditure,0)) AS expenditure
FROM facility_ward_view wv
         JOIN facilities f ON f.id = wv.id

         JOIN (
    SELECT
        facility_id,
        fr.funding_source_id,
        SUM(amount) AS carryover,
        0.00 AS receipt,
        0.00 AS expenditure
    FROM fund_trackings fr
             JOIN  facility_ward_view vw ON vw.id = fr.facility_id
    WHERE fr.date < $P{start_date}::date
      AND (vw.rid = $P{location_id} OR vw.cid = $P{location_id} OR vw.wid=$P{location_id} OR 1=$P{location_id})
    GROUP BY fr.facility_id,fr.funding_source_id

    UNION ALL

    SELECT
        ga.facility_id,
        fr.funding_source_id,
        0.00 AS carryover,
        SUM(CASE WHEN (ga.gl_account_type = 'REVENUE' OR ga.gl_account_type = 'DEPOSIT' OR  ga.gl_account_type = 'OPENING_BALANCE') THEN  amount  ELSE  0 END) AS receipt,
        SUM(CASE WHEN ga.gl_account_type = 'EXPENDITURE' THEN  -1 * amount  ELSE  0 END ) AS expenditure
    from fund_trackings fr
        JOIN  gl_accounts AS ga ON ga.code=fr.gl_account
        JOIN  funding_sources f ON f.code = ga.fund_code
        JOIN  facility_ward_view vw ON vw.id = ga.facility_id
    WHERE  ga.gl_account_type IN  ('EXPENDITURE','REVENUE','OPENING_BALANCE','DEPOSIT')
      AND (rid = $P{location_id}
       OR cid = $P{location_id}
       OR wid=  $P{location_id}
       OR 1 = $P{location_id})
      AND fr.date
        BETWEEN $P{start_date}::date
      AND $P{end_date}::date
    GROUP BY  ga.facility_id,fr.funding_source_id

) sub ON f.id = sub.facility_id
         JOIN funding_sources fs ON sub.funding_source_id = fs.id
WHERE (wv.rid = $P{location_id} OR wv.cid = $P{location_id} OR wv.wid=$P{location_id} OR 1=$P{location_id})
GROUP BY  wv.rname, wv.cname,fs.code,fs.description

-------------- consolidated payment and receipt
select
    wv.rname as region,
    wv.cname as council,
    ft.name as type,
    sum(coalesce(carryover,0)) as carryover,
    sum(coalesce(receipt,0)) as receipt,
    sum(coalesce(expenditure,0)) as expenditure
from facility_ward_view wv
         join facilities f on f.id = wv.id
         join facility_types ft on ft.id = f.facility_type_id
         left join (
    select
        facility_id,
        sum(amount) as carryover,
        0.00 as receipt,
        0.00 as expenditure
    from fund_trackings fr
             join facility_ward_view vw on vw.id = fr.facility_id
    where fr.date < $P{start_date}::date
      and (vw.rid = $P{location_id} or vw.cid = $P{location_id} or vw.wid=$P{location_id} or 1=$P{location_id})
    group by fr.facility_id

    UNION ALL

    select
        ga.facility_id,
        0.00 as carryover,
        SUM(case when ga.gl_account_type = 'REVENUE' then amount else 0 end) as receipt,
        SUM(case when ga.gl_account_type = 'EXPENDITURE' then -1 * amount else 0 end) as expenditure
    from fund_trackings fr
        join gl_accounts as ga on ga.code=fr.gl_account
        left join funding_sources f on f.code = ga.fund_code
        join facility_ward_view vw on vw.id = ga.facility_id
    where  ga.gl_account_type in  ('EXPENDITURE','REVENUE')
      and (rid = $P{location_id}
       or cid = $P{location_id}
       or wid=  $P{location_id}
       or 1 = $P{location_id})
      and fr.date
        between $P{start_date}::date
      and $P{end_date}::date
    group by  ga.facility_id

)
    sub on f.id = sub.facility_id
where (wv.rid = $P{location_id} or wv.cid = $P{location_id} or wv.wid=$P{location_id} or 1=$P{location_id})
group by wv.rname, wv.cname, ft.name


