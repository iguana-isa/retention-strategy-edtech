/* =========================================
   Предварительная обработка данных
========================================= */

# 1. Фильтрация аккаунтов, вывод целевых аккаунтов для исследования:

select distinct(u.id) as user_id, date(u.date_joined) as date_joined
from users u 
join userentry ue
on u.id = ue.user_id
where u.id >= 94 
	and u.company_id is null 
	and u.is_active = 1 
	and to_char(u.date_joined, 'YYYY') = '2022'

# Результат: таблица с уникальными user_id целевых пользователей и их датами регистрации, на основе которых которых будут рассчитываться метрики.
