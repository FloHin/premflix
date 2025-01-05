import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:premflix/main.dart';
import 'package:premflix/service/auth_service.dart';
import 'package:premflix/ui/folder_viewer/folder_viewer_screen.dart';
import 'package:window_manager/window_manager.dart';

import 'auth_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WindowListener {
  final _authService = sl<AuthService>();

  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((uri) {
      debugPrint('_MainAppState uriLinkStream: $uri');
      if (uri.scheme == kWindowsScheme) {
        // Handle the OAuth redirect here
        final code = uri.queryParameters['code'];
        if (code != null) {
          // Complete the OAuth grant with the received code
          debugPrint('Received OAuth code: $code');
        }
        _authService.continueAuthentication(uri);
      }
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/auth',
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => AuthScreenWidget(state: state),
        ),
        GoRoute(
          path: '/authenticate',
          builder: (context, state) => AuthScreenWidget(state: state),
        ),
        GoRoute(
          path: '/folders',
          name: 'folders',
          builder: (context, state) => const FolderViewerScreen(),
        ),
      ],
    );
    return MaterialApp.router(
      title: 'Premiumize Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }

  @override
  void onWindowClose() {
    debugPrint("onWindowClose run writeToStorage");
    debugPrint("onWindowClose run writeToStorage: DONE");
  }
}

class AppColors {
  static Color primary = const Color.fromARGB(255, 159, 138, 241);
  static Color primaryDark = const Color.fromARGB(255, 68, 57, 113);
  static Color primaryLight = const Color.fromARGB(255, 186, 168, 251);
  static Color secondary = const Color.fromARGB(255, 147, 237, 204);
  static Color secondaryDark = const Color.fromARGB(255, 66, 120, 101);
  static Color secondaryAccent = const Color.fromARGB(255, 47, 154, 116);
  static Color yellow = const Color.fromARGB(255, 218, 198, 74);
  static Color lightGrey = const Color.fromARGB(255, 184, 184, 184);
  static Color darkGrey = const Color.fromARGB(255, 115, 115, 115);
}
