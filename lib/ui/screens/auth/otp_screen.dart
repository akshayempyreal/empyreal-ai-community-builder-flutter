import 'package:empyreal_ai_community_builder_flutter/blocs/otp/otp_bloc.dart';
import 'package:empyreal_ai_community_builder_flutter/blocs/otp/otp_event.dart';
import 'package:empyreal_ai_community_builder_flutter/blocs/otp/otp_state.dart';
import 'package:empyreal_ai_community_builder_flutter/models/auth_models.dart';
import 'package:empyreal_ai_community_builder_flutter/project_helpers.dart';
import 'package:empyreal_ai_community_builder_flutter/repositories/auth_repository.dart';
import 'package:empyreal_ai_community_builder_flutter/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_theme.dart';

class OtpScreen extends StatelessWidget {
  final String userId;
  final String mobileNo;
  final Function(UserModel user, String token) onOtpVerified;
  final VoidCallback onBack;

  const OtpScreen({
    super.key,
    required this.userId,
    required this.mobileNo,
    required this.onOtpVerified,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpBloc(AuthRepository(ApiClient())),
      child: _OtpScreenContent(
        userId: userId,
        mobileNo: mobileNo,
        onOtpVerified: onOtpVerified,
        onBack: onBack,
      ),
    );
  }
}

class _OtpScreenContent extends StatefulWidget {
  final String userId;
  final String mobileNo;
  final Function(UserModel user, String token) onOtpVerified;
  final VoidCallback onBack;

  const _OtpScreenContent({
    required this.userId,
    required this.mobileNo,
    required this.onOtpVerified,
    required this.onBack,
  });

  @override
  State<_OtpScreenContent> createState() => _OtpScreenContentState();
}

class _OtpScreenContentState extends State<_OtpScreenContent> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp(String otp) {
    FocusScope.of(context).unfocus();
    context.read<OtpBloc>().add(OtpSubmitted(userId: widget.userId, otp: otp));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: BlocListener<OtpBloc, OtpState>(
                    listener: (context, state) {
                      if (state is OtpSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.response.message)),
                        );
                        widget.onOtpVerified(
                          state.response.data!.user!,
                          state.response.data!.token ?? '',
                        );
                      } else if (state is OtpFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error), backgroundColor: Colors.red),
                        );
                      } else if (state is OtpResendSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.arrow_back_ios_new, size: 20)
                                .paddingAll(context, 8)
                                .onClick(widget.onBack),
                          ],
                        ),
                        20.height(context),
                        
                        const Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                        ).centerAlign,
                        12.height(context),
                        Text(
                          'Enter the 6-digit code sent to\n${widget.mobileNo}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray600,
                          ),
                        ).centerAlign,
                        40.height(context),
                        
                        // OTP Input Boxes
                        Pinput(
                          length: 6,
                          autofocus: true,
                          controller: _otpController,
                          onCompleted: _verifyOtp,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          defaultPinTheme: PinTheme(
                            width: 50,
                            height: 50,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray900,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: 8.radius,
                              border: Border.all(color: AppColors.gray300),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 50,
                            height: 50,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryIndigo,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: 8.radius,
                              border: Border.all(color: AppColors.primaryIndigo, width: 2),
                            ),
                          ),
                          submittedPinTheme: PinTheme(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: 8.radius,
                              color: AppColors.primaryIndigo.withOpacity(0.05),
                              border: Border.all(color: AppColors.primaryIndigo),
                            ),
                          ),
                        ),
                        40.height(context),
                        
                        // Verify Button
                        BlocBuilder<OtpBloc, OtpState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is OtpLoading ? null : () {
                                String otp = _otpController.text;
                                if (otp.length == 6) {
                                  _verifyOtp(otp);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter 6-digit OTP')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: 12.roundBorder,
                              ),
                              child: state is OtpLoading
                                  ? 20.box(const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ))
                                  : const Text(
                                      'Verify',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                            );
                          },
                        ),
                        24.height(context),
                        
                        // Resend OTP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Didn't receive code? ",
                              style: TextStyle(color: AppColors.gray600),
                            ),
                            const Text(
                              'Resend',
                              style: TextStyle(
                                color: AppColors.primaryIndigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ).onClick(() {
                              context.read<OtpBloc>().add(OtpResendRequested(mobileNo: widget.mobileNo));
                            }),
                          ],
                        ),
                      ],
                    ).paddingAll(context, 32),
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
