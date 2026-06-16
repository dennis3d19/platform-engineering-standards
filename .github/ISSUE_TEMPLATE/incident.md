---
name: Incident Report
about: Document a platform incident or outage for post-mortem review
title: "incident: [SEVERITY] <brief description>"
labels: ["incident", "needs-review"]
assignees: []
---

## Incident Summary

| Field | Value |
|---|---|
| **Incident ID** | INC-<!-- number --> |
| **Severity** | <!-- SEV1 / SEV2 / SEV3 / SEV4 --> |
| **Status** | <!-- Active / Resolved / Monitoring --> |
| **Start Time** | <!-- YYYY-MM-DD HH:MM UTC --> |
| **End Time** | <!-- YYYY-MM-DD HH:MM UTC or Ongoing --> |
| **Duration** | <!-- e.g., 1h 23m --> |
| **Affected Services** | <!-- comma-separated list --> |
| **Incident Commander** | <!-- @username --> |

---

## Impact

<!-- Describe the user-facing or system impact -->

- **Affected users**: <!-- number or description -->
- **Affected environments**: <!-- tst / acc / prd -->
- **Symptoms observed**: <!-- what users or monitors saw -->

---

## Timeline

| Time (UTC) | Event |
|---|---|
| HH:MM | Alert fired / incident declared |
| HH:MM | Investigation started |
| HH:MM | Root cause identified |
| HH:MM | Mitigation applied |
| HH:MM | Service restored |
| HH:MM | Incident closed |

---

## Root Cause

<!-- Technical description of what caused the incident -->

---

## Contributing Factors

<!-- What conditions made this incident possible or worse? -->

1. Factor 1
2. Factor 2

---

## Detection

<!-- How was the incident detected? Alert, user report, automated check? -->

- **Detected by**: <!-- alert name / user / manual check -->
- **Time to detect**: <!-- from start to detection -->
- **Detection gap**: <!-- why wasn't this caught sooner? -->

---

## Resolution

<!-- What steps were taken to resolve the incident? -->

1. Step 1
2. Step 2

---

## Action Items

| # | Action | Owner | Due Date | Status |
|---|---|---|---|---|
| 1 | <!-- description --> | @username | YYYY-MM-DD | Open |
| 2 | <!-- description --> | @username | YYYY-MM-DD | Open |

---

## Lessons Learned

<!-- What did we learn? What went well? What could be improved? -->

### What Went Well

-

### What Could Be Improved

-

### What Surprised Us

-

---

## Prevention

<!-- What changes will prevent this type of incident in the future? -->

---

## Communications

<!-- Summary of communications sent during the incident -->

| Time (UTC) | Channel | Message |
|---|---|---|
| HH:MM | <!-- Slack/Email/Page --> | <!-- brief description --> |
