# Single app role contract

The app must never ask the user to choose Parent or Teacher. The server owns the
decision after OTP verification.

## Verify response

```json
{
  "token": "signed-access-token",
  "session": {
    "user_id": "TCH-001",
    "name": "Dr. Anita Rao",
    "mobile": "9876510001",
    "role": "teacher",
    "school_id": "SCH-001"
  }
}
```

`role` is strictly `parent`, `teacher` or `director`. Every later API derives identity,
school and role from the signed token. It must reject a client-supplied teacher
ID, parent ID or role that attempts to widen access.

## Resolution rules

- Active parent match only: issue a parent session.
- Active teacher match only: issue a teacher session.
- Active principal/director match only: issue a leadership session.
- No match: return 404 with a school-contact message.
- Both match: return 409 `identity_conflict`; school administration resolves it.
- Inactive match: return 403; do not reveal private record details.
- Rate-limit both OTP request and verification by number, device and IP.

## Data boundaries

- A parent token can read/update only linked children and parent-owned requests.
- A teacher token can access only assigned classes, subjects and students.
- A director token is read-mostly and campus-scoped. Mutations are limited to
  explicit leadership decisions such as approval, rejection, resolving an alert
  or publishing an authorised announcement; every decision is audited.
- Daily attendance write access is resolved from that date’s timetable: only
  the teacher assigned to the class’s first period can submit its register.
  The server must validate this again even when the mobile UI hides the action.
- Attendance, marks and homework writes keep actor, timestamp and before/after
  values in the audit trail.
- Homework validates both the assigned class and the teacher’s subject allocation;
  attachment uploads are scanned and stored under the homework record.
- Lesson plans are created and timed by the admin website. Teachers may view their
  assigned plan and mark completion, but cannot change the admin-owned timeline.
- Staff leave submissions flow to the admin approval queue with date range,
  leave type, reason and optional supporting document.
- Admin web controls the assignments; the mobile app does not grant them.
