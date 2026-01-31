import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shieldx/app/features/welcome/models/_welcome_model.dart';
import 'package:shieldx/app/features/welcome/widgets/_footer_buttons.dart';
import 'package:shieldx/app/features/welcome/widgets/_page_indicators.dart';
import 'package:shieldx/app/features/welcome/widgets/_skip_button.dart';
import 'package:shieldx/app/features/welcome/widgets/_welcome_description.dart';
import 'package:shieldx/app/features/welcome/widgets/_welcome_image_container.dart';
import 'package:shieldx/app/features/welcome/widgets/_welcome_title.dart';

/// Welcome/Onboarding page that displays introduction screens
/// Shows 3 slides with images, titles, and descriptions
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // Welcome data containing all onboarding slides
  final _welcomeList = welcomeData;

  // Controller for managing page transitions
  final PageController _pageController = PageController();

  Future<void> _storeOnboardedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizing calculations
    final windowSize = MediaQuery.of(context).size;
    final isSmallScreen = windowSize.height < 700;
    final horizontalPadding = windowSize.width > 600 ? 40.0 : 20.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              // Skip button - allows users to bypass onboarding
              SkipButton(
                onPressed: () async {
                  // store onboarded status in shared preferences
                  await _storeOnboardedStatus();

                  // Navigate to main app
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),

              // Main content - PageView with welcome slides
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

                            // Welcome image/illustration
                            WelcomeImageContainer(
                              imagePath: welcomeItem.imagePath,
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 20 : 30),

                            // Title text
                            WelcomeTitle(title: welcomeItem.title),
                            SizedBox(height: isSmallScreen ? 12 : 16),

                            // Description text
                            WelcomeDescription(
                              description: welcomeItem.description,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: _welcomeList.length,
                ),
              ),

              // Page indicators - shows current slide position
              const SizedBox(height: 20),
              PageIndicators(
                pageController: _pageController,
                pageCount: _welcomeList.length,
              ),

              // Footer buttons - navigation controls
              const SizedBox(height: 20),
              FooterButtons(
                pageController: _pageController,
                totalPages: _welcomeList.length,
                onGetStarted: () async{
                  await _storeOnboardedStatus();
                  // Navigate to get started or login
                  if (context.mounted) {
                    context.go('/register');
                  }
                },
                onNavigateToApp: () async {
                  // store onboarded status in shared preferences
                  await _storeOnboardedStatus();
                  // Navigate to main app
                  if (context.mounted) {
                    context.go('/login');
                  }
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
