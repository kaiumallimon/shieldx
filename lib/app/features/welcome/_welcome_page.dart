import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shieldx/app/features/welcome/models/_welcome_model.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  final _welcomeList = welcomeData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(child:PageView.builder(itemBuilder: (context, index) {
        final welcomeItem = _welcomeList[index];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: windowSize.height * 0.4,
                child: SvgPicture.asset(welcomeItem.imagePath),
              ),
              const SizedBox(height: 24),
              Text(
                welcomeItem.title,
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                welcomeItem.description,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
      itemCount: _welcomeList.length,
      ),)
    );
  }
}
