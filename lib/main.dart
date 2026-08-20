import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/app.dart';
import 'src/data/orison_repository.dart';
import 'src/state/auth_bloc.dart';
import 'src/state/parent_bloc.dart';
import 'src/state/teacher_bloc.dart';
import 'src/state/leadership_bloc.dart';

void main() {
  final repository = DemoOrisonRepository();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(repository)),
        BlocProvider(create: (_) => ParentBloc(repository)),
        BlocProvider(create: (_) => TeacherBloc(repository)),
        BlocProvider(create: (_) => LeadershipBloc(repository)),
      ],
      child: const OrisonParentApp(),
    ),
  );
}
