import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_service.dart';
import '../../widgets/profile_picture_widget.dart';
import '../../utils/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../utils/mobile_alerts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  late Future<void> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _initializeUserService();
  }

  Future<void> _initializeUserService() async {
    final userService = context.read<UserService>();
    await userService.initialize();
  }

  void _refreshUserProfile() {
    final userService = Provider.of<UserService>(context, listen: false);
    setState(() {
      _userProfileFuture = userService.getCurrentUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Title
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your account preferences and settings',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 32),

                _buildSettingsSection(
                  'Account Settings',
                  Icons.person,
                  [
                    _buildUserProfileCard(),
                    _buildAccountActionTile(
                      'Edit Profile',
                      'Update your personal information',
                      Icons.edit,
                      () => _editProfile(),
                    ),
                    _buildAccountActionTile(
                      'Change Password',
                      'Update your account password',
                      Icons.lock,
                      () => _changePassword(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingsSection(
                  'Preferences',
                  Icons.settings,
                  [
                    _buildSwitchTile(
                      'Enable Notifications',
                      'Receive alerts for low stock and important updates',
                      _notificationsEnabled,
                      (value) => setState(() => _notificationsEnabled = value),
                    ),
                    Consumer<ThemeService>(
                      builder: (context, themeService, child) {
                        return _buildAccountActionTile(
                          'Theme',
                          'Choose your preferred theme (${themeService.currentThemeDisplayName})',
                          Icons.palette,
                          () => _showThemeDialog(context, themeService),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingsSection(
                  'Storage Management',
                  Icons.storage,
                  [
                    _buildStorageTile(
                      'Clear Cache',
                      'Free up storage space by clearing cached data',
                      Icons.cleaning_services,
                      () => _clearCache(context),
                    ),
                    _buildInfoTile(
                      'Cache Size',
                      'Current size of cached data',
                      Icons.data_usage,
                      _getCacheSize(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingsSection(
                  'Support & Info',
                  Icons.info,
                  [
                    _buildInfoTile(
                      'App Version',
                      'Current version of the application',
                      Icons.app_settings_alt,
                      _getAppVersion(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingsSection(
                  'Danger Zone',
                  Icons.warning,
                  [
                    _buildDangerTile(
                      'Sign Out',
                      'Sign out of your account',
                      Icons.logout,
                      () => _signOut(context),
                    ),
                    _buildDangerTile(
                      'Delete Account',
                      'Permanently delete your account and data',
                      Icons.delete_forever,
                      () => _deleteAccount(context),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsSection(
      String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          // Section Content
          ...children,
        ],
      ),
    );
  }

  String _getDisplayName(String? firstName, String? lastName, String username) {
    if (firstName != null &&
        firstName.isNotEmpty &&
        lastName != null &&
        lastName.isNotEmpty) {
      return '$firstName $lastName';
    }
    return username;
  }

  Widget _buildUserProfileCard() {
    return Consumer2<AuthService, UserService>(
      builder: (context, authService, userService, child) {
        final user = authService.currentUser;
        if (user == null) {
          return const SizedBox.shrink();
        }

        // Get the current user profile from the UserService
        final userProfile = userService.currentUserProfile;

        if (userProfile == null) {
          // If no profile is loaded yet, show loading
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final displayName = _getDisplayName(
            userProfile.firstName, userProfile.lastName, userProfile.username);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              SmallProfilePictureWidget(
                profilePictureUrl: userProfile.profilePicture,
                displayName: displayName,
                email: user.email,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      'Role: ${userProfile.role}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _refreshUserProfile(),
                    tooltip: 'Refresh Profile',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActionTile(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDangerTile(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ListTile(
        leading: Icon(icon, color: statusError(context)),
        title: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: statusError(context)),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: statusError(context)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile(
      String title, String subtitle, IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  String _getAppVersion() {
    return '1.0.0+1';
  }

  String _getCacheSize() {
    // This would typically get the actual cache size from the app
    // For now, returning a placeholder value
    return '2.4 MB';
  }

  Widget _buildStorageTile(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // Action Methods
  void _editProfile() async {
    final result = await Navigator.pushNamed(context, '/edit-profile');

    // Refresh the user profile when returning from edit screen
    if (result == true) {
      _refreshUserProfile();
    }
  }

  void _changePassword() async {
    await Navigator.pushNamed(context, '/change-password');
  }

  void _clearCache(BuildContext context) async {
    final confirmed = await MobileAlerts.showConfirmationDialog(
      context: context,
      title: 'Clear Cache',
      message:
          'Are you sure you want to clear all cached data? This will free up storage space but may temporarily slow down the app on next use.',
      confirmText: 'Clear Cache',
      cancelText: 'Cancel',
      isDestructive: false,
    );

    if (confirmed == true && mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            content: Row(
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 20),
                Text(
                  'Clearing cache...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        },
      );

      try {
        // Simulate cache clearing process
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog

          // Show success message
          MobileAlerts.showInfoMessage(
            context: context,
            message:
                'Cache cleared successfully! Storage space has been freed up.',
          );

          // Refresh the cache size display
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          MobileAlerts.showInfoMessage(
            context: context,
            message: 'Failed to clear cache: ${e.toString()}',
          );
        }
      }
    }
  }

  void _signOut(BuildContext context) async {
    final authService = context.read<AuthService>();
    final navigator = Navigator.of(context);

    final confirmed = await MobileAlerts.showConfirmationDialog(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      isDestructive: false,
    );

    if (confirmed == true && mounted) {
      await authService.signOut();

      // Force navigation to login screen
      if (mounted) {
        navigator.pushReplacementNamed('/force-login');
      }
    }
  }

  void _deleteAccount(BuildContext context) async {
    final confirmed = await MobileAlerts.showConfirmationDialog(
      context: context,
      title: 'Delete Account',
      message:
          'Your account will be marked for deletion with a 24-hour recovery window. During this time, you can log back in to recover your account. After 24 hours, your data will be permanently deleted.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            content: Row(
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 20),
                Text(
                  'Marking account for deletion...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        },
      );

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final success = await authService.deleteAccount();

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog

          if (success) {
            // Show success message with recovery information
            MobileAlerts.showInfoMessage(
              context: context,
              message:
                  'Account marked for deletion. You have 24 hours to recover your account by logging back in. After 24 hours, your data will be permanently deleted.',
            );

            // Navigate to login screen
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          } else {
            // Check if re-authentication is required
            if (authService.error?.contains('requires-recent-login') == true) {
              _showReAuthenticationDialog(context, authService);
            } else {
              // Show error message
              MobileAlerts.showInfoMessage(
                context: context,
                message: authService.error ??
                    'Failed to mark account for deletion. Please try again.',
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          MobileAlerts.showInfoMessage(
            context: context,
            message: 'An unexpected error occurred: ${e.toString()}',
          );
        }
      }
    }
  }

  void _showReAuthenticationDialog(
      BuildContext context, AuthService authService) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          title: Text(
            'Re-authentication Required',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'For security reasons, please enter your password to confirm account deletion.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will have 24 hours to recover your account by logging back in.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAccountWithReAuth(
                    context, authService, passwordController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccountWithReAuth(
      BuildContext context, AuthService authService, String password) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          content: Row(
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 20),
              Text(
                'Verifying password and marking account for deletion...',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );

    try {
      // First re-authenticate
      final reAuthSuccess = await authService.reAuthenticateUser(password);

      if (reAuthSuccess) {
        // Now try to mark the account for deletion
        final deleteSuccess = await authService.deleteAccount();

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog

          if (deleteSuccess) {
            MobileAlerts.showInfoMessage(
              context: context,
              message:
                  'Account marked for deletion. You have 24 hours to recover your account by logging back in. After 24 hours, your data will be permanently deleted.',
            );

            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          } else {
            MobileAlerts.showInfoMessage(
              context: context,
              message: authService.error ??
                  'Failed to mark account for deletion after re-authentication.',
            );
          }
        }
      } else {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          MobileAlerts.showInfoMessage(
            context: context,
            message: authService.error ?? 'Password verification failed.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        MobileAlerts.showInfoMessage(
          context: context,
          message: 'An unexpected error occurred: ${e.toString()}',
        );
      }
    }
  }

  void _showThemeDialog(BuildContext context, ThemeService themeService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          title: Text(
            'Choose Theme',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(
                  'System',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Follow system theme',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                value: ThemeMode.system,
                groupValue: themeService.themeMode,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeService.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(
                  'Light',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Always use light theme',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                value: ThemeMode.light,
                groupValue: themeService.themeMode,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeService.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(
                  'Dark',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Always use dark theme',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                value: ThemeMode.dark,
                groupValue: themeService.themeMode,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeService.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
