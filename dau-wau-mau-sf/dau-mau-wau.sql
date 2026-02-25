-- dynamic dau

select 
	userentry.entry_at::date as day,
	count(distinct userentry.user_id) as cnt_users
from userentry 
join users 
	on users.id = userentry.user_id
where users.id >= 94 
	and users.company_id is null 
	and users.is_active = 1 
	and to_char(users.date_joined, 'YYYY') = '2022'
group by day

--statistic dau

with active_users as (
	select 
		ue.entry_at::date as day,
		count(distinct ue.user_id) as cnt_users
	from userentry ue
	join users u
		on u.id = ue.user_id
	where u.id >= 94
		and u.company_id is null
		and u.is_active = 1
		and to_char(u.date_joined, 'YYYY') = '2022'
	group by day
)
select 
	round(avg(cnt_users)) as average_dau,
	percentile_cont(0.5) within group (order by cnt_users) as median_dau,
	percentile_cont(0.25) within group (order by cnt_users) as p25,
	percentile_cont(0.75) within group (order by cnt_users) as p75,
	percentile_cont(0.9) within group (order by cnt_users) as p90
from active_users

