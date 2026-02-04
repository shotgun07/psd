import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildMenuSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF302b63),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF302b63), Color(0xFF24243e)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFFe94560),
                    child: Text(
                      'أ',
                      style: GoogleFonts.cairo(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFe94560),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'أحمد محمد',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '+218 91 234 5678',
                style: GoogleFonts.cairo(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('الرحلات', '48', Icons.directions_car)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('التقييم', '4.9', Icons.star)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('الرصيد', '250', Icons.wallet)),
      ],
    ).animate().fadeIn();
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha((0.1 * 255).round())),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFe94560), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(Icons.history, 'سجل الرحلات'),
        _buildMenuItem(Icons.wallet, 'المحفظة'),
        _buildMenuItem(Icons.location_on, 'العناوين المحفوظة'),
        _buildMenuItem(Icons.notifications, 'الإشعارات'),
        _buildMenuItem(Icons.shield, 'وصي الأمان'),
        _buildMenuItem(Icons.help, 'المساعدة والدعم'),
        _buildMenuItem(Icons.settings, 'الإعدادات'),
        const SizedBox(height: 16),
        _buildLogoutButton(),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
            color: Color(0xFFe94560).withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFe94560), size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
        onTap: () {},
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withAlpha((0.5 * 255).round())),
      ),
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text(
          'تسجيل الخروج',
          style:
              GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
