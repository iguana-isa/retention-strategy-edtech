/* =========================================
	Rolling Retention с разбивкой по когортам
(подсчет от зашедших в день регистрации (0-й день))
========================================= */

with active_users as (
	select 
		u.id,
		u.date_joined,
		to_char(u.date_joined, 'YYYY-MM') as cohort,
		ue.entry_at,
		extract(day from ue.entry_at - u.date_joined) as diff
	from users u
	join userentry ue
		on ue.user_id = u.id
	where u.id >= 94
		and u.company_id is null
		and u.is_active = 1
		and to_char(u.date_joined, 'YYYY') = '2022'
)
select cohort,
	round(count(distinct case when diff >= 0  then id end) 
		* 100.0 / count(distinct case when diff >= 0 then id end), 2) as "0 (%)",
	round(count(distinct case when diff >= 1  then id end) 
		* 100.0 / count(distinct case when diff >= 0 then id end), 2) as "1 (%)",
	round(count(distinct case when diff >= 3  then id end) 
		* 100.0 / count(distinct case when diff >= 0 then id end), 2) as "3 (%)",
	round(count(distinct case when diff >= 7  then id end) 
		* 100.0 / count(distinct case when diff >= 0 then id end), 2) as "7 (%)",
	round(count(distinct case when diff >= 14 then id end) 
		* 100.0 / count(distinct case when diff >= 0 then id end), 2) as "14 (%)",
	round(count(distinct case when diff >= 30 then id end) 
		* 100.0 / count(distinct case when diff >= 0 then id end), 2) as "30 (%)",
	round(count(distinct case when diff >= 60 then id end) 
		* 100.0 / count(distinct case when diff >= 0 then id end), 2) as "60 (%)",
	round(count(distinct case when diff >= 90 then id end) 
		* 100.0 / count(distinct case when diff >= 0 then id end), 2) as "90 (%)"
from active_users
group by cohort
order by cohort

