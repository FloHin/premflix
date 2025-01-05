import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:premflix/main.dart';
import 'package:premflix/service/premiumize_service.dart';
import 'package:premflix/ui/folder_viewer/view_options_bar.dart';

import 'folder_item_widget.dart';

class FolderViewerScreen extends StatefulWidget {
  const FolderViewerScreen({super.key});

  @override
  State<FolderViewerScreen> createState() => _FolderViewerScreenState();
}

class _FolderViewerScreenState extends State<FolderViewerScreen> {
  final PremiumizeService _viewModel = sl<PremiumizeService>();

  @override
  void initState() {
    super.initState();
    _viewModel.loadIndex();
  }

  @override
  void dispose() {
    debugPrint("FolderViewerScreen onDispose ");
    _viewModel.writeToStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folder Viewer')),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: BlocBuilder<PremiumizeService, FolderState>(
              bloc: _viewModel,
              builder: (context, state) {
                if (state is FolderLoaded || state is FolderIndex) {
                  final contents = state.folders;
                  return Container(
                    color: Colors.blueAccent[50],
                    child: Column(
                      children: [
                        ViewOptionsBar(
                          onTapShowHidden: (bool value) {
                            _viewModel.filterHidden(value);
                          },
                          onTapShowStarredOnly: (bool value) {
                            _viewModel.filterStarredOnly(value);
                          },
                        ),
                        Expanded(
                            child: ListView.builder(
                          itemCount: contents.length,
                          itemBuilder: (context, index) {
                            final folder = contents[index];
                            final hidden = folder.config?.hidden ?? false;
                            final starred = folder.config?.starred ?? false;
                            Icon? icon;
                            if (starred) {
                              icon = Icon(Icons.star, color: Colors.yellow[700]);
                            } else if (hidden) {
                              icon = const Icon(Icons.hide_source, color: Colors.black);
                            } else {
                              null;
                            }
                            return ListTile(
                              leading: const Icon(Icons.folder),
                              title: Text(folder.name),
                              trailing: icon,
                              onTap: () {
                                setState(() {
                                  _viewModel.loadFolder(folder.id);
                                });
                              },
                            );
                          },
                        ))
                      ],
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: FolderItemWidget(_viewModel),
          )
        ],
      ),
    );
  }
}
