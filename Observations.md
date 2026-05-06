## Time
**Estimated Time Spent:** TODO: Add time spent

> Given time constraints, I focused on fewer tasks done well rather than rushing through all five.

## AI
[x] - Did you use AI tooling during the completion of your work?

**Details**
What tooling did you use?: Claude (Anthropic)
Please provide a brief description of how you used it: Used Claude as a pair programming partner — talking through design decisions, debugging environment issues, and gut-checking approaches. I drove all implementation and wrote the code myself.

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
-

---

## Task Notes

### FE-001: Server Health Monitoring ✓
Implemented weighted health score (CPU 40%, memory 40%, disk 20%) as a computed (`serversWithHealth`) in the servers Pinia store. Health score surfaced as a column on both the dashboard recent servers table and the main servers list.

### FE-005: Error Handling and User Feedback ✓
Added `vue-sonner` for toast notifications. Pattern kept lean — toasts only where there's no other feedback channel:
- Success toasts on server create, update, and delete
- Error toast on delete failure (no form in context to show inline error)
- Form views (`ServerFormView`, `EditServerModal`) use inline errors via `serversStore.error`
- Profile page retains its existing inline success/error banners
- Loading and error states wired up on `ServersView` table and `DashboardView` recent servers table
- Delete confirmation button reflects in-flight state ("Deleting..." + disabled)
- Fixed `cpu_usage` display bug on dashboard — was rendering raw decimal (e.g. `0.54%`) instead of percentage (`54%`)
