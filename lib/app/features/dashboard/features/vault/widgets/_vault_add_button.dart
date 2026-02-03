import 'package:flutter/material.dart';

class VaultAddButton extends StatelessWidget {
  const VaultAddButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(onTap: onPressed, child: const Icon(Icons.add));
  }
}
