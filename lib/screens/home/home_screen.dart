import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome to HR Knives Inventory Management',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 32),

                // Stats Cards
                Expanded(
                  child: GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width >= 1200
                        ? 4
                        : MediaQuery.of(context).size.width >= 600
                            ? 3
                            : 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _buildStatCard(
                        context,
                        'Total Items',
                        '1,247',
                        Icons.inventory,
                        categoryPrimary(context),
                      ),
                      _buildStatCard(
                        context,
                        'Low Stock',
                        '23',
                        Icons.warning,
                        stockLevelLowStock(context),
                      ),
                      _buildStatCard(
                        context,
                        'Out of Stock',
                        '8',
                        Icons.error,
                        stockLevelOutOfStock(context),
                      ),
                      _buildStatCard(
                        context,
                        'Categories',
                        '15',
                        Icons.category,
                        categorySecondary(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Recent Activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
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
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return _buildActivityItem(context, index);
                      },
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

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
                             Icon(
                 Icons.trending_up,
                 color: statusSuccess(context),
                 size: 20,
               ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, int index) {
    final activities = [
      {
        'action': 'Item Added',
        'item': 'Chef Knife 8"',
        'time': '2 minutes ago'
      },
      {
        'action': 'Stock Updated',
        'item': 'Paring Knife',
        'time': '15 minutes ago'
      },
      {
        'action': 'Low Stock Alert',
        'item': 'Bread Knife',
        'time': '1 hour ago'
      },
      {
        'action': 'Category Created',
        'item': 'Specialty Knives',
        'time': '2 hours ago'
      },
      {
        'action': 'User Login',
        'item': 'admin@hrknives.com',
        'time': '3 hours ago'
      },
    ];

    final activity = activities[index];
    final isAlert = activity['action']!.contains('Alert') ||
        activity['action']!.contains('Low Stock');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
                 color: isAlert
             ? backgroundWarning(context)
             : Theme.of(context)
                 .colorScheme
                 .surfaceContainerHighest
                 .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
                 border: Border.all(
           color: isAlert
               ? borderWarning(context)
               : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
         ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAlert
                  ? Colors.orange.withValues(alpha: 0.2)
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
                         child: Icon(
               isAlert ? Icons.warning : Icons.info,
               size: 16,
               color: isAlert
                   ? iconWarning(context)
                   : Theme.of(context).colorScheme.onPrimaryContainer,
             ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action']!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  activity['item']!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            activity['time']!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
