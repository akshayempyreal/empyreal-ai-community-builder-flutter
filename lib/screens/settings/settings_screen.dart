import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../project_helpers.dart';

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryIndigo, AppTheme.primaryPurple],
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
                                activeColor: AppTheme.primaryIndigo,
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
                                foregroundColor: AppTheme.red500,
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
          color: AppTheme.primaryIndigo.withOpacity(0.1),
          borderRadius: 8.radius,
        ),
        child: Icon(icon, color: AppTheme.primaryIndigo, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.gray900,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.gray400),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Empyreal AI Event Builder',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryIndigo, AppTheme.primaryPurple],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.calendar_today, color: Colors.white, size: 24),
      ),
      children: [
        const Text(
          'Automate your community and corporate event planning with the power of AI.',
          style: TextStyle(color: AppTheme.gray600),
        ),
      ],
    );
  }
}
