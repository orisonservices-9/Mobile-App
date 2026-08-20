import 'package:equatable/equatable.dart';

enum AppUserRole { parent, teacher, director }

class AppSession extends Equatable {
  const AppSession({
    required this.userId,
    required this.name,
    required this.mobile,
    required this.role,
  });

  final String userId;
  final String name;
  final String mobile;
  final AppUserRole role;

  bool get isParent => role == AppUserRole.parent;
  bool get isTeacher => role == AppUserRole.teacher;
  bool get isDirector => role == AppUserRole.director;

  @override
  List<Object?> get props => [userId, name, mobile, role];
}
