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
        radius: 20,
        backgroundImage: CachedNetworkImageProvider(avatarUrl!),
        backgroundColor: theme.colorScheme.primary,
        onBackgroundImageError: (exception, stackTrace) {
          // If image fails to load, fallback is handled by backgroundColor
        },
      );
    }

    return CircleAvatar(
      radius: 20,
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
                leading: _buildAvatar(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
