import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/r2_config.dart';

class R2StorageService {
  static final R2StorageService _instance = R2StorageService._internal();
  factory R2StorageService() => _instance;
  R2StorageService._internal();

  final Uuid _uuid = const Uuid();

  // Track successful upload endpoint and bucket for consistent URL generation
  String? _lastSuccessfulEndpoint;
  String? _lastSuccessfulBucket;

  // Upload profile picture to R2
  Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    try {
      // Validate file
      if (!_isValidProfilePicture(imageFile)) {
        throw Exception('Invalid profile picture file');
      }

      // Generate unique filename
      final extension = path.extension(imageFile.path);
      if (extension.isEmpty) {
        throw Exception('No file extension found for file: ${imageFile.path}');
      }
      final cleanExtension = extension.toLowerCase();
      final fileName = 'profile_${userId}_${_uuid.v4()}$cleanExtension';

      // Read file bytes
      final bytes = await imageFile.readAsBytes();

      // Try different bucket names and endpoints
      final List<String> bucketNames = [
        R2Config.profilePicturesBucket,
        R2Config.profilePicturesBucketAlt,
      ];

      final List<String> endpoints = [
        R2Config.endpoint,
        R2Config.endpointAlternative1,
        R2Config.endpointAlternative2,
      ];

      Exception? lastException;

      for (final endpoint in endpoints) {
        for (final bucketName in bucketNames) {
          try {
            // For Cloudflare R2, the URL should include the bucket name
            // but the canonical URI for signing should not
            final url = '$endpoint/$bucketName/$fileName';
            final contentType = _getContentType(extension);

            final headers = _generateS3Headers(
                'PUT', fileName, contentType, bytes, bucketName, endpoint);

            final response = await http.put(
              Uri.parse(url),
              headers: headers,
              body: bytes,
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              // Store successful endpoint and bucket for consistent URL generation
              _lastSuccessfulEndpoint = endpoint;
              _lastSuccessfulBucket = bucketName;
              return fileName;
            } else {
              lastException = Exception(
                  'Failed to upload profile picture: ${response.statusCode} - ${response.body}');
            }
          } catch (e) {
            lastException = Exception('Upload error: $e');
          }
        }
      }

      // If we get here, all methods failed
      throw lastException ?? Exception('All upload methods failed');
    } catch (e) {
      throw Exception('Error uploading profile picture: $e');
    }
  }

  // Upload profile picture from bytes (useful for web)
  Future<String?> uploadProfilePictureFromBytes(
      Uint8List bytes, String userId, String extension) async {
    try {
      // Validate file size
      if (bytes.length > R2Config.maxProfilePictureSize) {
        throw Exception('File size exceeds maximum allowed size');
      }

      // Generate unique filename
      final fileName = 'profile_${userId}_${_uuid.v4()}.$extension';

      // Build target object path
      final objectPath =
          '${R2Config.endpoint}/${R2Config.profilePicturesBucket}/$fileName';
      final contentType = _getContentType(extension);

      if (kIsWeb) {
        // On web, use a presigned URL to avoid Authorization header CORS issues
        final presignedUrl = _generatePresignedPutUrl(
          fileName: fileName,
          bucketName: R2Config.profilePicturesBucket,
          endpoint: R2Config.endpoint,
          expiresInSeconds: 900,
        );

        final response = await http.put(
          Uri.parse(presignedUrl),
          headers: {
            // Keep headers minimal to reduce preflight complexity
            'Content-Type': contentType,
          },
          body: bytes,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return fileName;
        } else {
          throw Exception(
              'Failed to upload profile picture (web presigned): ${response.statusCode} - ${response.body}');
        }
      } else {
        // Native/Desktop: use signed headers
        final headers = _generateS3Headers('PUT', fileName, contentType, bytes,
            R2Config.profilePicturesBucket, R2Config.endpoint);

        final response = await http.put(
          Uri.parse(objectPath),
          headers: headers,
          body: bytes,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return fileName;
        } else {
          throw Exception(
              'Failed to upload profile picture: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error uploading profile picture from bytes: $e');
    }
  }

  // Generate a presigned URL for PUT (useful for web uploads)
  String _generatePresignedPutUrl({
    required String fileName,
    required String bucketName,
    required String endpoint,
    int expiresInSeconds = 900,
  }) {
    final now = DateTime.now().toUtc();
    final amzDate =
        '${now.toIso8601String().split('.')[0].replaceAll('-', '').replaceAll(':', '')}Z';
    final dateStamp = now.toIso8601String().split('T')[0].replaceAll('-', '');

    final host = Uri.parse(endpoint).host;
    final canonicalUri = '/$bucketName/$fileName';

    // Credential scope and query params
    final credentialScope =
        '$dateStamp/${R2Config.region}/${R2Config.service}/aws4_request';

    final queryParams = <String, String>{
      'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
      // Important: do not pre-encode here; encoding happens when building the canonical query string
      'X-Amz-Credential': '${R2Config.accessKeyId}/$credentialScope',
      'X-Amz-Date': amzDate,
      'X-Amz-Expires': expiresInSeconds.toString(),
      'X-Amz-SignedHeaders': 'host',
      // Optional hint for Cloudflare R2 routing
      'x-id': 'PutObject',
    };

    // Build canonical query string (sorted by key)
    final sortedKeys = queryParams.keys.toList()..sort();
    final canonicalQueryString = sortedKeys
        .map((k) =>
            '${Uri.encodeQueryComponent(k)}=${Uri.encodeQueryComponent(queryParams[k]!)}')
        .join('&');

    // Canonical headers and signed headers
    final canonicalHeaders = 'host:$host\n';
    const signedHeaders = 'host';

    // Use UNSIGNED-PAYLOAD for presigned URL
    const payloadHash = 'UNSIGNED-PAYLOAD';

    final canonicalRequest = [
      'PUT',
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    final algorithm = 'AWS4-HMAC-SHA256';
    final stringToSign = [
      algorithm,
      amzDate,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    // Derive signing key
    final kDate = Hmac(sha256, utf8.encode('AWS4${R2Config.secretAccessKey}'))
        .convert(utf8.encode(dateStamp));
    final kRegion =
        Hmac(sha256, kDate.bytes).convert(utf8.encode(R2Config.region));
    final kService =
        Hmac(sha256, kRegion.bytes).convert(utf8.encode(R2Config.service));
    final kSigning =
        Hmac(sha256, kService.bytes).convert(utf8.encode('aws4_request'));
    final signature = Hmac(sha256, kSigning.bytes)
        .convert(utf8.encode(stringToSign))
        .toString();

    // Append signature to query
    final presignedQuery = '$canonicalQueryString&X-Amz-Signature=$signature';
    final presignedUrl = '$endpoint$canonicalUri?$presignedQuery';
    return presignedUrl;
  }

  // Generate AWS S3 compatible headers for DELETE operations
  Map<String, String> _generateS3HeadersForDelete(
      String fileName, String bucketName, String endpoint) {
    final now = DateTime.now().toUtc();
    // Format date as YYYYMMDDTHHMMSSZ (AWS S3 standard format)
    final date =
        '${now.toIso8601String().split('.')[0].replaceAll('-', '').replaceAll(':', '')}Z';
    // Format dateStamp as YYYYMMDD (AWS S3 standard format)
    final dateStamp = now.toIso8601String().split('T')[0].replaceAll('-', '');

    // Create canonical request for DELETE
    final canonicalUri = '/$bucketName/$fileName';
    final canonicalQueryString = '';

    // For DELETE requests, we only need host and x-amz-date headers
    final sortedHeaders = <String, String>{
      'host': Uri.parse(endpoint).host,
      'x-amz-date': date,
    };

    final canonicalHeaders =
        '${sortedHeaders.entries.map((e) => '${e.key}:${e.value}').join('\n')}\n';
    final signedHeaders = sortedHeaders.keys.join(';');

    // For DELETE requests, use empty payload hash
    const payloadHash =
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

    final canonicalRequest = [
      'DELETE',
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    // Create string to sign
    final algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope =
        '$dateStamp/${R2Config.region}/${R2Config.service}/aws4_request';
    final stringToSign = [
      algorithm,
      date,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    // Calculate signature
    final kDate = Hmac(sha256, utf8.encode('AWS4${R2Config.secretAccessKey}'))
        .convert(utf8.encode(dateStamp));
    final kRegion =
        Hmac(sha256, kDate.bytes).convert(utf8.encode(R2Config.region));
    final kService =
        Hmac(sha256, kRegion.bytes).convert(utf8.encode(R2Config.service));
    final kSigning =
        Hmac(sha256, kService.bytes).convert(utf8.encode('aws4_request'));
    final signature = Hmac(sha256, kSigning.bytes)
        .convert(utf8.encode(stringToSign))
        .toString();

    // Create authorization header
    final authorization =
        '$algorithm Credential=${R2Config.accessKeyId}/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

    return {
      'Authorization': authorization,
      'X-Amz-Date': date,
    };
  }

  // Generate AWS S3 compatible headers
  Map<String, String> _generateS3Headers(String method, String fileName,
      String contentType, Uint8List body, String bucketName, String endpoint) {
    final now = DateTime.now().toUtc();
    // Format date as YYYYMMDDTHHMMSSZ (AWS S3 standard format)
    final date =
        '${now.toIso8601String().split('.')[0].replaceAll('-', '').replaceAll(':', '')}Z';
    // Format dateStamp as YYYYMMDD (AWS S3 standard format)
    final dateStamp = now.toIso8601String().split('T')[0].replaceAll('-', '');

    // Create canonical request
    // For Cloudflare R2, the canonical URI should include the bucket name
    // because the bucket is part of the path, not the hostname
    final canonicalUri = '/$bucketName/$fileName';
    final canonicalQueryString = '';

    // Sort headers alphabetically as required by AWS S3
    final sortedHeaders = <String, String>{
      'content-length': body.length.toString(),
      'content-type': contentType,
      'host': Uri.parse(endpoint).host,
      'x-amz-date': date,
    };

    final canonicalHeaders =
        '${sortedHeaders.entries.map((e) => '${e.key}:${e.value}').join('\n')}\n';
    final signedHeaders = sortedHeaders.keys.join(';');

    // Create payload hash
    final payloadHash = sha256.convert(body).toString();

    final canonicalRequest = [
      method,
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    // Create string to sign
    final algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope =
        '$dateStamp/${R2Config.region}/${R2Config.service}/aws4_request';
    final stringToSign = [
      algorithm,
      date,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    // Calculate signature
    final kDate = Hmac(sha256, utf8.encode('AWS4${R2Config.secretAccessKey}'))
        .convert(utf8.encode(dateStamp));
    final kRegion =
        Hmac(sha256, kDate.bytes).convert(utf8.encode(R2Config.region));
    final kService =
        Hmac(sha256, kRegion.bytes).convert(utf8.encode(R2Config.service));
    final kSigning =
        Hmac(sha256, kService.bytes).convert(utf8.encode('aws4_request'));
    final signature = Hmac(sha256, kSigning.bytes)
        .convert(utf8.encode(stringToSign))
        .toString();

    // Create authorization header
    final authorization =
        '$algorithm Credential=${R2Config.accessKeyId}/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

    return {
      'Authorization': authorization,
      'Content-Type': contentType,
      'Content-Length': body.length.toString(),
      'X-Amz-Date': date,
      'X-Amz-Content-Sha256': payloadHash,
    };
  }

  // Delete profile picture from R2
  Future<bool> deleteProfilePicture(String fileName) async {
    try {
      // For Cloudflare R2, the URL should include the bucket name
      // but the canonical URI for signing should not
      final url =
          '${R2Config.endpoint}/${R2Config.profilePicturesBucket}/$fileName';

      // For DELETE requests, we need to handle headers differently
      // DELETE requests typically don't need content-type or content-length
      final response = await http.delete(
        Uri.parse(url),
        headers: _generateS3HeadersForDelete(
            fileName, R2Config.profilePicturesBucket, R2Config.endpoint),
      );

      final success = response.statusCode == 200 || response.statusCode == 204;

      return success;
    } catch (e) {
      throw Exception('Error deleting profile picture: $e');
    }
  }

  // Get profile picture URL
  String getProfilePictureUrl(String fileName) {
    // Use public URL for access
    return R2Config.getProfilePictureUrl(fileName);
  }

  // Check if profile picture exists
  Future<bool> profilePictureExists(String fileName) async {
    try {
      // Check public URL without auth headers
      final url = R2Config.getProfilePictureUrl(fileName);
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get content type based on file extension
  String _getContentType(String extension) {
    // Handle null or empty extension
    if (extension.isEmpty) {
      return 'image/jpeg';
    }

    // Remove the dot if present
    final cleanExtension =
        extension.startsWith('.') ? extension.substring(1) : extension;

    switch (cleanExtension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // Default to JPEG
    }
  }

  // Validate profile picture file
  bool _isValidProfilePicture(File file) {
    // Check file size
    if (file.lengthSync() > R2Config.maxProfilePictureSize) {
      return false;
    }

    // Check file extension
    final extension = path.extension(file.path);
    if (extension.isEmpty) {
      return false;
    }

    final cleanExtension = extension.toLowerCase().replaceAll('.', '');
    if (!R2Config.allowedProfilePictureFormats.contains(cleanExtension)) {
      return false;
    }

    return true;
  }

  // Generate thumbnail filename
  String generateThumbnailFileName(String originalFileName) {
    if (originalFileName.isEmpty) {
      return '';
    }
    final nameWithoutExt = path.basenameWithoutExtension(originalFileName);
    final extension = path.extension(originalFileName);
    return '${nameWithoutExt}_thumb$extension';
  }

  // Get file extension from filename
  String getFileExtension(String fileName) {
    if (fileName.isEmpty) {
      return '';
    }
    final extension = path.extension(fileName);
    if (extension.isEmpty) {
      return '';
    }
    return extension.toLowerCase().replaceAll('.', '');
  }

  // Generate unique filename with timestamp
  String generateUniqueFileName(String userId, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'profile_${userId}_$timestamp.$extension';
  }

  // Manually set the working endpoint and bucket (useful for testing)
  void setWorkingEndpointAndBucket(String endpoint, String bucket) {
    _lastSuccessfulEndpoint = endpoint;
    _lastSuccessfulBucket = bucket;
  }

  // Get current working endpoint and bucket
  Map<String, String?> getWorkingEndpointAndBucket() {
    return {
      'endpoint': _lastSuccessfulEndpoint,
      'bucket': _lastSuccessfulBucket,
    };
  }

  // Get public development URL for a specific bucket
  String getPublicDevelopmentUrl(String bucketName) {
    // Use public development URL without bucket name for direct access
    return R2Config.profilePicturesPublicUrl;
  }

  // Get profile picture URL using public development URL
  String getProfilePictureUrlPublic(String fileName, {String? bucketName}) {
    // Use public development URL without bucket name for direct access
    return '${R2Config.profilePicturesPublicUrl}/$fileName';
  }

  // Test if public development URL is accessible
  Future<bool> testPublicDevelopmentUrl() async {
    try {
      // Test with a sample profile picture filename using the public development URL
      final testUrl =
          '${R2Config.profilePicturesPublicUrl}/test_profile_picture.jpg';
      final response = await http.get(Uri.parse(testUrl));
      return response.statusCode == 200 ||
          response.statusCode == 404; // 404 means accessible but file not found
    } catch (e) {
      return false;
    }
  }

  // Test if a specific profile picture URL is accessible
  Future<bool> testProfilePictureUrl(String profilePictureUrl) async {
    try {
      final response = await http.get(Uri.parse(profilePictureUrl));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Extract filename from a profile picture URL
  String? extractFilenameFromUrl(String profilePictureUrl) {
    try {
      if (profilePictureUrl.isEmpty) return null;
      final parts = profilePictureUrl.split('/');
      if (parts.isEmpty) return null;
      return parts.last;
    } catch (e) {
      return null;
    }
  }
}
