import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

class DevelopersScreen extends StatefulWidget {
  const DevelopersScreen({super.key});

  @override
  State<DevelopersScreen> createState() => _DevelopersScreenState();
}

class _DevelopersScreenState extends State<DevelopersScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.setSource(AssetSource('audio/f1.mp3'));
        await _audioPlayer.resume();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not play audio: $e')),
        );
      }
    }
  }

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
          onPressed: () {
            _audioPlayer.stop(); // Stop audio when going back
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Meet the Developers',
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleAudio,
            icon: Icon(
              _isPlaying ? Icons.music_note : Icons.music_off_outlined,
              color: AppColors.white,
            ),
            tooltip: 'Mood Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [

            Text(
              'The Minds Behind AmritaULABS',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mood Refresh Button (Prominent)
            Center(
              child: ElevatedButton.icon(
                onPressed: _toggleAudio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPlaying ? AppColors.white : AppColors.primaryMaroon,
                  foregroundColor: _isPlaying ? AppColors.primaryMaroon : AppColors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: AppColors.primaryMaroon.withOpacity(0.2)),
                  ),
                ),
                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                label: Text(
                  _isPlaying ? 'Pause Mood' : 'Mood Refresh',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Top Row: Mohan & Gurusaran
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildVerticalDeveloperCard(
                    context,
                    name: 'K.N.Mohan Gupta',
                    role: 'App Developer',
                    rollNo: 'CB.EN.U4CSE22524',
                    linkedInUrl: 'https://www.linkedin.com/in/mohanguptakoduru',
                    imagePath: 'assets/images/dev_mohan.png',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVerticalDeveloperCard(
                    context,
                    name: 'Gurusaran A B',
                    role: 'App Devloper',
                    rollNo: 'CB.EN.U4CSE22513',
                    linkedInUrl: 'https://www.linkedin.com/in/gurusaranab/',
                    imagePath: 'assets/images/dev_gurusaran.png',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Bottom Row: Rishik (Centered)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.45, // Match approx width of one column
                child: _buildVerticalDeveloperCard(
                  context,
                  name: 'Rishik Reddy Cheruku',
                  role: 'App Developer',
                  rollNo: 'CB.EN.U4CSE22009',
                  linkedInUrl: 'https://www.linkedin.com/in/rishikreddycheruku/',
                  imagePath: 'assets/images/dev_rishik.png',
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.code,
                    size: 16, color: AppColors.primaryMaroon.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text(
                  'Made with ❤️ at Amrita Vishwa Vidyapeetham',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDeveloperCard(
    BuildContext context, {
    required String name,
    required String role,
    required String rollNo,
    required String linkedInUrl,
    required String imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMaroon.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryMaroon.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryMaroon.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryMaroon.withOpacity(0.1),
                    child: Center(
                      child: Text(
                        name[0],
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryMaroon,
                          ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryMaroon.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              role.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryMaroon,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Roll No
          Text(
            rollNo,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // LinkedIn Button (Small)
          if (linkedInUrl.isNotEmpty)
            InkWell(
              onTap: () => _launchUrl(linkedInUrl),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0077B5).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.link,
                  color: Color(0xFF0077B5),
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(
        urlString.startsWith('http') ? urlString : 'https://$urlString');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}
