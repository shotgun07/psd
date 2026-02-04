import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:oblns/core/utils/enhanced_validators.dart';
import 'package:oblns/core/widgets/message_widgets.dart';
import 'package:oblns/features/auth/application/auth_notifier.dart';

class EnhancedLoginScreen extends ConsumerStatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  ConsumerState<EnhancedLoginScreen> createState() =>
      _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends ConsumerState<EnhancedLoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    _isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.otpSent && next.errorMessage == null) {
        _showSnackBar('تم إرسال رمز التحقق');
        Navigator.pushNamed(
          context,
          '/otp',
          arguments: next.phoneNumber ?? _phoneController.text.trim(),
        );
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        _showSnackBar(next.errorMessage!);
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),

                    // Animated Logo and Title
                    _buildHeader(),

                    SizedBox(height: 50),

                    // Login Card
                    _buildLoginCard(),

                    SizedBox(height: 24),

                    // Divider
                    _buildDivider(),

                    SizedBox(height: 24),

                    // Social Login Buttons
                    _buildSocialLogin(),

                    SizedBox(height: 30),

                    // Features Section
                    _buildFeatures(),

                    SizedBox(height: 20),

                    // Terms and Privacy
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated Logo
        Container(
              height: 100,
              width: 100,
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
              child: Icon(Icons.local_taxi, size: 50, color: Colors.white),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .shimmer(
              duration: 1500.ms,
              color: Colors.white.withValues(alpha: 0.3),
            ),

        SizedBox(height: 20),

        // App Title with Animated Text
        DefaultTextStyle(
          style: GoogleFonts.cairo(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Color(0xFFe94560).withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'OBLNS',
                speed: Duration(milliseconds: 200),
              ),
            ],
            totalRepeatCount: 1,
          ),
        ),

        SizedBox(height: 8),

        Text(
          'السرعة الليبية',
          style: GoogleFonts.cairo(
            fontSize: 20,
            color: Colors.white70,
            letterSpacing: 1,
          ),
        ).animate().fadeIn(delay: 800.ms),
      ],
    );
  }

  Widget _buildLoginCard() {
    return GlassContainer(
      padding: EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'مرحباً بك',
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'سجل دخولك للمتابعة',
            style: GoogleFonts.cairo(fontSize: 16, color: Colors.white70),
          ),

          SizedBox(height: 30),

          // Phone Input
          _buildPhoneInput(),

          SizedBox(height: 20),

          // Terms Checkbox
          _buildTermsCheckbox(),

          SizedBox(height: 24),

          // Login Button
          _buildLoginButton(),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 600.ms).fadeIn();
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم الهاتف',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              hintText: '09xxxxxxxx',
              hintStyle: GoogleFonts.cairo(
                color: Colors.white.withAlpha((0.4 * 255).round()),
              ),
              prefixIcon: Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFe94560).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.phone_android,
                  color: Color(0xFFe94560),
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: (value) => LibyanPhoneValidator.validate(value),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() => _agreedToTerms = value ?? false);
            },
            // ignore: deprecated_member_use
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Color(0xFFe94560);
              }
              return Colors.white.withValues(alpha: 0.3);
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70),
              children: [
                TextSpan(text: 'أوافق على '),
                TextSpan(
                  text: 'الشروط والأحكام',
                  style: TextStyle(
                    color: Color(0xFFe94560),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: ' و'),
                TextSpan(
                  text: 'سياسة الخصوصية',
                  style: TextStyle(
                    color: Color(0xFFe94560),
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

  Widget _buildLoginButton() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _agreedToTerms
              ? [Color(0xFFe94560), Color(0xFFff6b9d)]
              : [Colors.grey.shade600, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _agreedToTerms
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
          onTap: (_isLoading || !_agreedToTerms) ? null : _handleLogin,
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
                      Icon(Icons.arrow_forward, color: Colors.white),
                      SizedBox(width: 12),
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

  Widget _buildDivider() {
    return Row(
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
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أو',
            style: GoogleFonts.cairo(color: Colors.white60, fontSize: 14),
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
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        _buildSocialButton(
          icon: Icons.g_mobiledata,
          label: 'تسجيل الدخول بواسطة Google',
          color: const Color(0xFF4285F4),
          onTap: _handleGoogleSignIn,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isLoading ? null : _navigateToRegister,
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 15),
              children: [
                const TextSpan(text: 'ليس لديك حساب؟ '),
                TextSpan(
                  text: 'إنشاء حساب جديد',
                  style: TextStyle(
                    color: Color(0xFFe94560),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().slideY(begin: 0.2, delay: 400.ms).fadeIn();
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
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
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 12),
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

  Widget _buildFeatures() {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.security_rounded,
          title: 'آمن ومضمون 100%',
          description: 'حماية كاملة لبياناتك الشخصية',
          color: Color(0xFF4CAF50),
        ),
        SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.speed_rounded,
          title: 'سريع وموثوق',
          description: 'وصول السائق في دقائق معدودة',
          color: Color(0xFF2196F3),
        ),
        SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.payment_rounded,
          title: 'طرق دفع متعددة',
          description: 'نقدي، بطاقة، أو محفظة إلكترونية',
          color: Color(0xFFFF9800),
        ),
      ],
    ).animate().slideY(begin: 0.2, delay: 600.ms).fadeIn();
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.cairo(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        SizedBox(height: 8),
        Text(
          'النسخة 1.0.0',
          style: GoogleFonts.cairo(color: Colors.white30, fontSize: 12),
        ),
      ],
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showSnackBar('يجب الموافقة على الشروط والأحكام');
      return;
    }

    final phone = _phoneController.text.trim();
    ref.read(authProvider.notifier).sendOtp(phone: phone);
  }

  void _handleGoogleSignIn() {
    _showSnackBar('سيتم تفعيل تسجيل الدخول بواسطة Google قريباً');
    // ref.read(authProvider.notifier).signInWithGoogle();
  }

  void _showSnackBar(String message) {
    if (message.contains('خطأ') ||
        message.contains('فشل') ||
        message.contains('غير')) {
      MessageSnackBar.showError(context, message);
    } else {
      MessageSnackBar.showSuccess(context, message);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
