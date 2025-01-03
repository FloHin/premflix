import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:oauth2/oauth2.dart';
import 'package:premflix/main.dart';
import 'package:url_launcher/url_launcher.dart';

final authorizationEndpoint = Uri.parse('https://www.premiumize.me/authorize');
final tokenEndpoint = Uri.parse('https://www.premiumize.me/token');
final redirectUrl = Uri.parse('premiumizeviewer://authenticate');
final credentialsFile = File('~/.myapp/credentials.json');

class AuthService extends Cubit<AuthState> {
  String clientId;
  String clientSecret;
  AuthService({required this.clientId, required this.clientSecret}) : super(AuthNone());

  oauth2.Client? _client;

  late AuthorizationCodeGrant _grant;

  oauth2.Client? get client => _client;

  Future<void> authenticate() async {
    debugPrint('authenticate: ');
    // Simulate authentication process
    await Future.delayed(const Duration(seconds: 1));
    var exists = await credentialsFile.exists();
    debugPrint('authenticate: exists=$exists');

    if (exists) {
      _client = await _existingClient();
      emit(AuthLoaded());
    } else {
      _startAuthentication();
      emit(AuthStep1());
    }
  }

  Future<void> continueAuthentication(Uri redirectUri) async {
    debugPrint('continueAuthentication: $redirectUri');

    try {
      _client = await _grant.handleAuthorizationResponse(redirectUri.queryParameters);
      debugPrint('continueAuthentication: ${_client.toString()}');
      debugPrint('continueAuthentication: ${_client?.credentials.toString()}');

      emit(AuthAuthenticated());
      navigatorKey.currentState?.pushNamed("folders");
    } on Exception catch (e) {
      emit(AuthAuthenticationError(e.toString()));
    }
  }

  Future<void> refreshAuth() async {
    // Simulate refreshing authentication
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthRefreshed());
  }

  Future<oauth2.Client> _existingClient() async {
    var credentials = oauth2.Credentials.fromJson(await credentialsFile.readAsString());
    debugPrint('_existingClient: ');
    return oauth2.Client(credentials, identifier: clientId, secret: clientSecret);
  }

  Future<bool> _startAuthentication() async {
    _grant = oauth2.AuthorizationCodeGrant(clientId, authorizationEndpoint, tokenEndpoint, secret: clientSecret);

    // A URL on the authorization server (authorizationEndpoint with some additional
    // query parameters). Scopes and state can optionally be passed into this method.
    final randStateString = DateTime.timestamp().toString();
    var authorizationUrl = _grant.getAuthorizationUrl(redirectUrl, state:randStateString);
    debugPrint('_startAuthentication: authorizationUrl $authorizationUrl');

    // `redirect` and `listen` are not shown implemented here. See below for the
    // details.
    if (await canLaunchUrl(authorizationUrl)) {
      return await launchUrl(authorizationUrl);
    } else {
      return false;
    }
  }
}

abstract class AuthState {
  bool authenticated = false;

  AuthState(this.authenticated);
}

class AuthNone extends AuthState {
  AuthNone() : super(false);
}

class AuthAuthenticated extends AuthState {
  AuthAuthenticated() : super(true);
}

class AuthLoaded extends AuthState {
  AuthLoaded() : super(true);
}

class AuthStep1 extends AuthState {
  AuthStep1() : super(false);
}

class AuthStep2 extends AuthState {
  AuthStep2() : super(false);
}

class AuthRefreshed extends AuthState {
  AuthRefreshed() : super(true);
}

class AuthAuthenticationError extends AuthState {
  String message;
  AuthAuthenticationError(this.message) : super(false);
}
