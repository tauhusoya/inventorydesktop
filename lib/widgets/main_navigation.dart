import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/mobile_alerts.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Knives'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = context.read<AuthService>();
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.1),
              colorScheme.secondaryContainer.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Text(
                'Welcome to HR Knives',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                'Manage your inventory efficiently with our modern interface',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: 40),

              // Quick Actions Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildActionCard(
                      context,
                      icon: Icons.inventory_2,
                      title: 'Inventory',
                      subtitle: 'Manage stock levels',
                      color: colorScheme.primary,
                      onTap: () {
                        // TODO: Navigate to inventory screen
                        MobileAlerts.showInfoMessage(
                          context: context,
                          message: 'Inventory feature coming soon!',
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.category,
                      title: 'Categories',
                      subtitle: 'Organize items',
                      color: colorScheme.secondary,
                      onTap: () {
                        // TODO: Navigate to categories screen
                        MobileAlerts.showInfoMessage(
                          context: context,
                          message: 'Categories feature coming soon!',
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.analytics,
                      title: 'Reports',
                      subtitle: 'View analytics',
                      color: colorScheme.tertiary,
                      onTap: () {
                        // TODO: Navigate to reports screen
                        MobileAlerts.showInfoMessage(
                          context: context,
                          message: 'Reports feature coming soon!',
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'Configure app',
                      color: colorScheme.outline,
                      onTap: () {
                        // TODO: Navigate to settings screen
                        MobileAlerts.showInfoMessage(
                          context: context,
                          message: 'Settings feature coming soon!',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
