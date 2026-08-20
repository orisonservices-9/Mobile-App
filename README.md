# Orison School App

A single school-branded Flutter app for parents, teachers and school leadership. It uses BLoC and
a repository boundary so the verified mobile number—not a role picker—decides
which secure workspace opens.

## Access rule

1. The user enters the mobile number registered with the school and verifies OTP.
2. The backend resolves that number against active parent and teacher records.
3. It returns one signed session containing `role: parent`, `role: teacher` or `role: director`.
4. The app opens only the modules allowed for that role.

Duplicate parent/teacher ownership for the same number must be corrected by the
school; the login service must not guess or allow the user to select a privileged
role.

## Teacher workspace

- Premium daily dashboard, next class and teaching timeline
- Assigned classes and student roster
- Attendance submission
- Homework publishing
- Marks entry workspace
- Timetable and student performance insights
- Priority tasks, staff notices, leave, support and secure settings

The completed parent experience remains available without teacher/admin controls.

## Preview access

- Parent: `9876543210`, OTP `1234`
- Teacher: `9876510001`, OTP `1234`
- Principal / Director: `9876510002`, OTP `1234`

Run with `flutter pub get` and `flutter run`.
