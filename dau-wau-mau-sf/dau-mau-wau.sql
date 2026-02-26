/* =========================================
					DAU
========================================= */

-- Dynamic DAU:

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

/* Statistic DAU:
	- Среднее значение DAU
	- Медианное значение DAU
	- Перцентили:
		- P25 — нижний квартиль (дни низкой активности)
		- P75 — верхний квартиль (граница стабильной активности)
		- P90 — уровень пиковых нагрузок 
*/

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

/* =========================================
					WAU
	(недели, в которых было 5 и более дней 
			в рамках периода)
========================================= */

-- Dynamic WAU:

select
	date_trunc('week', ue.entry_at)::date as week_start,
	count(distinct ue.user_id) as wau
from userentry ue
join users u
	on u.id = ue.user_id
where u.id >= 94 
	and u.company_id is null 
	and u.is_active = 1 
	and to_char(u.date_joined, 'YYYY') = '2022'
group by date_trunc('week', ue.entry_at)
having count(distinct ue.entry_at::date) >= 5
order by week_start

/* Statistic WAU:
	- Среднее значение WAU
	- Медианное значение WAU 
*/

with weekly_users as (
select
	date_trunc('week', ue.entry_at)::date as week_start,
	count(distinct ue.user_id) as cnt
from userentry ue
join users u
on u.id = ue.user_id
where u.id >= 94 
	and u.company_id is null 
	and u.is_active = 1 
	and to_char(u.date_joined, 'YYYY') = '2022'
group by date_trunc('week', ue.entry_at)
having count(distinct ue.entry_at::date) >= 5
order by week_start
)
select 
	round(avg(cnt)) as average_wau,
	percentile_cont(0.5) within group (order by cnt) as median_wau
from weekly_users

/* =========================================
					MAU
(месяцы, в которые было минимум 25 заходов 
				на платформу)
========================================= */

-- Dynamic MAU:

select to_char(ue.entry_at, 'YYYY-MM') as month, 
		count(distinct ue.user_id) as mau
	from userentry ue 
	join users u 
	on u.id = ue.user_id
	where u.id >= 94 
		and u.company_id is null 
		and u.is_active = 1 
		and to_char(u.date_joined, 'YYYY') = '2022'
	group by month
	having count(distinct to_char(entry_at, 'YYYY-MM-DD')) >= 25

/* Statistic MAU:
	- Среднее значение MAU
	- Медианное значение MAU 
*/

with monthly_users as (
	select to_char(entry_at, 'YYYY-MM') as month, count(distinct user_id) as cnt
	from userentry ue 
	join users u 
	on u.id = ue.user_id
	where u.id >= 94 
		and u.company_id is null 
		and u.is_active = 1 
		and to_char(u.date_joined, 'YYYY') = '2022'
	group by month
	having count(distinct to_char(entry_at, 'YYYY-MM-DD')) >= 25
)
select 
	round(avg(cnt)) as average_mau,
	percentile_cont(0.5) within group (order by cnt) as median_mau
from monthly_users
