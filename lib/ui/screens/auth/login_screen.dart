import 'package:empyreal_ai_community_builder_flutter/blocs/login/login_bloc.dart';
import 'package:empyreal_ai_community_builder_flutter/blocs/login/login_event.dart';
import 'package:empyreal_ai_community_builder_flutter/blocs/login/login_state.dart';
import 'package:empyreal_ai_community_builder_flutter/repositories/auth_repository.dart';
import 'package:empyreal_ai_community_builder_flutter/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/buttons/primary_button.dart';


class LoginScreen extends StatelessWidget {
  final Function(String userId, String mobileNo, bool isNewUser) onLoginSuccess;
  final VoidCallback onNavigateToRegister;
  final VoidCallback onNavigateToForgotPassword;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onNavigateToRegister,
    required this.onNavigateToForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(AuthRepository(ApiClient())),
      child: _LoginScreenContent(
        onLoginSuccess: onLoginSuccess,
        onNavigateToRegister: onNavigateToRegister,
        onNavigateToForgotPassword: onNavigateToForgotPassword,
      ),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  final Function(String userId, String mobileNo, bool isNewUser) onLoginSuccess;
  final VoidCallback onNavigateToRegister;
  final VoidCallback onNavigateToForgotPassword;

  const _LoginScreenContent({
    required this.onLoginSuccess,
    required this.onNavigateToRegister,
    required this.onNavigateToForgotPassword,
  });

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _countryCodeController = TextEditingController(text: '+91');
  final _mobileController = TextEditingController();

  @override
  void dispose() {
    _countryCodeController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final fullMobileNo =
          '${_countryCodeController.text.trim()}${_mobileController.text.trim()}';
      context.read<LoginBloc>().add(LoginSubmitted(mobileNo: fullMobileNo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [AppColors.slate900, AppColors.slate800] 
              : [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Hero(
                tag: 'auth_card',
                child: Card(
                  elevation: isDark ? 0 : 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(32),
                    child: BlocListener<LoginBloc, LoginState>(
                      listener: (context, state) {
                        if (state is LoginSuccess) {
                          final fullMobileNo =
                              '${_countryCodeController.text.trim()}${_mobileController.text.trim()}';
                          widget.onLoginSuccess(
                            state.response.data?.userId ?? '',
                            fullMobileNo,
                            state.response.data?.isNewUser ?? false,
                          );
                        } else if (state is LoginFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo
                            Center(
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.secondary],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Title & Subtitle
                            Text(
                              context.tr('auth.welcome_back'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.tr('auth.sign_in_desc'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 40),

                            // Mobile Number field
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: _countryCodeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Code',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _mobileController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 10,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: InputDecoration(
                                      labelText: context.tr('auth.mobile_label'),
                                      prefixIcon: const Icon(Icons.phone_android_outlined, size: 20),
                                      counterText: '',
                                      hintText: '9876543210',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return context.tr('forms.required', arguments: {'field': 'Mobile number'});
                                      }
                                      if (value.length != 10) {
                                        return context.tr('forms.invalid_phone');
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Login button
                            BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                return PrimaryButton(
                                  text: context.tr('auth.send_otp'),
                                  isLoading: state is LoginLoading,
                                  onPressed: _handleLogin,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
