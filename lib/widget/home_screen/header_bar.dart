import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(
                    text: 'Re',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'Drive',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'DRIVE SMARTER',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 212, 149, 149),
                letterSpacing: 5.0,
              ),
            ),
          ],
        ),

        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withAlpha(80),
                Theme.of(context).colorScheme.surfaceContainer,
              ],
              stops: const [0.0, 0.6],
            ),
          ),
          padding: const EdgeInsets.all(1.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Запуск настроек
                },
                borderRadius: BorderRadius.circular(100),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/svg/dashboard/settings.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFBDF343),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
