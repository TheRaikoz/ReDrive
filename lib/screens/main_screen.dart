import 'package:flutter/material.dart';
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: GlobalState.panelHeight,
            builder: (context, height, child) {
              return Padding(
                padding: EdgeInsets.only(bottom: height),
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
    return ValueListenableBuilder<double>(
      valueListenable: GlobalState.panelHeight,
      builder: (context, height, child) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            double newHeight = height - details.delta.dy;
            GlobalState.panelHeight.value = newHeight.clamp(90.0, 400.0);
          },
          child: Container(
            height: height,
            decoration: const BoxDecoration(
              color: Color(0xFF0A0D14),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavItem(Icons.home, 0),
                      _buildNavItem(Icons.directions_car, 1),
                      _buildNavItem(Icons.smart_toy, 2),
                      _buildNavItem(Icons.flash_on, 3),
                      _buildNavItem(Icons.speed, 4),
                      _buildNavItem(Icons.map, 5),
                      _buildNavItem(Icons.music_note, 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isActive = _currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentIndex = index;
          GlobalState.panelHeight.value = 90.0;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: isActive ? AppColors.accent : Colors.white,
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isActive ? 1.0 : 0.0,
            child: Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.8),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
