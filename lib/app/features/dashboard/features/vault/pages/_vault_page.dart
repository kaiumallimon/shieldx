import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final AuthStorageService _authStorage = AuthStorageService();
  String? userName;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final session = await _authStorage.getUserSession();
    print(session);
    if (session != null && mounted) {
      setState(() {
        userName = session['name'] as String?;
        avatarUrl = session['avatar_url'] as String?;
      });
    }
  }

  Widget _buildAvatar(ThemeData theme) {
    final firstChar = (userName?.isNotEmpty ?? false)
        ? userName![0].toUpperCase()
        : 'U';

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(avatarUrl!),
        backgroundColor: theme.colorScheme.primary,
        onBackgroundImageError: (exception, stackTrace) {
          // If image fails to load, fallback is handled by backgroundColor
        },
      );
    }

    return CircleAvatar(
      backgroundColor: theme.colorScheme.primary,
      child: Text(
        firstChar,
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  final List<String> images = const [
    'assets/images/18930.jpg',
    'assets/images/143415.jpg',
    'assets/images/41064.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              sliver: SliverAppBar(
                backgroundColor: theme.colorScheme.surface,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildAvatar(theme),
                ),
                pinned: true,

                actions: [_addButton(theme)],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  spacing: 10,
                  children: [
                    // first row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 15,
                      children: [
                        Text(
                          'Keep',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            images[0],
                            width: 65,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),

                    // second row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 15,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            images[1],
                            width: 65,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          'Your Life',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // third row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 15,
                      children: [
                        Text(
                          'Safe & Secure',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            images[2],
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _addButton(ThemeData theme) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text('Add'),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      onPressed: () {
        // Navigate to settings page
      },
    );
  }
}
