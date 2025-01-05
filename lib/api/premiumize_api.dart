import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'folder_response.dart';

class PremiumizeApi {
  static var uri = "https://www.premiumize.me/";
  static BaseOptions options = BaseOptions(
      baseUrl: uri,
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      // ignore: missing_return
      validateStatus: (code) {
        if (code != null && code >= 200) {
          return true;
        }
        return false;
      });
  final Dio _dio = Dio(options);

  PremiumizeApi({required String apiKey});

  String? _accessToken;
  String? _apiKey;

  void setup({required String authToken, required String apiKey}) {
    _accessToken = authToken;
    _apiKey = apiKey;
  }

  Future<FolderResponse> getFolderList(String? id) async {
    final params = buildParams();
    if (id != null) {
      params["id"] = id;
    }
    try {
      final response = await _dio.get('/api/folder/list', queryParameters: params);
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      if (response.statusCode == 200 && data != null) {
        FolderResponse folderResponse = FolderResponse.fromJson(data);
        if (id != null) {
          folderResponse.folderId = id;
        } // Parse response
        return folderResponse;
      } else {
        throw Exception('Failed to load folders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching folder list: $e');
      rethrow; // Forward the exception
    }
  }

  buildParams() {
    return {
      "apikey": _apiKey,
      "access_token": _accessToken,
    };
  }
}
