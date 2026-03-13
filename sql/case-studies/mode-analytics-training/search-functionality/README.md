## Analyzing Search Functionality

### Overview

This case study investigates how users interact with Yammer's search functionality and whether the search features are effective in helping users find relevant results.

This analysis compares two search features(autocomplete, search run) and examines:
- how frequently search features are used
- how users behave within search sessions
- whether search interactions lead to clicks on results
- whether users repeatedly use search across sessions

### Dataset

The dataset comes from the Mode SQL Tutorial.

Key columns used from the table `yammer_events`:
- `search_autocomplete`: logged when a user clicks on a search option from autocomplete
- `yammer_events`: logged when a user runs a search and sees the results page
- `yammer_emails`: logged when a user clicks on a search result, X describing which position was clicked

### Analysis

The analysis was conducted in four main steps.

#### 1. Build session-level search metrics

User events were grouped into sessions using a 10-minute inactivity threshold, and search activity within each user session was summarized by session-level metrics.

This metrics include:
- number of autocompletes
- number of search runs
- number of search result clicks

#### 2. Measure weekly trends in search interactions

Weekly trends were analyzed to understand how frequently users interact with search features.

This step measures:
- total number of sessions
- number, share of sessions with autocompletes
- number, share of sessions with search runs

#### 3. Analyze search behavior within sessions

Search activity was examined for each session to understand how users interact with search results.

This step analyzes;
- distribution of autocompletes per session
- distribution of search runs per session
- distribution of clicks per session with search runs
- relationship between number of search runs and number of clicks
- distribution of search result positions receiving clicks

#### 4. Analyze user-level repeat search behavior

User-level behavior was examined to understand how frequently users interact with search features.

This step analyzes;
- distribution of users by the number of sessions with search runs
- distribution of users by the number of sessions with autocompletes

### Key Insights

Several patterns are discovered from the analysis:
- Autocompletes are used in a larger share of sessions than search runs.
- Search runs tend to repeat within sessions, meaning users often execute multiple searches in a single session.
- Additional searches do not lead to proportionally more clicks, meaning users many not be finding relevant results quickly.
- Clicks are not strongly concentrated in the top search results, meaning the ranking of search results may not be effective.

These patterns suggest that:
- Autocomplete may provide a more efficient way for users to find results.
- Search runs may require users to repeatedly refine their queries.
- Search result ranking may not be highly optimized.

Therefore, improving search ranking or query understading may help reduce repeated search runs.
