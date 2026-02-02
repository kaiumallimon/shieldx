import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CategoryDetailPage extends StatefulWidget {
  final String category;

  const CategoryDetailPage({super.key, required this.category});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  // TODO: Replace with real data from Supabase
  List<Map<String, dynamic>> get _categoryPasswords {
    return [
      {
        'id': '1',
        'title': 'Example Password',
        'username': 'user@example.com',
        'type': 'Login',
        'url': 'example.com',
        'health': 'strong',
        'isFavorite': false,
        'lastUsed': DateTime.now(),
      },
    ].where((p) => widget.category.toLowerCase() == 'work').toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryName = widget.category[0].toUpperCase() + widget.category.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: Text('$categoryName Category'),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getCategoryColor(widget.category),
                  _getCategoryColor(widget.category).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  _getCategoryIcon(widget.category),
                  size: 48,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(height: 12),
                Text(
                  categoryName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_categoryPasswords.length} passwords',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Passwords list
          Expanded(
            child: _categoryPasswords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No passwords in this category',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categoryPasswords.length,
                    itemBuilder: (context, index) {
                      final password = _categoryPasswords[index];
                      return _buildPasswordCard(context, password);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add password to this category
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Password'),
      ),
    );
  }

  Widget _buildPasswordCard(BuildContext context, Map<String, dynamic> password) {
    final theme = Theme.of(context);
    final healthColor = _getHealthColor(password['health']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTypeIcon(password['type']),
            color: theme.colorScheme.primary,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                password['title'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (password['isFavorite'])
              Icon(
                Icons.star,
                size: 18,
                color: Colors.amber,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(password['username']),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: healthColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  password['health'].toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: healthColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          // Navigate to password details
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work_outline;
      case 'personal':
        return Icons.person_outline;
      case 'social':
        return Icons.public;
      case 'finance':
        return Icons.account_balance;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.green;
      case 'social':
        return Colors.purple;
      case 'finance':
        return Colors.orange;
      case 'shopping':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Login':
        return Icons.login;
      case 'API Key':
        return Icons.key;
      case 'Credit Card':
        return Icons.credit_card;
      case 'Note':
        return Icons.note;
      case 'Identity':
        return Icons.badge;
      default:
        return Icons.lock;
    }
  }

  Color _getHealthColor(String health) {
    switch (health) {
      case 'strong':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'weak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
