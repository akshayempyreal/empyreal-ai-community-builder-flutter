// Stub file for web platform
// This file is used when dart:io is not available (web platform)
// Note: This is only used for type checking - actual File usage should be guarded by kIsWeb checks

class File {
  final String path;
  const File(this.path);
  
  bool existsSync() => false;
}
