import 'package:flutter/material.dart';
import 'package:whale_chat/view/app/screens/chat/image/chat_image_tile.dart';
import 'package:whale_chat/view/app/screens/chat/image/full_screen_image.dart';

class ImageGridWidget extends StatelessWidget {
  const ImageGridWidget({
    super.key,
    required this.imageUrls,
    required this.borderColor,
    required this.hasText,
    this.overlay,
    required this.containerColor,
  });

  final List<String> imageUrls;
  final Color borderColor;
  final bool hasText;
  final Widget? overlay;
  final Color containerColor;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.length == 1) {
      return _SingleImage(
        url: imageUrls.first,
        borderColor: borderColor,
        hasText: hasText,
        overlay: overlay,
      );
    }
    return _MultiImages(
      imageUrls: imageUrls,
      borderColor: borderColor,
      overlayBuilder: overlay,
      containerColor: containerColor,
    );
  }

}

class _SingleImage extends StatelessWidget {
  const _SingleImage({
    required this.url,
    required this.borderColor,
    required this.hasText,
    this.overlay,
  });

  final String url;
  final Color borderColor;
  final bool hasText;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImageViewer(
              imageUrls: [url],
            ),
          ),
        );
      },
      child: Hero(
        tag: 'image_$url',
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 280,
            maxHeight: 320,
          ),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Image.network(
                  url,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                if (overlay != null)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: overlay!,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MultiImages extends StatelessWidget {
  const _MultiImages({
    required this.imageUrls,
    required this.borderColor,
    required this.containerColor,
    this.overlayBuilder,
  });

  final List<String> imageUrls;
  final Color borderColor;
  final Widget? overlayBuilder;
  final Color containerColor;

  @override
  Widget build(BuildContext context) {
    final maxItems = imageUrls.length > 4 ? 4 : imageUrls.length;
    final remaining = imageUrls.length - 4;
    final rows = (maxItems / 2).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = (constraints.maxWidth - 8 - 4) / 2;
        final height = rows * tileSize + (rows - 1) * 4 + 8;

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: maxItems,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ChatImageTile(
                    url: imageUrls[index],
                    borderColor: Colors.transparent,
                    overlay: overlayBuilder,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImageViewer(
                            imageUrls: imageUrls,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                  ),
                  if (index == 3 && remaining > 0)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '+$remaining',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
