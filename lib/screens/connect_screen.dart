import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';
import '../models/obd_device.dart';

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

  void _toggleBluetooth(BluetoothProvider provider) {
    setState(() {
      bluetoothToggle = !bluetoothToggle;
    });

    if (bluetoothToggle) {
      provider.startScan();
    } else {
      provider.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = context.watch<BluetoothProvider>();

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
                _bluetoothButton(bluetoothProvider),
                SizedBox(height: 20),
                // _wifiButton(),
                SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bluetoothButton(BluetoothProvider provider) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 140),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutQuart,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 136,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _toggleBluetooth(provider),
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
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: bluetoothToggle
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                                child: const Text(
                                  "Bluetooth",
                                  textScaler: TextScaler.noScaling,
                                ),
                              ),
                              Text(
                                textScaler: TextScaler.noScaling,
                                provider.isScanning
                                    ? "Поиск устройств..."
                                    : "Нажмите для поиска",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(150),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),

                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            width: 75,
                            height: 45,
                            decoration: BoxDecoration(
                              color: bluetoothToggle
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              alignment: bluetoothToggle
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
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

              if (bluetoothToggle) ...[
                Divider(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withAlpha(100),
                  height: 1,
                  indent: 24,
                  endIndent: 24,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 16,
                  ),
                  child:
                      // если грузится и устройства отсутвуют то...
                      provider.isScanning && provider.discoveredDevices.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          children: provider.discoveredDevices.map((device) {
                            return _buildDeviceItem(device, provider);
                          }).toList(),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceItem(ObdDevice device, BluetoothProvider provider) {
    bool isConnected = provider.connectedDevice?.address == device.address;

    String statusText = isConnected ? "Подключено" : "Доступно";
    Color bgColor = isConnected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outlineVariant.withAlpha(150);
    Color textColor = isConnected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface.withAlpha(150);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!isConnected) provider.connectToDevice(device);
        },
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  device.name,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusText,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _wifiButton() {
  //   return Container(
  //     width: double.infinity,
  //     height: 140,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(36),
  //       color: Theme.of(context).colorScheme.surfaceContainer,
  //       border: Border.all(
  //         width: 2,
  //         color: Theme.of(context).colorScheme.outlineVariant,
  //       ),
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadiusGeometry.circular(36),
  //       child: Material(
  //         color: Colors.transparent,
  //         child: InkWell(
  //           onTap: () => setState(() {
  //             wifiToggle = !wifiToggle;
  //             // bluetooth conenction callable
  //           }),
  //           child: Padding(
  //             padding: const EdgeInsets.only(left: 36, right: 36),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     AnimatedDefaultTextStyle(
  //                       duration: const Duration(milliseconds: 170),
  //                       curve: Curves.easeInOut,
  //                       style: TextStyle(
  //                         fontSize: 19,
  //                         fontWeight: FontWeight.w800,
  //                         color: wifiToggle
  //                             ? Theme.of(context).colorScheme.primary
  //                             : Theme.of(context).colorScheme.onSurface,
  //                       ),
  //                       child: const Text("Wifi"),
  //                     ),
  //                     Text(
  //                       "Поиск устройств...",
  //                       style: TextStyle(
  //                         color: Theme.of(
  //                           context,
  //                         ).colorScheme.onSurface.withAlpha(150),
  //                         fontWeight: FontWeight.w800,
  //                         fontSize: 10.5,
  //                       ),
  //                     ),
  //                   ],
  //                 ),

  //                 //bluetooth switch
  //                 AnimatedContainer(
  //                   duration: const Duration(milliseconds: 200),
  //                   curve: Curves.easeInOut,
  //                   width: 80,
  //                   height: 45,
  //                   decoration: BoxDecoration(
  //                     color: wifiToggle
  //                         ? Theme.of(context).colorScheme.primary
  //                         : Theme.of(context).colorScheme.outlineVariant,
  //                     borderRadius: BorderRadius.circular(100),
  //                   ),
  //                   child: AnimatedAlign(
  //                     duration: const Duration(milliseconds: 200),
  //                     curve: Curves.easeInOut,
  //                     alignment: wifiToggle
  //                         ? Alignment.centerRight
  //                         : Alignment.centerLeft,
  //                     child: Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 8),
  //                       child: AnimatedContainer(
  //                         duration: const Duration(milliseconds: 220),
  //                         curve: Curves.easeInOut,
  //                         width: 30,
  //                         height: 30,
  //                         decoration: BoxDecoration(
  //                           color: wifiToggle
  //                               ? Theme.of(context).colorScheme.outline
  //                               : Theme.of(
  //                                   context,
  //                                 ).colorScheme.outline.withAlpha(100),
  //                           shape: BoxShape.circle,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
