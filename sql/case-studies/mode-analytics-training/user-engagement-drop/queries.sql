-- Case study: Investigating a drop in user engagement
SELECT DATE_TRUNC('week', e.occurred_at),
       COUNT(DISTINCT e.user_id) AS weekly_active_users
FROM tutorial.yammer_events e
WHERE e.event_type = 'engagement' 
      AND e.event_name = 'login'
GROUP BY 1
ORDER BY 1;

-- Step 1: Check whether the drop is related to user growth
SELECT DATE_TRUNC('day', created_at) AS day,
       COUNT(*) AS all_users,
       COUNT(CASE WHEN activated_at IS NOT NULL THEN user_id ELSE NULL END) AS activated_users
FROM tutorial.yammer_users
WHERE created_at >= '2014-05-01' 
      AND created_at < '2014-09-01'
GROUP BY 1
ORDER BY 1;

-- Step 2: Check which segment of existing users was affected
SELECT DATE_TRUNC('week', z.occurred_at) AS "week",
       AVG(z.age_at_event) AS "average age during week",
       COUNT(DISTINCT CASE WHEN z.user_age > 70 THEN z.user_id ELSE NULL END) AS "10+ weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 70 AND z.user_age >= 63 THEN z.user_id ELSE NULL END) AS "9 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 63 AND z.user_age >= 56 THEN z.user_id ELSE NULL END) AS "8 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 56 AND z.user_age >= 49 THEN z.user_id ELSE NULL END) AS "7 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 49 AND z.user_age >= 42 THEN z.user_id ELSE NULL END) AS "6 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 42 AND z.user_age >= 35 THEN z.user_id ELSE NULL END) AS "5 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 35 AND z.user_age >= 28 THEN z.user_id ELSE NULL END) AS "4 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 28 AND z.user_age >= 21 THEN z.user_id ELSE NULL END) AS "3 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 21 AND z.user_age >= 14 THEN z.user_id ELSE NULL END) AS "2 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 14 AND z.user_age >= 7 THEN z.user_id ELSE NULL END) AS "1 week",
       COUNT(DISTINCT CASE WHEN z.user_age < 7 THEN z.user_id ELSE NULL END) AS "less than a week"
FROM (
    SELECT e.occurred_at,
           u.user_id,
           EXTRACT('day' FROM e.occurred_at - u.activated_at) AS age_at_event,
           EXTRACT('day' FROM '2014-09-01'::TIMESTAMP - u.activated_at) AS user_age 
    FROM tutorial.yammer_users u 
    JOIN tutorial.yammer_events e
    ON e.user_id = u.user_id
       AND e.event_type = 'engagement'
       AND e.event_name = 'login'
       AND e.occurred_at >= '2014-05-01'
       AND e.occurred_at < '2014-09-01'
    WHERE u.activated_at IS NOT NULL
    ) z
GROUP BY 1
ORDER BY 1
LIMIT 100;

-- Step 3: Check whether the issue is localized to a specific device
SELECT DATE_TRUNC('week', occurred_at) AS week,
       COUNT(DISTINCT user_id) AS weekly_active_users,
       COUNT(DISTINCT CASE WHEN device IN ('dell inspiron desktop', 'macbook pro', 'asus chromebook', 'macbook air', 'lenovo thinkpad', 'mac mini',
                                           'acer aspire desktop', 'acer aspire notebook', 'dell inspiron notebook', 'hp pavilion desktop')
                           THEN user_id ELSE NULL END) AS computer,
       COUNT(DISTINCT CASE WHEN device IN ('amazon fire phone', 'iphone 5s', 'htc one', 'iphone 4s', 'iphone 5', 'samsung galaxy note', 'nexus 5',
                                           'nokia lumia 635', 'samsung galaxy s4')
                           THEN user_id ELSE NULL END) AS phone,
       COUNT(DISTINCT CASE WHEN device IN ('nexus 10', 'ipad mini', 'windows surface', 'samsumg galaxy tablet', 'nexus 7', 'kindle fire', 'ipad air')
                           THEN user_id ELSE NULL END) AS tablet
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
      AND event_name = 'login'
GROUP BY 1
ORDER BY 1
LIMIT 100;

-- Step 4: Check whether digest emails are related to the issue
SELECT DATE_TRUNC('week', occurred_at) AS week,
       COUNT(CASE WHEN action = 'sent_weekly_digest' THEN user_id ELSE NULL END) AS weekly_emails,
       COUNT(CASE WHEN action = 'sent_reengagement_email' THEN user_id ELSE NULL END) AS reengagement_emails,
       COUNT(CASE WHEN action = 'email_open' THEN user_id ELSE NULL END) AS email_opens,
       COUNT(CASE WHEN action = 'email_clickthrough' THEN user_id ELSE NULL END) AS email_clickthroughs
FROM tutorial.yammer_emails
GROUP BY 1
ORDER BY 1;

-- Step 5: Check open and clickthrough rates of the emails in more detail
SELECT week,
       weekly_opens/(CASE WHEN weekly_emails = 0 THEN 1 ELSE weekly_emails END::FLOAT) AS weekly_open_rate,
       weekly_clicks/(CASE WHEN weekly_opens = 0 THEN 1 ELSE weekly_opens END::FLOAT) AS weekly_ctr,
       retain_opens/(CASE WHEN retain_emails = 0 THEN 1 ELSE retain_emails END::FLOAT) AS retain_open_rate,
       retain_clicks/(CASE WHEN retain_opens = 0 THEN 1 ELSE retain_opens END::FLOAT) AS retain_ctr
FROM (
    SELECT DATE_TRUNC('week', e1.occurred_at) AS week,
           COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e1.user_id ELSE NULL END) AS weekly_emails,
           COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e2.user_id ELSE NULL END) AS weekly_opens,
           COUNT(CASE WHEN e1.action = 'sent_weekly_digest' THEN e3.user_id ELSE NULL END) AS weekly_clicks,
           COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN e1.user_id ELSE NULL END) AS retain_emails,
           COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN e2.user_id ELSE NULL END) AS retain_opens,
           COUNT(CASE WHEN e1.action = 'sent_reengagement_email' THEN e3.user_id ELSE NULL END) AS retain_clicks
    FROM tutorial.yammer_emails e1
    LEFT JOIN tutorial.yammer_emails e2
    ON e2.user_id = e1.user_id
       AND e2.occurred_at >= e1.occurred_at
       AND e2.occurred_at < e1.occurred_at + INTERVAL '5 minutes'
       AND e2.action = 'email_open'
    LEFT JOIN tutorial.yammer_emails e3
    ON e3.user_id = e2.user_id
       AND e3.occurred_at >= e2.occurred_at
       AND e3.occurred_at < e2.occurred_at + INTERVAL '5 minutes'
       AND e3.action = 'email_clickthrough'
    WHERE e1.occurred_at >= '2014-06-01'
          AND e1.occurred_at < '2014-09-01'
          AND e1.action IN ('sent_weekly_digest', 'sent_reengagement_email')
    GROUP BY 1
    ) a
ORDER BY 1;