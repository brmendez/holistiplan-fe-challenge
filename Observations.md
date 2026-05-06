## Time
**Estimated Time Spent:** TODO: Add time spent

> Given time constraints, I focused on fewer tasks done well rather than rushing through all five.

## AI
[x] - Did you use AI tooling during the completion of your work?

**Details**
What tooling did you use?: Claude (Anthropic)
Please provide a brief description of how you used it: Used Claude as a pair programming partner — talking through design decisions, debugging environment issues, and gut-checking approaches. I drove all implementation and wrote the code myself.

## Application Notes

**Observed Bugs**
- A regular user can escalate themselves to admin through the Edit Profile form. The `/api/auth/profile` endpoint accepts `is_admin` in the request body with no admin check on the requester. The field should also be hidden from non-admin users entirely.
  - Repro: Create a non-admin user → log in → Edit Profile → check Admin User → save. User is now an administrator.
- No client-side form validation on the Add Server form — required fields can be submitted empty.
- No success/error feedback when adding, updating, or deleting a server.
- Data inconsistency in server metrics: `memory_usage` is stored as a whole number (0–100) while `cpu_usage` and `disk_usage` are decimals (0–1). This caused the Average Resource Usage chart to display memory as 5710%. Metrics should use a consistent scale.
- Input fields had `required` on them, so instead of errors displaying under the fields, native browser form validation was kicking in.

**Other Insights**
-

## Task Notes