import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/role_utils.dart';
import '../../utils/mobile_alerts.dart';
import '../../services/cleanup_service.dart'; // Added import for CleanupService

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'All';
  String _selectedStatus = 'All';

  final List<Map<String, dynamic>> _users = [
    {
      'id': '001',
      'username': 'admin',
      'email': 'admin@hrknives.com',
      'role': 'Admin',
      'status': 'Active',
      'lastLogin': '2024-01-15 14:30',
      'createdAt': '2024-01-01',
      'permissions': ['All'],
    },
    {
      'id': '002',
      'username': 'manager',
      'email': 'manager@hrknives.com',
      'role': 'Manager',
      'status': 'Active',
      'lastLogin': '2024-01-15 12:15',
      'createdAt': '2024-01-02',
      'permissions': ['Read', 'Write', 'Delete'],
    },
    {
      'id': '003',
      'username': 'sales',
      'email': 'sales@hrknives.com',
      'role': 'Sales',
      'status': 'Active',
      'lastLogin': '2024-01-14 16:45',
      'createdAt': '2024-01-03',
      'permissions': ['Read', 'Write'],
    },
    {
      'id': '004',
      'username': 'inventory',
      'email': 'inventory@hrknives.com',
      'role': 'Inventory',
      'status': 'Active',
      'lastLogin': '2024-01-15 09:20',
      'createdAt': '2024-01-04',
      'permissions': ['Read', 'Write'],
    },
    {
      'id': '005',
      'username': 'viewer',
      'email': 'viewer@hrknives.com',
      'role': 'Viewer',
      'status': 'Inactive',
      'lastLogin': '2024-01-10 11:30',
      'createdAt': '2024-01-05',
      'permissions': ['Read'],
    },
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = user['username']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          user['email']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesRole =
          _selectedRole == 'All' || user['role'] == _selectedRole;
      final matchesStatus =
          _selectedStatus == 'All' || user['status'] == _selectedStatus;
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;

        // Check if user is admin
        if (!RoleUtils.isAdmin(user)) {
          return _buildAccessDeniedScreen();
        }

        return _buildUsersScreen();
      },
    );
  }

  Widget _buildAccessDeniedScreen() {
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Access Denied Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: backgroundError(context),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.lock,
                      size: 60,
                      color: userRoleAdmin(context),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Access Denied',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Message
                  Text(
                    'You do not have permission to access the Users Management page.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Only users with Admin role can manage user accounts.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Back Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate back or to home
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
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

  Widget _buildUsersScreen() {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Management',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage user accounts, roles, and permissions',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddUserDialog(context),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add User'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Filters and Search
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Search
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search users by username or email...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Role Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            'All',
                            'Admin',
                            'Manager',
                            'Sales',
                            'Inventory',
                            'Viewer'
                          ]
                              .map((role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Status Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: ['All', 'Active', 'Inactive', 'Suspended']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Account Cleanup Section (Admin Only)
                if (RoleUtils.isAdmin(context.read<AuthService>().currentUser))
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.cleaning_services,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Account Cleanup',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Manage accounts marked for deletion and perform cleanup operations',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showCleanupDialog(context),
                              icon: const Icon(Icons.cleaning_services),
                              label: const Text('Run Cleanup'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _showPendingDeletionsDialog(context),
                              icon: const Icon(Icons.pending_actions),
                              label: const Text('View Pending'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                if (RoleUtils.isAdmin(context.read<AuthService>().currentUser))
                  const SizedBox(height: 24),

                // Users Table
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Table Header
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
                              Expanded(
                                  flex: 2,
                                  child: Text('User', style: _headerStyle())),
                              Expanded(
                                  child: Text('Role', style: _headerStyle())),
                              Expanded(
                                  child: Text('Status', style: _headerStyle())),
                              Expanded(
                                  child: Text('Last Login',
                                      style: _headerStyle())),
                              Expanded(
                                  child:
                                      Text('Created', style: _headerStyle())),
                              Expanded(
                                  child:
                                      Text('Actions', style: _headerStyle())),
                            ],
                          ),
                        ),
                        // Table Body
                        Expanded(
                          child: ListView.builder(
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return _buildTableRow(user, index);
                            },
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
    );
  }

  Widget _buildTableRow(Map<String, dynamic> user, int index) {
    final isEven = index % 2 == 0;

    return Container(
      decoration: BoxDecoration(
        color: isEven
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['username'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    user['email'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'ID: ${user['id']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(user['role']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user['role'],
                  style: TextStyle(
                    color: _getRoleColor(user['role']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(user['status']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user['status'],
                  style: TextStyle(
                    color: _getStatusColor(user['status']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(child: Text(user['lastLogin'])),
            Expanded(child: Text(user['createdAt'])),
            Expanded(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _showEditUserDialog(context, user),
                    tooltip: 'Edit User',
                  ),
                  IconButton(
                    icon: const Icon(Icons.security, size: 18),
                    onPressed: () => _showPermissionsDialog(context, user),
                    tooltip: 'Manage Permissions',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () => _showDeleteConfirmation(context, user),
                    tooltip: 'Delete User',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return userRoleAdmin(context);
      case 'Manager':
        return userRoleManager(context);
      case 'Sales':
        return categorySecondary(context);
      case 'Inventory':
        return userRoleUser(context);
      case 'Viewer':
        return userRoleGuest(context);
      default:
        return userRoleGuest(context);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return statusSuccess(context);
      case 'Inactive':
        return statusNeutral(context);
      case 'Suspended':
        return statusError(context);
      default:
        return statusNeutral(context);
    }
  }

  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  void _showAddUserDialog(BuildContext context) {
    MobileAlerts.showInfoMessage(
      context: context,
      message: 'Add User functionality coming soon!',
    );
  }

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
    MobileAlerts.showInfoMessage(
      context: context,
      message: 'Edit ${user['username']} functionality coming soon!',
    );
  }

  void _showPermissionsDialog(BuildContext context, Map<String, dynamic> user) {
    MobileAlerts.showInfoMessage(
      context: context,
      message:
          'Manage permissions for ${user['username']} functionality coming soon!',
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> user) {
    MobileAlerts.showInfoMessage(
      context: context,
      message: 'Delete ${user['username']} functionality coming soon!',
    );
  }

  // Show cleanup dialog
  void _showCleanupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cleaning_services, color: Colors.orange),
              SizedBox(width: 8),
              Text('Run Account Cleanup'),
            ],
          ),
          content: const Text(
            'This will permanently delete all accounts that have been marked for deletion for more than 24 hours. This action cannot be undone.\n\nDo you want to proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performCleanup(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Run Cleanup'),
            ),
          ],
        );
      },
    );
  }

  // Show pending deletions dialog
  void _showPendingDeletionsDialog(BuildContext context) async {
    try {
      final cleanupService = context.read<CleanupService>();
      final pendingAccounts = await cleanupService.getPendingDeletionAccounts();

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.pending_actions, color: Colors.blue),
                SizedBox(width: 8),
                Text('Pending Account Deletions'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: pendingAccounts.isEmpty
                  ? const Text('No accounts are currently pending deletion.')
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            '${pendingAccounts.length} accounts pending deletion:'),
                        const SizedBox(height: 16),
                        ...pendingAccounts.map((account) {
                          final timeRemaining =
                              account['timeRemaining'] as Duration?;
                          final deletionAt =
                              account['automaticDeletionAt'] as DateTime?;

                          String statusText = 'Pending';
                          Color statusColor = Colors.orange;

                          if (timeRemaining != null) {
                            if (timeRemaining.isNegative) {
                              statusText = 'Ready for deletion';
                              statusColor = Colors.red;
                            } else if (timeRemaining.inHours < 1) {
                              statusText =
                                  '${timeRemaining.inMinutes} minutes remaining';
                              statusColor = Colors.red;
                            } else {
                              statusText =
                                  '${timeRemaining.inHours} hours remaining';
                              statusColor = Colors.orange;
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${account['username']} (${account['email']})',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Marked for deletion: ${account['deletionRequestedAt']?.toString().substring(0, 19) ?? 'Unknown'}',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                if (deletionAt != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Automatic deletion: ${deletionAt.toString().substring(0, 19)}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        MobileAlerts.showErrorMessage(
          context: context,
          message: 'Failed to load pending deletions: ${e.toString()}',
        );
      }
    }
  }

  // Perform cleanup
  Future<void> _performCleanup(BuildContext context) async {
    try {
      final cleanupService = context.read<CleanupService>();

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Running cleanup...'),
              ],
            ),
          );
        },
      );

      // Perform cleanup
      final deletedCount = await cleanupService.performServerTimeBasedCleanup();

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show results
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Cleanup Complete'),
              ],
            ),
            content: Text(
              deletedCount == 0
                  ? 'No accounts were deleted. All accounts are either active or still within the recovery window.'
                  : 'Successfully deleted $deletedCount account${deletedCount == 1 ? '' : 's'}.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        MobileAlerts.showErrorMessage(
          context: context,
          message: 'Cleanup failed: ${e.toString()}',
        );
      }
    }
  }
}
