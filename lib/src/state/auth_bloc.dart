import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/orison_repository.dart';

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

class Authenticated extends AuthState {}

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
      final ok =
          await repository.verifyOtp(event.mobile.trim(), event.otp.trim());
      emit(ok
          ? Authenticated()
          : const AuthFailure(
              'Enter a valid 10-digit mobile number and 4-digit OTP.'));
    });
    on<SignedOut>((event, emit) => emit(AuthSignedOut()));
  }
  final OrisonRepository repository;
}
