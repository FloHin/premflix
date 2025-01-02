import 'package:bloc/bloc.dart';

import 'api_service.dart';
import 'api/folder_model.dart';

class PremiumizeService extends Cubit<List<FolderModel>> {
  final FolderApiService _apiService;

  PremiumizeService(FolderApiService folderApiService): _apiService = folderApiService, super([]);

  void setup(String authToken) {
    _apiService.setup(authToken);
  }

  Future<void> loadFolders() async {
    try {
      final folders = await _apiService.getFolderList();
      emit(folders);
    } catch (e) {
      emit([]);
      throw Exception('Failed to load folders: $e');
    }
  }
}
