import 'package:flutter/material.dart';

class VaultSloganSection extends StatelessWidget {
  const VaultSloganSection({super.key});

  static const List<String> _images = [
    'assets/images/18930.jpg',
    'assets/images/143415.jpg',
    'assets/images/41064.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          // First row: "Keep" with image
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 15,
            children: [
              Text(
                'Keep',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildImageBadge(_images[0], 65, 40),
            ],
          ),

          // Second row: Image with "Your Life"
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 15,
            children: [
              _buildImageBadge(_images[1], 65, 40),
              Text(
                'Your Life',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Third row: "Safe & Secure" with image
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 15,
            children: [
              Text(
                'Safe & Secure',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildImageBadge(_images[2], 45, 45),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageBadge(String imagePath, double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
