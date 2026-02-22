import 'package:flutter/material.dart';
import 'package:whale_chat/theme/color_scheme.dart';
import 'package:whale_chat/view/app/screens/status/add_status_screen.dart';

class StatusFab extends StatelessWidget {
  const StatusFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'text_status_fab',
          elevation: 4,
          backgroundColor: colorScheme.surfaceContainerHighest,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddStatusScreen(isTextMode: true),
            ),
          ),
          child: Icon(Icons.edit_rounded, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'camera_status_fab',
          elevation: 6,
          backgroundColor: colorScheme.primary,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddStatusScreen(),
            ),
          ),
          child: Icon(Icons.camera_alt_rounded, color: colorScheme.surface),
        ),
      ],
    );
  }
}
