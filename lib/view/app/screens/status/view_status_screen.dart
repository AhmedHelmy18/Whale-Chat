import 'package:flutter/material.dart';
import 'package:whale_chat/view_model/status_view_model.dart';
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
  final StatusViewModel _viewModel = StatusViewModel();
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
    _viewModel.init();
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

  Future<void> _deleteCurrentStatus() async {
    _animationController.stop();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete status update?'),
        content: const Text(
            'This status update will be deleted for everyone who received it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final item = widget.status.statusItems[_currentIndex];
      await _viewModel.deleteStatusItem(widget.status.id, item.id);
      if (mounted) {
        Navigator.pop(context); // Close viewer after deletion
      }
    } else {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get background color from current status item
    Color backgroundColor = Colors.black;
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
          final val = int.tryParse(hex, radix: 16);
          if (val != null) {
            backgroundColor = Color(val);
          }
        } catch (e) {
          backgroundColor = Colors.black;
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
        onLongPress: widget.isMyStatus ? _deleteCurrentStatus : null,
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
                  Color bgColor = Colors.black;
                  if (item.backgroundColor != null &&
                      item.backgroundColor!.isNotEmpty) {
                    try {
                      String hex = item.backgroundColor!.replaceAll('#', '');
                      if (hex.length == 6) {
                        hex = 'FF$hex';
                      }
                      final val = int.tryParse(hex, radix: 16);
                      if (val != null) {
                        bgColor = Color(val);
                      }
                    } catch (e) {
                      bgColor = Colors.black;
                    }
                  }

                  return Container(
                    color: bgColor,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          item.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'PlayfairDisplay',
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
                            ? const Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.white, size: 50))
                            : Image.network(
                                item.content,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                      child: Icon(Icons.broken_image,
                                          color: Colors.white,
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
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            child: Text(
                              item.caption!,
                              style: const TextStyle(
                                color: Colors.white,
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

            // Top Bar
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  // Progress Indicators
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
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // User Info
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
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
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.status.userName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (widget.status.statusItems.isNotEmpty)
                              Text(
                                formatTimeAgo(widget
                                    .status.statusItems[_currentIndex].timestamp),
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      if (widget.isMyStatus)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (value) {
                             if (value == 'delete') {
                               _deleteCurrentStatus();
                             }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
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
