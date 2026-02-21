import 'package:flutter/material.dart';
import 'package:whale_chat/model/status/status.dart';
import 'package:whale_chat/util/format_time.dart';
import 'package:whale_chat/theme/color_scheme.dart';

class ViewStatusScreen extends StatefulWidget {
  final Status status;
  final bool isMyStatus;
  final int initialIndex;

  const ViewStatusScreen({
    super.key,
    required this.status,
    required this.isMyStatus,
    this.initialIndex = 0,
  });

  @override
  State<ViewStatusScreen> createState() => _ViewStatusScreenState();
}

class _ViewStatusScreenState extends State<ViewStatusScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToNextPage();
      }
    });
  }

  void _goToNextPage() {
    if (_currentIndex < widget.status.statusItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToPreviousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    // Get background color from current status item
    Color backgroundColor = colorScheme.scrim;
    if (_currentIndex < widget.status.statusItems.length) {
      final currentItem = widget.status.statusItems[_currentIndex];
      if (currentItem.type == StatusType.text &&
          currentItem.backgroundColor != null &&
          currentItem.backgroundColor!.isNotEmpty) {
        try {
          String hex = currentItem.backgroundColor!.replaceAll('#', '');
          if (hex.length == 6) {
            hex = 'FF$hex';
          }
          backgroundColor = Color(int.parse(hex, radix: 16));
        } catch (e) {
          backgroundColor = colorScheme.scrim;
        }
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _goToPreviousPage();
          } else {
            _goToNextPage();
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.status.statusItems.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _animationController.reset();
                _animationController.forward();
              },
              itemBuilder: (context, index) {
                final item = widget.status.statusItems[index];
                if (item.type == StatusType.text) {
                  Color bgColor = colorScheme.scrim;
                  if (item.backgroundColor != null &&
                      item.backgroundColor!.isNotEmpty) {
                    try {
                      String hex = item.backgroundColor!.replaceAll('#', '');
                      if (hex.length == 6) {
                        hex = 'FF\$hex';
                      }
                      bgColor = Color(int.parse(hex, radix: 16));
                    } catch (e) {
                      bgColor = colorScheme.scrim;
                    }
                  }

                  return Container(
                    color: bgColor,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          item.content,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: item.content.isEmpty
                            ? Center(
                                child: Icon(Icons.broken_image,
                                    color: colorScheme.onPrimary, size: 50))
                            : Image.network(
                                item.content,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                      child: Icon(Icons.broken_image,
                                          color: colorScheme.onPrimary,
                                          size: 50));
                                },
                              ),
                      ),
                      if (item.caption != null && item.caption!.isNotEmpty)
                        Positioned(
                          bottom: 120,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: colorScheme.scrim.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            child: Text(
                              item.caption!,
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                }
              },
            ),
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  Row(
                    children: List.generate(
                      widget.status.statusItems.length,
                      (index) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: _currentIndex == index
                                    ? _animationController.value
                                    : (_currentIndex > index ? 1 : 0),
                                backgroundColor: colorScheme.outline,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onPrimary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Hero(
                        tag: 'profile_${widget.status.userId}',
                        child: CircleAvatar(
                          backgroundImage: (widget.status.userProfileImage !=
                                      null &&
                                  widget.status.userProfileImage!.isNotEmpty)
                              ? NetworkImage(widget.status.userProfileImage!)
                              : null,
                          child: (widget.status.userProfileImage == null ||
                                  widget.status.userProfileImage!.isEmpty)
                              ? Icon(Icons.person, color: colorScheme.scrim)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.status.userName,
                            style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          if (widget.status.statusItems.isNotEmpty)
                            Text(
                              formatTimeAgo(widget
                                  .status.statusItems[_currentIndex].timestamp),
                              style: TextStyle(
                                  color: colorScheme.onPrimary
                                      .withValues(alpha: 0.7),
                                  fontSize: 12),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
