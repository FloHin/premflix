import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:premflix/api_service.dart';
import 'package:premflix/service/auth_service.dart';
import 'package:premflix/service/premiumize_service.dart';
import 'package:premflix/ui/auth_screen.dart';
import 'package:premflix/ui/folder_viewer_screen.dart';
import 'package:premflix/ui/main_app.dart';
import 'package:protocol_handler/protocol_handler.dart';
// import 'package:protocol_handler/protocol_handler.dart';

final GetIt sl = GetIt.instance;
final navigatorKey = GlobalKey<NavigatorState>();
const kWindowsScheme = 'premiumizeviewer';

void setupLocator({
  required clientId,
  required clientSecret,
}) {
  final folderApiService = FolderApiService(apiKey: "");
  // var goRouter = createRouter();
  // sl.registerSingleton<GoRouter>(goRouter);
  sl.registerLazySingleton<AuthService>(() => AuthService(clientId: clientId, clientSecret: clientSecret));
  sl.registerLazySingleton<FolderApiService>(() => folderApiService);
  sl.registerFactory<PremiumizeService>(() => PremiumizeService(folderApiService));
}

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/auth',
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => AuthScreenWidget(state: state),
      ),
      GoRoute(
        path: '/folders',
        name: 'folders',
        builder: (context, state) => const FolderViewerScreen(),
      ),
    ],
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env", mergeWith: Platform.environment, isOptional: true);

  final clientId = dotenv.env['CLIENT_ID'] ?? '';
  final clientSecret = dotenv.env['CLIENT_SECRET'] ?? '';

  setupLocator(
    clientId: clientId,
    clientSecret: clientSecret,
  );
  // var client = await createClient();

  await protocolHandler.register(kWindowsScheme);

  runApp(const MainApp());
}
