import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PasswordModeSelector extends StatelessWidget {
  final bool memorableMode;
  final ValueChanged<bool> onModeChanged;

  const PasswordModeSelector({
    super.key,
    required this.memorableMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CupertinoSlidingSegmentedControl<bool>(
        groupValue: memorableMode,
        onValueChanged: (value) => onModeChanged(value ?? false),
        children: const {
          false: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Random'),
          ),
          true: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Memorable'),
          ),
        },
      ),
    );
  }
}