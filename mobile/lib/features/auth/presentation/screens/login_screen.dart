import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/theme.dart';
import 'package:oblns/features/auth/application/auth_notifier.dart';
import 'package:oblns/features/auth/presentation/screens/verify_otp_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'oblns',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Libyan Speed Delivery',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(flex: 2),
              Text(
                'Phone Number',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 20, letterSpacing: 1.5),
                decoration: const InputDecoration(
                  hintText: '09X XXXXXXX',
                  prefixIcon: Icon(
                    Icons.phone_iphone_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authState.status == AuthStatus.loading
                    ? null
                    : () async {
                        final phone = _phoneController.text.trim();
                        if (phone.isNotEmpty) {
                          final navigator = Navigator.of(context);
                          await ref.read(authProvider.notifier).sendOtp(phone: phone);
                          if (mounted) {
                            navigator.push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    VerifyOtpScreen(phoneNumber: phone),
                              ),
                            );
                          }
                        }
                      },
                child: authState.status == AuthStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Get Verification Code'),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'By continuing, you agree to our Terms and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
