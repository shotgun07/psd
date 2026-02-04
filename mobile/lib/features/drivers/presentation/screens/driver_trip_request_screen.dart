import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';
import 'package:oblns/features/drivers/application/driver_notifier.dart';
import 'package:oblns/core/widgets/message_widgets.dart';

class DriverTripRequestScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String pickupAddress;
  final String destAddress;
  final double fare;
  final double distance;

  const DriverTripRequestScreen({
    super.key,
    required this.tripId,
    required this.pickupAddress,
    required this.destAddress,
    required this.fare,
    required this.distance,
  });

  @override
  ConsumerState<DriverTripRequestScreen> createState() =>
      _DriverTripRequestScreenState();
}

class _DriverTripRequestScreenState
    extends ConsumerState<DriverTripRequestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _remainingSeconds = 30;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _startCountdown();
    _vibrate();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        _startCountdown();
      } else if (mounted && _remainingSeconds == 0) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(pattern: [500, 1000, 500, 1000]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Timer
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 + (_pulseController.value * 0.1),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFe94560),
                            Color(0xFFe94560).withAlpha((0.6 * 255).round()),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(
                              0xFFe94560,
                            ).withAlpha((0.4 * 255).round()),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$_remainingSeconds',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              Text(
                'طلب رحلة جديد!',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Trip Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.05 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withAlpha((0.1 * 255).round()),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.my_location,
                      'من',
                      widget.pickupAddress,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.location_on,
                      'إلى',
                      widget.destAddress,
                      const Color(0xFFe94560),
                    ),
                    const Divider(color: Colors.white10, height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoChip(Icons.route, '${widget.distance} كم'),
                        _buildInfoChip(
                          Icons.monetization_on,
                          '${widget.fare} LYD',
                        ),
                        _buildInfoChip(Icons.access_time, '~10 دقائق'),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),

              const Spacer(),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'رفض',
                          style: GoogleFonts.cairo(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isAccepting ? null : _acceptTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isAccepting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'قبول الرحلة',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFe94560).withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFe94560), size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptTrip() async {
    setState(() => _isAccepting = true);

    final success = await ref
        .read(driverProvider.notifier)
        .acceptOrder(widget.tripId);

    if (mounted) {
      if (success) {
        MessageSnackBar.showSuccess(context, 'تم قبول الرحلة بنجاح!');
        Navigator.pop(context, true);
      } else {
        setState(() => _isAccepting = false);
        final errorMessage =
            ref.read(driverProvider).errorMessage ?? 'فشل في قبول الرحلة';
        MessageSnackBar.showError(context, errorMessage);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    Vibration.cancel();
    super.dispose();
  }
}
