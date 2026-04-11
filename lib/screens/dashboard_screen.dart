import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/obd_provider.dart';
import 'dart:developer' as developer;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final obdData = context.watch<ObdProvider>().data;

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
                _buildCarCardContainer(height: 220),
                const SizedBox(height: 15),
                _buildConnectionContainer(),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildDashboardCard(
                        title: "Текущая\nскорость",
                        value: obdData.speed,
                        suffix: "",
                        iconPath: 'assets/images/svg/dashboard/speed.svg',
                        gradientBegin: Alignment.topLeft,
                        gradientEnd: Alignment.bottomRight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDashboardCard(
                        title: "Обороты\nдвигателя",
                        value: obdData.rpm,
                        suffix: "",
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
                      child: _buildDashboardCardVoltage(
                        title: "Напряжение\nАКБ",
                        value: obdData.voltage,
                        suffix: "V",
                        iconPath: 'assets/images/svg/dashboard/fuel.svg',
                        gradientBegin: Alignment.bottomLeft,
                        gradientEnd: Alignment.topRight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDashboardCardTemp(
                        title: "Температура\nдвигателя",
                        value: obdData.engineTemp,
                        suffix: "°C",
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          child: Center(
            child: SvgPicture.asset(
              'assets/images/svg/dashboard/settings.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoModeToggle() {
    final colorScheme = Theme.of(context).colorScheme;
    final isToggledDemo = context.watch<ObdProvider>().isDemoMode;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          context.read<ObdProvider>().toggleDemoMode();
        },
        borderRadius: BorderRadius.circular(24),
        splashColor: colorScheme.primary.withValues(alpha: 0.3),
        highlightColor: colorScheme.primary.withValues(alpha: 0.1),
        child: Container(
          width: 65,
          height: 35,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: isToggledDemo
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isToggledDemo ? 8.0 : 7.0,
                  ),
                  child: Text(
                    'Demo\nmode',
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      fontSize: 9,
                      color: colorScheme.onSurface,
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
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    width: 23,
                    height: 23,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
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

  Widget _buildCarCardContainer({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: Text(
              'MITSUBISHI LANCER IX',
              textAlign: TextAlign.center,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Positioned(
            bottom: 35,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 300,
                height: 20,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Transform.translate(
              offset: const Offset(0, 20),
              child: Image.asset(
                'assets/images/png/car_background.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionContainer() {
    final colorScheme = Theme.of(context).colorScheme;

    final obdProvider = context.watch<ObdProvider>();

    final bool isActive = obdProvider.isRealMode;
    bool isConnected = obdProvider.isDeviceConnected;

    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: colorScheme.primary, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              developer.log("состояние $isConnected");
              if (isConnected) {
                if (isActive) {
                  obdProvider.toggleRealMode();
                  return;
                }

                bool isCanceled = false;

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) {
                    return PopScope(
                      canPop: false,
                      child: AlertDialog(
                        insetPadding: const EdgeInsets.symmetric(
                          horizontal: 60,
                        ),
                        backgroundColor: Theme.of(
                          dialogContext,
                        ).colorScheme.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: EdgeInsets.zero,
                        content: SizedBox(
                          height: 220,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 55,
                                  height: 55,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4.5,
                                  ),
                                ),

                                Consumer<ObdProvider>(
                                  builder: (context, obd, child) {
                                    return Text(
                                      obd.initMessage,
                                      textAlign: TextAlign.center,
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    );
                                  },
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 26,
                                    right: 26,
                                    bottom: 8,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        isCanceled = true;
                                        obdProvider.stopRealData();
                                        Navigator.pop(dialogContext);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          dialogContext,
                                        ).colorScheme.primary,
                                        foregroundColor: Theme.of(
                                          dialogContext,
                                        ).colorScheme.onSurface,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Отмена",
                                        textScaler: TextScaler.noScaling,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            dialogContext,
                                          ).colorScheme.onSurface,
                                          fontSize: 16,
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
                    );
                  },
                );

                await obdProvider.toggleRealMode();

                if (!isCanceled && context.mounted) {
                  Navigator.pop(context);

                  if (!obdProvider.isRealMode &&
                      !obdProvider.currentConnection.isReconnecting) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          "Ошибка: Не удалось связаться с ЭБУ",
                        ),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                }
              } else {
                developer.log("Bluetooth не подключен", name: 'UI');
              }
            },

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/svg/connect_main.svg',
                    width: 45,
                    height: 45,
                    colorFilter: ColorFilter.mode(
                      colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "Подключено",
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 70,
                    height: 43,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: isActive
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
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
    required int value,
    required String iconPath,
    required String suffix,
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
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                "$animatedValue$suffix",
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCardVoltage({
    required String title,
    required num value,
    required String iconPath,
    required String suffix,
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
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: value.toDouble()),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                "${animatedValue.toStringAsFixed(1)}$suffix",
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCardTemp({
    required String title,
    required int value,
    required String iconPath,
    required String suffix,
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
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                "$animatedValue$suffix",
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
