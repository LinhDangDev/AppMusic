import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Profile Screen with User Info & Settings
class ProfileScreenMusium extends StatelessWidget {
  const ProfileScreenMusium({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorMusium.darkBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Profile',
                style: AppTypographyMusium.heading3.copyWith(
                  color: AppColorMusium.accentTeal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // User profile card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorMusium.accentTeal.withValues(alpha: 0.3),
                    AppColorMusium.accentPurple.withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(
                  color: AppColorMusium.accentTeal.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColorMusium.accentTeal,
                          AppColorMusium.accentPurple,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Name
                  Text(
                    'Music Lover',
                    style: AppTypographyMusium.heading4.copyWith(
                      color: AppColorMusium.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Email
                  Text(
                    'user@musium.app',
                    style: AppTypographyMusium.bodySmall.copyWith(
                      color: AppColorMusium.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statCard('456', 'Playlists'),
                      _statCard('1.2K', 'Followers'),
                      _statCard('89', 'Following'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Account section
            _sectionTitle('Account'),
            _settingItem(Icons.edit, 'Edit Profile', () {}),
            _settingItem(Icons.lock, 'Change Password', () {}),
            _settingItem(Icons.security, 'Privacy Settings', () {}),

            const SizedBox(height: 20),

            // Preferences section
            _sectionTitle('Preferences'),
            _settingItem(Icons.volume_up, 'Sound Quality', () {}),
            _settingItem(Icons.download, 'Download Quality', () {}),
            _settingItem(Icons.notifications, 'Notifications', () {}),

            const SizedBox(height: 20),

            // Help section
            _sectionTitle('Help & Support'),
            _settingItem(Icons.help, 'FAQ', () {}),
            _settingItem(Icons.feedback, 'Send Feedback', () {}),
            _settingItem(Icons.info, 'About', () {}),

            const SizedBox(height: 20),

            // Logout button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColorMusium.error,
                    width: 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: Center(
                      child: Text(
                        'Logout',
                        style: AppTypographyMusium.labelLarge.copyWith(
                          color: AppColorMusium.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypographyMusium.heading4.copyWith(
            color: AppColorMusium.accentTeal,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypographyMusium.bodySmall.copyWith(
            color: AppColorMusium.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: AppTypographyMusium.heading5.copyWith(
          color: AppColorMusium.textPrimary,
        ),
      ),
    );
  }

  Widget _settingItem(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColorMusium.darkSurfaceLight.withValues(alpha: 0.5),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColorMusium.accentTeal,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTypographyMusium.bodyMedium.copyWith(
                    color: AppColorMusium.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColorMusium.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
