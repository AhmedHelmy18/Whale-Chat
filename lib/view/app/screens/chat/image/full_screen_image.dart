import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whale_chat/theme/color_scheme.dart';

class FullScreenImageViewer extends StatefulWidget {
  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _toggleAppBar() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.scrim,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleAppBar,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Center(
                  child: Hero(
                    tag: 'image_${widget.imageUrls[index]}',
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.network(
                        widget.imageUrls[index],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: colorScheme.surface,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorScheme.surface,
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(
                                    color: colorScheme.surface,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_showAppBar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: colorScheme.surface),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '${_currentIndex + 1} / ${widget.imageUrls.length}',
                              style: TextStyle(
                                color: colorScheme.surface,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon:
                              Icon(Icons.more_vert, color: colorScheme.surface),
                          onPressed: () {
                            // Add more options if needed
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_showAppBar && widget.imageUrls.length > 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.imageUrls.length > 10
                            ? 10
                            : widget.imageUrls.length,
                        (index) {
                          if (index == 9 && widget.imageUrls.length > 10) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Text(
                                '...',
                                style: TextStyle(
                                  color: colorScheme.surface
                                      .withValues(alpha: 0.5),
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentIndex == index
                                    ? colorScheme.surface
                                    : colorScheme.surface
                                        .withValues(alpha: 0.4),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
