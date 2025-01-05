import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

import 'internal_storage_service.dart';

final authorizationEndpoint = Uri.parse('https://www.premiumize.me/authorize');
final tokenEndpoint = Uri.parse('https://www.premiumize.me/token');
final redirectUrl = Uri.parse('premiumizeviewer://authenticate');
const credentialsFilePath = 'credentials.json';
const apiKeyPath = 'apiKey.txt';

class AuthService extends Cubit<AuthState> {
  String clientId;
  String clientSecret;

  AuthService({required this.clientId, required this.clientSecret}) : super(AuthNone());

  oauth2.Client? _client;
  String? _accessToken;
  String? _apiKey;

  late oauth2.AuthorizationCodeGrant _grant;

  oauth2.Client? get client => _client;

  String? get accessToken => _accessToken;

  String? get apiKey => _apiKey;

  Future<void> reload() async {
    debugPrint('authenticate: ');
    var hasApiKey = await InternalStorageService.getFile(apiKeyPath, create: false);
    var hasCredentials = await InternalStorageService.getFile(credentialsFilePath, create: false);

    if (await hasApiKey.exists()) {
      var apiKeyFile = await InternalStorageService.getFile(apiKeyPath, create: false);
      debugPrint('authenticate: read from apiKeyFile');
      _apiKey = await apiKeyFile.readAsString();

      if (await hasCredentials.exists()) {
        await Future.delayed(const Duration(milliseconds: 100));
        _client = await _existingClient();
        emit(AuthLoaded());
      } else {
        emit(AuthNone());
      }
    }
  }

  Future<void> authenticate(String apiKey) async {
    debugPrint('authenticate: ');
    // Simulate authentication process

    var hasApiKey = await InternalStorageService.getFile(apiKeyPath, create: false);
    var hasCredentials = await InternalStorageService.getFile(credentialsFilePath, create: false);
    debugPrint('authenticate: exists=$hasCredentials');

    _apiKey = apiKey;
    if (!await hasApiKey.exists()) {
      var apiKeyFile = await InternalStorageService.getFile(apiKeyPath, create: true);
      debugPrint('authenticate: write apiKeyFile');
      apiKeyFile.writeAsString(_apiKey!);
    }
    if (await hasCredentials.exists()) {
      await Future.delayed(const Duration(milliseconds: 100));
      _client = await _existingClient();
      emit(AuthLoaded());
    } else {
      emit(AuthStep1());
      await Future.delayed(const Duration(milliseconds: 200));
      _startAuthentication();
    }
  }

  Future<void> continueAuthentication(Uri redirectUri) async {
    debugPrint('continueAuthentication: $redirectUri');

    try {
      _client = await _grant.handleAuthorizationResponse(redirectUri.queryParameters);
      debugPrint('continueAuthentication: ${_client.toString()}');
      debugPrint('continueAuthentication: ${_client?.credentials.toString()}');
      var contents = _client?.credentials.toJson();
      _accessToken = _client?.credentials.accessToken;
      if (contents != null) {
        debugPrint('write JSON : $contents');
        final credentialsFile = await InternalStorageService.getFile(credentialsFilePath, create: true);
        await credentialsFile.writeAsString(contents, encoding: Encoding.getByName("utf-8")!, flush: true);
        var exists = await credentialsFile.exists();
        debugPrint('authenticate: written=$exists');
      }
      emit(AuthAuthenticated());
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
    final credentialsFile = await InternalStorageService.getFile(credentialsFilePath, create: false);
    var credentials = oauth2.Credentials.fromJson(await credentialsFile.readAsString());
    debugPrint('_existingClient: ');
    _accessToken = credentials.accessToken;
    return oauth2.Client(credentials, identifier: clientId, secret: clientSecret);
  }

  Future<bool> _startAuthentication() async {
    _grant = oauth2.AuthorizationCodeGrant(clientId, authorizationEndpoint, tokenEndpoint, secret: clientSecret);

    // A URL on the authorization server (authorizationEndpoint with some additional
    // query parameters). Scopes and state can optionally be passed into this method.
    final randStateString = DateTime.timestamp().toString();
    var authorizationUrl = _grant.getAuthorizationUrl(redirectUrl, state: randStateString);
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
  bool isLoading = false;

  AuthState(this.authenticated, this.isLoading);
}

class AuthInit extends AuthState {
  AuthInit() : super(false, true);
}

class AuthNone extends AuthState {
  AuthNone() : super(false, false);
}

class AuthAuthenticated extends AuthState {
  AuthAuthenticated() : super(true, false);
}

class AuthLoaded extends AuthState {
  AuthLoaded() : super(true, false);
}

class AuthStep1 extends AuthState {
  AuthStep1() : super(false, true);
}

class AuthStep2 extends AuthState {
  AuthStep2() : super(false, true);
}

class AuthRefreshed extends AuthState {
  AuthRefreshed() : super(true, false);
}

class AuthAuthenticationError extends AuthState {
  String message;

  AuthAuthenticationError(this.message) : super(false, false);
}
