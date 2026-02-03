import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';
import 'package:shieldx/app/core/services/password_generator_service.dart';
import 'package:shieldx/app/shared/widgets/scrollable_appbar.dart';
import 'package:shieldx/app/shared/widgets/circular_action_button.dart';
import 'package:shieldx/app/features/dashboard/features/generator/widgets/password_display_card.dart';
import 'package:shieldx/app/features/dashboard/features/generator/widgets/password_mode_selector.dart';
import 'package:shieldx/app/features/dashboard/features/generator/widgets/password_length_slider.dart';
import 'package:shieldx/app/features/dashboard/features/generator/widgets/character_types_selector.dart';
import 'package:shieldx/app/features/dashboard/features/generator/widgets/security_tips_card.dart';

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
                    child: PasswordDisplayCard(
                      generatedPassword: _generatedPassword,
                      passwordStrength: _passwordStrength,
                      onGenerate: _generatePassword,
                    ),
                  ),
                ),
                // Mode selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PasswordModeSelector(
                      memorableMode: _memorableMode,
                      onModeChanged: (value) {
                        setState(() {
                          _memorableMode = value;
                        });
                        _generatePassword();
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // Password length slider (only for random mode)
                if (!_memorableMode) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PasswordLengthSlider(
                        passwordLength: _passwordLength,
                        onLengthChanged: (value) {
                          setState(() {
                            _passwordLength = value;
                          });
                        },
                        onGeneratePassword: _generatePassword,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
                // Character types
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CharacterTypesSelector(
                      memorableMode: _memorableMode,
                      includeUppercase: _includeUppercase,
                      includeLowercase: _includeLowercase,
                      includeNumbers: _includeNumbers,
                      includeSymbols: _includeSymbols,
                      onUppercaseChanged: (value) {
                        setState(() {
                          _includeUppercase = value;
                        });
                        _generatePassword();
                      },
                      onLowercaseChanged: (value) {
                        setState(() {
                          _includeLowercase = value;
                        });
                        _generatePassword();
                      },
                      onNumbersChanged: (value) {
                        setState(() {
                          _includeNumbers = value;
                        });
                        _generatePassword();
                      },
                      onSymbolsChanged: (value) {
                        setState(() {
                          _includeSymbols = value;
                        });
                        _generatePassword();
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // Security tips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SecurityTipsCard(memorableMode: _memorableMode),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                // Bottom spacing for floating navigation bar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 76 + MediaQuery.of(context).padding.bottom + 32,
                  ),
                ),
              ],
            ),
            // ScrollableAppBar
            ScrollableAppBar(
              title: 'Password Generator',
              scrollController: _scrollController,
              leading: CircularActionButton(
                icon: Icons.menu,
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
}
