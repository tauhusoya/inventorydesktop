import 'dart:async';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'user_service.dart';

class CleanupService extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  Timer? _cleanupTimer;
  static const Duration _cleanupInterval =
      Duration(minutes: 30); // Check every 30 minutes

  CleanupService(this._authService, this._userService);

  // Start the cleanup service
  void startCleanupService() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_cleanupInterval, (timer) {
      _performCleanup();
    });

    // Also perform cleanup immediately when starting
    _performCleanup();
  }

  // Stop the cleanup service
  void stopCleanupService() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  // Perform cleanup of expired deletion requests
  Future<void> _performCleanup() async {
    try {
      // Use the new server-time based cleanup method
      await performServerTimeBasedCleanup();
    } catch (e) {
      // Error during cleanup: $e
    }
  }

  // Manually trigger cleanup (useful for testing)
  Future<void> triggerCleanup() async {
    await _performCleanup();
  }

  // Perform cleanup based on server time (can be called externally)
  Future<int> performServerTimeBasedCleanup() async {
    try {
      // Get accounts that should be deleted based on server time
      final accountsToDelete =
          await _userService.getAccountsForAutomaticDeletion();

      if (accountsToDelete.isEmpty) {
        return 0;
      }

      int deletedCount = 0;
      for (final userId in accountsToDelete) {
        try {
          final success = await _authService.permanentlyDeleteAccount(userId);
          if (success) {
            deletedCount++;
          }
        } catch (e) {
          // Error deleting account $userId: $e
        }
      }

      return deletedCount;
    } catch (e) {
      // Error during server-time based cleanup: $e
      return 0;
    }
  }

  // Get accounts pending deletion (for admin purposes)
  Future<List<Map<String, dynamic>>> getPendingDeletionAccounts() async {
    try {
      // Use the new server-time based method for better accuracy
      return await _userService.getPendingDeletionAccountsWithServerTime();
    } catch (e) {
      // Error getting pending deletion accounts: $e
      return [];
    }
  }

  // Dispose resources
  @override
  void dispose() {
    stopCleanupService();
    super.dispose();
  }
}
