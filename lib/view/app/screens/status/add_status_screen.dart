import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whale_chat/view_model/status_view_model.dart';
import 'package:whale_chat/model/status/status.dart';
import 'dart:io';
import 'package:whale_chat/view/common/custom_snackbar.dart';
import 'package:whale_chat/view/common/image_options/model_sheet_options.dart';
import 'package:whale_chat/view/app/screens/status/widgets/status_color_palette.dart';
import 'package:whale_chat/view/app/screens/status/widgets/status_action_bar.dart';

class AddStatusScreen extends StatefulWidget {
  final bool isTextMode;
  const AddStatusScreen({super.key, this.isTextMode = false});

  @override
  State<AddStatusScreen> createState() => _AddStatusScreenState();
}

class _AddStatusScreenState extends State<AddStatusScreen> {
  final StatusViewModel _viewModel = StatusViewModel();
  final TextEditingController _textController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  Color _selectedColor = const Color(0xFF0891B2);

  static const List<Color> _backgroundColors = [
    Color(0xFF0891B2),
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFFDC2626),
    Color(0xFFEA580C),
    Color(0xFFCA8A04),
    Color(0xFF059669),
    Color(0xFF0D9488),
    Color(0xFF57534E),
    Color(0xFF1E293B),
  ];

  @override
  void initState() {
    super.initState();
    if (!widget.isTextMode) {
      WidgetsBinding.instance
          .addPostFrameCallback((Duration _) => _showImagePicker());
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _showImagePicker() async {
    await showImageSourcePicker(
      context: context,
      onPick: (ImageSource source) async {
        try {
          final XFile? image = await ImagePicker().pickImage(
            source: source,
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 85,
          );
          if (image != null) {
            setState(() => _selectedImage = File(image.path));
          }
        } catch (e) {
          if (mounted) {
            showCustomSnackBar(context, 'Error picking image: $e',
                isError: true);
          }
        }
      },
    );
  }

  Future<void> _postStatus() async {
    if (_selectedImage == null && _textController.text.trim().isEmpty) {
      showCustomSnackBar(context, 'Please add text or select an image',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_selectedImage != null) {
        await _viewModel.addStatus(
          type: StatusType.image,
          content: '',
          imageFile: _selectedImage,
          caption: _textController.text.trim().isNotEmpty
              ? _textController.text.trim()
              : null,
        );
      } else {
        await _viewModel.addStatus(
          type: StatusType.text,
          content: _textController.text.trim(),
          backgroundColor:
              '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
        );
      }
      if (mounted) {
        Navigator.pop(context);
        showCustomSnackBar(context, 'Status posted successfully!');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, 'Error posting status: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImageMode = _selectedImage != null;

    return Scaffold(
      backgroundColor: isImageMode ? Colors.black : _selectedColor,
      appBar: _buildAppBar(isImageMode),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMainContent(isImageMode)),
            if (!isImageMode)
              StatusColorPalette(
                colors: _backgroundColors,
                selected: _selectedColor,
                onSelect: (Color color) =>
                    setState(() => _selectedColor = color),
              ),
            StatusActionBar(
              isImageMode: isImageMode,
              captionController: _textController,
              isLoading: _isLoading,
              onPickImage: _showImagePicker,
              onPost: _postStatus,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isImageMode) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (isImageMode) ...[
          IconButton(
            icon: _actionIcon(Icons.image_rounded),
            onPressed: _showImagePicker,
          ),
          IconButton(
            icon: _actionIcon(Icons.delete_rounded),
            onPressed: () => setState(() => _selectedImage = null),
          ),
        ],
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _actionIcon(IconData icon) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      );

  Widget _buildMainContent(bool isImageMode) {
    if (isImageMode) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.contain,
        width: double.infinity,
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: TextField(
          controller: _textController,
          maxLines: null,
          maxLength: 700,
          textAlign: TextAlign.center,
          autofocus: true,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w600,
            height: 1.4,
            shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Type a status...',
            hintStyle: TextStyle(
              color: Colors.white54,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
            counterStyle: TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }
}
