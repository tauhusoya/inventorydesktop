import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/mobile_alerts.dart';
import '../screens/home/home_screen.dart';
import '../screens/items/items_screen.dart';
import '../screens/stock/stock_screen.dart';
import '../screens/users/users_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/profile_picture_widget.dart';

class ResponsiveNavigation extends StatefulWidget {
  const ResponsiveNavigation({super.key});

  @override
  State<ResponsiveNavigation> createState() => _ResponsiveNavigationState();
}

class _ResponsiveNavigationState extends State<ResponsiveNavigation> {
  int _currentIndex = 0;

  // Define all possible screens and their metadata
  final List<Map<String, dynamic>> _allScreens = [
    {
      'screen': const HomeScreen(),
      'title': 'Home',
      'icon': Icons.home,
      'requiresAdmin': false,
    },
    {
      'screen': const ItemsScreen(),
      'title': 'Items',
      'icon': Icons.inventory,
      'requiresAdmin': false,
    },
    {
      'screen': const StockScreen(),
      'title': 'Stock',
      'icon': Icons.assessment,
      'requiresAdmin': false,
    },
    {
      'screen': const UsersScreen(),
      'title': 'Users',
      'icon': Icons.people,
      'requiresAdmin': true, // Only admins can access Users
    },
    {
      'screen': const SettingsScreen(),
      'title': 'Settings',
      'icon': Icons.settings,
      'requiresAdmin': false,
    },
  ];

  // Get filtered screens based on user role
  List<Map<String, dynamic>> _getFilteredScreens(AppUser? user) {
    if (user == null) {
      return [];
    }

    final userRole = user.role.toLowerCase();
    return _allScreens.where((screen) {
      final requiresAdmin = screen['requiresAdmin'] as bool? ?? false;
      final hasAccess = userRole == 'admin' || !requiresAdmin;
      return hasAccess;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final filteredScreens = _getFilteredScreens(user);

    // Ensure current index is within bounds
    final adjustedIndex =
        _currentIndex >= filteredScreens.length ? 0 : _currentIndex;

    // Update state if needed, but only once per frame
    if (adjustedIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentIndex = adjustedIndex;
          });
        }
      });
    }

    final screenWidth = MediaQuery.of(context).size.width;

    // Material Design 3 breakpoints:
    // Mobile: 0-599px (bottom navigation)
    // Tablet: 600-1199px (bottom navigation with larger touch targets)
    // Desktop: 1200px+ (sidebar navigation)
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    if (isDesktop) {
      return _buildDesktopLayout(filteredScreens, adjustedIndex, user);
    } else if (isTablet) {
      return _buildTabletLayout(filteredScreens, adjustedIndex, user);
    } else {
      return _buildMobileLayout(filteredScreens, adjustedIndex, user);
    }
  }

  Widget _buildDesktopLayout(List<Map<String, dynamic>> filteredScreens,
      int currentIndex, AppUser? user) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                // App Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HR Knives',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Inventory System',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredScreens.length,
                    itemBuilder: (context, index) {
                      final screenData = filteredScreens[index];
                      final isSelected = index == currentIndex;

                      return _buildSidebarItem(
                        index,
                        isSelected,
                        screenData,
                      );
                    },
                  ),
                ),

                // User Profile Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: _buildUserProfile(),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: filteredScreens[currentIndex]['screen'],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      int index, bool isSelected, Map<String, dynamic> screenData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() => _currentIndex = index);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  screenData['icon'],
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Text(
                  screenData['title'],
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
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
          return const Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loading...'),
                    Text(''),
                  ],
                ),
              ),
            ],
          );
        }

        final displayName = userProfile.firstName != null &&
                userProfile.firstName!.isNotEmpty &&
                userProfile.lastName != null &&
                userProfile.lastName!.isNotEmpty
            ? '${userProfile.firstName} ${userProfile.lastName}'
            : user.username;

        return Row(
          children: [
            SmallProfilePictureWidget(
              profilePictureUrl: userProfile.profilePicture,
              displayName: displayName,
              email: user.email,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final confirmed = await MobileAlerts.showConfirmationDialog(
                  context: context,
                  title: 'Sign Out',
                  message: 'Are you sure you want to sign out?',
                  confirmText: 'Sign Out',
                  cancelText: 'Cancel',
                  isDestructive: false,
                );

                if (confirmed == true && context.mounted) {
                  final navigator = Navigator.of(context);
                  await authService.signOut();

                  // Force navigation to login screen
                  if (context.mounted) {
                    navigator.pushReplacementNamed('/force-login');
                  }
                }
              },
              tooltip: 'Sign Out',
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabletLayout(List<Map<String, dynamic>> filteredScreens,
      int currentIndex, AppUser? user) {
    return Scaffold(
      body: filteredScreens[currentIndex]['screen'],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: filteredScreens.asMap().entries.map((entry) {
          final screenData = entry.value;
          return NavigationDestination(
            icon: Icon(screenData['icon']),
            label: screenData['title'],
          );
        }).toList(),
        // Tablet-specific styling: larger touch targets and better spacing
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    );
  }

  Widget _buildMobileLayout(List<Map<String, dynamic>> filteredScreens,
      int currentIndex, AppUser? user) {
    return Scaffold(
      body: filteredScreens[currentIndex]['screen'],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: filteredScreens.asMap().entries.map((entry) {
          final screenData = entry.value;
          return NavigationDestination(
            icon: Icon(screenData['icon']),
            label: screenData['title'],
          );
        }).toList(),
        // Mobile-specific styling: standard touch targets
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    );
  }
}
