import 'package:flutter/material.dart';

class TypeDetailPage extends StatefulWidget {
  final String type;

  const TypeDetailPage({super.key, required this.type});

  @override
  State<TypeDetailPage> createState() => _TypeDetailPageState();
}

class _TypeDetailPageState extends State<TypeDetailPage> {
  // TODO: Replace with real data from Supabase
  List<Map<String, dynamic>> get _typePasswords {
    return [
      {
        'id': '1',
        'title': 'Example Password',
        'username': 'user@example.com',
        'category': 'Work',
        'url': 'example.com',
        'health': 'strong',
        'isFavorite': false,
        'lastUsed': DateTime.now(),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeName = _getTypeName(widget.type);

    return Scaffold(
      appBar: AppBar(
        title: Text(typeName),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          // Type header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  _getTypeIcon(widget.type),
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  typeName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_typePasswords.length} items',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Passwords list
          Expanded(
            child: _typePasswords.isEmpty
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
                          'No items of this type',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _typePasswords.length,
                    itemBuilder: (context, index) {
                      final password = _typePasswords[index];
                      return _buildPasswordCard(context, password);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new item of this type
        },
        icon: const Icon(Icons.add),
        label: Text('Add ${_getTypeName(widget.type)}'),
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
            _getTypeIcon(widget.type),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    password['category'],
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
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

  String _getTypeName(String type) {
    switch (type) {
      case 'login':
        return 'Login Credentials';
      case 'api-key':
        return 'API Keys';
      case 'credit-card':
        return 'Credit Cards';
      case 'note':
        return 'Secure Notes';
      case 'identity':
        return 'Identity Documents';
      default:
        return 'Items';
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'login':
        return Icons.login;
      case 'api-key':
        return Icons.key;
      case 'credit-card':
        return Icons.credit_card;
      case 'note':
        return Icons.note;
      case 'identity':
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
