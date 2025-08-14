import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/mobile_alerts.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSortBy = 'Name';

  final List<Map<String, dynamic>> _items = [
    {
      'id': '001',
      'name': 'Chef Knife 8"',
      'category': 'Chef Knives',
      'sku': 'CK-8-001',
      'stock': 45,
      'price': 89.99,
      'status': 'In Stock',
      'lastUpdated': '2024-01-15',
    },
    {
      'id': '002',
      'name': 'Paring Knife 3.5"',
      'category': 'Paring Knives',
      'sku': 'PK-3.5-002',
      'stock': 12,
      'price': 24.99,
      'status': 'Low Stock',
      'lastUpdated': '2024-01-14',
    },
    {
      'id': '003',
      'name': 'Bread Knife 10"',
      'category': 'Bread Knives',
      'sku': 'BK-10-003',
      'stock': 0,
      'price': 34.99,
      'status': 'Out of Stock',
      'lastUpdated': '2024-01-13',
    },
    {
      'id': '004',
      'name': 'Utility Knife 6"',
      'category': 'Utility Knives',
      'sku': 'UK-6-004',
      'stock': 28,
      'price': 19.99,
      'status': 'In Stock',
      'lastUpdated': '2024-01-12',
    },
    {
      'id': '005',
      'name': 'Santoku Knife 7"',
      'category': 'Chef Knives',
      'sku': 'SK-7-005',
      'stock': 15,
      'price': 79.99,
      'status': 'In Stock',
      'lastUpdated': '2024-01-11',
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    return _items.where((item) {
      final matchesSearch = item['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          item['sku']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || item['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Items Management',
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
                            'Manage your inventory items and categories',
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
                      onPressed: () => _showAddItemDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
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
                            hintText: 'Search items by name or SKU...',
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
                      // Category Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            'All',
                            'Chef Knives',
                            'Paring Knives',
                            'Bread Knives',
                            'Utility Knives'
                          ]
                              .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Sort By
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSortBy,
                          decoration: InputDecoration(
                            labelText: 'Sort By',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: ['Name', 'Stock', 'Price', 'Last Updated']
                              .map((sort) => DropdownMenuItem(
                                    value: sort,
                                    child: Text(sort),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSortBy = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Items Table
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
                                  child: Text('Item', style: _headerStyle())),
                              Expanded(
                                  child:
                                      Text('Category', style: _headerStyle())),
                              Expanded(
                                  child: Text('SKU', style: _headerStyle())),
                              Expanded(
                                  child: Text('Stock', style: _headerStyle())),
                              Expanded(
                                  child: Text('Price', style: _headerStyle())),
                              Expanded(
                                  child: Text('Status', style: _headerStyle())),
                              Expanded(
                                  child:
                                      Text('Actions', style: _headerStyle())),
                            ],
                          ),
                        ),
                        // Table Body
                        Expanded(
                          child: ListView.builder(
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              return _buildTableRow(item, index);
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

  Widget _buildTableRow(Map<String, dynamic> item, int index) {
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
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'ID: ${item['id']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: Text(item['category'])),
            Expanded(child: Text(item['sku'])),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStockColor(item['stock']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item['stock']}',
                  style: TextStyle(
                    color: _getStockColor(item['stock']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(child: Text('\$${item['price'].toStringAsFixed(2)}')),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(item['status']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['status'],
                  style: TextStyle(
                    color: _getStatusColor(item['status']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _showEditItemDialog(context, item),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () => _showDeleteConfirmation(context, item),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return stockLevelOutOfStock(context);
    if (stock <= 15) return stockLevelLowStock(context);
    return stockLevelInStock(context);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Stock':
        return stockLevelInStock(context);
      case 'Low Stock':
        return stockLevelLowStock(context);
      case 'Out of Stock':
        return stockLevelOutOfStock(context);
      default:
        return stockLevelUnknown(context);
    }
  }

  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  void _showAddItemDialog(BuildContext context) {
    // TODO: Implement add item dialog
    MobileAlerts.showInfoMessage(
      context: context,
      message: 'Add Item functionality coming soon!',
    );
  }

  void _showEditItemDialog(BuildContext context, Map<String, dynamic> item) {
    // TODO: Implement edit item dialog
    MobileAlerts.showInfoMessage(
      context: context,
      message: 'Edit ${item['name']} functionality coming soon!',
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> item) {
    // TODO: Implement delete confirmation
    MobileAlerts.showInfoMessage(
      context: context,
      message: 'Delete ${item['name']} functionality coming soon!',
    );
  }
}
