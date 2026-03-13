## Investigating a Drop in User Engagement

### Overview

This case study investigates a drop in user engagement on Yammer.
By examining several potential causes including user growth, user retention, device usage, and email engagement via SQL, the analysis identifies the most likely factor contributing to this issue.

### Problem

Yammer experienced a noticeable drop in user engagement.

Possible explanations include:
- Declining user growth
- Reduced engagement of existing users
- Issues with specific devices
- Changes in email interaction behavior
  
This analysis explores each hypothesis to identify the root cause of the engagement drop.

### Dataset

The dataset comes from the Mode SQL Tutorial.

Key tables used:
- `yammer_users`: user signup and activation information
- `yammer_events`: user activity events such as login, messaging, and search
- `yammer_emails`: email interactions including sent emails, opens, and clickthroughs

### Analysis

The analysis follows a step-by-step diagnostic approach.

#### 1. Confirm the engagement drop

Weekly active users were retrieved using login events to confirm that engagement actually declined.

#### 2. Check user growth

User signups and activations were analyzed to check whether the drop was related to slower user growth.

#### 3. Identify affected user segments

Existing users were segmented by account age to check whether engagement declined among specific cohorts.

#### 4. Analyze device usage

User logins were analyzed by device type (computer, phone, tablet) to check whether the issue was localized to a particular device.

#### 5. Investigate email interactions

Email metrics were analyzed to determine whether changes in digest email performance were related to the decline.

### Key Insights

The analysis suggests that the engagement drop is mainly related to:

- Decreased activity among long-tenured users
- A noticeable decline in mobile engagement
- Lower clickthrough rates with digest emails

These findings indicate that issues related to mobile use and digest emails may be contributing to the drop in engagement.
