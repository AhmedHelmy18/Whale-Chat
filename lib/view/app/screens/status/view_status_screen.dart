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
      if (status == AnimationStatus.completed) _goToNextPage();
    });
    _viewModel.init();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentIndex < widget.status.statusItems.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToPreviousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteCurrentStatus() async {
    _animationController.stop();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            child: Text('Delete', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _viewModel.deleteStatusItem(
          widget.status.id, widget.status.statusItems[_currentIndex].id);
      if (mounted) Navigator.pop(context);
    } else {
      _animationController.forward();
    }
  }

  Color _parseHexColor(String? hex, {Color fallback = Colors.black}) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      String h = hex.replaceAll('#', '');
      if (h.length == 6) h = 'FF$h';
      final val = int.tryParse(h, radix: 16);
      return val != null ? Color(val) : fallback;
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.black;
    if (_currentIndex < widget.status.statusItems.length) {
      final item = widget.status.statusItems[_currentIndex];
      if (item.type == StatusType.text) {
        bgColor = _parseHexColor(item.backgroundColor);
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTapDown: (details) {
          final half = MediaQuery.of(context).size.width / 2;
          if (details.globalPosition.dx < half) {
            _goToPreviousPage();
          } else {
            _goToNextPage();
          }
        },
        onLongPress: widget.isMyStatus ? _deleteCurrentStatus : null,
        child: Stack(
          children: [
            _buildPageView(),
            _buildTopScrim(),
            _buildTopBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.status.statusItems.length,
      onPageChanged: (index) {
        setState(() => _currentIndex = index);
        _animationController
          ..reset()
          ..forward();
      },
      itemBuilder: (context, index) {
        final item = widget.status.statusItems[index];
        return item.type == StatusType.text
            ? _buildTextPage(item)
            : _buildImagePage(item);
      },
    );
  }

  Widget _buildTextPage(StatusItem item) {
    final bgColor = _parseHexColor(item.backgroundColor);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withValues(alpha: 0.75)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Text(
            item.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w600,
              height: 1.4,
              shadows: [
                Shadow(
                    color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePage(StatusItem item) {
    return Stack(
      children: [
        Positioned.fill(
          child: item.content.isEmpty
              ? const Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: Colors.white54, size: 64))
              : Image.network(
                  item.content,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image_rounded,
                        color: Colors.white54, size: 64),
                  ),
                ),
        ),
        if (item.caption != null && item.caption!.isNotEmpty)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                item.caption!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopScrim() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 180,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.65),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: Column(
        children: [
          _buildProgressBars(),
          const SizedBox(height: 12),
          _buildUserInfoRow(),
        ],
      ),
    );
  }

  Widget _buildProgressBars() {
    return Row(
      children: List.generate(
        widget.status.statusItems.length,
        (index) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _currentIndex == index
                      ? _animationController.value
                      : (_currentIndex > index ? 1.0 : 0.0),
                  minHeight: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.35),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 24),
        ),
        const SizedBox(width: 10),
        _buildAvatar(),
        const SizedBox(width: 10),
        Expanded(child: _buildNameAndTime()),
        if (widget.isMyStatus) _buildDeleteMenu(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Hero(
      tag: 'profile_${widget.status.userId}',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          backgroundImage: (widget.status.userProfileImage != null &&
                  widget.status.userProfileImage!.isNotEmpty)
              ? NetworkImage(widget.status.userProfileImage!)
              : null,
          child: (widget.status.userProfileImage == null ||
                  widget.status.userProfileImage!.isEmpty)
              ? const Icon(Icons.person_rounded,
                  color: Colors.white70, size: 20)
              : null,
        ),
      ),
    );
  }

  Widget _buildNameAndTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.status.userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
          ),
        ),
        if (widget.status.statusItems.isNotEmpty)
          Text(
            formatTimeAgo(widget.status.statusItems[_currentIndex].timestamp),
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
      ],
    );
  }

  Widget _buildDeleteMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'delete') _deleteCurrentStatus();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_rounded, color: colorScheme.error, size: 18),
              const SizedBox(width: 10),
              Text('Delete', style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }
}
