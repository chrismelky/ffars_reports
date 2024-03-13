SELECT type, facility_name,facility_code,council,council_id,code,description,budget,expenditure,
       coalesce(implementation,' ') AS implementation ,coalesce(reason,' ') AS reason, coalesce(constraints,' ') AS constraints,balance,
       coalesce(allocation,0.0)  AS allocation FROM (

                                                        SELECT wv.ftype as type,f.name as facility_name,f.code AS facility_code,wv.cname AS council,wv.ccode AS council_id,
                                                               a.code, a.description,coalesce(bg.budget,0.0) AS budget, coalesce(exp.expenditure,0.0) AS expenditure,

                                                               CASE  WHEN   EXTRACT(QUARTER FROM  to_date('01-08-2022','DD/MM/YYYY'))   =  3  THEN  q1_implementation
                                                                     WHEN   EXTRACT(QUARTER FROM  to_date('01-08-2022','DD/MM/YYYY')) =  4   THEN  q2_implementation
                                                                     WHEN   EXTRACT(QUARTER FROM  to_date('01-08-2022','DD/MM/YYYY')) =  1  THEN  q3_implementation
                                                                     WHEN   EXTRACT(QUARTER FROM  to_date('01-08-2022','DD/MM/YYYY')) =  2   THEN  q4_implementation  ELSE ' ' END AS implementation,

                                                               case WHEN   EXTRACT(QUARTER FROM  to_date('01-08-2022','DD/MM/YYYY'))   =  3  THEN  q1_reason
                                                                    WHEN   EXTRACT(QUARTER FROM  to_date('01-08-2022','DD/MM/YYYY')) =  4     THEN  q2_reason
                                                                    WHEN   EXTRACT(QUARTER FROM  to_date('01-08-2022','DD/MM/YYYY')) =  1    THEN  q3_reason
                                                                    WHEN   EXTRACT(QUARTER FROM  to_date('01-08-2022','DD/MM/YYYY')) =  2  THEN "q4_reason character"   ELSE  ' '  END AS  reason ,

                                                               case WHEN   EXTRACT(QUARTER FROM  to_date('01-08-2022','DD/MM/YYYY'))   =  3  THEN  q1_constraints
                                                                    WHEN   EXTRACT(QUARTER FROM  to_date('01-08-2022','DD/MM/YYYY')) =   4 THEN  q2_constraints
                                                                    WHEN   EXTRACT(QUARTER FROM  to_date('01-08-2022','DD/MM/YYYY')) =  1 THEN q3_constraints
                                                                    WHEN   EXTRACT(QUARTER FROM  to_date('01-08-2022','DD/MM/YYYY')) =  2  THEN  q4_constraints  ELSE ' ' END AS constraints ,

                                                               budget - expenditure as balance , allocation from activities a
                                                                                                                     JOIN facilities f ON f.id = a.facility_id
                                                                                                                     JOIN facility_ward_view wv ON wv.id  = f.id
                                                                                                                     LEFT JOIN

                                                                                                                 ( Select b.activity_id,sum(b.amount) AS budget ,sum(al.amount) AS allocation FROM (SELECT financial_year_id, ac.facility_id, activity_id,SUM(amount) AS amount
                                                                                                                     FROM activity_costings ac JOIN gl_accounts ga ON ga.id = ac.account_id GROUP BY ac.facility_id, ac.activity_id,ac.financial_year_id) b
                                                                                                                                                                                                       LEFT JOIN (SELECT a.id AS activity_id, fal.financial_year_id, SUM(amount) AS amount
                                                                                                                                                                                                       FROM fund_allocations fal
                                                                                                                                                                                                       JOIN gl_accounts ga ON ga.code = fal.gl_account
                                                                                                                                                                                                       JOIN activities a ON a.code = ga.activity_code
                                                                                                                                                                                                       WHERE  fal.created_at
                                                                                                                                                                                                           BETWEEN to_date('01-08-2022','DD/MM/YYYY')
                                                                                                                     and  to_date('01-01-2024','DD/MM/YYYY') AND   fal.facility_id =  28200 GROUP BY  fal.financial_year_id, a.id

                                                                                                                 ) al ON al.activity_id = b.activity_id AND al.financial_year_id = b.financial_year_id
                                                                                                                   WHERE b.facility_id =  28200
                                                                                                                     AND b.financial_year_id  =  1
                                                                                                                   GROUP BY b.activity_id
                                                                                                                 )bg
                                                                                                                 on a.id = bg.activity_id

                                                                                                                     LEFT JOIN
                                                                                                                 (SELECT  a.id as activity_id, sum(dr_amount - cr_amount) AS expenditure FROM gl_entries  ge
                                                                                                                     JOIN gl_entry_groups geg ON geg.id = ge.gl_entry_group_id
                                                                                                                 JOIN gl_accounts ga  ON ga.code = ge.account AND ga.gl_account_type = 'EXPENDITURE'

                                                                                                                 JOIN activities a ON a.code = ga.activity_code
                                                                                                                  WHERE  geg.financial_year_id = 1  AND geg.facility_id = 28200
                                                                                                                    AND geg.apply_date BETWEEN to_date('01-08-2022','DD/MM/YYYY') AND  to_date('01-01-2024','DD/MM/YYYY'
                                                                                                                        )  GROUP BY activity_id )exp
                                                                                                                 ON a.id = exp.activity_id WHERE a.facility_id = 28200 AND a.financial_year_id = 1
                                                    )report


--select * From activities where financial_year_id = 1 and facility_id = 28200
