import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/profile_picture_service.dart';
import '../../utils/mobile_alerts.dart';
import '../../widgets/profile_picture_widget.dart';
import '../../widgets/profile_picture_picker_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isUsernameAvailable = true;
  bool _isCheckingUsername = false;
  bool _hasUsernameFieldBeenFocused = false;
  String? _errorMessage;
  String? _successMessage;
  String? _currentProfilePicture;

  // Track if user has ever filled both first and last name
  bool _hasEverFilledBothNames = false;
  bool _hasInitializedNames = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserData() async {
    final authService = context.read<AuthService>();
    final userService = Provider.of<UserService>(context, listen: false);
    final user = authService.currentUser;

    if (user != null) {
      try {
        final userProfile = await userService.getCurrentUserProfile();

        setState(() {
          if (userProfile != null) {
            _firstNameController.text = userProfile.firstName ?? '';
            _lastNameController.text = userProfile.lastName ?? '';
            _usernameController.text = userProfile.username ?? '';
            _emailController.text = userProfile.email ?? user.email ?? '';
            _currentProfilePicture = userProfile.profilePicture;

            // Check if user has ever filled both names
            _hasEverFilledBothNames =
                (userProfile.firstName?.isNotEmpty == true &&
                    userProfile.lastName?.isNotEmpty == true);
            _hasInitializedNames = true;

            // Initialize the ProfilePictureService with the current profile picture
            final profilePictureService = context.read<ProfilePictureService>();
            profilePictureService
                .setCurrentProfilePictureUrl(userProfile.profilePicture);
          } else {
            // Fallback to auth service data if user profile is null
            _firstNameController.text = '';
            _lastNameController.text = '';
            _usernameController.text = user.username ?? '';
            _emailController.text = user.email ?? '';
            _currentProfilePicture = null;
            _hasEverFilledBothNames = false;
            _hasInitializedNames = true;

            print(
                'DEBUG: Setting email to (fallback): "${_emailController.text}"');
            print(
                'DEBUG: Setting username to (fallback): "${_usernameController.text}"');

            // Initialize the ProfilePictureService with null
            final profilePictureService = context.read<ProfilePictureService>();
            profilePictureService.setCurrentProfilePictureUrl(null);
          }
        });
      } catch (e) {
        // Fallback to auth service data if there's an error
        setState(() {
          _firstNameController.text = '';
          _lastNameController.text = '';
          _usernameController.text = user.username ?? '';
          _emailController.text = user.email ?? '';
          _currentProfilePicture = null;
          _hasEverFilledBothNames = false;
          _hasInitializedNames = true;

          print(
              'DEBUG: Setting email to (error fallback): "${_emailController.text}"');
          print(
              'DEBUG: Setting username to (error fallback): "${_usernameController.text}"');

          // Initialize the ProfilePictureService with null
          final profilePictureService = context.read<ProfilePictureService>();
          profilePictureService.setCurrentProfilePictureUrl(null);
        });
      }
    } else {}
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty || username.length < 3) return;

    final userService = context.read<UserService>();
    final currentUser = context.read<AuthService>().currentUser;

    // If username is the same as current user, it's available
    if (currentUser != null &&
        username.toLowerCase() == currentUser.username.toLowerCase()) {
      setState(() {
        _isUsernameAvailable = true;
        _isCheckingUsername = false;
      });
      return;
    }

    setState(() => _isCheckingUsername = true);

    try {
      final isTaken = await userService.isUsernameTaken(username);
      if (mounted) {
        setState(() {
          _isUsernameAvailable = !isTaken;
          _isCheckingUsername = false;
        });
      }
    } catch (e) {
      // If there's an error checking availability, assume it's available
      if (mounted) {
        setState(() {
          _isUsernameAvailable = true;
          _isCheckingUsername = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final userService = context.read<UserService>();
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Validate username availability
      if (!_isUsernameAvailable) {
        throw Exception('Username is already taken');
      }

      // Update user profile
      final success = await userService.updateUserProfileFields(
        currentUser.id,
        {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'username': _usernameController.text.trim(),
        },
      );

      if (success) {
        // Update tracking variable if both names are now filled
        if (_firstNameController.text.trim().isNotEmpty &&
            _lastNameController.text.trim().isNotEmpty) {
          _hasEverFilledBothNames = true;
        }

        setState(() {
          _successMessage = 'Profile updated successfully!';
        });

        // Refresh auth service to get updated user data
        await authService.refreshUserProfile();

        // Show success message and navigate back after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(true); // Return true to indicate success
          }
        });
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button in App Layout Area
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context)
                            .pop(false), // Return false to indicate no changes
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title Below App Layout
                  Text(
                    'Edit Your Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Update your personal information and preferences',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Picture Section
                  _buildProfilePictureSection(),
                  const SizedBox(height: 32),

                  // Form Fields
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildNameFields(),
                          const SizedBox(height: 24),
                          _buildUsernameField(),
                          const SizedBox(height: 24),
                          _buildEmailField(),
                          const SizedBox(height: 32),

                          // Error and Success Messages
                          if (_errorMessage != null)
                            _buildMessageCard(
                              _errorMessage!,
                              Icons.error,
                              statusError(context),
                              true,
                            ),
                          if (_successMessage != null)
                            _buildMessageCard(
                              _successMessage!,
                              Icons.check_circle,
                              statusSuccess(context),
                              false,
                            ),

                          const SizedBox(height: 32),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _saveProfile,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Consumer<ProfilePictureService>(
      builder: (context, profilePictureService, child) {
        // Get the current profile picture from the service
        final currentPictureUrl =
            profilePictureService.currentProfilePictureUrl;

        return Center(
          child: Column(
            children: [
              // Use our new profile picture widget
              LargeProfilePictureWidget(
                profilePictureUrl: currentPictureUrl,
                displayName: _getDisplayName(),
                email: _emailController.text,
                isEditable: false, // We'll handle editing through the button
                size: 100,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _showProfilePicturePicker,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Change Photo'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNameFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Desktop view - side by side
              return Row(
                children: [
                  Expanded(
                    child: _buildFirstNameField(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLastNameField(),
                  ),
                ],
              );
            } else {
              // Mobile view - stacked
              return Column(
                children: [
                  _buildFirstNameField(),
                  const SizedBox(height: 16),
                  _buildLastNameField(),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _firstNameController,
      decoration: InputDecoration(
        hintText: 'Enter your first name',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        final trimmedValue = value?.trim() ?? '';

        // If user has never filled both names, both are required
        if (!_hasEverFilledBothNames) {
          if (trimmedValue.isEmpty) {
            return 'First name is required. Both first and last name must be filled.';
          }
          if (trimmedValue.length < 2) {
            return 'First name must be at least 2 characters';
          }
          // Check if last name is also filled
          final lastNameTrimmed = _lastNameController.text.trim();
          if (lastNameTrimmed.isEmpty) {
            return 'Both first and last name must be filled together';
          }
        } else {
          // User has previously filled both names, so first name cannot be left blank
          if (trimmedValue.isEmpty) {
            return 'First name cannot be left blank once it has been filled';
          }
          if (trimmedValue.length < 2) {
            return 'First name must be at least 2 characters';
          }
        }
        return null;
      },
      onChanged: (value) {
        // Trigger validation for both fields when either changes
        if (_hasInitializedNames) {
          _formKey.currentState?.validate();
        }
      },
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: _lastNameController,
      decoration: InputDecoration(
        hintText: 'Enter your last name',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        final trimmedValue = value?.trim() ?? '';

        // If user has never filled both names, both are required
        if (!_hasEverFilledBothNames) {
          if (trimmedValue.isEmpty) {
            return 'Last name is required. Both first and last name must be filled.';
          }
          if (trimmedValue.length < 2) {
            return 'Last name must be at least 2 characters';
          }
          // Check if first name is also filled
          final firstNameTrimmed = _firstNameController.text.trim();
          if (firstNameTrimmed.isEmpty) {
            return 'Both first and last name must be filled together';
          }
        } else {
          // User has previously filled both names, so last name cannot be left blank
          if (trimmedValue.isEmpty) {
            return 'Last name cannot be left blank once it has been filled';
          }
          if (trimmedValue.length < 2) {
            return 'Last name must be at least 2 characters';
          }
        }
        return null;
      },
      onChanged: (value) {
        // Trigger validation for both fields when either changes
        if (_hasInitializedNames) {
          _formKey.currentState?.validate();
        }
      },
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: 'Enter your username',
            prefixIcon: const Icon(Icons.person),
            suffixIcon: _usernameController.text.isNotEmpty
                ? _isCheckingUsername
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isUsernameAvailable ? Icons.check_circle : Icons.error,
                        color: _isUsernameAvailable
                            ? statusSuccess(context)
                            : statusError(context),
                      )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username is required';
            }
            if (value.trim().length < 3) {
              return 'Username must be at least 3 characters';
            }
            if (value.trim().length > 20) {
              return 'Username must be less than 20 characters';
            }
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
              return 'Username can only contain letters, numbers, and underscores';
            }
            if (!_isUsernameAvailable) {
              return 'Username is already taken';
            }
            return null;
          },
          onTap: () {
            // Mark that the field has been focused/clicked
            if (!_hasUsernameFieldBeenFocused) {
              setState(() {
                _hasUsernameFieldBeenFocused = true;
              });
            }
          },
          onChanged: (value) {
            // Reset availability when text is empty
            if (value.isEmpty) {
              setState(() {
                _isUsernameAvailable = true;
                _isCheckingUsername = false;
                _hasUsernameFieldBeenFocused = false;
              });
              return;
            }

            // Check availability after user stops typing (300ms delay)
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted &&
                  value == _usernameController.text &&
                  value.length >= 3) {
                _checkUsernameAvailability(value);
              }
            });
          },
        ),
        // Show availability status only after field has been focused and user is typing
        if (_hasUsernameFieldBeenFocused &&
            _usernameController.text.isNotEmpty &&
            _usernameController.text.length >= 3)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                if (_isCheckingUsername)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    _isUsernameAvailable ? Icons.check_circle : Icons.error,
                    size: 16,
                    color: _isUsernameAvailable
                        ? statusSuccess(context)
                        : statusError(context),
                  ),
                const SizedBox(width: 8),
                Text(
                  _isCheckingUsername
                      ? 'Checking username availability...'
                      : _isUsernameAvailable
                          ? 'Username is available'
                          : 'Username is already taken',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isCheckingUsername
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : _isUsernameAvailable
                            ? statusSuccess(context)
                            : statusError(context),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Debug text to show what's in the controller
                if (_emailController.text.isNotEmpty)
                  TextFormField(
                    controller: _emailController,
                    enabled: false, // Email cannot be changed
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Email address cannot be changed once registered. Contact an administrator if you need to update your email.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard(
      String message, IconData icon, Color color, bool isError) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isError)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                setState(() => _errorMessage = null);
              },
              color: color,
            ),
        ],
      ),
    );
  }

  // Helper method to get display name
  String _getDisplayName() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      final displayName = '$firstName $lastName';
      return displayName;
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else {
      final username = _usernameController.text.trim();
      return username;
    }
  }

  // Show profile picture picker dialog
  void _showProfilePicturePicker() {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user != null) {
      showDialog(
        context: context,
        builder: (context) => ProfilePicturePickerDialog(
          userId: user.id,
          currentProfilePicture: _currentProfilePicture,
          displayName: _getDisplayName(),
        ),
      ).then((result) {
        if (result == true) {
          // Profile picture was updated, refresh the display
          _loadCurrentUserData();
        }
      });
    } else {
      MobileAlerts.showErrorMessage(
        context: context,
        message: 'User not authenticated',
      );
    }
  }
}
