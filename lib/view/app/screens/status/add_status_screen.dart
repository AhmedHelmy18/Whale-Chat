import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whale_chat/controller/status/status_controller.dart';
import 'package:whale_chat/model/status/status.dart';
import 'dart:io';
import 'package:whale_chat/theme/color_scheme.dart';

class AddStatusScreen extends StatefulWidget {
  final bool isTextMode;
  const AddStatusScreen({super.key, this.isTextMode = false});

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
    const Color(0xFF0891B2), // Cyan
    const Color(0xFFDC2626), // Red
    const Color(0xFF7C3AED), // Violet
    const Color(0xFFEA580C), // Orange
    const Color(0xFF059669), // Emerald
    const Color(0xFF2563EB), // Blue
    const Color(0xFFDB2777), // Pink
    const Color(0xFF0D9488), // Teal
    const Color(0xFF57534E), // Stone
  ];

  @override
  void initState() {
    super.initState();
    if (!widget.isTextMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImage();
      });
    }
  }

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
              '#${_selectedColor.value.toRadixString(16).substring(2)}',
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
          _selectedImage != null ? Colors.black : _selectedColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedImage == null)
            IconButton(
              icon: const Icon(Icons.palette, color: Colors.white),
              onPressed: () {
                // Cycle through colors or show picker
                final currentIndex = _backgroundColors.indexOf(_selectedColor);
                final nextIndex = (currentIndex + 1) % _backgroundColors.length;
                setState(() {
                  _selectedColor = _backgroundColors[nextIndex];
                });
              },
            ),
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.crop_rotate, color: Colors.white),
              onPressed: () {
                // Placeholder for crop/rotate
                ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Image editing coming soon')),
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: TextField(
                              controller: _textController,
                              maxLines: null,
                              maxLength: 700,
                              textAlign: TextAlign.center,
                              autofocus: _selectedImage == null,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PlayfairDisplay', // Using custom font if available or fallback
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type a status',
                                hintStyle: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 32,
                                ),
                                counterStyle: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),
                  ),
                ),

                // Bottom Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.black26,
                  child: Row(
                    children: [
                      if (_selectedImage != null)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Add a caption...',
                                hintStyle: TextStyle(color: Colors.white70),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      if (_selectedImage == null)
                         IconButton(
                            icon: const Icon(Icons.image, color: Colors.white),
                            onPressed: _pickImage,
                         ),
                      const SizedBox(width: 12),

                      // Post Button
                      GestureDetector(
                        onTap: _isLoading ? null : _postStatus,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_selectedImage != null)
             Positioned(
                top: 50, // Below AppBar
                left: 16,
                child: CircleAvatar(
                   backgroundColor: Colors.black45,
                   child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                         setState(() {
                            _selectedImage = null;
                         });
                      },
                   ),
                ),
             ),
        ],
      ),
    );
  }
}
