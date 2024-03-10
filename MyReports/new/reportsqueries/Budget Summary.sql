select rid,fwv.rname,cid, cname as council,fwv.ccode as vote, fwv.ftype as ftype,sum(amount) as budget
from activity_costings ac
    join facility_ward_view fwv on fwv.id = ac.facility_id
    where financial_year_id  = 1 and ( rid = 407 or cid = 407 or 1 = 407) -- 407 replace with location_id parameter
    group by cname, fwv.ftype,cid,ccode,rname,rid
    order by  cname asc;

-- Replace financial year 1 with parameter financial_year_id, replace 407 by location_id parameter, do not replace the 1 in the brackets 
--it fixes the national id so that when you send 1  as location_id, the the expression in the brackets returns true and all
--the councils are returned in the result. If confusing let me know.

