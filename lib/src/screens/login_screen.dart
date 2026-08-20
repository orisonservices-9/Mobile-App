import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../school_brand.dart';
import '../state/auth_bloc.dart';

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

  void _useDemo(String number) {
    setState(() {
      mobile.text = number;
      otp.text = '1234';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: _LoginBackground()),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _BrandHeader(),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x240B1837),
                                  blurRadius: 30,
                                  offset: Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Welcome back',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Use your school-registered mobile number. Your workspace opens automatically.',
                                  style: TextStyle(
                                    height: 1.45,
                                    color: Color(0xFF697386),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                TextField(
                                  controller: mobile,
                                  keyboardType: TextInputType.phone,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumber
                                  ],
                                  maxLength: 10,
                                  decoration: const InputDecoration(
                                    labelText: 'Registered mobile number',
                                    prefixIcon:
                                        Icon(Icons.phone_iphone_rounded),
                                    counterText: '',
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: otp,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Secure 4-digit OTP',
                                    prefixIcon:
                                        Icon(Icons.lock_outline_rounded),
                                    counterText: '',
                                  ),
                                ),
                                if (state is AuthFailure)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      state.message,
                                      style: const TextStyle(
                                        color: SchoolBrand.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 18),
                                FilledButton.icon(
                                  onPressed: state is AuthLoading
                                      ? null
                                      : () => context.read<AuthBloc>().add(
                                            SignInRequested(
                                              mobile.text,
                                              otp.text,
                                            ),
                                          ),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: state is AuthLoading
                                      ? const SizedBox.square(
                                          dimension: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.arrow_forward_rounded),
                                  label: Text(
                                    state is AuthLoading
                                        ? 'Verifying securely…'
                                        : 'Continue securely',
                                  ),
                                ),
                                const SizedBox(height: 17),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      size: 17,
                                      color: Color(0xFF68758A),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'No role selection needed. The school directory securely identifies parent, teacher or leadership access.',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          height: 1.35,
                                          color: Color(0xFF68758A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _DemoAccess(onSelected: _useDemo),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1934), Color(0xFF17244A), Color(0xFF7A101B)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -80,
              top: -70,
              child: Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x22FFFFFF),
                ),
              ),
            ),
            Positioned(
              left: -110,
              bottom: 40,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x16FFFFFF),
                ),
              ),
            ),
          ],
        ),
      );
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) => const Column(
        children: [
          SchoolLogo(size: 72),
          SizedBox(height: 16),
          Text(
            SchoolBrand.schoolName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -.4,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'One school. One secure app.',
            style: TextStyle(
              color: Color(0xFFD8DEEA),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}

class _DemoAccess extends StatelessWidget {
  const _DemoAccess({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PREVIEW ACCESS  •  OTP 1234',
              style: TextStyle(
                color: Color(0xFFCFD7E8),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: _DemoButton(
                    icon: Icons.family_restroom_rounded,
                    label: 'Parent',
                    number: '9876543210',
                    onTap: onSelected,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DemoButton(
                    icon: Icons.co_present_rounded,
                    label: 'Teacher',
                    number: '9876510001',
                    onTap: onSelected,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DemoButton(
              icon: Icons.workspace_premium_rounded,
              label: 'Principal / Director',
              number: '9876510002',
              onTap: onSelected,
            ),
          ],
        ),
      );
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.icon,
    required this.label,
    required this.number,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String number;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: () => onTap(number),
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        number,
                        style: const TextStyle(
                          color: Color(0xFFC9D1E1),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
