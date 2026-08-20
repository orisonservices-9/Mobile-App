import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/orison_repository.dart';
import '../models/app_session.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SignInRequested extends AuthEvent {
  const SignInRequested(this.mobile, this.otp);
  final String mobile;
  final String otp;
  @override
  List<Object?> get props => [mobile, otp];
}

class SignedOut extends AuthEvent {}

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthSignedOut extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  const Authenticated(this.session);

  final AppSession session;

  @override
  List<Object?> get props => [session];
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this.repository) : super(AuthSignedOut()) {
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      final session = await repository.authenticateWithOtp(
        event.mobile.trim(),
        event.otp.trim(),
      );
      emit(session != null
          ? Authenticated(session)
          : const AuthFailure(
              'This number is not linked to an active school app account.'));
    });
    on<SignedOut>((event, emit) => emit(AuthSignedOut()));
  }
  final OrisonRepository repository;
}
