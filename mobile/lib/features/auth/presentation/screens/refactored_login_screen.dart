import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:oblns/core/theme.dart';
import 'package:oblns/core/widgets/glass_container.dart';
import 'package:oblns/features/auth/application/auth_notifier.dart';
import 'package:oblns/features/auth/domain/models/auth_form_model.dart';
import 'package:oblns/features/auth/presentation/screens/refactored_otp_screen.dart';
import 'dart:async';

class RefactoredLoginScreen extends ConsumerStatefulWidget {
  const RefactoredLoginScreen({super.key});

  @override
  ConsumerState<RefactoredLoginScreen> createState() =>
      _RefactoredLoginScreenState();
}

class _RefactoredLoginScreenState
    extends ConsumerState<RefactoredLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  Timer? _debounceTimer;

  AuthFormModel _formModel = const AuthFormModel();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateFormModel(AuthFormModel Function(AuthFormModel) updater) {
    setState(() {
      _formModel = updater(_formModel);
    });
  }

  void _debounceSubmit() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_formModel.canSendOtp && !_isSubmitting) {
        _handleSubmit();
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_formModel.agreedToTerms) {
      _showError('يجب الموافقة على الشروط والأحكام');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(authProvider.notifier).sendOtp(
            phone: _formModel.method == AuthMethod.phone
                ? _formModel.phone
                : null,
            email: _formModel.method == AuthMethod.email
                ? _formModel.email
                : null,
          );

      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState.status == AuthStatus.otpSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RefactoredOtpScreen(
                phoneNumber: authState.phoneNumber,
                email: authState.email,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: AppColors.textError,
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
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Show error if exists
    if (authState.status == AuthStatus.error && authState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError(authState.errorMessage!);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  
                  // Welcome Header
                  _buildWelcomeHeader(),
                  
                  const SizedBox(height: AppSpacing.xxxl),
                  
                  // Login Card
                  _buildLoginCard(isRTL),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Social Login
                  _buildSocialLogin(),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Terms and Privacy
                  _buildTermsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        // Animated Logo
        Container(
          height: 100,
          width: 100,
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
          child: const Icon(
            Icons.local_taxi,
            size: 50,
            color: Colors.white,
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3)),
        
        const SizedBox(height: AppSpacing.lg),
        
        // App Title
        Text(
          'OBLNS',
          style: AppTypography.displayLarge(context).copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
            shadows: [
              Shadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
        
        const SizedBox(height: AppSpacing.sm),
        
        Text(
          'السرعة الليبية',
          style: AppTypography.headlineSmall(context).copyWith(
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildLoginCard(bool isRTL) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'مرحباً بك',
            style: AppTypography.headlineMedium(context),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            'سجل دخولك للمتابعة',
            style: AppTypography.bodyMedium(context).copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Phone/Email Toggle
          _buildMethodToggle(isRTL),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Input Field
          _formModel.method == AuthMethod.phone
              ? _buildPhoneInput()
              : _buildEmailInput(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Terms Checkbox
          _buildTermsCheckbox(),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 600.ms).fadeIn();
  }

  Widget _buildMethodToggle(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'رقم الهاتف',
              icon: Icons.phone_android,
              isSelected: _formModel.method == AuthMethod.phone,
              onTap: () {
                _updateFormModel((model) => model.copyWith(
                      method: AuthMethod.phone,
                    ));
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _buildToggleButton(
              label: 'البريد الإلكتروني',
              icon: Icons.email,
              isSelected: _formModel.method == AuthMethod.email,
              onTap: () {
                _updateFormModel((model) => model.copyWith(
                      method: AuthMethod.email,
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم الهاتف',
          style: AppTypography.labelLarge(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '09xxxxxxxx',
            hintStyle: GoogleFonts.cairo(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.phone_android,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            _updateFormModel((model) => model.copyWith(phone: value ?? ''));
            return _formModel.phoneError;
          },
          onChanged: (value) {
            _updateFormModel((model) => model.copyWith(phone: value));
            _debounceSubmit();
          },
        ),
      ],
    );
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البريد الإلكتروني',
          style: AppTypography.labelLarge(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'example@email.com',
            hintStyle: GoogleFonts.cairo(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.email,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            _updateFormModel((model) => model.copyWith(email: value ?? ''));
            return _formModel.emailError;
          },
          onChanged: (value) {
            _updateFormModel((model) => model.copyWith(email: value));
            _debounceSubmit();
          },
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _formModel.agreedToTerms,
            onChanged: (value) {
              _updateFormModel((model) =>
                  model.copyWith(agreedToTerms: value ?? false));
            },
            // ignore: deprecated_member_use
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return Colors.white.withValues(alpha: 0.3);
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodySmall(context),
              children: [
                const TextSpan(text: 'أوافق على '),
                TextSpan(
                  text: 'الشروط والأحكام',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' و'),
                TextSpan(
                  text: 'سياسة الخصوصية',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final isLoading = _isSubmitting ||
        ref.watch(authProvider).status == AuthStatus.loading;
    final isEnabled = _formModel.canSendOtp && !isLoading;

    return Container(
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEnabled
              ? [AppColors.primary, const Color(0xFFff6b9d)]
              : [Colors.grey.shade600, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled
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
          onTap: isEnabled ? _handleSubmit : null,
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
                      const Icon(Icons.arrow_forward, color: Colors.white),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'إرسال رمز التحقق',
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
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.white30],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'أو',
                style: AppTypography.bodySmall(context),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white30, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSocialButton(
          icon: Icons.g_mobiledata,
          label: 'تسجيل الدخول بواسطة Google',
          color: const Color(0xFF4285F4),
          onTap: () {
            ref.read(authProvider.notifier).signInWithGoogle();
          },
        ),
      ],
    ).animate().slideY(begin: 0.2, delay: 400.ms).fadeIn();
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            // Navigate to register screen
          },
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodyMedium(context),
              children: [
                const TextSpan(text: 'ليس لديك حساب؟ '),
                TextSpan(
                  text: 'إنشاء حساب جديد',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'النسخة 1.0.0',
          style: AppTypography.bodySmall(context).copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
