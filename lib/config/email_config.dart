// Email Configuration for Gmail SMTP
//
// PRODUCTION CONFIGURATION
// This file contains real Gmail credentials for production use.
//
// Security Notes:
// - 2-Factor Authentication is enabled on the Gmail account
// - App Password is used instead of regular password
// - This configuration is production-ready

class EmailConfig {
  // Gmail account credentials (PRODUCTION)
  static const String gmailUser = 'tauhusoyaaa@gmail.com';
  static const String gmailAppPassword = 'ijhz ofbi yzqf dkeu';

  // Email settings
  static const String appName = 'HR Knives';
  static const String fromName = 'HR Knives Support';

  // OTP settings
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;

  // SMTP settings
  static const String smtpServer = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const bool enableTLS = true;

  // Validation
  static bool get isConfigured {
    return gmailUser.isNotEmpty && gmailAppPassword.isNotEmpty;
  }

  // Get formatted email address
  static String get fromEmail => gmailUser;

  // Get display name for emails
  static String get displayName => fromName;
}
