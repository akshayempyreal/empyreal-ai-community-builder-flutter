import 'dart:io';
import 'package:empyreal_ai_community_builder_flutter/blocs/complete_profile/complete_profile_bloc.dart';
import 'package:empyreal_ai_community_builder_flutter/blocs/complete_profile/complete_profile_event.dart';
import 'package:empyreal_ai_community_builder_flutter/blocs/complete_profile/complete_profile_state.dart';
import 'package:empyreal_ai_community_builder_flutter/models/user.dart';
import 'package:empyreal_ai_community_builder_flutter/project_helpers.dart';
import 'package:empyreal_ai_community_builder_flutter/repositories/auth_repository.dart';
import 'package:empyreal_ai_community_builder_flutter/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  final String token;
  final Function(String name, String profilePic) onProfileUpdated;
  final VoidCallback onBack;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.token,
    required this.onProfileUpdated,
    required this.onBack,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
                          widget.onProfileUpdated(
                            state.response.data?.name ?? _nameController.text,
                            state.response.data?.profilePic ?? widget.user.profilePic ?? "",
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
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: widget.onBack,
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gray900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              24.height(context),
                              
                              // Profile Picture Picker
                              GestureDetector(
                                onTap: _pickImage,
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundColor: AppTheme.primaryIndigo,
                                      child: CircleAvatar(
                                        radius: 58,
                                        backgroundColor: AppTheme.gray100,
                                        backgroundImage: _imageFile != null
                                            ? (kIsWeb
                                                ? NetworkImage(_imageFile!.path) as ImageProvider
                                                : FileImage(File(_imageFile!.path)))
                                            : (widget.user.profilePic != null && widget.user.profilePic!.isNotEmpty)
                                                ? NetworkImage(widget.user.profilePic!.fixImageUrl)
                                                : null,
                                        onBackgroundImageError: (exception, stackTrace) {
                                          debugPrint('Error loading profile image: $exception');
                                        },
                                        child: (_imageFile == null && (widget.user.profilePic == null || widget.user.profilePic!.isEmpty))
                                            ? const Icon(Icons.person, size: 60, color: AppTheme.gray400)
                                            : null,
                                      ),
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
                              
                              // Update Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state is CompleteProfileLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!.validate()) {
                                            context.read<CompleteProfileBloc>().add(
                                                  ProfileSubmitted(
                                                    userId: widget.user.id,
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
                                      : const Text('Update Profile'),
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
