import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Conditional import - only import dart:io on non-web platforms
import 'dart:io' if (dart.library.html) 'package:empyreal_ai_community_builder_flutter/core/platform/image_helper_stub.dart' as io;

/// Helper to get ImageProvider for local file or web URL
/// On web, always uses NetworkImage
/// On mobile, uses FileImage for local files
ImageProvider getImageProvider(String path) {
  if (kIsWeb) {
    // On web, path is a URL string (from XFile.path on web)
    return NetworkImage(path) as ImageProvider;
  } else {
    // On mobile, use FileImage with dart:io File
    // The conditional import ensures File is available here
    // We use dynamic cast to handle the type difference between stub and real File
    final file = io.File(path);
    // ignore: argument_type_not_assignable
    return FileImage(file as dynamic) as ImageProvider;
  }
}
