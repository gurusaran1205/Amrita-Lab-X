import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/colors.dart';

class DevelopersScreen extends StatelessWidget {
  const DevelopersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryMaroon,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meet the Developers',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            const Text(
              'The Minds Behind AmritaULABS',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _buildDeveloperCard(
              context,
              name: 'K.N.Mohan Gupta',
              role: 'Developer',
              rollNo: 'CB.EN.U4CSE22524',
              batch: '2022-2026',
              linkedInUrl: 'https://www.linkedin.com/in/mohanguptakoduru',
              imagePath: 'assets/images/dev_mohan.png',
            ),
            const SizedBox(height: 20),
            _buildDeveloperCard(
              context,
              name: 'Gurusaran',
              role: 'Developer',
              rollNo: 'CB.EN.U4CSE22512',
              batch: '2022-2026',
              linkedInUrl: 'https://www.linkedin.com/in/gurusaranab/',
              imagePath: 'assets/images/dev_gurusaran.png',
            ),
            const SizedBox(height: 20),
            _buildDeveloperCard(
              context,
              name: 'Rishik Reddy',
              role: 'Developer',
              rollNo: 'CB.EN.U4CSE22512',
              batch: '2022-2026',
              linkedInUrl: 'https://www.linkedin.com/in/rishikreddycheruku/',
              imagePath: 'assets/images/dev_rishik.png',
            ),
            const SizedBox(height: 40),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.code, size: 16, color: AppColors.primaryMaroon.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text(
                  'Made with ❤️ at Amrita Vishwa Vidyapeetham',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(
    BuildContext context, {
    required String name,
    required String role,
    required String rollNo,
    required String batch,
    required String linkedInUrl,
    required String imagePath,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMaroon.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryMaroon.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryMaroon.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMaroon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryMaroon,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rollNo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Batch $batch',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          
          // LinkedIn Button
          if (linkedInUrl.isNotEmpty)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _launchUrl(linkedInUrl),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0077B5).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link,
                    color: Color(0xFF0077B5),
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString.startsWith('http') ? urlString : 'https://$urlString');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}
