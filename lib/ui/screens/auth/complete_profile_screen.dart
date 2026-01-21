import 'dart:io';
import 'package:empyreal_ai_community_builder_flutter/blocs/complete_profile/complete_profile_bloc.dart';
import 'package:empyreal_ai_community_builder_flutter/blocs/complete_profile/complete_profile_event.dart';
import 'package:empyreal_ai_community_builder_flutter/blocs/complete_profile/complete_profile_state.dart';
import 'package:empyreal_ai_community_builder_flutter/project_helpers.dart';
import 'package:empyreal_ai_community_builder_flutter/repositories/auth_repository.dart';
import 'package:empyreal_ai_community_builder_flutter/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String userId;
  final String token;
  final Function(String name, String profilePic) onProfileCompleted;

  const CompleteProfileScreen({
    super.key,
    required this.userId,
    required this.token,
    required this.onProfileCompleted,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
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
                margin: const EdgeInsets.all(24),
                shape: 16.roundBorder,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(32.0),
                  child: BlocProvider(
                    create: (context) => CompleteProfileBloc(AuthRepository(ApiClient())),
                    child: BlocConsumer<CompleteProfileBloc, CompleteProfileState>(
                      listener: (context, state) {
                        if (state is CompleteProfileSuccess) {
                          widget.onProfileCompleted(
                            state.response.data?.name ?? _nameController.text,
                            state.response.data?.profilePic ?? "",
                          );
                        } else if (state is CompleteProfileFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
                          );
                        }
                      },
                      builder: (context, state) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Complete Your Profile',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray900,
                                ),
                              ),
                              24.height(context),
                              
                              // Profile Picture Picker
                              GestureDetector(
                                onTap: _pickImage,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: AppColors.gray100,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.primaryIndigo, width: 2),
                                        image: _imageFile != null
                                            ? DecorationImage(
                                                image: kIsWeb 
                                                    ? NetworkImage(_imageFile!.path) as ImageProvider
                                                    : FileImage(File(_imageFile!.path)),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: _imageFile == null
                                          ? const Icon(Icons.person, size: 60, color: AppColors.gray400)
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryIndigo,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              32.height(context),
                              
                              // Name Input
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(borderRadius: 12.radius),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              32.height(context),
                              
                              // Save Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state is CompleteProfileLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!.validate()) {
                                            context.read<CompleteProfileBloc>().add(
                                                  ProfileSubmitted(
                                                    userId: widget.userId,
                                                    name: _nameController.text,
                                                    imageFile: _imageFile,
                                                    token: widget.token,
                                                  ),
                                                );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: 12.roundBorder,
                                  ),
                                  child: state is CompleteProfileLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text('Save & Continue'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
