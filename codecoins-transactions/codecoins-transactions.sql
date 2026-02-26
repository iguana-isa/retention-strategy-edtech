/* =========================================
Распределение списаний и начислений CodeCoins
========================================= */

with active_users as (
	select distinct(u.id) as user_id, date(u.date_joined) as date_joined
	from users u 
	join userentry ue
	on u.id = ue.user_id
	where u.id >= 94 
		and u.company_id is null 
		and u.is_active = 1 
		and to_char(u.date_joined, 'YYYY') = '2022'
),
coins as (
    select
        au.user_id,
        sum(case when type_id in (1, 23, 24, 25, 26, 27, 28) then -value end) write_off,
        sum(case when type_id not in (1, 23, 24, 25, 26, 27, 28) then value end) accruals,
        sum(case when type_id in (1, 23, 24, 25, 26, 27, 28) then -value else value end) balance
    from "transaction" t
    join active_users au
    on au.user_id = t.user_id 
    where value < 500
    group by au.user_id
)
select
    round(avg(write_off), 2) as write_off,
    round(avg(accruals), 2) as accruals,
    round(avg(balance), 2) as balance
from coins
