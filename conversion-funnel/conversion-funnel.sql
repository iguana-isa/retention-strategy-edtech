/* =========================================
	Воронка: регистрация - вход - активность - 
        успех - покупка CodeCoins
========================================= */

with activities as (
	select user_id from coderun
	union
	select user_id from codesubmit
	union
	select user_id from teststart
),
registrations as (
	select 
		id as user_id,
		date_joined
	from users
    where  id >= 94
		and company_id is null
		and is_active = 1
		and to_char(date_joined, 'YYYY') = '2022'
),
first_entries as (
	select 
		ue.user_id,
		min(ue.entry_at) as first_entry_at
	from userentry ue
	join registrations r
		on r.user_id = ue.user_id
	group by ue.user_id
),
first_activities as (
	select 
		r.user_id,
		case 
		when a.user_id is not null then 1 
		else 0
		end as has_activity
	from registrations r
	left join activities a
		on r.user_id = a.user_id
),
first_successes as (
	select 
		r.user_id,
		case 
		when cs.user_id is not null then 1 
		else 0
		end as has_success
	from registrations  r
	left join (
		select distinct user_id
		from codesubmit
		where is_false = 0
	) cs
		on r.user_id = cs.user_id
),
first_purchases as (
	select
		r.user_id,
		case 
			when t.user_id is not null then 1
			else 0
		end as has_purchase
	from registrations r
	left join (
		select distinct user_id
		from transaction
		where type_id = 2
	) t
		on r.user_id = t.user_id
)
select 
	'Регистрация' as description,
	count(*) as users_cnt
from registrations
union all
select 
	'Первый заход' as description,
	count(*) as users_cnt
from first_entries
union all
select 
	'Первая активность' as description,
	count(*) as users_cnt
from first_activities
where has_activity = 1
union all
select 
	'Первый успех' as description,
	count(*) as users_cnt
from first_successes
where has_success = 1
union all
select
	'Первая покупка CodeCoins' as description,
	count(*) as users_cnt
from first_purchases
where has_purchase = 1
