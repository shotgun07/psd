import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 
import 'package:google_fonts/google_fonts.dart';
import 'package:oblns/core/widgets/glass_container.dart';
import 'package:oblns/features/orders/application/order_notifier.dart';
 

class TripRatingScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String driverName;
  final double amount;

  const TripRatingScreen({
    super.key,
    required this.tripId,
    required this.driverName,
    required this.amount,
  });

  @override
  ConsumerState<TripRatingScreen> createState() => _TripRatingScreenState();
}

class _TripRatingScreenState extends ConsumerState<TripRatingScreen> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Success Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'وصلت بسلامة!',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'كيف كانت رحلتك مع ${widget.driverName}؟',
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Rating Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFFFD700),
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() => _rating = index + 1.0);
                    },
                  );
                }),
              ),
              const SizedBox(height: 30),

              // Comment Field
              GlassContainer(
                padding: const EdgeInsets.all(4),
                borderRadius: 16,
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'اكتب ملاحظاتك هنا (اختياري)',
                    hintStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Fare Breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المبلغ الإجمالي',
                      style: GoogleFonts.cairo(color: Colors.white70),
                    ),
                    Text(
                      '${widget.amount.toStringAsFixed(2)} LYD',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFe94560),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFe94560),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'إرسال التقييم',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1));

    final comment = _commentController.text.isEmpty ? null : _commentController.text;
    final success = await ref.read(orderProvider.notifier).rateTrip(widget.tripId, _rating.toInt(), comment);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل إرسال التقييم')));
      }
    }
  }
}
