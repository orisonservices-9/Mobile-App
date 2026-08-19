# Orison Parent App

A parent-only Flutter client derived from the Orison ERP. It uses BLoC and a repository boundary, with demo data enabled until parent authentication and parent-scoped API endpoints are added to the ERP backend.

## Parent scope

- View linked children and switch between them
- View attendance, marks/report card, homework and timetable
- View fee balance/history and initiate payment
- Apply for student leave
- View bus/transport information
- Read school notifications
- Update parent contact information

Admin, teacher, fee-manager, HR, inventory, configuration and approval features are intentionally excluded.

## Run

If platform folders are not present, run `flutter create .` once. Then:

```bash
flutter pub get
flutter run
```

Demo sign-in: enter any valid 10-digit mobile number and any 4-digit OTP.
