import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/scheduler.dart';

class UserProfile {
  final String id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isPendingDeletion;
  final DateTime? deletionRequestedAt;
  final DateTime? scheduledDeletionAt;
  final String? profilePicture;
  final DateTime? profilePictureUpdatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isPendingDeletion = false,
    this.deletionRequestedAt,
    this.scheduledDeletionAt,
    this.profilePicture,
    this.profilePictureUpdatedAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime convertToDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      if (value is int) {
        // Assume millisecondsSinceEpoch
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.now();
    }

    DateTime? convertToNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value);
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return null;
    }

    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      role: data['role'] ?? 'Staff',
      createdAt: convertToDate(data['createdAt']),
      updatedAt: convertToDate(data['updatedAt']),
      isActive: data['isActive'] ?? true,
      isPendingDeletion: data['isPendingDeletion'] ?? false,
      deletionRequestedAt: convertToNullableDate(data['deletionRequestedAt']),
      scheduledDeletionAt: convertToNullableDate(data['scheduledDeletionAt']),
      profilePicture: data['profilePicture'],
      profilePictureUpdatedAt:
          convertToNullableDate(data['profilePictureUpdatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'isPendingDeletion': isPendingDeletion,
      'deletionRequestedAt': deletionRequestedAt != null
          ? Timestamp.fromDate(deletionRequestedAt!)
          : null,
      'scheduledDeletionAt': scheduledDeletionAt != null
          ? Timestamp.fromDate(scheduledDeletionAt!)
          : null,
      'profilePicture': profilePicture,
      'profilePictureUpdatedAt': profilePictureUpdatedAt != null
          ? Timestamp.fromDate(profilePictureUpdatedAt!)
          : null,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isPendingDeletion,
    DateTime? deletionRequestedAt,
    DateTime? scheduledDeletionAt,
    String? profilePicture,
    DateTime? profilePictureUpdatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isPendingDeletion: isPendingDeletion ?? this.isPendingDeletion,
      deletionRequestedAt: deletionRequestedAt ?? this.deletionRequestedAt,
      scheduledDeletionAt: scheduledDeletionAt ?? this.scheduledDeletionAt,
      profilePicture: profilePicture ?? this.profilePicture,
      profilePictureUpdatedAt:
          profilePictureUpdatedAt ?? this.profilePictureUpdatedAt,
    );
  }
}

