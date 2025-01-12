import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:premflix/api/item.dart';
import 'package:premflix/service/premiumize_service.dart';
import 'package:premflix/ui/folder_viewer/folder_action_bar.dart';
import 'package:premflix/ui/main_app.dart';

import '../../api/folder_response.dart';

class FolderItemWidget extends StatefulWidget {
  final PremiumizeService viewModel;

  const FolderItemWidget(this.viewModel, {super.key});

  @override
  State<FolderItemWidget> createState() => _FolderItemWidgetState();
}

class _FolderItemWidgetState extends State<FolderItemWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PremiumizeService, FolderState>(
      bloc: widget.viewModel,
      builder: (context, state) {
        if (state is FolderLoaded) {
          final items = state.folderResponse.content ?? [];
          final FolderResponse folder = state.folderResponse;
          bool showBar = !(state is SeriesFolderLoaded && state.currentSeason != null);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildNameIcon(state, context, widget.viewModel),
              if (showBar)
                FolderActionBar(
                  folder: folder,
                  onTapHide: (bool value) {
                    if (folder.folderId != null) {
                      widget.viewModel.setHidden(folder.folderId!, value);
                    }
                  },
                  onTapStar: (bool value) {
                    if (folder.folderId != null) {
                      widget.viewModel.setStarred(folder.folderId!, value);
                    }
                  },
                  onTapSeries: (bool value) {
                    if (folder.folderId != null) {
                      widget.viewModel.setSeries(folder.folderId!, value);
                    }
                  },
                ),
              Expanded(
                  child: Material(
                      child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return itemRow(item);
                },
              )))
            ],
          );
        } else {
          return const Center(child: Text('Select a folder'));
        }
      },
    );
  }

  Padding buildNameIcon(FolderLoaded state, BuildContext context, PremiumizeService viewModel) {
    if (state is SeriesFolderLoaded) {
      List<Widget> seasonsWidgets = [];
      state.seasons.forEach((String key, String name) {
        bool isCurrent = state.currentSeason == key;
        Widget widget = MaterialButton(
          onPressed: () {
            viewModel.loadSeason(key);
          },
          color: (isCurrent) ? AppColors.primary : AppColors.secondary,
          child: Text(name),
        );
        seasonsWidgets.add(widget);
      });
      return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.video_collection, size: 32),
                  Text(
                    state.folderResponse.name ?? "",
                    style: Theme.of(context).textTheme.headlineLarge!,
                  )
                ],
              ),
              Row(children: [Text("Seasons:"), ...seasonsWidgets])
            ],
          ));
    } else {
      return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            state.folderResponse.name ?? "",
            style: Theme.of(context).textTheme.headlineLarge!,
          ));
    }
  }

  ListTile itemRow(Item item) {
    Icon typeIcon = Icon(item.getIcon());
    final openedAt = item.config?.openedAt != null;
    String sizeString = "";
    if (item.size != null) {
      sizeString = " - ${(item.size! / 1024).round()} kb";
    }
    String openString = "";
    if (item.config?.openedAt != null) {
      openString = " - ${(item.config?.openedAt)}";
    }
    final subtitle = "${item.type}$sizeString$openString";
    return ListTile(
      isThreeLine: true,
      leading: typeIcon,
      title: Text(item.name),
      subtitle: Text(subtitle),
      tileColor: (openedAt) ? Colors.green[100] : null,
      hoverColor: Colors.blueAccent[100],
      onTap: () {
        setState(() {
          widget.viewModel.streamFile(item);
        });
      },
    );
  }
}
