import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'r2_storage_service.dart';
import 'user_service.dart';
import '../config/r2_config.dart';

class ProfilePictureService extends ChangeNotifier {
  final R2StorageService _r2Service = R2StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  String? _error;
  String? _currentProfilePictureUrl;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentProfilePictureUrl => _currentProfilePictureUrl;

  // Set the current profile picture URL (used for initialization)
  void setCurrentProfilePictureUrl(String? url) {
    _currentProfilePictureUrl = url;
    notifyListeners();
  }

  // Initialize the service with current user's profile picture
  Future<void> initialize(String? userId) async {
    if (userId != null) {
      try {
        // Try to get the current profile picture URL from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final profilePictureUrl = data['profilePicture'] as String?;
          if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
            _currentProfilePictureUrl = profilePictureUrl;
            notifyListeners();
          }
        }
      } catch (e) {
        // Silently fail - profile picture is not critical for app startup
      }
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: R2Config.maxProfilePictureDimension.toDouble(),
        maxHeight: R2Config.maxProfilePictureDimension.toDouble(),
        imageQuality: 85,
      );

      if (image != null) {
        // Handle web vs mobile differently
        if (kIsWeb) {
          // For web, we need to get bytes and use uploadProfilePictureFromBytes
          // Extract extension from image name or path, default to jpg
          String extension = 'jpg'; // Default extension
          try {
            // Try to get extension from image name first (more reliable on web)
            if (image.name.isNotEmpty) {
              final nameParts = image.name.split('.');
              if (nameParts.length > 1) {
                final lastPart = nameParts.last.toLowerCase();
                if (R2Config.allowedProfilePictureFormats.contains(lastPart)) {
                  extension = lastPart;
                }
              }
            }

            // Fallback to path if name didn't work
            if (extension == 'jpg' && image.path.isNotEmpty) {
              final pathParts = image.path.split('.');
              if (pathParts.length > 1) {
                final lastPart = pathParts.last.toLowerCase();
                if (R2Config.allowedProfilePictureFormats.contains(lastPart)) {
                  extension = lastPart;
                }
              }
            }
          } catch (e) {
            // Error extracting extension, using default: $e
          }
          return null;
        } else {
          // For mobile, use File
          final file = File(image.path);
          return file;
        }
      }
      return null;
    } catch (e) {
      // Error picking image from gallery: $e
      _setError('Failed to pick image from gallery: $e');
      return null;
    }
  }

  // Take photo with camera
  Future<File?> takePhotoWithCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: R2Config.maxProfilePictureDimension.toDouble(),
        maxHeight: R2Config.maxProfilePictureDimension.toDouble(),
        imageQuality: 85,
      );

      if (image != null) {
        // Handle web vs mobile differently
        if (kIsWeb) {
          // For web, we need to get bytes and use uploadProfilePictureFromBytes
          // Extract extension from image name or path, default to jpg
          String extension = 'jpg'; // Default extension
          try {
            // Try to get extension from image name first (more reliable on web)
            if (image.name.isNotEmpty) {
              final nameParts = image.name.split('.');
              if (nameParts.length > 1) {
                final lastPart = nameParts.last.toLowerCase();
                if (R2Config.allowedProfilePictureFormats.contains(lastPart)) {
                  extension = lastPart;
                }
              }
            }

            // Fallback to path if name didn't work
            if (extension == 'jpg' && image.path.isNotEmpty) {
              final pathParts = image.path.split('.');
              if (pathParts.length > 1) {
                final lastPart = pathParts.last.toLowerCase();
                if (R2Config.allowedProfilePictureFormats.contains(lastPart)) {
                  extension = lastPart;
                }
              }
            }
          } catch (e) {
            // Error extracting extension, using default: $e
          }
          return null;
        } else {
          // For mobile, use File
          final file = File(image.path);
          return file;
        }
      }
      return null;
    } catch (e) {
      // Error taking photo with camera: $e
      _setError('Failed to take photo: $e');
      return null;
    }
  }

  // Upload profile picture
  Future<bool> uploadProfilePicture(
      File imageFile, String userId, UserService userService) async {
    try {
      _setLoading(true);
      _clearError();

      // Validate image file first
      if (!isValidImageFile(imageFile)) {
        _setError('Invalid image file. Please check the file format and size.');
        return false;
      }

      // Check if user has an existing profile picture and delete it first
      if (_currentProfilePictureUrl != null &&
          _currentProfilePictureUrl!.isNotEmpty) {
        try {
          final oldFileName =
              extractFilenameFromUrl(_currentProfilePictureUrl!);
          if (oldFileName != null && oldFileName.isNotEmpty) {
            final deleteResult =
                await _r2Service.deleteProfilePicture(oldFileName);
            if (deleteResult) {
              // Old profile picture deleted successfully
            } else {
              // Warning - old profile picture deletion failed (this is normal if R2 permissions are not set up for delete operations)
            }
          } else {
            // Warning - could not extract filename from URL: $_currentProfilePictureUrl
          }
        } catch (e) {
          // Warning - failed to delete old profile picture: $e
          // Continue with upload even if deletion fails
        }
      }

      // Validate and resize image if needed
      final processedImage = await _processImage(imageFile);

      // Upload to R2
      final fileName =
          await _r2Service.uploadProfilePicture(processedImage, userId);

      if (fileName != null) {
        // Store the complete public URL, not just the filename
        // This allows direct access to the image without URL generation
        final publicUrl = R2Config.getProfilePictureUrl(fileName);
        // Add cache-busting query to avoid stale CDN cache immediately after upload
        final versionedUrl =
            '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';

        final success = await userService.updateUserProfileFields(userId, {
          'profilePicture':
              versionedUrl, // Store the complete public URL with version
          'profilePictureUpdatedAt': FieldValue.serverTimestamp(),
        });

        if (success) {
          _currentProfilePictureUrl =
              versionedUrl; // Store full public URL (versioned) for local state
          notifyListeners();
          _setLoading(false);
          return true;
        } else {
          _setError('Failed to update user profile in database');
          _setLoading(false);
          return false;
        }
      } else {
        _setError('Failed to upload image to storage');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error uploading profile picture: $e');
      _setLoading(false);
      return false;
    }
  }

  // Upload profile picture from bytes (useful for web)
  Future<bool> uploadProfilePictureFromBytes(Uint8List bytes, String userId,
      String extension, UserService userService) async {
    try {
      _setLoading(true);
      _clearError();

      // Check if user has an existing profile picture and delete it first
      if (_currentProfilePictureUrl != null &&
          _currentProfilePictureUrl!.isNotEmpty) {
        try {
          final oldFileName =
              extractFilenameFromUrl(_currentProfilePictureUrl!);
          if (oldFileName != null && oldFileName.isNotEmpty) {
            final deleteResult =
                await _r2Service.deleteProfilePicture(oldFileName);
            if (deleteResult) {
              // Old profile picture deleted successfully
            } else {
              // Warning - old profile picture deletion failed (this is normal if R2 permissions are not set up for delete operations)
            }
          } else {
            // Warning - could not extract filename from URL: $_currentProfilePictureUrl
          }
        } catch (e) {
          // Warning - failed to delete old profile picture: $e
          // Continue with upload even if deletion fails
        }
      }

      // Upload to R2
      final fileName = await _r2Service.uploadProfilePictureFromBytes(
          bytes, userId, extension);

      if (fileName != null) {
        // Store the complete public URL, not just the filename
        // This allows direct access to the image without URL generation
        final publicUrl = R2Config.getProfilePictureUrl(fileName);
        final versionedUrl =
            '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';

        final success = await userService.updateUserProfileFields(userId, {
          'profilePicture': versionedUrl, // Store the complete public URL
          'profilePictureUpdatedAt': FieldValue.serverTimestamp(),
        });

        if (success) {
          _currentProfilePictureUrl =
              versionedUrl; // Store full public URL for local state
          notifyListeners();
          _setLoading(false);
          return true;
        } else {
          _setError('Failed to update user profile in database');
          _setLoading(false);
          return false;
        }
      } else {
        _setError('Failed to upload image to storage');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to upload profile picture: $e');
      _setLoading(false);
      return false;
    }
  }

  // Delete profile picture
  Future<bool> deleteProfilePicture(
      String userId, String profilePictureUrl, UserService userService) async {
    try {
      _setLoading(true);
      _clearError();

      // Extract filename from the full URL for deletion
      final fileName = extractFilenameFromUrl(profilePictureUrl);
      if (fileName == null || fileName.isEmpty) {
        _setError('Invalid profile picture URL');
        return false;
      }

      // Delete from R2 using the extracted filename
      final deleted = await _r2Service.deleteProfilePicture(fileName);

      if (deleted) {
        // Update user profile to remove picture reference
        final success = await userService.updateUserProfileFields(userId, {
          'profilePicture': null,
          'profilePictureUpdatedAt': null,
        });

        if (success) {
          _currentProfilePictureUrl = null;
          notifyListeners();
          _setLoading(false);
          return true;
        } else {
          _setError('Failed to update user profile in database');
          _setLoading(false);
          return false;
        }
      } else {
        _setError('Failed to delete profile picture');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete profile picture: $e');
      _setLoading(false);
      return false;
    }
  }

  // Load profile picture URL
  Future<void> loadProfilePictureUrl(String profilePictureUrl) async {
    if (profilePictureUrl.isNotEmpty) {
      // The profilePictureUrl is now the complete public URL, store it for local state
      _currentProfilePictureUrl = profilePictureUrl;
      notifyListeners();
    }
  }

  // Process image (resize if needed)
  Future<File> _processImage(File imageFile) async {
    try {
      // Read image
      final bytes = await imageFile.readAsBytes();

      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Check if resizing is needed
      if (image.width <= R2Config.maxProfilePictureDimension &&
          image.height <= R2Config.maxProfilePictureDimension) {
        return imageFile; // No resizing needed
      }

      // Resize image
      final resizedImage = img.copyResize(
        image,
        width: R2Config.maxProfilePictureDimension,
        height: R2Config.maxProfilePictureDimension,
        interpolation: img.Interpolation.linear,
      );

      // Convert back to bytes
      final resizedBytes = img.encodeJpg(resizedImage, quality: 85);

      // Create temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File(
          '${tempDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(resizedBytes);

      return tempFile;
    } catch (e) {
      // Error processing image: $e
      // If processing fails, return original file
      return imageFile;
    }
  }

  // Validate image file
  bool isValidImageFile(File file) {
    try {
      // Check file size
      if (file.lengthSync() > R2Config.maxProfilePictureSize) {
        return false;
      }

      // Check file extension - be more flexible with extensions
      final path = file.path.toLowerCase();
      final hasValidExtension = R2Config.allowedProfilePictureFormats.any(
          (format) =>
              path.endsWith('.$format') ||
              path.endsWith('.$format'.toUpperCase()));

      if (!hasValidExtension) {
        return false;
      }

      // Additional validation: try to read the file to ensure it's actually an image
      try {
        final bytes = file.readAsBytesSync();
        if (bytes.length < 10) {
          return false;
        }

        // Check for common image file signatures
        final isValidImage = _isValidImageSignature(bytes);
        if (!isValidImage) {
          return false;
        }

        return true;
      } catch (e) {
        // Error reading file for validation: $e
        return false;
      }
    } catch (e) {
      // Error validating file: $e
      return false;
    }
  }

  // Check if file has valid image signature
  bool _isValidImageSignature(List<int> bytes) {
    if (bytes.length < 4) return false;

    // JPEG signature: FF D8 FF
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return true;
    }

    // PNG signature: 89 50 4E 47 0D 0A 1A 0A
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return true;
    }

    // WebP signature: 52 49 46 46 ... 57 45 42 50
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return true;
    }

    return false;
  }

  // Get file size in MB
  double getFileSizeInMB(File file) {
    final sizeInMB = file.lengthSync() / (1024 * 1024);
    return sizeInMB;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear current profile picture URL
  void clearProfilePictureUrl() {
    _currentProfilePictureUrl = null;
    notifyListeners();
  }

  // Helper method to extract filename from a profile picture URL
  String? extractFilenameFromUrl(String profilePictureUrl) {
    try {
      if (profilePictureUrl.isEmpty) {
        return null;
      }

      final uri = Uri.parse(profilePictureUrl);

      if (uri.pathSegments.isEmpty) {
        return null;
      }

      final filename =
          uri.pathSegments.last; // Automatically strips query/fragment

      // Additional validation
      if (filename.isEmpty) {
        return null;
      }

      // Check if filename looks valid (has an extension)
      if (!filename.contains('.')) {
        // Warning - extracted filename has no extension: $filename
      }

      return filename;
    } catch (e) {
      // Error parsing URI: $e
      // Fallback: naive extraction without query params
      try {
        final pathPart = profilePictureUrl.split('?').first.split('#').first;
        final filename = pathPart.split('/').last;

        // Additional validation for fallback
        if (filename.isEmpty) {
          return null;
        }

        return filename;
      } catch (_) {
        return null;
      }
    }
  }

  // Web-specific method to handle image upload
  Future<bool> uploadWebImage(
      XFile image, String userId, UserService userService) async {
    try {
      _setLoading(true);
      _clearError();

      // Get image bytes
      final bytes = await image.readAsBytes();

      // Extract extension from image name or path, default to jpg
      String extension = 'jpg'; // Default extension
      try {
        // Try to get extension from image name first (more reliable on web)
        if (image.name.isNotEmpty) {
          final nameParts = image.name.split('.');
          if (nameParts.length > 1) {
            final lastPart = nameParts.last.toLowerCase();
            if (R2Config.allowedProfilePictureFormats.contains(lastPart)) {
              extension = lastPart;
            }
          }
        }

        // Fallback to path if name didn't work
        if (extension == 'jpg' && image.path.isNotEmpty) {
          final pathParts = image.path.split('.');
          if (pathParts.length > 1) {
            final lastPart = pathParts.last.toLowerCase();
            if (R2Config.allowedProfilePictureFormats.contains(lastPart)) {
              extension = lastPart;
            }
          }
        }
      } catch (e) {
        // Error extracting extension, using default: $e
      }

      // Use the bytes upload method
      final success = await uploadProfilePictureFromBytes(
          bytes, userId, extension, userService);

      if (success) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Exception during web image upload: $e
      _setError('Failed to upload web image: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
