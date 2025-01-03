import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:premflix/api/content.dart';
import 'package:premflix/main.dart';
import 'package:premflix/service/premiumize_service.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folder Viewer')),
      body: Row(
        children: [
          Expanded(
            child: BlocBuilder<PremiumizeService, FolderState>(
              bloc: _viewModel,
              builder: (context, state) {
                if (state is FolderLoaded || state is FolderIndex) {
                  final contents = state.folders;
                  return ListView.builder(
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      final folder = contents[index];
                      return ListTile(
                        title: Text(folder.name),
                        onTap: () {
                          setState(() {
                            _viewModel.loadFolder(folder.id);
                          });
                        },
                      );
                    },
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<PremiumizeService, FolderState>(
                bloc: _viewModel,
                builder: (context, state) {
                  if (state is FolderLoaded) {
                    final items = state.folderResponse.content ?? [];
                   return
                    ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ListTile(
                                title: Text(item.name),
                                subtitle: Text(item.type),
                                onTap: () {
                                  setState(() {
                                    _viewModel.streamFile(item);
                                  });
                                },
                              );
                            },
                          );
                  } else {
                    return const Center(child: Text('Select a folder'));
                  }
                }),
          ),
        ],
      ),
    );
  }
}
