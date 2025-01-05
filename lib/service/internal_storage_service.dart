import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class InternalStorageService {
  static Future<File> getFile(String path, {required bool create}) async {
    final Directory directory = await getApplicationCacheDirectory();
    // final Directory directory = Directory("${cacheDir.path}/$appPath");
    final dirExists = await directory.exists();
    if (!dirExists) {
      debugPrint("creating directory $directory ${directory.path}");
      await directory.create();
    }
    final file = File("${directory.path}/$path");
    debugPrint("getFile  ${file.path} create=$create");

    final fileExists = await directory.exists();
    if (create && !fileExists) {
      await file.create();
    }
    return file;
  }
}
