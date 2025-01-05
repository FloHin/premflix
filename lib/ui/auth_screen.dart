import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:premflix/main.dart';
import 'package:premflix/service/auth_service.dart';
import 'package:premflix/service/premiumize_service.dart';

class AuthScreenWidget extends StatefulWidget {
  final GoRouterState state;

  const AuthScreenWidget({super.key, required this.state});

  @override
  State<AuthScreenWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreenWidget> {
  final _authService = sl<AuthService>();
  final _premService = sl<PremiumizeService>();

  String apiKey = "";
  TextEditingController apiKeyController = TextEditingController();

  _AuthScreenState();

  @override
  void initState() {
    super.initState();
    _authService.reload();
  }

  void startAuthentication({String? apiKey}) {
    debugPrint('startAuthentication: ');
    final bool usable = apiKey?.isNotEmpty ?? false;
    if (usable) {
      _authService.authenticate(apiKey!);
    } else {
      // _authService.authenticate(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome!')),
      body: Center(
          child: BlocConsumer<AuthService, AuthState>(
        bloc: _authService,
        listener: (BuildContext context, AuthState state) {
          if (state is AuthAuthenticated || state is AuthLoaded) {
            _premService.setup(authToken: _authService.accessToken!, apiKey: _authService.apiKey!);
            context.goNamed("folders");
          }
        },
        builder: (BuildContext context, AuthState state) {
          final isLoading = state.isLoading;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              (state is AuthAuthenticationError) ? Text(state.message) : const SizedBox(),
              TextField(controller: apiKeyController),
              (!isLoading)
                  ? MaterialButton(
                      onPressed: () {
                        startAuthentication(apiKey: apiKeyController.text);
                      },
                      color: Colors.purple,
                      child: const Text("Connect with your premiumize.me account"),
                    )
                  : const CircularProgressIndicator(),
            ],
          );
        },
      )),
    );
  }
}
