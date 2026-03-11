import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:redrive/screens/connect_screen.dart';
import '../core/global_state.dart';
import 'dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _panelAnimation;

  final double minHeight = 50.0;
  final double maxHeight = 100.0;

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
    const ConnectionScreen(),
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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animationController.addListener(() {
      GlobalState.panelHeight.value = _panelAnimation.value;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragEnd(DragEndDetails details) {
    double currentHeight = GlobalState.panelHeight.value;
    double midPoint = (minHeight + maxHeight) / 2;

    double targetHeight;
    if (details.primaryVelocity! < -100) {
      targetHeight = maxHeight;
    } else if (details.primaryVelocity! > 100) {
      targetHeight = minHeight;
    } else {
      targetHeight = currentHeight >= midPoint ? maxHeight : minHeight;
    }

    _panelAnimation = Tween<double>(begin: currentHeight, end: targetHeight)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: GlobalState.panelHeight,
            child: IndexedStack(index: _currentIndex, children: _screens),
            builder: (context, height, cachedChild) {
              return Padding(
                padding: EdgeInsets.only(bottom: height),
                child: cachedChild,
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
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
        double t = ((height - minHeight) / (maxHeight - minHeight)).clamp(
          0.0,
          1.0,
        );

        return GestureDetector(
          onVerticalDragUpdate: (details) {
            _animationController.stop();

            double newHeight = height - (details.delta.dy * 1.5);
            GlobalState.panelHeight.value = newHeight.clamp(
              minHeight,
              maxHeight,
            );
          },
          onVerticalDragEnd: _onDragEnd,

          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Color.lerp(
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceContainer,
                t,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 20,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Container(
                    width: 35,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Иконки
                Opacity(
                  opacity: t,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        _buildNavItem(
                          'assets/images/svg/bottomBar/home.svg',
                          52,
                          0,
                        ),
                        _buildNavItem(
                          'assets/images/svg/bottomBar/car.svg',
                          45,
                          1,
                          padding: const EdgeInsets.only(left: 7),
                        ),
                        _buildNavItem(
                          'assets/images/svg/bottomBar/dashboard.svg',
                          38,
                          2,
                          padding: const EdgeInsets.only(left: 10),
                        ),
                        _buildNavItem(
                          'assets/images/svg/bottomBar/light.svg',
                          40,
                          3,
                        ),
                        _buildNavItem(
                          'assets/images/svg/bottomBar/bot.svg',
                          47,
                          4,
                          padding: const EdgeInsets.only(right: 8),
                        ),
                        _buildNavItem(
                          'assets/images/svg/bottomBar/map.svg',
                          43,
                          5,
                          padding: const EdgeInsets.only(right: 2),
                        ),
                        _buildNavItem(
                          'assets/images/svg/bottomBar/music.svg',
                          43,
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

  Widget _buildNavItem(
    String iconPath,
    double size,
    int index, {
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    bool isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },

        child: SizedBox(
          height: 55,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: padding,
                child: AnimatedScale(
                  scale: isActive ? (size + 5) / size : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: SvgPicture.asset(
                    iconPath,
                    width: size,
                    height: size,
                    colorFilter: ColorFilter.mode(
                      isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
