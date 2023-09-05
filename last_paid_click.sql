with tab as (
select distinct on (visitor_id)
	visitor_id,
	visit_date,
	source,
	medium,
	campaign,
	lead_id,
	created_at,
	amount,
	closing_reason,
	status_id
from sessions 
left join leads
using(visitor_id)
where medium != 'organic'
order by visitor_id, visit_date desc)

select * from tab
where created_at > visit_date or created_at is null
order by amount desc nulls last
