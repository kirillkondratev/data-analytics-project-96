with tab as (
    select distinct on (visitor_id)
        visitor_id,
        visit_date,
        source as utm_source,
        medium as utm_medium,
        campaign as utm_campaign,
        lead_id,
        created_at,
        amount,
        closing_reason,
        status_id
    from sessions
    left join leads
        using (visitor_id)
where medium != 'organic'
order by visitor_id asc, visit_date desc
), lpc as (

select
    visitor_id,
    visit_date,
    utm_source,
    utm_medium,
    utm_campaign,
    lead_id,
    created_at,
    amount,
    closing_reason,
    status_id,
    case when status_id = 142 then 1 else 0 end as mark
from tab
where created_at >= visit_date or created_at is null
order by
    amount desc nulls last,
    visit_date asc,
    utm_source asc,
    utm_medium asc,
    utm_campaign asc
), lpc_agg as (

select 
	date(visit_date) as visit_date,
	lpc.utm_source,
	lpc.utm_medium,
	lpc.utm_campaign,
	sum(amount) as revenue,
	count(lead_id) as leads_count,
	count(visitor_id) as visitors_count,
	sum(mark) as purchases_count
	from lpc
group by
	date(visit_date),
	lpc.utm_source,
	lpc.utm_medium,
	lpc.utm_campaign
), vk_ya_agg as (

	select 
	date(campaign_date) as visit_date, 
	utm_source, utm_medium, 
	utm_campaign, 
	sum(daily_spent)
from ya_ads
group by 
	date(campaign_date),
	utm_source,
	utm_medium,
	utm_campaign	
union all
select 
	date(campaign_date) as visit_date, 
	utm_source, utm_medium, 
	utm_campaign, 
	sum(daily_spent)
from vk_ads
group by 
	date(campaign_date),
	utm_source,
	utm_medium,
	utm_campaign
)
select
	lpc_agg.visit_date,
	lpc_agg.utm_source,
	lpc_agg.utm_medium,
	lpc_agg.utm_campaign,
	lpc_agg.revenue,
	vk_ya_agg.sum as total_cost,
	leads_count,
	purchases_count
from lpc_agg
left join vk_ya_agg
	on lpc_agg.visit_date = vk_ya_agg.visit_date and
	lpc_agg.utm_source = vk_ya_agg.utm_source and
	lpc_agg.utm_medium = vk_ya_agg.utm_medium and 
	lpc_agg.utm_campaign = vk_ya_agg.utm_campaign
order by revenue desc nulls last


