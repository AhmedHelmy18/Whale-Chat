import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whale_chat/controller/status/status_controller.dart';
import 'package:whale_chat/model/status/status.dart';
import 'dart:io';
import 'package:whale_chat/theme/color_scheme.dart';

class AddStatusScreen extends StatefulWidget {
  const AddStatusScreen({super.key});

  @override
  State<AddStatusScreen> createState() => _AddStatusScreenState();
}

class _AddStatusScreenState extends State<AddStatusScreen> {
  final StatusController _controller = StatusController();
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  Color _selectedColor = const Color(0xFF0891B2);

  final List<Color> _backgroundColors = [
    const Color(0xFF0891B2),
    const Color(0xFFDC2626),
    const Color(0xFF7C3AED),
    const Color(0xFFEA580C),
    const Color(0xFF059669),
    const Color(0xFF2563EB),
    const Color(0xFFDB2777),
    const Color(0xFF0D9488),
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _postStatus() async {
    if (_selectedImage == null && _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add text or select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_selectedImage != null) {
        await _controller.addStatus(
          type: StatusType.image,
          content: '',
          imageFile: _selectedImage,
          caption: _textController.text.trim().isNotEmpty
              ? _textController.text.trim()
              : null,
        );
      } else {
        await _controller.addStatus(
          type: StatusType.text,
          content: _textController.text.trim(),
          backgroundColor:
              '#${_selectedColor.toARGB32().toRadixString(16).substring(2)}',
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status posted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting status: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _selectedImage != null ? colorScheme.scrim : _selectedColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.surface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedImage == null)
            PopupMenuButton<Color>(
              constraints: BoxConstraints(maxWidth: 50),
              icon: Icon(Icons.palette, color: colorScheme.surface),
              offset: const Offset(0, 35),
              onSelected: (color) {
                setState(() => _selectedColor = color);
              },
              itemBuilder: (context) => _backgroundColors.map((color) {
                return PopupMenuItem<Color>(
                  value: color,
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color == _selectedColor
                              ? colorScheme.surface
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_selectedImage == null)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surface.withValues(alpha: 0.05),
                ),
              ),
            ),
          if (_selectedImage == null)
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 200,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surface.withValues(alpha: 0.05),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: _selectedImage != null
                        ? Stack(
                            children: [
                              Image.file(
                                _selectedImage!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: colorScheme.surface,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    setState(() => _selectedImage = null);
                                  },
                                ),
                              ),
                            ],
                          )
                        : Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: TextField(
                              controller: _textController,
                              maxLines: null,
                              maxLength: 700,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.surface,
                                fontSize: 32,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type your status...',
                                hintStyle: TextStyle(
                                  color: colorScheme.surface
                                      .withValues(alpha: 0.6),
                                  fontSize: 32,
                                ),
                                counterStyle: TextStyle(
                                    color: colorScheme.surface
                                        .withValues(alpha: 0.6)),
                              ),
                            ),
                          ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.scrim.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    children: [
                      if (_selectedImage != null)
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: TextStyle(color: colorScheme.surface),
                            decoration: InputDecoration(
                              hintText: 'Add a caption...',
                              hintStyle: TextStyle(
                                  color: colorScheme.surface
                                      .withValues(alpha: 0.6)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      if (_selectedImage == null)
                        Expanded(
                          child: IconButton(
                            icon: Icon(
                              Icons.photo_library_rounded,
                              color: colorScheme.surface,
                              size: 28,
                            ),
                            onPressed: _pickImage,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Material(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          onTap: _isLoading ? null : _postStatus,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.surface,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.send_rounded,
                                        color: colorScheme.surface,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'POST',
                                        style: TextStyle(
                                          color: colorScheme.surface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
