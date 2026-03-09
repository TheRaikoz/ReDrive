import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isToggledDemo = false;
  bool isToggledConnection = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, top: 3, right: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildDemoModeToggle(),
                    const Spacer(),
                    _buildSettingsButton(),
                  ],
                ),
                const SizedBox(height: 10),
                _buildLargeContainer(height: 220),
                const SizedBox(height: 15),
                _buildRoundedContainer(),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildDashboardCard(
                        title: "Текущая\nскорость",
                        value: "120",
                        iconPath: 'assets/images/svg/dashboard/speed.svg',
                        gradientBegin: Alignment.topLeft,
                        gradientEnd: Alignment.bottomRight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDashboardCard(
                        title: "Обороты\nдвигателя",
                        value: "2500",
                        iconPath: 'assets/images/svg/dashboard/engine.svg',
                        gradientBegin: Alignment.topRight,
                        gradientEnd: Alignment.bottomLeft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildDashboardCard(
                        title: "Уровень\nтоплива",
                        value: "65%",
                        iconPath: 'assets/images/svg/dashboard/fuel.svg',
                        gradientBegin: Alignment.bottomLeft,
                        gradientEnd: Alignment.topRight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDashboardCardTemp(
                        title: "Температура\nдвигателя",
                        value: "90°C",
                        iconPath: 'assets/images/svg/dashboard/temp.svg',
                        gradientBegin: Alignment.bottomRight,
                        gradientEnd: Alignment.topLeft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return Container(
      width: 35,
      height: 35,
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // onTap: () {
          //   // Настройки
          // },
          borderRadius: BorderRadius.circular(100),
          child: Center(
            child: SvgPicture.asset(
              'assets/images/svg/dashboard/settings.svg',
              width: 30,
              height: 30,
              colorFilter: const ColorFilter.mode(
                AppColors.accent,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Виджет для переключателя Demo Mode
  Widget _buildDemoModeToggle() {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => setState(() => isToggledDemo = !isToggledDemo),
        borderRadius: BorderRadius.circular(24),
        splashColor: AppColors.accent.withValues(alpha: 0.3),
        highlightColor: AppColors.accent.withValues(alpha: 0.1),
        child: Container(
          width: 65,
          height: 35,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accent, width: 2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: isToggledDemo
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: Text(
                    textScaler: TextScaler.noScaling,
                    'Demo\nmode',
                    textAlign: isToggledDemo ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.accent,
                      height: 1.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: isToggledDemo
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    width: 23,
                    height: 23,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
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

  // Переиспользуемый виджет для больших контейнеров
  Widget _buildLargeContainer({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Добавляем градиент
        color: AppColors.cardBg,
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [
        //     const Color(0xFF000000), // Черный (0%)
        //     const Color(0xFF112042), // Синий (100%)
        //   ],
        // ),
      ),

      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            child: Image.asset(
              'assets/images/png/car_background.png',
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }

  // Специальный виджет для круглого контейнера
  Widget _buildRoundedContainer() {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                setState(() => isToggledConnection = !isToggledConnection),
            splashColor: AppColors.accent.withValues(alpha: 0.2),
            highlightColor: AppColors.accent.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/svg/connect_main.svg',
                    width: 45,
                    height: 45,
                    colorFilter: ColorFilter.mode(
                      AppColors.accent,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Text(
                    "Подключено",
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 70,
                    height: 43,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.accent, width: 2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: isToggledConnection
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required String iconPath,
    required Alignment gradientBegin,
    required Alignment gradientEnd,
  }) {
    return Container(
      height: 178,
      padding: const EdgeInsets.only(left: 12, top: 12, right: 10, bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: gradientBegin,
          end: gradientEnd,
          colors: const [Color(0xFF000000), Color(0xFF112042)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: AppColors.cardBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      AppColors.accent,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
          Text(
            value,
            textScaler: TextScaler.noScaling,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 42,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCardTemp({
    required String title,
    required String value,
    required String iconPath,
    required Alignment gradientBegin,
    required Alignment gradientEnd,
  }) {
    return Container(
      height: 178,
      padding: const EdgeInsets.only(left: 12, top: 12, right: 10, bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: gradientBegin,
          end: gradientEnd,
          colors: const [Color(0xFF000000), Color(0xFF112042)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: AppColors.cardBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      AppColors.accent,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
          Text(
            value,
            textScaler: TextScaler.noScaling,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 42,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
