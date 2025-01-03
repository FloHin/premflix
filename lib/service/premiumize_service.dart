import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:premflix/api/folder_response.dart';
import 'package:premflix/api/premiumize_api.dart';

import '../api/content.dart';

class PremiumizeService extends Cubit<FolderState> {
  final PremiumizeApi _api;

  List<Content>? _folderList;
  Map<String, List<Content>> folderFilesMap = {};

  PremiumizeService(PremiumizeApi api)
      : _api = api,
        super(FolderNone());

  void setup({required String authToken, required String apiKey}) {
    _api.setup(authToken: authToken, apiKey: apiKey);
  }

  Future<void> loadIndex() async {
    if (_folderList != null) {
      emit(FolderIndex(_folderList!));
    }
    try {
      final folders = await _api.getFolderList(null);
      final List<Content> items = folders.content ?? [];
      _folderList = [];
      folderFilesMap["root"] = [];

      // Separate folders and files
      for (var item in items) {
        if (item.type == 'folder') {
          // Collect all folders
          _folderList!.add(item);
          folderFilesMap[item.id] = [];
        } else {
          folderFilesMap["root"]!.add(item); // Add file to the corresponding folder
        }
      }
      emit(FolderIndex(_folderList!));
    } catch (e, s) {
      emit(FolderLoadError(e.toString()));
      debugPrintStack(stackTrace: s);
      throw Exception('Failed to load folders: $e');
    }
  }

  Future<void> loadFolder(String id) async {
    try {
      final folderContent = await _api.getFolderList(id);
      final List<Content> items = folderContent.content ?? [];

      folderFilesMap[id] = [];

      // Separate folders and files
      for (var item in items) {
        if (item.type == 'folder') {
          // ignore
        } else {
          folderFilesMap[id]!.add(item); // Add file to the corresponding folder
        }
      }
      emit(FolderLoaded(_folderList!, folderContent));
    } catch (e, s) {
      emit(FolderLoadError(e.toString()));
      debugPrintStack(stackTrace: s);
      throw Exception('Failed to load folders: $e');
    }
  }

  bool streamFile(Content item) {
    debugPrint("streamFile item (${item.name}): link=${item.link} streamLink=${item.streamLink} directlink=${item.directlink}");
    final bestLink = item.streamLink ?? item.link ?? item.directlink;
    if (bestLink == null) {
      return false;
    }
    final link = "https://www.premiumize.me/play.xspf?location=${bestLink}";
    OpenFile.open(link);
    return true;
  }

  // void openFile(Content item) {
  //   debugPrint("open item: ${item.toString()}");
  //   final link = "https://www.premiumize.me/play.xspf?location=${item.streamLink}";
  //   OpenFile.open(link);
  // }
}

abstract class FolderState {
  List<Content> folders;

  FolderState(this.folders);
}

class FolderNone extends FolderState {
  FolderNone() : super([]);
}

class FolderIndex extends FolderState {
  FolderIndex(super.folders);
}

class FolderLoaded extends FolderState {
  FolderResponse folderResponse;

  FolderLoaded(super.folders, this.folderResponse);
}

class FolderLoadError extends FolderState {
  String message;

  FolderLoadError(this.message) : super([]);
}
