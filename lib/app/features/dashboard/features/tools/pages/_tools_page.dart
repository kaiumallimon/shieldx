import 'package:flutter/material.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Tools Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}