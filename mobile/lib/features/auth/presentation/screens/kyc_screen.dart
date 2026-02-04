import 'package:flutter/material.dart';
import 'package:oblns/core/theme.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({super.key});

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ID Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete your KYC',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'To ensure the safety of our community, please upload a clear photo of your ID or Passport.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),
            _buildUploadCard(
              title: 'National ID / Passport',
              subtitle: 'Front and back side',
              icon: Icons.badge_rounded,
            ),
            const SizedBox(height: 24),
            _buildUploadCard(
              title: 'Selfie with ID',
              subtitle: 'Ensure your face is clearly visible',
              icon: Icons.face_rounded,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isUploading ? null : _submitKYC,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit for Review'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
        ],
      ),
    );
  }

  Future<void> _submitKYC() async {
    setState(() => _isUploading = true);
    await Future.delayed(const Duration(seconds: 2)); // Mock upload
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Documents submitted. We will notify you once verified.',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }
}