class UserService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  UserProfile? _currentUserProfile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Create or update user profile in Firestore
  Future<bool> createOrUpdateUserProfile(UserProfile profile) async {
    _setLoading(true);
    _clearError();

    try {
      final now = DateTime.now();
      final updatedProfile = profile.copyWith(
        updatedAt: now,
        createdAt: profile.createdAt,
      );

      await _firestore
          .collection('users')
          .doc(profile.id)
          .set(updatedProfile.toFirestore(), SetOptions(merge: true));

      _currentUserProfile = updatedProfile;
      _notifySafely();
      return true;
    } catch (e) {
      _setError('Failed to save user profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user profile from Firestore
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final profile = UserProfile.fromFirestore(doc);
        _currentUserProfile = profile;
        _notifySafely();
        _setLoading(false);
        return profile;
      } else {
        _currentUserProfile = null;
        _notifySafely();
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Failed to get user profile: $e');
      _setLoading(false);
      return null;
    }
  }

  // Get user profile by username
  Future<UserProfile?> getUserProfileByUsername(String username) async {
    _setLoading(true);
    _clearError();

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final profile = UserProfile.fromFirestore(querySnapshot.docs.first);
        return profile;
      }

      return null;
    } catch (e) {
      _setError('Failed to get user profile by username: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Check if username already exists
  Future<bool> isUsernameTaken(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Check if email already exists
  Future<bool> isEmailTaken(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get user profile by ID

  // Update specific user profile fields
  Future<bool> updateUserProfileFields(
      String userId, Map<String, dynamic> fields) async {
    try {
      final updateData = {
        ...fields,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore.collection('users').doc(userId).update(updateData);

      // Refresh current user profile if it's the same user
      if (_currentUserProfile?.id == userId) {
        await getUserProfile(userId);
      }

      return true;
    } catch (e) {
      _setError('Failed to update user profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete user profile
  Future<bool> deleteUserProfile(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestore.collection('users').doc(userId).delete();

      if (_currentUserProfile?.id == userId) {
        _currentUserProfile = null;
        _notifySafely();
      }

      return true;
    } catch (e) {
      _setError('Failed to delete user profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get all users (admin only)
  Future<List<UserProfile>> getAllUsers() async {
    _setLoading(true);
    _clearError();

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final users = querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();

      return users;
    } catch (e) {
      _setError('Failed to get users: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Search users by name or email
  Future<List<UserProfile>> searchUsers(String query) async {
    _setLoading(true);
    _clearError();

    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple prefix search implementation
      final querySnapshot = await _firestore
          .collection('users')
          .where('isActive', isEqualTo: true)
          .get();

      final users = querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .where((user) =>
              user.username.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return users;
    } catch (e) {
      _setError('Failed to search users: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Get current user profile with caching
  Future<UserProfile?> getCurrentUserProfile() async {
    // If we already have a profile and it's recent (less than 5 minutes old), return it
    if (_currentUserProfile != null) {
      final timeSinceUpdate =
          DateTime.now().difference(_currentUserProfile!.updatedAt);
      if (timeSinceUpdate.inMinutes < 5) {
        return _currentUserProfile;
      }
    }

    // Get current user ID from AuthService
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    // Load fresh profile without setting loading state to avoid rebuilds during build
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) {
        final profile = UserProfile.fromFirestore(doc);

        // Only update and notify if the profile actually changed
        if (_currentUserProfile?.id != profile.id ||
            _currentUserProfile?.updatedAt != profile.updatedAt) {
          _currentUserProfile = profile;
          _notifySafely();
        }

        return profile;
      }

      return null;
    } catch (e) {
      _setError('Failed to get user profile: ${e.toString()}');
      return null;
    }
  }

  // Force refresh current user profile (bypass cache)
  Future<UserProfile?> refreshCurrentUserProfile() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    // Clear current profile to force refresh
    _currentUserProfile = null;
    _notifySafely();

    // Load fresh profile
    return await getUserProfile(currentUser.uid);
  }

  // Initialize user service
  Future<void> initialize() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Load the user profile immediately to prevent infinite loading
      await getUserProfile(user.uid);
    }
  }

  // Initialize user profile for current user (called from auth service)
  Future<void> initializeCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Load the user profile immediately to prevent infinite loading
      await getUserProfile(user.uid);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    _notifySafely();
  }

  void _setError(String error) {
    _error = error;
    _notifySafely();
  }

  void _clearError() {
    _error = null;
    _notifySafely();
  }

  void _notifySafely() {
    // Always defer to the next frame to avoid notifying during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Clear current user profile (useful for sign out)
  void clearCurrentUserProfile() {
    _currentUserProfile = null;
    _notifySafely();
  }

  // Mark user account for deletion (24-hour recovery window)
  Future<bool> markAccountForDeletion(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      // Use Firestore server timestamp for accurate server time
      final serverTimestamp = FieldValue.serverTimestamp();

      // Calculate 24 hours from now for local display (will be updated with server time)
      final now = DateTime.now();
      final scheduledDeletion = now.add(const Duration(hours: 24));

      await _firestore.collection('users').doc(userId).update({
        'isPendingDeletion': true,
        'deletionRequestedAt': serverTimestamp, // Server timestamp
        'scheduledDeletionAt': serverTimestamp, // Will be set to server time
        'updatedAt': serverTimestamp,
        'deletionWindowHours': 24, // Store deletion window for flexibility
      });

      // Update local profile if it's the current user
      if (_currentUserProfile?.id == userId) {
        _currentUserProfile = _currentUserProfile!.copyWith(
          isPendingDeletion: true,
          deletionRequestedAt: now,
          scheduledDeletionAt: scheduledDeletion,
          updatedAt: now,
        );
        _notifySafely();
      }

      return true;
    } catch (e) {
      _setError('Failed to mark account for deletion: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Recover user account (cancel deletion)
  Future<bool> recoverAccount(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      // Use Firestore server timestamp for accurate server time
      final serverTimestamp = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userId).update({
        'isPendingDeletion': false,
        'deletionRequestedAt': null,
        'scheduledDeletionAt': null,
        'updatedAt': serverTimestamp,
        'deletionWindowHours': null, // Clear deletion window
      });

      // Update local profile if it's the current user
      if (_currentUserProfile?.id == userId) {
        _currentUserProfile = _currentUserProfile!.copyWith(
          isPendingDeletion: false,
          deletionRequestedAt: null,
          scheduledDeletionAt: null,
          updatedAt: DateTime.now(),
        );
        _notifySafely();
      }

      return true;
    } catch (e) {
      _setError('Failed to recover account: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Permanently delete user account (after 24 hours)
  Future<bool> permanentlyDeleteAccount(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      // Delete the user profile document
      await _firestore.collection('users').doc(userId).delete();

      // Clear local profile if it's the current user
      if (_currentUserProfile?.id == userId) {
        _currentUserProfile = null;
        _notifySafely();
      }

      return true;
    } catch (e) {
      _setError('Failed to permanently delete account: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if user account is pending deletion
  bool isAccountPendingDeletion() {
    return _currentUserProfile?.isPendingDeletion == true;
  }

  // Get time remaining until permanent deletion
  Duration? getTimeUntilDeletion() {
    final profile = _currentUserProfile;
    if (profile?.scheduledDeletionAt == null) return null;

    final remaining = profile!.scheduledDeletionAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // Get formatted time remaining string
  String getFormattedTimeRemaining() {
    final remaining = getTimeUntilDeletion();
    if (remaining == null) return '';

    if (remaining.inHours > 0) {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      return '$hours hours, $minutes minutes';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes} minutes';
    } else {
      return 'Less than 1 minute';
    }
  }

  // Get accounts that should be automatically deleted (server-time based)
  Future<List<String>> getAccountsForAutomaticDeletion() async {
    try {
      // Query for accounts marked for deletion more than 24 hours ago
      // Using server timestamp comparison for accuracy
      final cutoffTime = Timestamp.fromDate(
          DateTime.now().subtract(const Duration(hours: 24)));

      final querySnapshot = await _firestore
          .collection('users')
          .where('isPendingDeletion', isEqualTo: true)
          .where('deletionRequestedAt', isLessThan: cutoffTime)
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      // Error getting accounts for automatic deletion: $e
    }
    return [];
  }

  // Get accounts pending deletion with server time info (for admin purposes)
  Future<List<Map<String, dynamic>>>
      getPendingDeletionAccountsWithServerTime() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('isPendingDeletion', isEqualTo: true)
          .orderBy('deletionRequestedAt')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final deletionRequestedAt = data['deletionRequestedAt'] as Timestamp?;
        final deletionWindowHours = data['deletionWindowHours'] as int? ?? 24;

        // Calculate when the account will be automatically deleted
        DateTime? automaticDeletionAt;
        automaticDeletionAt = deletionRequestedAt
            ?.toDate()
            .add(Duration(hours: deletionWindowHours));

        return {
          'id': doc.id,
          'email': data['email'] ?? '',
          'username': data['username'] ?? '',
          'deletionRequestedAt': deletionRequestedAt?.toDate(),
          'automaticDeletionAt': automaticDeletionAt,
          'deletionWindowHours': deletionWindowHours,
          'timeRemaining': automaticDeletionAt?.difference(DateTime.now()),
        };
      }).toList();
    } catch (e) {
      _setError('Failed to get pending deletion accounts: ${e.toString()}');
      return [];
    }
  }
}
