-- Step 1: Build session-level search metrics

DROP TABLE IF EXISTS session_search_metrics;

CREATE TEMP TABLE session_search_metrics AS

WITH events_with_sessions AS (
  SELECT e.*,
         session.session,
         session.session_start
  FROM tutorial.yammer_events e
  LEFT JOIN (
    SELECT user_id,
           session,
           MIN(occurred_at) AS session_start,
           MAX(occurred_at) AS session_end
    FROM (
      SELECT bounds.*,
             CASE WHEN last_event IS NULL THEN id
                  WHEN last_event >= INTERVAL '10 minutes' THEN id
                  ELSE LAG(id, 1) OVER (PARTITION BY user_id ORDER BY occurred_at) END AS session
      FROM (
        SELECT  user_id,
                event_type,
                event_name,
                occurred_at,
                occurred_at - LAG(occurred_at, 1) OVER (PARTITION BY user_id ORDER BY occurred_at) AS last_event,
                LEAD(occurred_at, 1) OVER (PARTITION BY user_id ORDER BY occurred_at) - occurred_at AS next_event,
                ROW_NUMBER() OVER() AS id
        FROM tutorial.yammer_events
        WHERE event_type = 'engagement'
        ORDER BY user_id, occurred_at -- 1.1 Compute time gaps between consecutive events for each user
        ) bounds 
      WHERE last_event IS NULL
            OR next_event >= INTERVAL '10 minutes'
            OR last_event >= INTERVAL '10 minutes'
            OR next_event IS NULL
      ) final -- 1.2 Create session boundaries and assign identifiers
    GROUP BY 1, 2
    ) session -- 1.3 Convert boundary rows into session-level start and end timestamps
  ON e.user_id = session.user_id
     AND e.occurred_at >= session.session_start
     AND e.occurred_at <= session.session_end
  WHERE e.event_type = 'engagement'
  ) -- 1.4 Assign each engagement event to its corresponding session

SELECT session_start,
       session,
       user_id,
       COUNT(CASE WHEN event_name = 'search_autocomplete' THEN user_id ELSE NULL END) AS autocompletes,
       COUNT(CASE WHEN event_name = 'search_run' THEN user_id ELSE NULL END) AS runs,
       COUNT(CASE WHEN event_name LIKE 'search_click_%' THEN user_id ELSE NULL END) AS clicks  
FROM events_with_sessions
GROUP BY 1, 2, 3; -- 1.5 Count autocomplete, search run, click events within each session


-- Step 2: Measure weekly trends in search interactions

SELECT DATE_TRUNC('week', session_start) AS week,
       COUNT(*) AS sessions,
       COUNT(CASE WHEN autocompletes > 0 THEN session ELSE NULL END) AS with_autocompletes,
       COUNT(CASE WHEN runs > 0 THEN session ELSE NULL END) AS with_runs
FROM session_search_metrics
GROUP BY 1
ORDER BY 1; -- 2.1 Calculate weekly session counts and those with search interactions

SELECT DATE_TRUNC('week', session_start) AS week,
       COUNT(CASE WHEN autocompletes > 0 THEN session ELSE NULL END) / COUNT(*)::float AS with_autocompletes,
       COUNT(CASE WHEN runs > 0 THEN session ELSE NULL END) / COUNT(*)::float AS with_runs
FROM session_search_metrics
GROUP BY 1
ORDER BY 1; -- 2.2 Calculate the weekly share of sessions with search interactions


-- Step 3: Analyze search behavior within sessions

SELECT autocompletes,
       COUNT(*) AS sessions
FROM session_search_metrics
WHERE autocompletes > 0
GROUP BY 1
ORDER BY 1; -- 3.1 Analyze the distribution of autocompletes per session

SELECT runs,
       COUNT(*) AS sessions
FROM session_search_metrics
WHERE runs > 0
GROUP BY 1
ORDER BY 1; -- 3.2 Analyze the distribution of search runs per session

SELECT clicks,
       COUNT(*) AS sessions
FROM session_search_metrics
WHERE runs > 0
GROUP BY 1
ORDER BY 1; -- 3.3 Analyze the distribution of clicks per session with search runs

SELECT runs,
       AVG(clicks)::float AS average_clicks
FROM session_search_metrics
WHERE runs > 0
GROUP BY 1
ORDER BY 1; -- 3.4 Calculate the average number of clicks by the number of search runs

SELECT TRIM('search_click_result_' FROM event_name)::int AS search_result,
       COUNT(*) AS clicks
FROM tutorial.yammer_events
WHERE event_name LIKE 'search_click_%'
GROUP BY 1
ORDER BY 1; -- 3.5 Analyze the distribution of search result positions receiving clicks


-- Step 4: Analyze user-level repeat search behavior across sessions

SELECT search_sessions,
       COUNT(*) AS users
FROM (
  SELECT user_id,
         COUNT(*) AS search_sessions
  FROM session_search_metrics
  WHERE runs > 0
  GROUP BY 1
  ) z
GROUP BY 1
ORDER BY 1
LIMIT 100; -- 4.1 Analyze the distribution of users by the number of sessions with search runs

SELECT autocomplete_sessions,
       COUNT(*) AS users
FROM (
  SELECT user_id,
         COUNT(*) AS autocomplete_sessions
  FROM session_search_metrics
  WHERE autocompletes > 0
  GROUP BY 1
  ) z
GROUP BY 1
ORDER BY 1

LIMIT 100; -- 4.2 Analyze the distribution of users by the number of sessions with autocompletes
