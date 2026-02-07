import 'package:flutter/material.dart';

class ChatImageTile extends StatelessWidget {
  const ChatImageTile({
    super.key,
    required this.url,
    required this.borderColor,
    required this.onTap,
    this.overlay,
    this.borderRadius = 10,
  });

  final String url;
  final Color borderColor;
  final VoidCallback onTap;
  final Widget? overlay;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - 1),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          if (overlay != null)
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: overlay!,
              ),
            ),
        ],
      ),
    );
  }
}
