import 'package:dio/dio.dart';

import 'api/folder_model.dart';

class FolderApiService {
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

  FolderApiService({required String apiKey});

  void setup(String authToken) {
    _dio.options.headers['Authorization'] = 'Bearer ' + authToken;
  }

  Future<List<FolderModel>> getFolderList() async {
    final response = await _dio.get('/api/folder/list');
    return (response.data as List).map((item) => FolderModel.fromJson(item)).toList();
  }
}
