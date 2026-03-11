import 'package:flutter/material.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() {
    return _ConnectionScreenState();
  }
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  bool bluetoothToggle = false;
  bool wifiToggle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.only(top: 3, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.only(left: 10),
                  child: Text(
                    "Подключение",
                    style: TextStyle(
                      fontSize: 28,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // bluetooth toggle button
                _bluetoothButton(),
                SizedBox(height: 20),
                _wifiButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bluetoothButton() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(36),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() {
              bluetoothToggle = !bluetoothToggle;
              // bluetooth conenction callable
            }),
            child: Padding(
              padding: const EdgeInsets.only(left: 36, right: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 170),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: bluetoothToggle
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        child: const Text("Bluetooth"),
                      ),
                      Text(
                        "Поиск устройств...",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(150),
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),

                  //bluetooth switch
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 80,
                    height: 45,
                    decoration: BoxDecoration(
                      color: bluetoothToggle
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: bluetoothToggle
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: bluetoothToggle
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(
                                    context,
                                  ).colorScheme.outline.withAlpha(100),
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

  Widget _wifiButton() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(36),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() {
              wifiToggle = !wifiToggle;
              // bluetooth conenction callable
            }),
            child: Padding(
              padding: const EdgeInsets.only(left: 36, right: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 170),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: wifiToggle
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        child: const Text("Wifi"),
                      ),
                      Text(
                        "Поиск устройств...",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(150),
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),

                  //bluetooth switch
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 80,
                    height: 45,
                    decoration: BoxDecoration(
                      color: wifiToggle
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: wifiToggle
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: wifiToggle
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(
                                    context,
                                  ).colorScheme.outline.withAlpha(100),
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
}
