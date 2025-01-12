import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:premflix/api/folder_response.dart';
import 'package:premflix/api/item.dart';
import 'package:premflix/api/premiumize_api.dart';
import 'package:premflix/service/internal_storage_service.dart';
import 'package:premflix/service/item_config.dart';

const cacheFilePath = "foldersCache.json";
const seasonPrefix = "SEASON-";
final seriesRegex = RegExp(r's[0-9]{1,2}e[0-9]{1,3}', caseSensitive: false);

class PremiumizeService extends Cubit<FolderState> {
  final PremiumizeApi _api;

  Map<String, Item>? _indexFolderMap;

  // Map<String, List<Item>> _folderFilesMap = {};
  final Map<String, FolderResponse> _responseMap = {};
  final Map<String, Map<String, String>> _seriesFolderMap = {};
  final Map<String, ItemConfig> _itemConfig = {};

  bool _showStarredOnly = false;
  bool _showHidden = false;
  String? currentFolderId;

  PremiumizeService(PremiumizeApi api)
      : _api = api,
        super(FolderNone());

  void setup({required String authToken, required String apiKey}) {
    _api.setup(authToken: authToken, apiKey: apiKey);
  }

  List<Item> _filterCurrent(Iterable<Item> items) {
    return items.where((Item item) {
      final hidden = item.config?.hidden ?? false;
      final starred = item.config?.starred ?? false;
      if (!_showHidden && hidden) return false;
      if (_showStarredOnly && !starred) return false;
      return true;
    }).toList();
  }

  Future<void> loadIndex() async {
    if (_indexFolderMap != null) {
      debugPrint("loadIndex returns _folderList from cache");
      emit(FolderIndex(_filterCurrent(_indexFolderMap!.values)));
      return;
    }
    try {
      await readFromStorage();

      final folders = await _api.getFolderList(null);
      final List<Item> items = folders.content ?? [];
      _indexFolderMap = {};
      for (var item in items) {
        if (item.type == 'folder') {
          item.config = _getOrCreateItemConfig(item.id);
          _indexFolderMap![item.id] = item;
        }
      }
      debugPrint("loadIndex returns _folderList from api: ${_indexFolderMap?.length}");
      emit(FolderIndex(_filterCurrent(_indexFolderMap!.values)));
    } catch (e, s) {
      emit(FolderLoadError(e.toString()));
      debugPrintStack(stackTrace: s);
      throw Exception('Failed to load folders: $e');
    }
  }

  Future<void> loadFolder(String folderId) async {
    if (_responseMap[folderId] != null) {
      debugPrint("loadFolder returns folderFilesMap[id=$folderId] from cache");
      var folderContent = _responseMap[folderId]!;
      if (folderContent.config?.series ?? false) {
        buildSeriesMap(folderContent);
        final seasons = _seriesFolderMap[folderId] ?? {};
        emit(SeriesFolderLoaded(_filterCurrent(_indexFolderMap!.values), folderContent, seasons, null));
      } else {
        emit(FolderLoaded(_filterCurrent(_indexFolderMap!.values), folderContent));
      }
      return;
    }

    try {
      FolderResponse folderResponse = await _api.getFolderList(folderId);
      _responseMap[folderId] = folderResponse;
      enrichAndEmit(folderId);
    } catch (e, s) {
      emit(FolderLoadError(e.toString()));
      debugPrintStack(stackTrace: s);
      throw Exception('Failed to load folders: $e');
    }
  }

  Future<void> loadSeason(String id) async {
    final season = _responseMap[id];
    if (season == null) {
      debugPrint("loadSeason returns season == null");
      return;
    }
    final parent = _responseMap[season.parentId!];
    if (parent == null) {
      debugPrint("loadSeason returns parent == null");
      return;
    }
    final seasonMap = _seriesFolderMap[parent.folderId];
    if (seasonMap == null) {
      debugPrint("loadSeason returns seasonMap == null");
      return;
    }
    emit(SeriesFolderLoaded(_filterCurrent(_indexFolderMap!.values), season, seasonMap, id));
  }

  ItemConfig _getOrCreateItemConfig(String id) {
    if (!_itemConfig.containsKey(id)) {
      _itemConfig[id] = ItemConfig(id);
    }
    return _itemConfig[id]!;
  }

  void filterStarredOnly(bool value) {
    debugPrint("filterStarredOnly $value");
    _showStarredOnly = value;
    emit(FolderIndex(_filterCurrent(_indexFolderMap!.values)));
  }

  void filterHidden(bool value) {
    debugPrint("filterHidden $value");
    _showHidden = value;
    emit(FolderIndex(_filterCurrent(_indexFolderMap!.values)));
  }

  bool streamFile(Item item) {
    debugPrint("streamFile item (${item.id} ${item.name}): link=${item.link} streamLink=${item.streamLink} directlink=${item.directlink}");
    final bestLink = item.streamLink ?? item.link ?? item.directlink;
    if (bestLink == null) {
      return false;
    }
    final link = "https://www.premiumize.me/play.xspf?location=$bestLink";
    OpenFile.open(link);
    ItemConfig config = _getOrCreateItemConfig(item.id);
    _itemConfig[item.id] = config.copyWith(openedAt: DateTime.timestamp());
    if (item.folderId != null) {
      enrichAndEmit(item.folderId!);
    }

    return true;
  }

