import 'package:flutter/material.dart';

class ViewOptionsBar extends StatefulWidget {
  final Function(bool value) onTapShowHidden;
  final Function(bool value) onTapShowStarredOnly;

  const ViewOptionsBar({
    super.key,
    required this.onTapShowHidden,
    required this.onTapShowStarredOnly,
  });

  @override
  State<ViewOptionsBar> createState() => _ViewOptionsBarState();
}

class _ViewOptionsBarState extends State<ViewOptionsBar> {
  bool _showHidden = false;
  bool _showStarsOnly = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showHidden = !_showHidden;
                  widget.onTapShowHidden(_showHidden);
                });
              },
              child: Row(
                children: [
                  Checkbox(
                    value: _showHidden,
                    onChanged: (bool? value) {
                      setState(() {
                        _showHidden = value ?? false;
                        widget.onTapShowHidden(_showHidden);
                      });
                    },
                  ),
                  const Text('Show Hidden'),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showStarsOnly = !_showStarsOnly;
                  widget.onTapShowStarredOnly(_showStarsOnly);
                });
              },
              child: Row(
                children: [
                  Checkbox(
                    value: _showStarsOnly,
                    onChanged: (bool? value) {
                      setState(() {
                        _showStarsOnly = value ?? false;
                        widget.onTapShowStarredOnly(_showStarsOnly);
                      });
                    },
                  ),
                  const Text('Show Stars Only'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
