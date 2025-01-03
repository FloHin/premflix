import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:premflix/api/folder_model.dart';
import 'package:premflix/main.dart';
import 'package:premflix/service/premiumize_service.dart';

class FolderViewerScreen extends StatefulWidget {
  const FolderViewerScreen({super.key});

  @override
  State<FolderViewerScreen> createState() => _FolderViewerScreenState();
}

class _FolderViewerScreenState extends State<FolderViewerScreen> {
  final PremiumizeService _viewModel = sl<PremiumizeService>();
  FolderModel? selectedFolder;

  @override
  void initState() {
    super.initState();
    _viewModel.loadFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folder Viewer')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<PremiumizeService, List<FolderModel>>(
              bloc: _viewModel,
              builder: (context, folders) {
                return ListView.builder(
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    return ListTile(
                      title: Text(folder.name),
                      onTap: () {
                        setState(() {
                          selectedFolder = folder;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: selectedFolder == null
                ? const Center(child: Text('Select a folder'))
                : ListView.builder(
                    itemCount: selectedFolder!.content.length,
                    itemBuilder: (context, index) {
                      final content = selectedFolder!.content[index];
                      return ListTile(
                        title: Text(content.name),
                        subtitle: Text(content.type),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
