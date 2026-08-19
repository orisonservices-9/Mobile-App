import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/auth_bloc.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final mobile = TextEditingController(text: '9876543210');
  final otp = TextEditingController(text: '1234');
  @override
  void dispose() {
    mobile.dispose();
    otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                              color: orisonRed,
                              borderRadius: BorderRadius.circular(22)),
                          child: const Icon(Icons.school_rounded,
                              color: Colors.white, size: 38),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Welcome to Orison',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      const Text('Parent portal',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.black54, fontSize: 16)),
                      const SizedBox(height: 36),
                      TextField(
                          controller: mobile,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: const InputDecoration(
                              labelText: 'Registered mobile number',
                              prefixIcon: Icon(Icons.phone_outlined),
                              counterText: '')),
                      const SizedBox(height: 14),
                      TextField(
                          controller: otp,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: '4-digit OTP',
                              prefixIcon: Icon(Icons.lock_outline),
                              counterText: '')),
                      if (state is AuthFailure)
                        Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(state.message,
                                style: const TextStyle(color: orisonRed))),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () => context
                                .read<AuthBloc>()
                                .add(SignInRequested(mobile.text, otp.text)),
                        style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        child: state is AuthLoading
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Sign in securely'),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                          'Only parents linked to an active student account can sign in.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
