import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/app_colors.dart';
import '../core/global_state.dart';
import 'dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    Container(
      color: Colors.red.withValues(alpha: 0.2),
      child: const Center(child: Text("Экран 2")),
    ),
    Container(
      color: Colors.green.withValues(alpha: 0.2),
      child: const Center(child: Text("Экран 3")),
    ),
    Container(
      color: Colors.purple.withValues(alpha: 0.2),
      child: const Center(child: Text("Экран 4")),
    ),
    Container(
      color: Colors.orange.withValues(alpha: 0.2),
      child: const Center(child: Text("Экран 5")),
    ),
    Container(
      color: Colors.teal.withValues(alpha: 0.2),
      child: const Center(child: Text("Экран 6")),
    ),
    Container(
      color: Colors.pink.withValues(alpha: 0.2),
      child: const Center(child: Text("Экран 7")),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: GlobalState.panelHeight,
            builder: (context, height, child) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: IndexedStack(index: _currentIndex, children: _screens),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildDraggableBottomPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableBottomPanel() {
    const double minHeight = 50.0;
    const double maxHeight = 100.0;

    return ValueListenableBuilder<double>(
      valueListenable: GlobalState.panelHeight,
      builder: (context, height, child) {
        double t = ((height - minHeight) / (maxHeight - minHeight)).clamp(
          0.0,
          1.0,
        );

        return GestureDetector(
          onVerticalDragUpdate: (details) {
            double newHeight = height - details.delta.dy;
            GlobalState.panelHeight.value = newHeight.clamp(
              minHeight,
              maxHeight,
            );
          },
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Color.lerp(Colors.transparent, const Color(0xFF0A0D14), t),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 35,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 4),
                // Иконки
                Opacity(
                  opacity: t,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      // spaceBetween тут больше не нужен, Expanded сделает всю работу
                      children: [
                        _buildNavItem(
                          'assets/images/svg/bottomBar/home.svg',
                          55,
                          0,
                        ),
                        _buildNavItem(
                          'assets/images/svg/bottomBar/car.svg',
                          40,
                          1,
                        ),
                        _buildNavItem(
                          'assets/images/svg/bottomBar/dashboard.svg',
                          40,
                          2,
                        ),
                        _buildNavItem(
                          'assets/images/svg/bottomBar/light.svg',
                          40,
                          3,
                        ),
                        _buildNavItem(
                          'assets/images/svg/bottomBar/bot.svg',
                          40,
                          4,
                        ),
                        _buildNavItem(
                          'assets/images/svg/bottomBar/map.svg',
                          40,
                          5,
                        ),
                        _buildNavItem(
                          'assets/images/svg/bottomBar/music.svg',
                          40,
                          6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(String iconPath, double size, int index) {
    bool isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: size,
              height: size,
              colorFilter: ColorFilter.mode(
                isActive ? AppColors.accent : Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),

            // AnimatedOpacity(
            //   duration: const Duration(milliseconds: 500),
            //   opacity: isActive ? 1.0 : 0.0,
            //   child: Container(
            //     width: 24,
            //     height: 3,
            //     decoration: BoxDecoration(
            //       color: AppColors.accent,
            //       borderRadius: BorderRadius.circular(10),
            //       boxShadow: [
            //         BoxShadow(
            //           color: AppColors.accent.withValues(alpha: 0.8),
            //           blurRadius: 6,
            //           spreadRadius: 1,
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
