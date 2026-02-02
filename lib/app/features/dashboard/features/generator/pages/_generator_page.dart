import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:shieldx/app/core/services/password_generator_service.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';
import 'package:shieldx/app/shared/widgets/circular_action_button.dart';
import 'package:shieldx/app/shared/widgets/scrollable_appbar.dart';

class PasswordGeneratorPage extends StatefulWidget {
  const PasswordGeneratorPage({super.key});

  @override
  State<PasswordGeneratorPage> createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  final ScrollController _scrollController = ScrollController();
  String _generatedPassword = '';
  double _passwordLength = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _memorableMode = false;
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generatePassword() {
    setState(() {
      if (_memorableMode) {
        _generatedPassword = PasswordGeneratorService.generateMemorablePassword(
          wordCount: 3,
          includeNumbers: _includeNumbers,
          includeSymbols: _includeSymbols,
        );
      } else {
        _generatedPassword = PasswordGeneratorService.generatePassword(
          length: _passwordLength.round(),
          includeUppercase: _includeUppercase,
          includeLowercase: _includeLowercase,
          includeNumbers: _includeNumbers,
          includeSymbols: _includeSymbols,
        );
      }
      _passwordStrength = PasswordGeneratorService.calculatePasswordStrength(
        _generatedPassword,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strengthColor = _getStrengthColor(_passwordStrength);
    final strengthLabel = PasswordGeneratorService.getPasswordStrengthLabel(
      _passwordStrength,
    );

    final windowSize = MediaQuery.of(context).size;
    final appBarHeight = windowSize.height * 0.067;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Background
            Container(color: theme.colorScheme.surface),
            // Scrollable content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              slivers: [
                // Top spacing for appbar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: appBarHeight + MediaQuery.of(context).padding.top,
                  ),
                ),
                // Generated password display
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
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
                            _generatedPassword.isEmpty
                                ? 'Tap generate'
                                : _generatedPassword,
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
                                    '($_passwordStrength%)',
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
                                  value: _passwordStrength / 100,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation(
                                    strengthColor,
                                  ),
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
                                    if (_generatedPassword.isNotEmpty) {
                                      Clipboard.setData(
                                        ClipboardData(text: _generatedPassword),
                                      );
                                      HapticFeedback.mediumImpact();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Password copied!'),
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                  color: theme.colorScheme.secondaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.doc_on_clipboard,
                                        color: theme
                                            .colorScheme
                                            .onSecondaryContainer,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Copy',
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onSecondaryContainer,
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
                                    _generatePassword();
                                  },
                                  color: theme.colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
                    ),
                  ),
                ),
                // Mode selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CupertinoSlidingSegmentedControl<bool>(
                        groupValue: _memorableMode,
                        onValueChanged: (value) {
                          setState(() {
                            _memorableMode = value ?? false;
                          });
                          _generatePassword();
                        },
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
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // Options
                if (!_memorableMode) ...[
                  // Password length slider
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Length',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${_passwordLength.round()}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: CupertinoSlider(
                                value: _passwordLength,
                                min: 8,
                                max: 32,
                                divisions: 24,
                                onChanged: (value) {
                                  setState(() {
                                    _passwordLength = value;
                                  });
                                },
                                onChangeEnd: (_) => _generatePassword(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
                // Character types
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          if (!_memorableMode) ...[
                            _buildIOSToggle(
                              context,
                              title: 'Uppercase (A-Z)',
                              value: _includeUppercase,
                              onChanged: (value) {
                                setState(() {
                                  _includeUppercase = value;
                                });
                                _generatePassword();
                              },
                            ),
                            _buildDivider(),
                            _buildIOSToggle(
                              context,
                              title: 'Lowercase (a-z)',
                              value: _includeLowercase,
                              onChanged: (value) {
                                setState(() {
                                  _includeLowercase = value;
                                });
                                _generatePassword();
                              },
                            ),
                            _buildDivider(),
                          ],
                          _buildIOSToggle(
                            context,
                            title: 'Numbers (0-9)',
                            value: _includeNumbers,
                            onChanged: (value) {
                              setState(() {
                                _includeNumbers = value;
                              });
                              _generatePassword();
                            },
                          ),
                          _buildDivider(),
                          _buildIOSToggle(
                            context,
                            title: 'Symbols (!@#\$)',
                            value: _includeSymbols,
                            onChanged: (value) {
                              setState(() {
                                _includeSymbols = value;
                              });
                              _generatePassword();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // Tips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.lightbulb,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Security Tips',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._getTips().map(
                            (tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    CupertinoIcons.checkmark_circle_fill,
                                    size: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.blue.shade900,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
            // ScrollableAppBar
            ScrollableAppBar(
              title: 'Password Generator',
              scrollController: _scrollController,
              leading: CircularActionButton(
                icon: CupertinoIcons.line_horizontal_3,
                onTap: () {
                  wrapperScaffoldKey.currentState?.openDrawer();
                },
                scrollController: _scrollController,
              ),
            ),
          ],
        ),
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.secondary.withAlpha(50),
      ),
    );
  }

  List<String> _getTips() {
    if (_memorableMode) {
      return [
        'Memorable passwords are easier to remember',
        'Use 3-4 words for better security',
        'Still maintain uniqueness across accounts',
      ];
    } else {
      return [
        'Use at least 12-16 characters',
        'Mix all character types for strength',
        'Never reuse passwords',
        'Store passwords securely',
      ];
    }
  }

  Color _getStrengthColor(int strength) {
    if (strength >= 80) return Colors.green;
    if (strength >= 60) return Colors.lightGreen;
    if (strength >= 40) return Colors.orange;
    if (strength >= 20) return Colors.deepOrange;
    return Colors.red;
  }
}
