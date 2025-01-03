import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/src/state.dart';
import 'package:premflix/main.dart';
import 'package:premflix/service/auth_service.dart';

class AuthScreenWidget extends StatefulWidget {
  final GoRouterState state;
  const AuthScreenWidget({super.key, required this.state});

  @override
  State<AuthScreenWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreenWidget> {
  final _authService = sl<AuthService>();

  _AuthScreenState();

  bool isLoading = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
  }

  void startAuthentication() {
    debugPrint('startAuthentication: ');
    _authService.authenticate();
    setState(() {
      isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return defaultScreen();
  }

  Widget defaultScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Default Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            (!isLoading) ?
            MaterialButton(
              child: const Text("Connect with your premiumize.me account"),
              onPressed: () {
                startAuthentication();
              },
            ) : const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
