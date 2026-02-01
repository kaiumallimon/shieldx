import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class VaultAvatar extends StatelessWidget {
  const VaultAvatar({
    super.key,
    required this.userName,
    required this.avatarUrl,
  });

  final String? userName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
}
