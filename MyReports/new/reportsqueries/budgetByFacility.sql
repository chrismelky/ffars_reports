select rid,fwv.rname as region , fwv.rcode as vote,cid, cname as council,fwv.ccode as council_id, fwv.ftype as type,

       fwv.name  as facility, fwv.code as  facility_code,sum(amount) as budget

from activity_costings ac
         join facility_ward_view fwv on fwv.id = ac.facility_id
where financial_year_id  = 1 and ( rid = 407 or cid = 407 or 1 = 407) -- 407 replace with location_id parameter
group by rid, fwv.rname, fwv.rcode, cid, cname, fwv.ccode, fwv.ftype, fwv.name, fwv.code
order by  cname asc;

