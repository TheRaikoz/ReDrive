import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redrive/widget/home_screen/car_display.dart';
import 'package:redrive/widget/home_screen/connections_buttons.dart';
import 'package:redrive/widget/home_screen/header_bar.dart';
import 'package:redrive/widget/home_screen/telemetry_card.dart';
import '../providers/obd_provider.dart';
import 'dart:developer' as developer;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<String>? _errorSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ObdProvider>();
      _errorSubscription = provider.errorEvents.listen((errorMessage) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final obdProvider = context.watch<ObdProvider>();

    final obdData = obdProvider.data;
    final bool isActive = obdProvider.isRealMode;
    final bool isDemo = obdProvider.isDemoMode;
    final bool isConnected = obdProvider.isDeviceConnected;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderBar(), // шапка ( название + настройки )
                const SizedBox(height: 15),

                const CarDisplay(), // отображение карусели машин
                const SizedBox(height: 15),

                /// отображение телеметрии
                /// ( две карточки связующие с obd модулем )
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 190,
                        child: TelemetryCard(
                          title: "Speed",
                          value: obdData.speed.toDouble(),
                          fractionDigits: 0,
                          valueSuffix: "",
                          unit: "km/h",
                          iconPath: 'assets/images/svg/dashboard/speed.svg',
                          progress: obdData.speed / 240,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 190,
                        child: TelemetryCard(
                          title: "RPM",
                          value: obdData.rpm / 1000,
                          fractionDigits: 1,
                          valueSuffix: "K",
                          unit: "rpm",
                          iconPath: 'assets/images/svg/dashboard/engine.svg',
                          progress: (obdData.rpm / 8000).clamp(0.0, 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                /// кнопки для подключения к эбу
                /// либо для подключения демо режима
                ConnectionButtons(
                  isConnected: isActive,
                  isDemoMode: isDemo,

                  onConnect: () async {
                    developer.log("состояние $isConnected");
                    if (isConnected) {
                      if (isActive ||
                          obdProvider.state ==
                              ObdConnectionState.initializing) {
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                                borderRadius:
                                                    BorderRadius.circular(100),
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

                        /// Если не в реальном режиме при выходе с функции
                        /// не переподключается в данный момент
                        /// и не в демо режиме ( изза того что оно при вызове
                        /// функции отключается ) то вызываем
                        if ((!obdProvider.isRealMode &&
                                !obdProvider
                                    .currentConnection
                                    .isReconnecting) &&
                            (!obdProvider.isDemoMode)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Ошибка: Не удалось связаться с ЭБУ",
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Сначала подключитесь к Ble/Wifi/USB",
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },

                  onViewDemo: () {
                    if (isActive) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Сначала отключитесь от ЭБУ"),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    } else {
                      context.read<ObdProvider>().toggleDemoMode();
                    }
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
