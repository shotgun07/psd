import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

import 'package:oblns/core/utils/enhanced_validators.dart';
import 'package:oblns/core/widgets/message_widgets.dart';
import 'package:oblns/features/auth/application/auth_notifier.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String? name;
  final String? email;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.name,
    this.email,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _remainingSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focusNodes[0].requestFocus();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    _isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        MessageSnackBar.showSuccess(context, 'تم التحقق بنجاح!');
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        MessageSnackBar.showError(context, next.errorMessage!);
        // Clear inputs on error
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(height: 20),

                      // Animated Icon
                      _buildAnimatedIcon(),

                      SizedBox(height: 40),

                      // Title and Description
                      _buildHeader(),

                      SizedBox(height: 50),

                      // OTP Input
                      _buildOtpInput(),

                      SizedBox(height: 30),

                      // Timer and Resend
                      _buildTimerAndResend(),

                      SizedBox(height: 40),

                      // Verify Button
                      _buildVerifyButton(),

                      SizedBox(height: 20),

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
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white),
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
              colors: [Color(0xFFe94560), Color(0xFFff6b9d)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFe94560).withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(Icons.sms_outlined, size: 60, color: Colors.white),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3))
        .shake(duration: 3000.ms, delay: 1000.ms);
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'تحقق من رقم الهاتف',
          style: GoogleFonts.cairo(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn().slideY(begin: -0.2),

        SizedBox(height: 12),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.cairo(fontSize: 15, color: Colors.white70),
            children: [
              TextSpan(text: 'تم إرسال رمز التحقق إلى\n'),
              TextSpan(
                text: widget.phoneNumber,
                style: TextStyle(
                  color: Color(0xFFe94560),
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
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? Color(0xFFe94560)
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
        decoration: InputDecoration(counterText: '', border: InputBorder.none),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          // Auto-verify when all boxes are filled
          if (index == 5 && value.isNotEmpty) {
            _verifyOtp();
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
          Icon(Icons.access_time, color: Colors.white60, size: 18),
          SizedBox(width: 8),
          Text(
            'إعادة الإرسال بعد $_remainingSeconds ثانية',
            style: GoogleFonts.cairo(color: Colors.white60, fontSize: 14),
          ),
        ] else ...[
          TextButton(
            onPressed: _resendOtp,
            child: Text(
              'إعادة إرسال الرمز',
              style: GoogleFonts.cairo(
                color: Color(0xFFe94560),
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

    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComplete
              ? [Color(0xFFe94560), Color(0xFFff6b9d)]
              : [Colors.grey.shade600, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isComplete
            ? [
                BoxShadow(
                  color: Color(0xFFe94560).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (_isLoading || !isComplete) ? null : _verifyOtp,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? SizedBox(
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
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
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
        'تغيير رقم الهاتف',
        style: GoogleFonts.cairo(
          color: Colors.white70,
          fontSize: 15,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _verifyOtp() {
    final otp = _controllers.map((c) => c.text).join();

    // Use OTPValidator
    final validationError = OTPValidator.validate(otp);
    if (validationError != null) {
      MessageSnackBar.showError(context, validationError);
      return;
    }

    ref
        .read(authProvider.notifier)
        .verifyOtp(otp, name: widget.name, email: widget.email);
  }

  void _resendOtp() {
    ref.read(authProvider.notifier).sendOtp(phone: widget.phoneNumber);
    setState(() => _remainingSeconds = 60);
    _startTimer();
    MessageSnackBar.showSuccess(context, 'تم إعادة إرسال الرمز');
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
}
