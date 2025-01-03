import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:premflix/main.dart';
import 'package:premflix/service/auth_service.dart';
import 'package:premflix/ui/folder_viewer_screen.dart';

import 'auth_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _authService = sl<AuthService>();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('_MainAppState uriLinkStream: $uri');
      if (uri.scheme == kWindowsScheme) {
        // Handle the OAuth redirect here
        final code = uri.queryParameters['code'];
        if (code != null) {
          // Complete the OAuth grant with the received code
          print('Received OAuth code: $code');
        }
        _authService.continueAuthentication(uri);
      }
    });
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
