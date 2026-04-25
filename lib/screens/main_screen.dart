import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:redrive/screens/car_screen.dart';
import 'package:redrive/screens/connect_screen.dart';
import 'dashboard_screen.dart';

class BottomBarItemData {
  final String iconPath;
  final String label;

  const BottomBarItemData({required this.iconPath, required this.label});
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final double _currentHeight = 100.0;

  final Color _activeColor = const Color(0xFFBDF343);
  final Color _inactiveColor = Colors.grey.shade600;

  late final List<Widget> _screens = [
    const DashboardScreen(), // главный экран (дашборд)
    Container(color: Colors.black), // экран приборной панели
    const ConnectionScreen(), // экран подключения
    const CarScreen(), // экран гаража и выбора машин
    Container(color: Colors.black), // экран ошибок и их исправления
  ];

  final List<BottomBarItemData> _navItems = const [
    BottomBarItemData(
      iconPath: 'assets/images/svg/bottomBar/home.svg',
      label: 'Home',
    ),
    BottomBarItemData(
      iconPath: 'assets/images/svg/bottomBar/dashboard.svg',
      label: 'Dashboard',
    ),
    BottomBarItemData(
      iconPath: 'assets/images/svg/bottomBar/connection.svg',
      label: 'Connection',
    ),
    BottomBarItemData(
      iconPath: 'assets/images/svg/bottomBar/garage.svg',
      label: 'Garage',
    ),
    BottomBarItemData(
      iconPath: 'assets/images/svg/bottomBar/dtc.svg',
      label: 'DTC',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: _currentHeight,
      decoration: const BoxDecoration(color: Colors.black),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_navItems.length, (index) {
          return _buildNavItem(_navItems[index], index);
        }),
      ),
    );
  }

  Widget _buildNavItem(BottomBarItemData data, int index) {
    bool isActive = _currentIndex == index;
    Color currentColor = isActive ? _activeColor : _inactiveColor;

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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: SvgPicture.asset(
                data.iconPath,
                width: isActive ? 25 : 23,
                height: isActive ? 25 : 23,
                colorFilter: ColorFilter.mode(currentColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 6),

            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: currentColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(data.label),
            ),
            const SizedBox(height: 4),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: isActive ? 24 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
