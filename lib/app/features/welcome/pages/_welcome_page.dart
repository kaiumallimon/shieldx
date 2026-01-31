import 'package:flutter/material.dart';
import 'package:shieldx/app/features/welcome/models/_welcome_model.dart';
import 'package:shieldx/app/features/welcome/widgets/_footer_buttons.dart';
import 'package:shieldx/app/features/welcome/widgets/_page_indicators.dart';
import 'package:shieldx/app/features/welcome/widgets/_skip_button.dart';
import 'package:shieldx/app/features/welcome/widgets/_welcome_description.dart';
import 'package:shieldx/app/features/welcome/widgets/_welcome_image_container.dart';
import 'package:shieldx/app/features/welcome/widgets/_welcome_title.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _welcomeList = welcomeData;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    final isSmallScreen = windowSize.height < 700;
    final horizontalPadding = windowSize.width > 600 ? 40.0 : 20.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              SkipButton(
                onPressed: () {
                  // Navigate to main app or skip onboarding
                },
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final welcomeItem = _welcomeList[index];
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: isSmallScreen ? 10 : 20),
                            WelcomeImageContainer(
                              imagePath: welcomeItem.imagePath,
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 20 : 30),
                            WelcomeTitle(title: welcomeItem.title),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            WelcomeDescription(description: welcomeItem.description),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: _welcomeList.length,
                ),
              ),
              const SizedBox(height: 20),
              PageIndicators(
                pageController: _pageController,
                pageCount: _welcomeList.length,
              ),
              const SizedBox(height: 20),
              FooterButtons(
                pageController: _pageController,
                totalPages: _welcomeList.length,
                onGetStarted: () {
                  // Navigate to get started or login
                },
                onNavigateToApp: () {
                  // Navigate to main app
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
