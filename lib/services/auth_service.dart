import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'user_service.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  final String role;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.createdAt,
  });

  factory AppUser.fromFirebase(firebase_auth.User user) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      username: user.displayName ?? user.email?.split('@')[0] ?? 'User',
      role: 'Staff', // Default role
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
    };
  }
}

class AuthService extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final UserService _userService;
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthService(this._userService) {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Stream for auth state changes - fixed to prevent infinite loops
  Stream<AppUser?> get authStateChanges {
    try {
      return _auth.authStateChanges().timeout(
        const Duration(seconds: 5), // 5 second timeout
        onTimeout: (sink) {
          sink.add(null); // Force show login screen
          sink.close(); // Close the stream to prevent infinite loops
        },
      ).map((firebaseUser) {
        if (firebaseUser != null) {
          _currentUser = AppUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            username: firebaseUser.displayName ?? 'User',
            role: firebaseUser.email?.contains('admin') == true
                ? 'Admin'
                : 'Staff',
            createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          );
        } else {
          _currentUser = null;
        }
        SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return _currentUser;
      }).handleError((error) {
        _currentUser = null;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return null;
      });
    } catch (e) {
      // Return a simple stream that immediately shows login
      return Stream.value(null);
    }
  }

  // Initialize auth service - optimized for speed
  Future<void> initialize() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Set basic user info immediately for fast startup
        _currentUser = AppUser(
          id: user.uid,
          email: user.email ?? '',
          username: user.displayName ?? 'User',
          role: user.email?.contains('admin') == true ? 'Admin' : 'Staff',
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        );
        SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });

        // Load detailed profile immediately to ensure sidebar shows user info
        await _loadUserProfileInBackground(user.uid);

        // Initialize user service to prevent infinite loading
        await _userService.initializeCurrentUserProfile();
      }
    } catch (e) {
      // Don't let initialization errors crash the app
    }
  }

  // Load user profile in background without blocking UI
  Future<void> _loadUserProfileInBackground(String uid) async {
    try {
      final userProfile = await _userService
          .getUserProfile(uid)
          .timeout(const Duration(seconds: 5)); // Increased timeout

      if (userProfile != null) {
        _currentUser = AppUser(
          id: userProfile.id,
          email: userProfile.email,
          username: userProfile.username,
          role: userProfile.role,
          createdAt: userProfile.createdAt,
        );
        SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    } catch (e) {
      // Silently fail - we already have basic user info
      print('Failed to load user profile: $e');
    }
  }

  // Manually refresh user profile from Firestore
  Future<bool> refreshUserProfile() async {
    try {
      if (_currentUser == null) return false;

      final userProfile = await _userService.getUserProfile(_currentUser!.id);

      if (userProfile != null) {
        _currentUser = AppUser(
          id: userProfile.id,
          email: userProfile.email,
          username: userProfile.username,
          role: userProfile.role,
          createdAt: userProfile.createdAt,
        );
        SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Login with username and password
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      String email;

      // Check if input is an email or username
      if (username.contains('@')) {
        // Input is an email, use it directly
        email = username;
      } else {
        // Input is a username, look up the email
        try {
          final userProfile =
              await _userService.getUserProfileByUsername(username);

          if (userProfile != null) {
            email = userProfile.email;
          } else {
            // No user found with this username
            _setError('No user found with this username.');
            return false;
          }
        } catch (e) {
          _setError('Failed to look up user. Please try again.');
          return false;
        }
      }

      // Attempt to login with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Try to get user profile from Firestore
        UserProfile? userProfile;
        try {
          userProfile =
              await _userService.getUserProfile(userCredential.user!.uid);
        } catch (e) {
          // Silently fail - we'll use basic user info
        }

        if (userProfile != null) {
          _currentUser = AppUser(
            id: userProfile.id,
            email: userProfile.email,
            username: userProfile.username,
            role: userProfile.role,
            createdAt: userProfile.createdAt,
          );
        } else {
          // Fallback to basic user info from Firebase Auth
          _currentUser = AppUser(
            id: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            username: userCredential.user!.displayName ?? username,
            role: userCredential.user!.email?.contains('admin') == true
                ? 'Admin'
                : 'Staff',
            createdAt:
                userCredential.user!.metadata.creationTime ?? DateTime.now(),
          );
        }

        notifyListeners();
        return true;
      }
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register with email and password
  Future<bool> register(String username, String email, String password,
      String confirmPassword) async {
    _setLoading(true);
    _clearError();

    try {
      // Validation
      if (password != confirmPassword) {
        _setError('Passwords do not match');
        return false;
      }

      if (password.length < 6) {
        _setError('Password must be at least 6 characters');
        return false;
      }

      // Username validation
      if (username.trim().length < 3) {
        _setError('Username must be at least 3 characters long');
        return false;
      }

      if (username.contains(' ')) {
        _setError('Username cannot contain spaces');
        return false;
      }

      // Only allow alphanumeric characters and underscores
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
        _setError(
            'Username can only contain letters, numbers, and underscores');
        return false;
      }

      // Check if username is already taken
      final isUsernameTaken = await _userService.isUsernameTaken(username);
      if (isUsernameTaken) {
        _setError('Username is already taken. Please choose a different one.');
        return false;
      }

      // Check if email is already taken
      final isEmailTaken = await _userService.isEmailTaken(email);
      if (isEmailTaken) {
        _setError(
            'Email is already registered. Please use a different email or sign in.');
        return false;
      }

      // Create user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(username);

        // Create user profile in Firestore
        try {
          final userProfile = UserProfile(
            id: userCredential.user!.uid,
            email: email,
            username: username,
            role: email.contains('admin') ? 'Admin' : 'Staff',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _userService.createOrUpdateUserProfile(userProfile);
        } catch (e) {
          // If Firestore fails, we still have a valid Firebase user
        }

        _currentUser = AppUser.fromFirebase(userCredential.user!);
        SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      }
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Password Reset
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Failed to send password reset email: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change Password
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) {
        _setError('No user is currently signed in');
        return false;
      }

      if (newPassword.length < 6) {
        _setError('New password must be at least 6 characters');
        return false;
      }

      // Re-authenticate user with current password
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Failed to change password: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();

      _currentUser = null;

      // Clear user profile from UserService
      _userService.clearCurrentUserProfile();

      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      // Force a rebuild by calling notifyListeners again after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      });
    } catch (e) {
      // Even if Firebase sign out fails, clear local user data
      _currentUser = null;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String error) {
    _error = error;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _clearError() {
    _error = null;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Convert Firebase error codes to user-friendly messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'requires-recent-login':
        return 'Please log in again to change your password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Create a test user for development (only in debug mode)
  Future<bool> createTestUser() async {
    if (!kDebugMode) return false;

    try {
      return await register(
          'testuser', 'test@example.com', 'password123', 'password123');
    } catch (e) {
      return false;
    }
  }

  // Delete account completely
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _setError('No user is currently signed in');
        return false;
      }

      // Mark the account for deletion (24-hour recovery window)
      final markedForDeletion =
          await _userService.markAccountForDeletion(currentUser.uid);

      if (!markedForDeletion) {
        _setError('Failed to mark account for deletion');
        return false;
      }

      // Sign out the user
      await signOut();

      return true;
    } catch (e) {
      String errorMessage = 'Failed to delete account';

      if (e is firebase_auth.FirebaseAuthException) {
        switch (e.code) {
          case 'requires-recent-login':
            errorMessage =
                'Please log in again recently to delete your account. This is a security requirement.';
            break;
          case 'user-not-found':
            errorMessage = 'User account not found';
            break;
          case 'invalid-credential':
            errorMessage = 'Invalid credentials';
            break;
          default:
            errorMessage = 'Authentication error: ${e.message}';
        }
      } else {
        errorMessage = 'Failed to delete account: ${e.toString()}';
      }

      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Recover deleted account (within 24 hours)
  Future<bool> recoverAccount() async {
    try {
      _setLoading(true);
      _clearError();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _setError('No user is currently signed in');
        return false;
      }

      // Recover the account
      final recovered = await _userService.recoverAccount(currentUser.uid);

      if (!recovered) {
        _setError('Failed to recover account');
        return false;
      }

      return true;
    } catch (e) {
      _setError('Failed to recover account: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Permanently delete account (after 24 hours - called by cleanup service)
  Future<bool> permanentlyDeleteAccount(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      // Delete the user profile from Firestore
      final profileDeleted =
          await _userService.permanentlyDeleteAccount(userId);
      if (!profileDeleted) {
        _setError('Failed to delete user profile');
        return false;
      }

      // Note: Firebase Auth user deletion requires admin SDK or user to be signed in
      // For now, we'll just delete the profile and let the user handle auth deletion
      // when they try to sign in again

      return true;
    } catch (e) {
      _setError('Failed to permanently delete account: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Re-authenticate user before sensitive operations like account deletion
  Future<bool> reAuthenticateUser(String password) async {
    try {
      _setLoading(true);
      _clearError();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _setError('No user is currently signed in');
        return false;
      }

      if (currentUser.email == null) {
        _setError('User email not available for re-authentication');
        return false;
      }

      // Create credential with current email and provided password
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: currentUser.email!,
        password: password,
      );

      // Re-authenticate the user
      await currentUser.reauthenticateWithCredential(credential);

      _clearError();
      return true;
    } catch (e) {
      String errorMessage = 'Re-authentication failed';

      if (e is firebase_auth.FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'user-not-found':
            errorMessage = 'User account not found';
            break;
          case 'invalid-credential':
            errorMessage = 'Invalid credentials';
            break;
          case 'user-disabled':
            errorMessage = 'This user account has been disabled';
            break;
          default:
            errorMessage = 'Authentication error: ${e.message}';
        }
      } else {
        errorMessage = 'Re-authentication failed: ${e.toString()}';
      }

      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();

      _currentUser = null;

      // Clear user profile from UserService
      _userService.clearCurrentUserProfile();

      notifyListeners();

      // Force a rebuild by calling notifyListeners again after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        notifyListeners();
      });
    } catch (e) {
      // Even if Firebase sign out fails, clear local user data
      _currentUser = null;
      notifyListeners();
    }
  }

  void _onAuthStateChanged(firebase_auth.User? user) {
    if (user != null) {
      _currentUser = AppUser.fromFirebase(user);

      // Load detailed profile immediately to ensure sidebar shows user info
      _loadUserProfileInBackground(user.uid);
      _userService.initializeCurrentUserProfile();

      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      _currentUser = null;
      _userService.clearCurrentUserProfile();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}
