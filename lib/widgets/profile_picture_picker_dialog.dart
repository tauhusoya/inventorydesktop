import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/profile_picture_service.dart';
import '../utils/mobile_alerts.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class ProfilePicturePickerDialog extends StatefulWidget {
  final String userId;
  final String? currentProfilePicture;
  final String? displayName;

  const ProfilePicturePickerDialog({
    super.key,
    required this.userId,
    this.currentProfilePicture,
    this.displayName,
  });

  @override
  State<ProfilePicturePickerDialog> createState() =>
      _ProfilePicturePickerDialogState();
}

class _ProfilePicturePickerDialogState
    extends State<ProfilePicturePickerDialog> {
  dynamic _selectedImage; // Can be File (mobile) or XFile (web)
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Profile Picture'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current profile picture display
          if (widget.currentProfilePicture != null) ...[
            const Text('Current Profile Picture:'),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  widget.currentProfilePicture!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Selected image preview
          if (_selectedImage != null) ...[
            const Text('New Profile Picture Preview:'),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 8),
            Text('Selected: ${_getFileName()}'),
            const SizedBox(height: 16),
          ],

          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _takePhotoWithCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_selectedImage != null)
          ElevatedButton(
            onPressed: _isUploading ? null : _uploadImage,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Upload'),
          ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (kIsWeb && _selectedImage is XFile) {
      return Image.network(
        _selectedImage.path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              Icons.image_not_supported,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
      );
    } else if (_selectedImage is File) {
      return Image.file(
        _selectedImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              Icons.image_not_supported,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.image_not_supported,
        size: 40,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      if (kIsWeb) {
        // For web, pick image directly
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _selectedImage = image;
          });
        } else {}
      } else {
        // For mobile, use the service
        final profilePictureService = context.read<ProfilePictureService>();
        final imageFile = await profilePictureService.pickImageFromGallery();

        if (imageFile != null &&
            profilePictureService.isValidImageFile(imageFile)) {
          setState(() {
            _selectedImage = imageFile;
          });
        } else {
          if (mounted) {
            MobileAlerts.showErrorMessage(
              context: context,
              message:
                  'Invalid image file. Please select a valid image (JPG, PNG, WebP) under 5MB.',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        MobileAlerts.showErrorMessage(
          context: context,
          message: 'Failed to pick image: $e',
        );
      }
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      if (kIsWeb) {
        // For web, take photo directly
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _selectedImage = image;
          });
        } else {}
      } else {
        // For mobile, use the service
        final profilePictureService = context.read<ProfilePictureService>();
        final imageFile = await profilePictureService.takePhotoWithCamera();

        if (imageFile != null &&
            profilePictureService.isValidImageFile(imageFile)) {
          setState(() {
            _selectedImage = imageFile;
          });
        } else {
          if (mounted) {
            MobileAlerts.showErrorMessage(
              context: context,
              message:
                  'Invalid image file. Please select a valid image (JPG, PNG, WebP) under 5MB.',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        MobileAlerts.showErrorMessage(
          context: context,
          message: 'Failed to take photo: $e',
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      setState(() {
        _isUploading = true;
      });

      final profilePictureService = context.read<ProfilePictureService>();
      final userService = context.read<UserService>();
      final authService = context.read<AuthService>();
      final userId = authService.currentUser?.id;

      if (userId == null) {
        throw Exception('No authenticated user found');
      }

      bool success = false;

      if (kIsWeb && _selectedImage is XFile) {
        success = await profilePictureService.uploadWebImage(
          _selectedImage,
          userId,
          userService,
        );
      } else if (_selectedImage is File) {
        success = await profilePictureService.uploadProfilePicture(
          _selectedImage,
          userId,
          userService,
        );
      } else {
        throw Exception(
            'Unsupported image type: ${_selectedImage.runtimeType}');
      }

      if (mounted) {
        if (success) {
          MobileAlerts.showSuccessMessage(
            context: context,
            message: 'Profile picture updated successfully!',
          );
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _errorMessage = 'Failed to upload profile picture';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // Helper method to get filename
  String _getFileName() {
    if (_selectedImage == null) return '';

    if (kIsWeb && _selectedImage is XFile) {
      // For web, try to get the name from the XFile first, then fallback to path
      String filename = '';
      if (_selectedImage.name.isNotEmpty) {
        filename = _selectedImage.name;
      } else if (_selectedImage.path.isNotEmpty) {
        filename = _selectedImage.path.split('/').last;
      } else {
        filename = 'web_image';
      }
      return filename;
    } else if (_selectedImage is File) {
      final filename = _selectedImage!.path.split('/').last;
      return filename;
    }

    return 'Unknown file';
  }
}
