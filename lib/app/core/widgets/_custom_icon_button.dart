import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../theme/_styles.dart';

class CustomIconCard extends StatelessWidget {
  const CustomIconCard({
    super.key,
    required this.theme,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final ColorScheme theme;
  final String text;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
            color: theme.primary.withOpacity(.1),
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            SvgPicture.asset(
              icon,
              height: 30,
              width: 30,
            ),
            const SizedBox(height: 5),
            Text(
              text,
              style: AppStyles.bodyTextStyle.copyWith(
                color: theme.onSurface.withOpacity(.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
