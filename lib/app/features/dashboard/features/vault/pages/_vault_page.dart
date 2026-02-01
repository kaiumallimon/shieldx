import 'package:flutter/material.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_button.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_avatar.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_slogan_section.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_password_health_card.dart';

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

  final List<String> _categories = [
    'All',
    'Social',
    'Work',
    'Finance',
    'Shopping',
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
                  child: VaultAvatar(userName: userName, avatarUrl: avatarUrl),
                ),
                pinned: true,
                actions: [
                  VaultAddButton(
                    onPressed: () {
                      // Navigate to add password page
                    },
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: VaultSloganSection()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(50),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'Categories',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: const [
                              Colors.transparent,
                              Colors.black,
                              Colors.black,
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.05, 0.85, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: SizedBox(
                          height: 45,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List.generate(_categories.length, (
                              index,
                            ) {
                              return GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 45,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withAlpha(
                                      50,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    _categories[index],
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface
                                          .withAlpha(128),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 45,
                        width: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.add,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: VaultPasswordHealthCard(
                  totalPasswords: 69,
                  safeCount: 54,
                  weakCount: 12,
                  reusedCount: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
