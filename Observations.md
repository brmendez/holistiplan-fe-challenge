## Time
**Estimated Time Spent:** ~4 hours

> Given time constraints, I focused on fewer tasks done well rather than rushing through all five.

## AI
[x] - Did you use AI tooling during the completion of your work?

**Details**
What tooling did you use?: Claude (Anthropic)
Please provide a brief description of how you used it: Used Claude as a collaborative pair programmer — worked through design decisions, implementation, and debugging together.

---

## Application Notes

**Observed Bugs**

**Addressed**
- A regular user could escalate themselves to admin via the Edit Profile form — the `/api/auth/profile` endpoint accepted `is_admin` with no requester auth check. *(Fixed: removed `is_admin` from the profile endpoint entirely; field now hidden from non-admin users in `MyAccountView.vue`)*
- Input fields had `required` on them, so native browser form validation was firing instead of the app's custom inline errors. *(Fixed: removed `required` attrs from `ServerFormView.vue` and `EditServerModal.vue`)*
- No client-side validation on the Add Server form — required fields could be submitted empty. *(Fixed: `validateForm` in `ServerFormView.vue` now runs on submit and shows inline errors per field)*
- Data inconsistency: `memory_usage` was generated as a whole number (0–100) while `cpu_usage` and `disk_usage` used decimals (0–1), causing the Average Resource Usage chart to display memory at 5710%. *(Fixed: normalized to 0–1 in `backend/app.py`)*
- No success/error feedback when adding, updating, or deleting a server. *(Addressed via FE-005 — see Task Notes)*
- Edit Profile form could be submitted without any changes made. *(Fixed: `hasChanges` computed disables Save until a field is actually modified)*
- An admin could demote themselves or deactivate their own account via the Edit User modal, losing access with no self-recovery path. *(Fixed: `is_admin` and `is_active` fields replaced with read-only badges when editing your own account)*
- Disabled buttons had no visual indication — no opacity change, cursor stayed as pointer. *(Fixed: added `disabled:opacity-50 disabled:cursor-not-allowed` globally to `.btn` in `main.css`)*

### Other Insights
No additional observations beyond the bugs documented above.

---

## Task Notes

### FE-001: Server Health Monitoring ✓
Implemented weighted health score (CPU 40%, memory 40%, disk 20%) as a computed (`serversWithHealth`) in the servers Pinia store. Health score surfaced as a column on both the dashboard recent servers table and the main servers list.

### FE-002: Filtering and Sorting ✓
All filtering and sorting is client-side in `ServersView.vue` — no backend changes needed.
- Filter by server name (live substring search), IP address (partial match), status (dropdown), and location (dropdown auto-populated from actual server data)
- Sort by Name, Status, Location, and Uptime via clickable column headers — click once for asc, again for desc; inactive columns show ↕ indicator
- Status sort uses semantic ordering (online → maintenance → error → offline) rather than alphabetical
- Clear Filters button appears only when a filter is active; clears all filters without resetting sort
- Empty state distinguishes "no servers" from "no results for current filters" with an inline Clear Filters shortcut
- Filter state resets on page leave as specified

### FE-003: Dashboard Interactivity (not implemented)
Would add polling with a "last updated" timestamp for a real-time feel, and make the status/usage charts clickable to navigate to the Servers list with filters pre-applied.

### FE-004: Bulk Operations (not implemented)
Would add a checkbox column with select-all, and a contextual action bar that appears when rows are selected with bulk delete and status update options. Bulk delete would require a confirmation step.

### FE-005: Error Handling and User Feedback ✓
Added `vue-sonner` for toast notifications. Pattern kept lean — toasts only where there's no other feedback channel:
- Success toasts on server create, update, and delete
- Error toast on delete failure (no form in context to show inline error)
- Form views (`ServerFormView`, `EditServerModal`) use inline errors via `serversStore.error`
- Profile page retains its existing inline success/error banners
- Loading and error states wired up on `ServersView` table and `DashboardView` recent servers table
- Delete confirmation button reflects in-flight state ("Deleting..." + disabled)
- Fixed `cpu_usage` display bug on dashboard — was rendering raw decimal (e.g. `0.54%`) instead of percentage (`54%`)
