import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../theme/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  File? _selectedImage;
  XFile? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();
  List<String> _selectedBoards = <String>[];

  final List<String> _boards = [
    'Photography',
    'Art & Design',
    'Fashion',
    'Food & Recipes',
    'Nature',
    'Travel',
    'Home',
    'Beauty & Skincare',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImageFile = image;
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _createPost() {
    if (_selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // TODO: Implement actual post creation logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post created successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );

    // Reset form
    setState(() {
      _selectedImage = null;
      _selectedImageFile = null;
      _titleController.clear();
      _captionController.clear();
      _selectedBoards = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Create Post',
                    style: GoogleFonts.raleway(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 70, 68, 189),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Reset form
                      setState(() {
                        _selectedImage = null;
                        _selectedImageFile = null;
                        _titleController.clear();
                        _captionController.clear();
                        _selectedBoards = [];
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Upload Photo Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: _selectedImageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Upload Photos',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose photos from your gallery',
                              style: GoogleFonts.nunito(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedImageFile!.path,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return FutureBuilder<Uint8List>(
                                      future: _selectedImageFile!.readAsBytes(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          );
                                        }
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    );
                                  },
                                )
                              : Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Create Board Title
              Text(
                'Create Board Title',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Add your title',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Board Category
              Row(
                children: [
                  Text(
                    'Choose Tags',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${_selectedBoards.length}/3)',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: _selectedBoards.length >= 3 
                          ? AppTheme.errorColor 
                          : AppTheme.textSecondaryColor,
                      fontWeight: _selectedBoards.length >= 3 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _boards.map((board) {
                  final isSelected = _selectedBoards.contains(board);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedBoards.remove(board);
                        } else {
                          if (_selectedBoards.length < 3) {
                            _selectedBoards.add(board);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You can select maximum 3 tags'),
                                backgroundColor: AppTheme.errorColor,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppTheme.primaryColor.withValues(alpha: 0.9)
                            : AppTheme.primaryColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected 
                              ? AppTheme.primaryColor.withValues(alpha: 0.4)
                              : AppTheme.primaryColor.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        board,
                        style: GoogleFonts.nunito(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Caption
              Text(
                'Caption',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _captionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Tell everyone what makes this Pin special',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Post Button
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.8),
                    foregroundColor: const Color.fromARGB(255, 236, 236, 236),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child:  
                  Text(
                    'Post',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }
}