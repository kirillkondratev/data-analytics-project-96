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
        on sessions.visitor_id = leads.visitor_id
where medium != 'organic'
order by visitor_id asc, visit_date desc
)

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
    status_id
from tab
where created_at >= visit_date or created_at is null
order by
    amount desc nulls last,
    visit_date asc,
    utm_source asc,
    utm_medium asc,
    utm_campaign asc
