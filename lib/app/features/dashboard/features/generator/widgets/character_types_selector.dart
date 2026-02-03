import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CharacterTypesSelector extends StatelessWidget {
  final bool memorableMode;
  final bool includeUppercase;
  final bool includeLowercase;
  final bool includeNumbers;
  final bool includeSymbols;
  final ValueChanged<bool> onUppercaseChanged;
  final ValueChanged<bool> onLowercaseChanged;
  final ValueChanged<bool> onNumbersChanged;
  final ValueChanged<bool> onSymbolsChanged;

  const CharacterTypesSelector({
    super.key,
    required this.memorableMode,
    required this.includeUppercase,
    required this.includeLowercase,
    required this.includeNumbers,
    required this.includeSymbols,
    required this.onUppercaseChanged,
    required this.onLowercaseChanged,
    required this.onNumbersChanged,
    required this.onSymbolsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (!memorableMode) ...[
            _buildIOSToggle(
              context,
              title: 'Uppercase (A-Z)',
              value: includeUppercase,
              onChanged: onUppercaseChanged,
            ),
            _buildDivider(context),
            _buildIOSToggle(
              context,
              title: 'Lowercase (a-z)',
              value: includeLowercase,
              onChanged: onLowercaseChanged,
            ),
            _buildDivider(context),
          ],
          _buildIOSToggle(
            context,
            title: 'Numbers (0-9)',
            value: includeNumbers,
            onChanged: onNumbersChanged,
          ),
          _buildDivider(context),
          _buildIOSToggle(
            context,
            title: 'Symbols (!@#\$)',
            value: includeSymbols,
            onChanged: onSymbolsChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildIOSToggle(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: theme.colorScheme.secondary.withAlpha(50),
      ),
    );
  }
}