class LoginRequest {
  final String mobileNo;
  final String deviceType;
  final String deviceToken;

  LoginRequest({
    required this.mobileNo,
    this.deviceType = 'Web',
    this.deviceToken = '',
  });

  Map<String, dynamic> toJson() => {
        'mobileNo': mobileNo,
        'deviceType': deviceType,
        'deviceToken': deviceToken,
      };
}

class LoginResponse {
  final bool status;
  final String message;
  final LoginData? data;

  LoginResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }
}

class LoginData {
  final bool isNewUser;
  final String userId;

  LoginData({
    required this.isNewUser,
    required this.userId,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      isNewUser: json['isNewUser'] ?? false,
      userId: json['userId'] ?? '',
    );
  }
}

class VerifyOtpRequest {
  final String userId;
  final String otp;

  VerifyOtpRequest({
    required this.userId,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'otp': otp,
      };
}

class VerifyOtpResponse {
  final bool status;
  final String message;
  final VerifyOtpData? data;

  VerifyOtpResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? VerifyOtpData.fromJson(json['data']) : null,
    );
  }
}

class VerifyOtpData {
  final UserModel? user;
  final String? token;

  VerifyOtpData({this.user, this.token});

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      token: json['token'],
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String? email;
  final String mobileNo;
  final String profilePic;
  final String deviceType;
  final String? deviceToken;
  final bool status;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    required this.mobileNo,
    required this.profilePic,
    required this.deviceType,
    this.deviceToken,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      mobileNo: json['mobileNo'] ?? '',
      profilePic: json['profilePic'] ?? '',
      deviceType: json['deviceType'] ?? '',
      deviceToken: json['deviceToken'],
      status: json['status'] ?? false,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class FileUploadResponse {
  final bool status;
  final String message;
  final List<FileUploadData>? data;

  FileUploadResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? (json['data'] as List).map((i) => FileUploadData.fromJson(i)).toList() 
          : null,
    );
  }
}

class FileUploadData {
  final String name;
  final String url;

  FileUploadData({required this.name, required this.url});

  factory FileUploadData.fromJson(Map<String, dynamic> json) {
    return FileUploadData(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class UpdateProfileResponse {
  final bool status;
  final String message;
  final UpdateProfileData? data;

  UpdateProfileResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UpdateProfileData.fromJson(json['data']) : null,
    );
  }
}

class UpdateProfileData {
  final String name;
  final String profilePic;

  UpdateProfileData({required this.name, required this.profilePic});

  factory UpdateProfileData.fromJson(Map<String, dynamic> json) {
    return UpdateProfileData(
      name: json['name'] ?? '',
      profilePic: json['profilePic'] ?? '',
    );
  }
}

class ProfileResponse {
  final bool status;
  final String message;
  final UserModel? data;

  ProfileResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserModel.fromJson(json['data']) : null,
    );
  }
}
