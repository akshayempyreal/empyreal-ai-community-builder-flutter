// Stub file for web platform
// This file is imported when dart:io is not available (web platform)
// Provides a File class stub that matches dart:io's File interface for type checking

class File {
  final String path;
  const File(this.path);
  
  bool existsSync() => false;
}
