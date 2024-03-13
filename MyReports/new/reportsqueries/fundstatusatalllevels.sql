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
