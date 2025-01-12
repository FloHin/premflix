import 'package:flutter/material.dart';
import 'package:premflix/api/folder_response.dart';
import 'package:premflix/ui/main_app.dart';

class FolderActionBar extends StatelessWidget {
  final FolderResponse folder;
  final Function(bool value) onTapStar;
  final Function(bool value) onTapHide;
  final Function(bool value) onTapSeries;

  bool get _isHidden => folder.config?.hidden ?? false;

  bool get _isStarred => folder.config?.starred ?? false;

  bool get _isSeries => folder.config?.series ?? false;

  const FolderActionBar({
    super.key,
    required this.folder,
    required this.onTapHide,
    required this.onTapStar,
    required this.onTapSeries,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildStarButton(),
          const SizedBox(width: 16),
          buildMarkSeriesButton(),
          const SizedBox(width: 16),
          buildHideButton(),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  GestureDetector buildStarButton() {
    return GestureDetector(
      onTap: () {
        onTapStar(!_isStarred);
      },
      child: Row(
        children: [
          Icon(
            _isStarred ? Icons.star : Icons.star_outline,
            color: _isStarred ? AppColors.yellow : AppColors.lightGrey,
          ),
          const Text('Star'),
        ],
      ),
    );
  }

  GestureDetector buildHideButton() {
    return GestureDetector(
      onTap: () {
        onTapHide(!_isHidden);
      },
      child: Row(
        children: [
          Icon(
            _isHidden ? Icons.hide_source_rounded : Icons.hide_source_rounded,
            color: _isHidden ? Colors.black : AppColors.lightGrey,
          ),
          const Text('Hide'),
        ],
      ),
    );
  }

  GestureDetector buildMarkSeriesButton() {
    return GestureDetector(
      onTap: () {
        onTapSeries(!_isSeries);
      },
      child: Row(
        children: [
          Icon(
            Icons.video_collection,
            color: _isSeries ? Colors.black : AppColors.lightGrey,
          ),
          const Text('Mark as Series'),
        ],
      ),
    );
  }
}
