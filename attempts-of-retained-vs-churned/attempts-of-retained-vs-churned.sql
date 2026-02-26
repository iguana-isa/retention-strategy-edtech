/* =========================================
Сравнение активности по отправке кода на проверку 
(по таблице CodeSubmit) у удержавшихся и ушедших 
пользователей на примере Rolling Retention 30-го дня
========================================= */

with active_users as (
	select 
		u.id as user_id, 
		date(u.date_joined) as date_joined,
		date(ue.entry_at) as entry_at
	from users u
	join userentry ue 
	on u.id = ue.user_id
	where true
		and u.id >= 94 
		and u.company_id is null 
		and u.is_active = 1 
		and to_char(u.date_joined, 'YYYY') = '2022'
),
user_groups as (
	select 
		user_id, 
		case 
		when max(entry_at) >= date_joined + interval '30 day' then 'Активные более 30 дней' 
		else 'Остальные' 
		end as user_group,
		date_joined
	from active_users
	group by user_id, date_joined
),
attempts_30d as (
	select cs.user_id,
		count(*) filter (
			where cs.created_at < ug.date_joined + interval '30 day'
		) as attempts_30d,
		count(*) filter (
			where cs.created_at < ug.date_joined + interval '30 day'
			and cs.is_false = 0
		) as success_30d
	from codesubmit cs
	join user_groups ug
		on ug.user_id = cs.user_id
	group by cs.user_id
),
summary as (
	select
		ug.user_group,
		count(distinct ug.user_id) as cnt_users,
		avg(coalesce(ad.attempts_30d, 0)) as avg_attempts,
		avg(coalesce(ad.success_30d, 0)) as avg_success_attempts
	from user_groups ug
	left join attempts_30d ad
		on ad.user_id = ug.user_id
	group by ug.user_group
)
select 
	user_group,
	'Студенты' as metric,
	cnt_users::numeric as value
from summary
union all
select 
	user_group,
	'Попытки (среднее за 30 дней)' as metric,
	round(avg_attempts::numeric, 2) as value
from summary
union all
select 
	user_group,
	'Успешные попытки (среднее за 30 дней)' as metric,
	round(avg_success_attempts::numeric, 2) as value
from summary
