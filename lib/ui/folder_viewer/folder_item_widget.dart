import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:premflix/api/item.dart';
import 'package:premflix/service/premiumize_service.dart';
import 'package:premflix/ui/folder_viewer/folder_action_bar.dart';

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.folderResponse.name ?? "",
                    style: Theme.of(context).textTheme.headlineLarge!,
                  )),
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
