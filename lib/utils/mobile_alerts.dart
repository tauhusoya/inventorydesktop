import 'package:flutter/material.dart';

/// Mobile-appropriate alert and message utilities
///
/// Guidelines:
/// - Error/Warning that needs attention: AlertDialog
/// - Success/Info: SnackBar
/// - Undo/Retry actions: SnackBar with buttons
class MobileAlerts {
  /// Show an error or warning that needs user attention
  /// Use for: validation errors, critical failures, confirmations
  static Future<bool?> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(cancelText),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: isDestructive
                  ? Theme.of(context).colorScheme.onError
                  : Theme.of(context).colorScheme.onPrimary,
              elevation: 2,
            ),
            child: Text(confirmText ?? 'OK'),
          ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog for destructive actions
  /// Use for: delete, logout, irreversible changes
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: isDestructive
                  ? Theme.of(context).colorScheme.onError
                  : Theme.of(context).colorScheme.onPrimary,
              elevation: 2,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show a success message
  /// Use for: successful operations, confirmations
  static void showSuccessMessage({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      // Fallback: try to show a simple dialog if SnackBar fails
      _showFallbackMessage(context, message, 'Success');
    }
  }

  /// Show an info message
  /// Use for: informational updates, status changes
  static void showInfoMessage({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      // Fallback: try to show a simple dialog if SnackBar fails
      _showFallbackMessage(context, message, 'Info');
    }
  }

  /// Show an error message
  /// Use for: non-critical errors, validation failures
  static void showErrorMessage({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onError,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      // Fallback: try to show a simple dialog if SnackBar fails
      _showFallbackMessage(context, message, 'Error');
    }
  }

  /// Show a message with undo/retry action
  /// Use for: actions that can be undone or retried
  static void showActionMessage({
    required BuildContext context,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    Duration duration = const Duration(seconds: 5),
  }) {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            action: SnackBarAction(
              label: actionLabel,
              onPressed: onAction,
              textColor: Theme.of(context).colorScheme.primary,
            ),
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      // Fallback: try to show a simple dialog if SnackBar fails
      _showFallbackMessage(context, message, 'Action');
    }
  }

  /// Show a message with both undo and retry actions
  /// Use for: actions that can be undone or retried
  static void showUndoRetryMessage({
    required BuildContext context,
    required String message,
    required String undoLabel,
    required VoidCallback onUndo,
    required String retryLabel,
    required VoidCallback onRetry,
    Duration duration = const Duration(seconds: 6),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        action: SnackBarAction(
          label: undoLabel,
          onPressed: onUndo,
          textColor: Theme.of(context).colorScheme.primary,
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        // Add retry button in a custom way since SnackBar only supports one action
        // For now, we'll use a custom SnackBar with buttons
      ),
    );
  }

  /// Show a custom SnackBar with multiple actions
  /// Use for: complex undo/retry scenarios
  static void showCustomActionMessage({
    required BuildContext context,
    required String message,
    required List<SnackBarAction> actions,
    Duration duration = const Duration(seconds: 6),
  }) {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            action: actions.isNotEmpty ? actions.first : null,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      // Fallback: try to show a simple dialog if SnackBar fails
      _showFallbackMessage(context, message, 'Action');
    }
  }

  /// Show a warning message
  /// Use for: warnings that don't require immediate action
  static void showWarningMessage({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: Theme.of(context).colorScheme.onTertiary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            duration: duration,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      // Fallback: try to show a simple dialog if SnackBar fails
      _showFallbackMessage(context, message, 'Warning');
    }
  }

  /// Show an info message using a callback approach to avoid BuildContext dependencies
  /// Use for: cases where BuildContext might not be available or valid
  static void showInfoMessageWithCallback({
    required String message,
    required VoidCallback showMessage,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Execute the callback to show the message
    showMessage();
  }

  /// Fallback method to show a simple dialog when SnackBar fails
  static void _showFallbackMessage(
      BuildContext context, String message, String title) {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          title: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Failed to show message: $message
    }
  }

  /// Test method to demonstrate all alert types for color visibility testing
  /// Use this in development to verify colors are working properly
  static void showAllAlertTypes(BuildContext context) {
    // Show success message
    showSuccessMessage(
      context: context,
      message: 'This is a success message with proper contrast',
    );

    // Show info message after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        showInfoMessage(
          context: context,
          message: 'This is an info message with proper contrast',
        );
      }
    });

    // Show warning message after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        showWarningMessage(
          context: context,
          message: 'This is a warning message with proper contrast',
        );
      }
    });

    // Show error message after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        showErrorMessage(
          context: context,
          message: 'This is an error message with proper contrast',
        );
      }
    });

    // Show action message after a delay
    Future.delayed(const Duration(seconds: 4), () {
      if (context.mounted) {
        showActionMessage(
          context: context,
          message: 'This is an action message with proper contrast',
          actionLabel: 'Undo',
          onAction: () {
            // Action performed
          },
        );
      }
    });
  }
}
