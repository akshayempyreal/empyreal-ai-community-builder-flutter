import 'package:empyreal_ai_community_builder_flutter/core/theme/app_theme.dart';
import 'package:empyreal_ai_community_builder_flutter/project_helpers.dart';
import 'package:flutter/material.dart';


class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onLogout;
  final VoidCallback onNavigateToProfile;
  final VoidCallback onNavigateToPrivacy;
  final VoidCallback onNavigateToTerms;

  const SettingsScreen({
    super.key,
    required this.onBack,
    required this.onLogout,
    required this.onNavigateToProfile,
    required this.onNavigateToPrivacy,
    required this.onNavigateToTerms,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)
                        .paddingAll(context, 8)
                        .onClick(widget.onBack),
                    const Spacer(),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40), // For balance
                  ],
                ),
              ),
              
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Account'),
                          _buildSettingsGroup([
                            _buildSettingsTile(
                              icon: Icons.person_outline,
                              title: 'Profile Information',
                              onTap: widget.onNavigateToProfile,
                            ),
                          ]),
                          
                          32.height(context),
                          _buildSectionTitle('Notifications'),
                          _buildSettingsGroup([
                            _buildSettingsTile(
                              icon: Icons.notifications_none,
                              title: 'Push Notifications',
                              trailing: Switch(
                                value: _notificationsEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _notificationsEnabled = value;
                                  });
                                  // In a real app, you might update this via a service
                                },
                                activeColor: AppColors.primaryIndigo,
                              ),
                            ),
                          ]),
                          
                          32.height(context),
                          _buildSectionTitle('Legal & Support'),
                          _buildSettingsGroup([
                            _buildSettingsTile(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              onTap: widget.onNavigateToPrivacy,
                            ),
                            const Divider(height: 1, indent: 56),
                            _buildSettingsTile(
                              icon: Icons.description_outlined,
                              title: 'Terms & Conditions',
                              onTap: widget.onNavigateToTerms,
                            ),
                            const Divider(height: 1, indent: 56),
                            _buildSettingsTile(
                              icon: Icons.info_outline,
                              title: 'About App',
                              onTap: () => _showAboutDialog(context),
                            ),
                          ]),
                          
                          48.height(context),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: widget.onLogout,
                              icon: const Icon(Icons.logout),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.error,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: 12.roundBorder,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          const Center(
                            child: Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: 16.roundBorder,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryIndigo.withOpacity(0.1),
          borderRadius: 8.radius,
        ),
        child: Icon(icon, color: AppColors.primaryIndigo, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.gray900,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.gray400),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'EvoMeet',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'E',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      children: [
        const Text(
          'Automate your community and corporate event planning with the power of AI.',
          style: TextStyle(color: AppColors.gray600),
        ),
      ],
    );
  }
}
