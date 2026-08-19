import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'state/auth_bloc.dart';
import 'state/parent_bloc.dart';
import 'theme.dart';

class OrisonParentApp extends StatelessWidget {
  const OrisonParentApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Orison Parent',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              context.read<ParentBloc>().add(ParentLoaded());
              return const HomeShell();
            }
            return const LoginScreen();
          },
        ),
      );
}
