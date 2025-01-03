import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:premflix/api/folder_response.dart';
import 'package:premflix/api/premiumize_api.dart';

class PremiumizeService extends Cubit<FolderState> {
  final PremiumizeApi _api;

  FolderResponse? _cached;

  PremiumizeService(PremiumizeApi api)
      : _api = api,
        super(FolderNone());

  void setup({required String authToken, required String apiKey}) {
    _api.setup(authToken:authToken, apiKey: apiKey);
  }

  Future<void> loadFolders() async {
    if (_cached != null) {
      emit(FolderLoaded(_cached!));
    }
    try {
      final folders = await _api.getFolderList();
      _cached = folders;
      emit(FolderLoaded(folders));
    } catch (e,s) {
      emit(FolderLoadError(e.toString()));
      debugPrintStack(stackTrace: s);
      throw Exception('Failed to load folders: $e');
    }
  }
}

abstract class FolderState {
  FolderState();
}

class FolderNone extends FolderState {
  FolderNone() : super();
}

class FolderLoaded extends FolderState {
  FolderResponse folderResponse;
  FolderLoaded(this.folderResponse) : super();
}

class FolderLoadError extends FolderState {
  String message;
  FolderLoadError(this.message);
}
