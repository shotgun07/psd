import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oblns/features/wallet/application/wallet_notifier.dart';
import 'package:oblns/core/widgets/glass_container.dart';

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  final TextEditingController _amountController = TextEditingController();
  final List<double> _presets = [10, 20, 50, 100];
  String? _selectedMethod = 'sadad'; // sadad, adfali, card

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'شحن المحفظة',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance
            Center(
              child: Column(
                children: [
                  Text(
                    'الرصيد الحالي',
                    style: GoogleFonts.cairo(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${ref.watch(walletProvider).balance.toStringAsFixed(2)} LYD',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Amount Input
            Text(
              'أدخل المبلغ',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              borderRadius: 16,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Text(
                    'LYD',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFe94560),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Presets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _presets.map((amount) {
                return GestureDetector(
                  onTap: () => _amountController.text = amount.toString(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      '${amount.toInt()}',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Payment Methods
            Text(
              'طريقة الدفع',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethod(
              id: 'sadad',
              name: 'سداد (Sadad)',
              icon: Icons.qr_code_2,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethod(
              id: 'adfali',
              name: 'ادفع لي (Adfali)',
              icon: Icons.account_balance_wallet,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethod(
              id: 'card',
              name: 'بطاقة مصرفية',
              icon: Icons.credit_card,
            ),

            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  if (amount > 0 && _selectedMethod != null) {
                    ref
                        .read(walletProvider.notifier)
                        .addFunds(amount, _selectedMethod!);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe94560),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'تأكيد الشحن',
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
    );
  }

  Widget _buildPaymentMethod({
    required String id,
    required String name,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFe94560).withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFe94560) : Colors.white10,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFe94560) : Colors.white70,
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: GoogleFonts.cairo(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFe94560)),
          ],
        ),
      ),
    );
  }
}
