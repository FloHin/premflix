import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:premflix/api/folder_model.dart';
import 'package:premflix/api_service.dart';

class PremiumizeService extends Cubit<List<FolderModel>> {
  final FolderApiService _apiService;

  PremiumizeService(FolderApiService folderApiService)
      : _apiService = folderApiService,
        super([]);

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
