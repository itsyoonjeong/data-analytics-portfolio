## Analyzing Search Functionality

### Overview

This case study investigates how users interact with Yammer's search functionality and evaluates whether the search features effectively help users find relevant results.
The analysis focuses on two search mechanisms: **autocomplete** and **full search runs**.

Specifically, the analysis examines:
- how frequently each search feature is used
- how users behave within search sessions
- whether search interactions lead to clicks on results
- whether users repeatedly use search across sessions

### Dataset

The dataset comes from the Mode SQL Tutorial.

Key columns from the table `yammer_events`:
- `search_autocomplete`: logged when a user clicks on a search option from autocomplete
- `search_run`: logged when a user runs a search and sees the results page
- `search_click_result_x`: logged when a user clicks on a search result, where X indicates the position of the clicked result

### Analysis

The analysis is conducted in four main steps.

#### 1. Build session-level search metrics

User engagement events were grouped into sessions using a 10-minute inactivity threshold. Event-level data was then aggregated to build session-level metrics that summarize search activity within each session.

These metrics include:
- number of autocompletes
- number of search runs
- number of clicks on search results

#### 2. Measure weekly trends in search interactions

Weekly trends were analyzed to understand how frequently the two search features are used and how their usage changes over time.

This step measures:
- total number of sessions per week
- number, share of sessions with autocompletes per week
- number, share of sessions with search runs per week

#### 3. Analyze search behavior within sessions

Search behavior within sessions was analyzed to understand how users interact with search results.

This step analyzes:
- distribution of autocompletes per session
- distribution of search runs per session
- distribution of clicks per session with search runs
- relationship between number of search runs and number of clicks
- distribution of search result positions receiving clicks

#### 4. Analyze user-level repeat search behavior across sessions

User-level behavior was examined to understand how frequently users rely on search features across sessions.

This step analyzes:
- distribution of users by the number of sessions with search runs
- distribution of users by the number of sessions with autocompletes

### Key Insights

Several patterns are discovered from the analysis:
- Autocompletes are more commonly used in sessions than search runs.
- Search runs tend to repeat within sessions, meaning users often run multiple full searches in a single session.
- Additional searches do not lead to proportionally more clicks, meaning users may not be finding relevant results quickly.
- Clicks are not strongly concentrated in the top search results, meaning the ranking algorithm of search results may not be effective.

These patterns suggest that:
- Autocomplete may provide a more efficient way for users to find results.
- Search runs may require users to repeatedly refine their queries.
- Search result ranking may not be fully optimized.
- Improving the ranking algorithm or query understanding for full search runs may enhance the overall search experience on Yammer.
