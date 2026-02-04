import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:oblns/core/theme.dart';
import 'package:oblns/features/auth/application/auth_notifier.dart';

class RefactoredOtpScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;
  final String? email;

  const RefactoredOtpScreen({
    super.key,
    this.phoneNumber,
    this.email,
  });

  @override
  ConsumerState<RefactoredOtpScreen> createState() =>
      _RefactoredOtpScreenState();
}

class _RefactoredOtpScreenState extends ConsumerState<RefactoredOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  int _remainingSeconds = 60;
  Timer? _timer;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOtp() async {
    setState(() {
      _remainingSeconds = 60;
    });
    _startTimer();

    try {
      await ref.read(authProvider.notifier).sendOtp(
            phone: widget.phoneNumber,
            email: widget.email,
          );
      _showSnackBar('تم إعادة إرسال الرمز');
    } catch (e) {
      _showSnackBar('فشل إعادة الإرسال: $e');
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      _showSnackBar('الرجاء إدخال الرمز كاملاً (6 أرقام)');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      await ref.read(authProvider.notifier).verifyOtp(otp);

      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated) {
        setState(() => _showSuccess = true);
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          // Navigate to home or handle success
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      _showSnackBar('رمز التحقق غير صحيح');
      // Clear OTP
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final contactInfo = widget.phoneNumber ?? widget.email ?? '';

    // Show error if exists
    if (authState.status == AuthStatus.error && authState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(authState.errorMessage!);
        ref.read(authProvider.notifier).clearError();
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBackground,
              const Color(0xFF302b63),
              const Color(0xFF24243e),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xl),

                      // Animated Icon
                      _buildAnimatedIcon(),

                      const SizedBox(height: AppSpacing.xl),

                      // Title and Description
                      _buildHeader(contactInfo),

                      const SizedBox(height: AppSpacing.xxxl),

                      // OTP Input
                      _buildOtpInput(),

                      const SizedBox(height: AppSpacing.xl),

                      // Timer and Resend
                      _buildTimerAndResend(),

                      const SizedBox(height: AppSpacing.xl),

                      // Verify Button
                      _buildVerifyButton(),

                      const SizedBox(height: AppSpacing.lg),

                      // Change Number
                      _buildChangeNumber(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, const Color(0xFFff6b9d)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: _showSuccess
              ? const Icon(Icons.check_circle, size: 60, color: Colors.white)
              : const Icon(Icons.sms_outlined, size: 60, color: Colors.white),
        )
        .animate(target: _showSuccess ? 1 : 0)
        .scale(duration: 300.ms, curve: Curves.elasticOut)
        .then()
        .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3));
  }

  Widget _buildHeader(String contactInfo) {
    return Column(
      children: [
        Text(
          'تحقق من ${widget.phoneNumber != null ? "رقم الهاتف" : "البريد الإلكتروني"}',
          style: AppTypography.headlineMedium(context),
          textAlign: TextAlign.center,
        ).animate().fadeIn().slideY(begin: -0.2),
        
        const SizedBox(height: AppSpacing.md),
        
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTypography.bodyMedium(context),
            children: [
              TextSpan(
                text: 'تم إرسال رمز التحقق إلى\n',
              ),
              TextSpan(
                text: contactInfo,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) => _buildOtpBox(index)),
    ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn();
  }

  Widget _buildOtpBox(int index) {
    final hasValue = _controllers[index].text.isNotEmpty;

    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValue
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          // Auto-verify when all boxes are filled
          if (index == 5 && value.isNotEmpty) {
            final allFilled = _controllers.every((c) => c.text.isNotEmpty);
            if (allFilled) {
              _verifyOtp();
            }
          }

          setState(() {});
        },
      ),
    );
  }

  Widget _buildTimerAndResend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_remainingSeconds > 0) ...[
          Icon(Icons.access_time, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'إعادة الإرسال بعد $_remainingSeconds ثانية',
            style: AppTypography.bodySmall(context),
          ),
        ] else ...[
          TextButton(
            onPressed: _resendOtp,
            child: Text(
              'إعادة إرسال الرمز',
              style: GoogleFonts.cairo(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerifyButton() {
    final isComplete = _controllers.every((c) => c.text.isNotEmpty);
    final isLoading = _isVerifying ||
        ref.watch(authProvider).status == AuthStatus.loading;

    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComplete && !isLoading
              ? [AppColors.primary, const Color(0xFFff6b9d)]
              : [Colors.grey.shade600, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isComplete && !isLoading
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isComplete && !isLoading) ? _verifyOtp : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'تحقق',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ).animate().slideY(begin: 0.2, delay: 600.ms).fadeIn();
  }

  Widget _buildChangeNumber() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        'تغيير ${widget.phoneNumber != null ? "رقم الهاتف" : "البريد الإلكتروني"}',
        style: GoogleFonts.cairo(
          color: AppColors.textSecondary,
          fontSize: 15,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
