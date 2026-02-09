import 'package:flutter/material.dart';
import 'package:whale_chat/controller/status/status_controller.dart';
import 'package:whale_chat/model/status/status.dart';
import 'dart:async';
import 'package:whale_chat/theme/color_scheme.dart';

class ViewStatusScreen extends StatefulWidget {
  const ViewStatusScreen({
    super.key,
    required this.status,
    required this.isMyStatus,
  });

  final Status status;
  final bool isMyStatus;

  @override
  State<ViewStatusScreen> createState() => _ViewStatusScreenState();
}

class _ViewStatusScreenState extends State<ViewStatusScreen>
    with SingleTickerProviderStateMixin {
  final StatusController _controller = StatusController();
  late AnimationController _animationController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _startStatusTimer();
    _animationController.forward();

    if (!widget.isMyStatus) {
      _markAsViewed();
    }
  }

  void _startStatusTimer() {
    _timer = Timer(const Duration(seconds: 5), () {
      _nextStatus();
    });
  }

  void _markAsViewed() {
    final currentItem = widget.status.statusItems[_currentIndex];
    _controller.markStatusAsViewed(widget.status.id, currentItem.id);
  }

  void _nextStatus() {
    if (_currentIndex < widget.status.statusItems.length - 1) {
      setState(() {
        _currentIndex++;
        _animationController.reset();
        _animationController.forward();
      });
      _timer?.cancel();
      _startStatusTimer();

      if (!widget.isMyStatus) {
        _markAsViewed();
      }
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStatus() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _animationController.reset();
        _animationController.forward();
      });
      _timer?.cancel();
      _startStatusTimer();
    }
  }

  void _pauseStatus() {
    _timer?.cancel();
    _animationController.stop();
  }

  void _resumeStatus() {
    _startStatusTimer();
    _animationController.forward();
  }

  Color _parseColor(String? colorString) {
    if (colorString == null) return const Color(0xFF0891B2);
    try {
      return Color(int.parse('0xFF$colorString'));
    } catch (e) {
      return const Color(0xFF0891B2);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = widget.status.statusItems[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          _pauseStatus();
        },
        onTapUp: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < screenWidth / 2) {
            _previousStatus();
          } else {
            _nextStatus();
          }
        },
        onLongPressStart: (_) {
          _pauseStatus();
        },
        onLongPressEnd: (_) {
          _resumeStatus();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildStatusContent(currentItem),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: List.generate(
                        widget.status.statusItems.length,
                            (index) => Expanded(
                          child: Container(
                            height: 2.5,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: index < _currentIndex
                                    ? 1.0
                                    : index == _currentIndex
                                    ? _animationController.value
                                    : 0.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: widget.status.userProfileImage != null
                                ? Image.network(
                              widget.status.userProfileImage!,
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              'assets/images/download.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.status.userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _getTimeAgo(currentItem.timestamp),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  if (currentItem.type == StatusType.image && currentItem.caption != null)
                    Positioned(
                      bottom: 80,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          currentItem.caption!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (widget.isMyStatus)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${currentItem.viewedBy.length} views',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusContent(StatusItem item) {
    switch (item.type) {
      case StatusType.text:
        return Container(
          color: _parseColor(item.backgroundColor),
          child: Stack(
            children: [
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    item.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );

      case StatusType.image:
        return Center(
          child: Image.network(
            item.content,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  color: colorScheme.primary,
                ),
              );
            },
          ),
        );

      case StatusType.video:
        return const Center(
          child: Text(
            'Video player not implemented',
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return 'Yesterday';
    }
  }
}