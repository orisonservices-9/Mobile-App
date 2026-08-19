# Orison Parent App — live API contract

This contract matches the prepared admin ERP backend. The Flutter app remains on its
local demo repository until the production API URL, SMS provider, storage and payment
policy are approved. That explicit switch prevents a design build from writing to real
school data.

## Session and ownership

1. `POST /api/parent/auth/request-otp` with `{ "mobile": "9876543210" }`.
2. `POST /api/parent/auth/verify-otp` with `{ "mobile": "...", "otp": "1234" }`.
3. Store the returned JWT in iOS Keychain / Android Keystore and send
   `Authorization: Bearer <token>` on every following request.
4. The backend derives the parent from the JWT and verifies ownership on every
   student-scoped route. The client must never send or trust a parent ID.

## Parent and children

| Method | Endpoint | App use |
|---|---|---|
| GET / PUT | `/api/parent/me` | Profile, mobile/email/address and preferences |
| GET | `/api/parent/students` | Child switcher |
| GET | `/api/parent/students/{id}/dashboard` | Home cards, today and latest notice |

## Parent features

| Method | Endpoint | App use |
|---|---|---|
| GET | `/api/parent/students/{id}/attendance?month=YYYY-MM` | Calendar and monthly totals |
| GET | `/api/parent/students/{id}/results` | Academics, exams and exam comparison |
| GET | `/api/parent/students/{id}/homework` | Assignments and completion state |
| PUT | `/api/parent/students/{id}/homework/{homework_id}/status` | `{ "completed": true }` |
| GET | `/api/parent/students/{id}/timetable?date=YYYY-MM-DD` | Date/day timetable |
| GET | `/api/parent/students/{id}/fees` | Year-wise invoices and receipts |
| POST | `/api/parent/fees/{fee_id}/payment-proof` | Amount, transaction ID and uploaded proof URL |
| POST | `/api/parent/students/{id}/leave` | Dates, type and optional reason/attachment |
| GET | `/api/parent/students/{id}/hall-tickets` | Eligibility, overdue days and previous tickets |
| GET | `/api/parent/students/{id}/transport` | Route, vehicle, driver, trip, stop and ETA |
| GET | `/api/parent/students/{id}/notices` | Targeted notices with unread state |
| PUT | `/api/parent/students/{id}/notices/{notice_id}/read` | Save notice read state |
| POST | `/api/parent/students/{id}/help-requests` | School callback or Orison app issue |
| POST | `/api/parent/uploads/{payment-proof|leave|help}` | Multipart attachment, maximum 12 MB |

## Payment truth rule

Uploading a UPI proof creates `Pending Review`; it never changes the fee. An authorised
finance user approves it in Parent App Center. Only then does the existing fee
transaction update paid/due totals, create a receipt and queue the parent notification.
A future direct payment gateway must follow the same rule through a verified,
idempotent server webhook.

## Release configuration still required

- Production HTTPS API URL and allowed admin-web origin.
- SMS provider credentials; keep `PARENT_OTP_DEBUG` disabled.
- Private object storage or signed URLs for payment, leave and help files.
- Push provider and device-token registration for real-time notifications.
- Map/GPS provider for moving bus coordinates.
- Secure staff login/SSO and full legacy ERP endpoint RBAC.

Do not switch any Flutter screen away from `DemoOrisonRepository` until these deployment
items and an end-to-end staging test are complete.
