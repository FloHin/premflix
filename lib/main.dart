import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:premflix/ui/main_app.dart';

import 'api_service.dart';
import 'premiumize_service.dart';

final GetIt sl = GetIt.instance;

void setupLocator() {
  final folderApiService = FolderApiService(apiKey: "");

  sl.registerLazySingleton<FolderApiService>(() => folderApiService);
  sl.registerFactory<PremiumizeService>(() => PremiumizeService(folderApiService));
}

void main() {
  setupLocator();
  runApp(const MainApp());
}
