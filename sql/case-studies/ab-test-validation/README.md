## Validating A/B Test Results

### Overview

This case study investigates if Yammer's publisher update experiment increased user engagement. 
The analysis compares engagement metrics, including message postings, login activities, and days engaged, between the **control group** and **treatment group**, and examines potential issues in the experiment design that could bias the results.

Specifically, the analysis examines:
- whether the treatment group shows higher engagement than the control group
- whether the observed differences are statistically significant
- whether the experiment design is valid or if the results are affected by sampling bias

### Dataset

The dataset comes from the Mode SQL Tutorial.

Key tables used:
- `yammer_users`: user signup and activation information
- `yammer_events`: user activity events such as login, messaging, and search
- `yammer_experiments`: experiment assignments indicating experiment groups and timestamps

### Analysis

The analysis is conducted in five main steps.

#### 1. Compare post-treatment message postings

This step evaluates whether the treatment increased the number of message postings per user after treatment.

#### 2. Compare post-treatment login engagement

This step examines the number of logins per user across experiment groups after treatment.

#### 3. Compare post-treatment days engaged

This step measures the number of distinct days each user engaged with the platform after treatment.

#### 4. Check distribution of new users

This step examines whether new users are evenly distributed across experiment groups, which helps detect potential bias in the experiment design.

#### 4. Re-evaluate message postings among existing users

The analysis identifies that new users are disproportinately assigned to the control group. To address this issue, the experiment is re-evaluated using existing users only, by measuring the number of message postings per existing user after treatment.

### Key Insights

Several findings emerge from the analysis:
- The treatment group initially appears to have higher engagement across several metrics, including message postings, login activity, and days engaged.
- However, further analysis reveals that new users are not evenly distributed across experiment groups.
- All new users are assigned to the control group, which lowers the control group's engagement metrics.
- After restricting the analysis to existing users, the treatment impact becomes much smaller.

These findings suggest that:
- Although the initial analysis shows that the publisher update experiment increased user engagement, the experiment contains a major sampling bias.
- Because new users are allocated only to the control group, the engagement difference between experiment groups is likely inflated.
- Therefore, the experiment results cannot be considered fully reliable without correcting the experiment design.
