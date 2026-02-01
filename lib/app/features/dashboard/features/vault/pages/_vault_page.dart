import 'package:flutter/material.dart';

class VaultPage extends StatelessWidget {
  const VaultPage({super.key});

  final List<String> images = const [
    'assets/images/18930.jpg',
    'assets/images/143415.jpg',
    'assets/images/41064.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: CustomScrollView(
        slivers: [
          SliverAppBar(
            
          )
        ],
      )),
    );
  }
}