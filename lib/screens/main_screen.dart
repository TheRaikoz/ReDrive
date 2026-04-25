import 'package:flutter/material.dart';
import 'package:redrive/screens/car_screen.dart';
import 'package:redrive/screens/connect_screen.dart';
import 'package:redrive/widget/bottom_bar/custom_bottom_bar.dart';
import 'dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const DashboardScreen(),
    Container(color: Colors.black),
    const ConnectionScreen(),
    const CarScreen(),
    Container(color: Colors.black),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
