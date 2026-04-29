import 'package:flutter/material.dart';
import 'dart:math' as math;

class CarDisplay extends StatefulWidget {
  const CarDisplay({super.key});

  @override
  State<CarDisplay> createState() => _CarDisplayState();
}

class _CarDisplayState extends State<CarDisplay> {
  final PageController _pageController = PageController();
  final int _carCount = 5;

  bool _isImagesCached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isImagesCached) {
      for (int i = 1; i <= _carCount; i++) {
        precacheImage(AssetImage('assets/images/png/car$i.png'), context);
      }
      _isImagesCached = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withAlpha(120),
            const Color.fromARGB(255, 45, 47, 48),
            const Color.fromARGB(255, 45, 47, 48),
            Theme.of(context).colorScheme.primary.withAlpha(120),
          ],
          stops: const [0.0, 0.10, 0.90, 1.0],
          transform: const GradientRotation(math.pi / 5),
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.5),
          color: const Color(0xFF121212),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _carCount,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      'assets/images/png/car${index + 1}.png',
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double pageOffset = 0.0;
                  if (_pageController.hasClients &&
                      _pageController.position.haveDimensions) {
                    pageOffset = _pageController.page ?? 0.0;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_carCount, (index) {
                      double distance = (pageOffset - index).abs();
                      double factor = (1 - distance).clamp(0.0, 1.0);

                      double width = 8.0 + (8.0 * factor);

                      Color activeColor = Theme.of(context).colorScheme.primary;
                      Color inactiveColor = Colors.white.withValues(alpha: 0.2);
                      Color? currentColor = Color.lerp(
                        inactiveColor,
                        activeColor,
                        factor,
                      );

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3.0),
                        width: width,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
