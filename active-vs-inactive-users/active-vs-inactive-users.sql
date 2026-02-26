/* =========================================
Соотношение пользователей, зашедших хотя бы 
1 раз на платформу, но ни разу не проявивших 
        активность, и активных
========================================= */

with activities as (
    select user_id from coderun
	union
	select user_id from codesubmit
	union
	select user_id from teststart
),
active_users as (
	select distinct users.id
	from users 
	join userentry 
		on users.id = userentry.user_id
	where users.id >= 94
		and users.company_id is null
		and users.is_active = 1
		and to_char(users.date_joined, 'YYYY') = '2022'
)
	select 
		case 
			when activities.user_id is null then 'inactive'
			else 'active'
		end as status, count(*) as users_count
	from active_users
	left join activities 
		on active_users.id = activities.user_id
group by status