  void setHidden(String folderId, bool value) {
    debugPrint("setHidden $folderId $value");
    ItemConfig config = _getOrCreateItemConfig(folderId);
    _itemConfig[folderId] = config.copyWith(hidden: value);
    enrichAndEmit(folderId);
  }

  void setStarred(String folderId, bool value) {
    debugPrint("setStarred $folderId $value");
    ItemConfig config = _getOrCreateItemConfig(folderId);
    _itemConfig[folderId] = config.copyWith(starred: value);
    enrichAndEmit(folderId);
  }

  void setSeries(String folderId, bool value) {
    debugPrint("setSeries $folderId $value");
    ItemConfig config = _getOrCreateItemConfig(folderId);
    _itemConfig[folderId] = config.copyWith(series: true);
    enrichAndEmit(folderId);
  }

  void enrichAndEmit(String folderId) {
    FolderResponse folderContent = _responseMap[folderId]!;
    var itemConfig = _getOrCreateItemConfig(folderId);
    folderContent.config = itemConfig;
    folderContent.folderId = folderId;
    folderContent.content?.forEach((item) {
      item.config = _getOrCreateItemConfig(item.id);
      item.folderId = folderId;
    });

    _responseMap[folderId] = folderContent;
    _indexFolderMap![folderId] = _indexFolderMap![folderId]!..config = itemConfig;

    if (folderContent.config?.series ?? false) {
      buildSeriesMap(folderContent);
      final seasons = _seriesFolderMap[folderId] ?? {};
      emit(SeriesFolderLoaded(_filterCurrent(_indexFolderMap!.values), folderContent, seasons, null));
    } else {
      emit(FolderLoaded(_filterCurrent(_indexFolderMap!.values), folderContent));
    }
    writeToStorage();
  }

  Future<void> readFromStorage() async {
    try {
      var cacheFile = await InternalStorageService.getFile(cacheFilePath, create: false);
      if (await cacheFile.exists()) {
        final contents = await cacheFile.readAsString();
        var jsonDecode2 = jsonDecode(contents);
        Map<String, dynamic> jsonMap = jsonDecode2 as Map<String, dynamic>;
        jsonMap.forEach((k, v) {
          _itemConfig[k] = ItemConfig.fromJson(v);
        });
        debugPrint("readFromStorage reloads ${_itemConfig.length} elements");
      }
    } on Exception catch (e) {
      debugPrint("readFromStorage failed: $e");
    }
  }

  Future<void> writeToStorage() async {
    debugPrint("writeToStorage writes: ${_itemConfig.length} ");
    var cacheFile = await InternalStorageService.getFile(cacheFilePath, create: true);
    final json = jsonEncode(_itemConfig);
    cacheFile.writeAsString(json);
    debugPrint("writeToStorage writes ${_itemConfig.length} elements");
  }

  /// Scan all items of folder and create virtual subfolders for seasons.
  /// Store seasons in the series map with a newly created FolderContent for the season.
  void buildSeriesMap(FolderResponse folderContent) {
    // 1. get seasons
    final Map<String, FolderResponse> seasonsFolderMap = {};
    final Map<String, String> seasonsNamesMap = {};

    var folderId = folderContent.folderId ?? 'folderId';

    for (Item item in folderContent.content ?? []) {
      String name = item.name;
      if (seriesRegex.hasMatch(name)) {
        final match = seriesRegex.firstMatch(name);
        final matchedText = match?.group(0)?.toLowerCase();
        if (matchedText != null) {
          final seasonKey = matchedText.substring(0, matchedText.indexOf("e")).toUpperCase();
          final seriesSeasonFolderKey = "$seasonPrefix$folderId-$seasonKey";
          if (_responseMap.containsKey(seriesSeasonFolderKey)) {
            continue;
          }
          FolderResponse seasonFolder;
          if (!seasonsFolderMap.containsKey(seriesSeasonFolderKey)) {
            seasonFolder = FolderResponse(
              status: "",
              content: [],
              breadcrumbs: [],
              name: "${folderContent.name ?? ''} $seasonKey".trim(),
              parentId: folderContent.folderId,
              folderId: seriesSeasonFolderKey,
            );
          } else {
            seasonFolder = seasonsFolderMap[seriesSeasonFolderKey]!;
          }

          seasonsFolderMap[seriesSeasonFolderKey] = seasonFolder;
          seasonsNamesMap[seriesSeasonFolderKey] = seasonKey;
          seasonFolder.content?.add(item);
        }
      }
    }

    if (seasonsFolderMap.isNotEmpty) {
      seasonsFolderMap.forEach((String key, FolderResponse value) {
        _responseMap[key] = value;
      });
      _seriesFolderMap[folderId] = seasonsNamesMap;
    }
  }

// void openFile(Content item) {
//   debugPrint("open item: ${item.toString()}");
//   final link = "https://www.premiumize.me/play.xspf?location=${item.streamLink}";
//   OpenFile.open(link);
// }
}

abstract class FolderState {
  List<Item> folders;

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

class SeriesFolderLoaded extends FolderLoaded {
  Map<String, String> seasons;
  String? currentSeason;

  SeriesFolderLoaded(super.folders, super.folderResponse, this.seasons, this.currentSeason);
}

class FolderLoadError extends FolderState {
  String message;

  FolderLoadError(this.message) : super([]);
}
