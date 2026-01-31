import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.sizeOf(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if(context.mounted){
          GoRouter.of(context).go('/welcome');
        }
      });
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/logo/1.png',
                height: windowSize.height * 0.4,
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: CupertinoActivityIndicator(
                  color: theme.colorScheme.onSurface.withAlpha(128),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
