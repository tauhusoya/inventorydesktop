import 'package:flutter/material.dart';
import '../../utils/mobile_alerts.dart';
import '../../utils/app_colors.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _stockMovements = [
    {
      'id': '001',
      'item': 'Chef Knife 8"',
      'type': 'In',
      'quantity': 50,
      'previousStock': 45,
      'newStock': 95,
      'reason': 'Restock',
      'date': '2024-01-15',
      'user': 'admin@hrknives.com',
    },
    {
      'id': '002',
      'item': 'Paring Knife 3.5"',
      'type': 'Out',
      'quantity': 3,
      'previousStock': 15,
      'newStock': 12,
      'reason': 'Sale',
      'date': '2024-01-14',
      'user': 'sales@hrknives.com',
    },
    {
      'id': '003',
      'item': 'Bread Knife 10"',
      'type': 'Out',
      'quantity': 8,
      'previousStock': 8,
      'newStock': 0,
      'reason': 'Sale',
      'date': '2024-01-13',
      'user': 'sales@hrknives.com',
    },
    {
      'id': '004',
      'item': 'Utility Knife 6"',
      'type': 'In',
      'quantity': 25,
      'previousStock': 3,
      'newStock': 28,
      'reason': 'Restock',
      'date': '2024-01-12',
      'user': 'admin@hrknives.com',
    },
  ];

  final List<Map<String, dynamic>> _stockAlerts = [
    {
      'item': 'Bread Knife 10"',
      'type': 'Out of Stock',
      'currentStock': 0,
      'minStock': 5,
      'priority': 'High',
      'date': '2024-01-13',
    },
    {
      'item': 'Paring Knife 3.5"',
      'type': 'Low Stock',
      'currentStock': 12,
      'minStock': 15,
      'priority': 'Medium',
      'date': '2024-01-14',
    },
    {
      'item': 'Santoku Knife 7"',
      'type': 'Low Stock',
      'currentStock': 15,
      'minStock': 20,
      'priority': 'Medium',
      'date': '2024-01-11',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Stock Management',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor stock levels, movements, and alerts',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 32),

                // Search Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        // Search functionality to be implemented
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Tabs
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.onSurface,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Movements'),
                      Tab(text: 'Alerts'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildMovementsTab(),
                      _buildAlertsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),

            // Stock Summary Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                                     _buildStockCard(
                     'Total Items',
                     '1,247',
                     Icons.inventory,
                     categoryPrimary(context),
                     'All inventory items',
                   ),
                   _buildStockCard(
                     'In Stock',
                     '1,216',
                     Icons.check_circle,
                     stockLevelInStock(context),
                     'Available for sale',
                   ),
                   _buildStockCard(
                     'Low Stock',
                     '23',
                     Icons.warning,
                     stockLevelLowStock(context),
                     'Below minimum level',
                   ),
                   _buildStockCard(
                     'Out of Stock',
                     '8',
                     Icons.error,
                     stockLevelOutOfStock(context),
                     'No stock available',
                   ),
                   _buildStockCard(
                     'Total Value',
                     '\$45,892',
                     Icons.attach_money,
                     categoryTertiary(context),
                     'Inventory value',
                   ),
                   _buildStockCard(
                     'Categories',
                     '15',
                     Icons.category,
                     categorySecondary(context),
                     'Product categories',
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementsTab() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Header
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
                Expanded(flex: 2, child: Text('Item', style: _headerStyle())),
                Expanded(child: Text('Type', style: _headerStyle())),
                Expanded(child: Text('Quantity', style: _headerStyle())),
                Expanded(child: Text('Stock', style: _headerStyle())),
                Expanded(child: Text('Reason', style: _headerStyle())),
                Expanded(child: Text('Date', style: _headerStyle())),
              ],
            ),
          ),
          // Movements List
          Expanded(
            child: ListView.builder(
              itemCount: _stockMovements.length,
              itemBuilder: (context, index) {
                final movement = _stockMovements[index];
                return _buildMovementRow(movement, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Header
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
                Expanded(flex: 2, child: Text('Item', style: _headerStyle())),
                Expanded(child: Text('Alert Type', style: _headerStyle())),
                Expanded(child: Text('Current Stock', style: _headerStyle())),
                Expanded(child: Text('Min Stock', style: _headerStyle())),
                Expanded(child: Text('Priority', style: _headerStyle())),
                Expanded(child: Text('Actions', style: _headerStyle())),
              ],
            ),
          ),
          // Alerts List
          Expanded(
            child: ListView.builder(
              itemCount: _stockAlerts.length,
              itemBuilder: (context, index) {
                final alert = _stockAlerts[index];
                return _buildAlertRow(alert, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                child: Icon(icon, color: color, size: 24),
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
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementRow(Map<String, dynamic> movement, int index) {
    final isEven = index % 2 == 0;
    final isIn = movement['type'] == 'In';

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
              child: Text(
                movement['item'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                 decoration: BoxDecoration(
                   color: isIn 
                       ? backgroundSuccess(context)
                       : backgroundError(context),
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: Text(
                   movement['type'],
                   style: TextStyle(
                     color: isIn 
                         ? movementTypeStockIn(context)
                         : movementTypeStockOut(context),
                     fontWeight: FontWeight.w600,
                   ),
                 ),
              ),
            ),
            Expanded(
                             child: Text(
                 '${isIn ? '+' : '-'}${movement['quantity']}',
                 style: TextStyle(
                   color: isIn 
                       ? movementTypeStockIn(context)
                       : movementTypeStockOut(context),
                   fontWeight: FontWeight.w600,
                 ),
               ),
            ),
            Expanded(
              child: Text(
                  '${movement['previousStock']} → ${movement['newStock']}'),
            ),
            Expanded(child: Text(movement['reason'])),
            Expanded(child: Text(movement['date'])),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertRow(Map<String, dynamic> alert, int index) {
    final isEven = index % 2 == 0;
    final priorityColor = _getPriorityColor(alert['priority']);

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
              child: Text(
                alert['item'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert['type'],
                  style: TextStyle(
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
                             child: Text(
                 '${alert['currentStock']}',
                 style: TextStyle(
                   color: alert['currentStock'] == 0 
                       ? stockLevelOutOfStock(context)
                       : stockLevelLowStock(context),
                   fontWeight: FontWeight.w600,
                 ),
               ),
            ),
            Expanded(child: Text('${alert['minStock']}')),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert['priority'],
                  style: TextStyle(
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    onPressed: () => _restockItem(alert['item']),
                    tooltip: 'Restock',
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_off, size: 18),
                    onPressed: () => _dismissAlert(alert['item']),
                    tooltip: 'Dismiss',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return priorityHigh(context);
      case 'Medium':
        return priorityMedium(context);
      case 'Low':
        return priorityLow(context);
      default:
        return priorityNone(context);
    }
  }

  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  void _restockItem(String itemName) {
    // TODO: Implement restock functionality
    MobileAlerts.showInfoMessage(
      context: context,
      message: 'Restock $itemName functionality coming soon!',
    );
  }

  void _dismissAlert(String itemName) {
    // TODO: Implement dismiss alert functionality
    MobileAlerts.showInfoMessage(
      context: context,
      message: 'Dismiss alert for $itemName functionality coming soon!',
    );
  }
}
