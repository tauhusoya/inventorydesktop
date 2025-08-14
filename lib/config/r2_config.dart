class R2Config {
  // Cloudflare R2 Configuration
  static const String accountId = 'efecd43d152e420e6c47e6aa25707709';
  static const String accessKeyId = 'aa222bcf99f491f9d8f0f796125ca752';
  static const String secretAccessKey =
      'bb76d40b036925a60bf1b26a5a9dcd3f75802b12fb92aa088697f3b042492de8';

  // SOLUTION: Use the PRIVATE R2 instance for uploads (where files are actually stored)
  // This is the endpoint that accepts authenticated uploads
  // Based on the working logs, this endpoint works
  static const String endpoint =
      'https://efecd43d152e420e6c47e6aa25707709.r2.cloudflarestorage.com';

  // Alternative endpoint formats to try
  static const String endpointAlternative1 = 'https://r2.cloudflarestorage.com';
  static const String endpointAlternative2 =
      'https://efecd43d152e420e6c47e6aa25707709.r2.cloudflarestorage.com';

  // PUBLIC DEVELOPMENT URLs - Use Cloudflare's public R2 URLs for access
  // These URLs are publicly accessible without authentication
  static const String profilePicturesPublicUrl =
      'https://pub-16791c7de8ab472cbbe2f10d9a47d12c.r2.dev';
  static const String profilePicturesBucketAltPublicUrl =
      'https://pub-16791c7de8ab472cbbe2f10d9a47d12c.r2.dev';

  // Note: We use private endpoint for uploads and public URLs for access
  // The bucket must be configured for public read access in Cloudflare R2

  // Bucket names - try different variations
  // Based on the logs, 'profile-pictures' (with hyphen) is the working bucket
  static const String profilePicturesBucket =
      'profile-pictures'; // With hyphen (working)
  static const String profilePicturesBucketAlt =
      'profilepictures'; // No hyphen (fallback)
  static const String generalStorageBucket =
      'general-storage'; // For future use

  // Profile picture settings
  static const int maxProfilePictureSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedProfilePictureFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp'
  ];
  static const int maxProfilePictureDimension =
      1024; // Max width/height in pixels

  // AWS S3 compatible settings
  static const String region = 'auto'; // Cloudflare R2 uses 'auto' region
  static const String service = 's3';

  // URL patterns - IMPORTANT: Use public URLs for access, private endpoint for uploads
  static String getProfilePictureUrl(String fileName) {
    // Use public URL for access (no bucket name needed in path)
    return '$profilePicturesPublicUrl/$fileName';
  }

  static String getProfilePictureUrlAlternative1(String fileName) {
    // Use alternative public URL for access
    return '$profilePicturesBucketAltPublicUrl/$fileName';
  }

  static String getProfilePictureUrlAlternative2(String fileName) {
    // Fallback to main public URL
    return '$profilePicturesPublicUrl/$fileName';
  }

  static String getGeneralStorageUrl(String fileName) {
    return '$endpoint/$generalStorageBucket/$fileName';
  }
}
