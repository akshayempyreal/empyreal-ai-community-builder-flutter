import 'package:empyreal_ai_community_builder_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../project_helpers.dart';
import '../../blocs/login/login_bloc.dart';
import '../../blocs/login/login_event.dart';
import '../../blocs/login/login_state.dart';
import '../../repositories/auth_repository.dart';
import '../../services/api_client.dart';

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
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final fullMobileNo =
          '${_countryCodeController.text.trim()}${_mobileController.text.trim()}';
      context.read<LoginBloc>().add(LoginSubmitted(mobileNo: fullMobileNo));
    }
  }

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
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                shape: 16.roundBorder,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: BlocListener<LoginBloc, LoginState>(
                    listener: (context, state) {
                      if (state is LoginSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.response.message)),
                        );
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
                            backgroundColor: Colors.red,
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
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryIndigo,
                                  AppColors.primaryPurple,
                                ],
                              ),
                              borderRadius: 16.radius,
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 32,
                            ),
                          ).centerAlign,
                          24.height(context),

                          // Title
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray900,
                            ),
                          ).centerAlign,
                          8.height(context),
                          const Text(
                            'Sign in with your mobile number',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray600,
                            ),
                          ).centerAlign,
                          32.height(context),

                          // Mobile Number field
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Country Code
                              SizedBox(
                                width: 70,
                                child: TextFormField(
                                  readOnly: true,
                                  controller: _countryCodeController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    // labelText: 'Code',
                                    hintText: '+91',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Req';
                                    }
                                    if (!value.startsWith('+')) {
                                      return '+';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              4.width,
                              // Mobile Number
                              Expanded(
                                child: TextFormField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.number,
                                  // number keyboard
                                  maxLength: 10,
                                  // limit to 10 digits
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    // allow digits only
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Mobile Number',
                                    prefixIcon: Icon(
                                      Icons.phone_android_outlined,
                                      size: 18,
                                    ),
                                    hintText: '9876543210',
                                    counterText: '', // hides 0/10 counter
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter mobile number';
                                    }
                                    if (value.length != 10) {
                                      return 'Mobile number must be 10 digits';
                                    }
                                    // Indian mobile number starts with 6–9
                                    return null;
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          24.height(context),

                          // Login button
                          BlocBuilder<LoginBloc, LoginState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state is LoginLoading
                                    ? null
                                    : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: state is LoginLoading
                                    ? 20.box(
                                        const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Send OTP',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              );
                            },
                          ),
                          16.height(context),

                          // Register link
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     const Text(
                          //       "Don't have an account? ",
                          //       style: TextStyle(color: AppTheme.gray600),
                          //     ),
                          //     const Text(
                          //       'Sign up',
                          //       style: TextStyle(
                          //         color: AppTheme.primaryIndigo,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ).onClick(widget.onNavigateToRegister),
                          //   ],
                          // ),
                        ],
                      ).paddingAll(context, 32),
                    ),
                  ),
                ),
              ).paddingAll(context, 24),
            ),
          ),
        ),
      ),
    );
  }
}
