import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_theme.dart';
import '../../project_helpers.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../repositories/auth_repository.dart';
import '../../services/api_client.dart';
import '../../models/auth_models.dart';

class ProfileScreen extends StatelessWidget {
  final String token;
  final VoidCallback onBack;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.token,
    required this.onBack,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(AuthRepository(ApiClient()))..add(ProfileFetched(token)),
      child: _ProfileScreenContent(token: token, onBack: onBack, onLogout: onLogout),
    );
  }
}

class _ProfileScreenContent extends StatelessWidget {
  final String token;
  final VoidCallback onBack;
  final VoidCallback onLogout;

  const _ProfileScreenContent({
    required this.token,
    required this.onBack,
    required this.onLogout,
  });

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
                        .onClick(onBack),
                    const Spacer(),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.logout, color: Colors.white, size: 24)
                        .paddingAll(context, 8)
                        .onClick(onLogout),
                  ],
                ),
              ),
              
              Expanded(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileLoading) {
                      return const CircularProgressIndicator(color: Colors.white).centerAlign;
                    } else if (state is ProfileSuccess) {
                      final user = state.user;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Profile Image
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                image: DecorationImage(
                                  image: NetworkImage(user.profilePic.isNotEmpty 
                                    ? user.profilePic.fixImageUrl 
                                    : 'https://via.placeholder.com/150'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            24.height(context),
                            
                            // User Name
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            4.height(context),
                            Text(
                              user.mobileNo,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            32.height(context),
                            
                            // Info Card
                            Card(
                              elevation: 8,
                              shape: 16.roundBorder,
                              child: Column(
                                children: [
                                  _buildInfoRow(context, Icons.phone_android_outlined, 'Mobile', user.mobileNo),
                                  // const Divider(),
                                  // _buildInfoRow(context, Icons.devices_outlined, 'Device', user.deviceType),
                                  const Divider(),
                                  _buildInfoRow(context, Icons.calendar_today_outlined, 'Joined', 
                                    user.createdAt?.substring(0, 10) ?? 'N/A'),
                                ],
                              ).paddingAll(context, 16),
                            ),
                          ],
                        ),
                      );
                    } else if (state is ProfileFailure) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white, size: 64),
                          16.height(context),
                          Text(state.error, style: const TextStyle(color: Colors.white)),
                          24.height(context),
                          ElevatedButton(
                            onPressed: () => context.read<ProfileBloc>().add(ProfileFetched(token)),
                            child: const Text('Retry'),
                          ),
                        ],
                      ).centerAlign;
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryIndigo.withOpacity(0.1),
            borderRadius: 8.radius,
          ),
          child: Icon(icon, color: AppTheme.primaryIndigo, size: 20),
        ),
        16.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.gray500)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.gray900)),
          ],
        ),
      ],
    ).paddingVertical(context, 8);
  }
}
