/* =========================================
  Процент заходов с проявлением активности
========================================= */

with activities as (
	select user_id, to_char(created_at, 'YYYY-MM-DD') as activity_date
	from coderun
	union 
	select user_id, to_char(created_at, 'YYYY-MM-DD') as activity_date
	from codesubmit
	union 
	select user_id, to_char(created_at, 'YYYY-MM-DD') as activity_date
	from teststart
)
select round(sum(
	case 
    when a.user_id is null then 0
    else 1
    end) * 100.0 / count(*), 2) as "entries_with_activities (%)"
from userentry ue
left join activities a
on to_char(ue.entry_at, 'YYYY-MM-DD') = a.activity_date and ue.user_id = a.user_id
join users u
on u.id = ue.user_id
where u.id >= 94 
	and u.company_id is null 
	and u.is_active = 1 
	and to_char(u.date_joined, 'YYYY') = ‘2022'
