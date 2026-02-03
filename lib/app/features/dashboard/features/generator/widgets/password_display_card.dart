import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';
import 'package:shieldx/app/core/services/password_generator_service.dart';

class PasswordDisplayCard extends StatelessWidget {
  final String generatedPassword;
  final int passwordStrength;
  final VoidCallback onGenerate;

  const PasswordDisplayCard({
    super.key,
    required this.generatedPassword,
    required this.passwordStrength,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strengthColor = _getStrengthColor(passwordStrength);
    final strengthLabel = PasswordGeneratorService.getPasswordStrengthLabel(passwordStrength);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(100),
        ),
      ),
      child: Column(
        children: [
          SelectableText(
            generatedPassword.isEmpty ? 'Tap generate' : generatedPassword,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Strength indicator
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: strengthColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    strengthLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: strengthColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '($passwordStrength%)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: passwordStrength / 100,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(strengthColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: () {
                    if (generatedPassword.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: generatedPassword));
                      HapticFeedback.mediumImpact();
                      toastification.show(
                        context: context,
                        title: const Text('Password copied!'),
                        type: ToastificationType.success,
                        autoCloseDuration: const Duration(seconds: 2),
                      );
                    }
                  },
                  color: theme.colorScheme.secondaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.doc_on_clipboard,
                        color: theme.colorScheme.onSecondaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Copy',
                        style: TextStyle(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onGenerate();
                  },
                  color: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.refresh,
                        size: 20,
                        color: theme.colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Generate',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStrengthColor(int strength) {
    if (strength >= 80) return Colors.green;
    if (strength >= 60) return Colors.lightGreen;
    if (strength >= 40) return Colors.orange;
    if (strength >= 20) return Colors.deepOrange;
    return Colors.red;
  }
}