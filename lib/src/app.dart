import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'screens/teacher_home_shell.dart';
import 'screens/leadership_home_shell.dart';
import 'school_brand.dart';
import 'state/auth_bloc.dart';
import 'state/parent_bloc.dart';
import 'state/teacher_bloc.dart';
import 'state/leadership_bloc.dart';
import 'theme.dart';

class OrisonParentApp extends StatelessWidget {
  const OrisonParentApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: SchoolBrand.appName,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              if (state.session.isDirector) {
                final leadershipBloc = context.read<LeadershipBloc>();
                if (leadershipBloc.state is LeadershipInitial) {
                  leadershipBloc.add(LeadershipLoaded(state.session.userId));
                }
                return const LeadershipHomeShell();
              }
              if (state.session.isTeacher) {
                final teacherBloc = context.read<TeacherBloc>();
                if (teacherBloc.state is TeacherInitial) {
                  teacherBloc.add(TeacherLoaded(state.session.userId));
                }
                return const TeacherHomeShell();
              }
              final parentBloc = context.read<ParentBloc>();
              if (parentBloc.state is ParentInitial) {
                parentBloc.add(ParentLoaded());
              }
              return const HomeShell();
            }
            return const LoginScreen();
          },
        ),
      );
}
