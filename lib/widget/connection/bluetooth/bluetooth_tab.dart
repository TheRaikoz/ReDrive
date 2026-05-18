import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redrive/models/obd_device.dart';
import 'package:redrive/providers/bluetooth_provider.dart';
import 'package:redrive/providers/ble_provider.dart';
import 'package:redrive/providers/connection_mode_provider.dart';
import 'package:redrive/providers/base_obd_transport_provider.dart';

BaseObdTransportProvider _activeProvider(BuildContext context) {
  final mode = context.watch<ConnectionModeProvider>().mode;
  return mode == ConnectionMode.classic
      ? context.read<BluetoothProvider>()
      : context.read<BleProvider>();
}

class BluetoothTab extends StatefulWidget {
  const BluetoothTab({super.key});

  @override
  State<BluetoothTab> createState() => _BluetoothTabState();
}

class _BluetoothTabState extends State<BluetoothTab> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = _activeProvider(context);

      if (!provider.isScanning && !provider.isConnected) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (!mounted) return;
          _activeProvider(context).startScan();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        BluetoothScanStatusCard(),
        SizedBox(height: 20),
        Expanded(child: BluetoothDevicePanel()),
      ],
    );
  }
}

class BluetoothScanStatusCard extends StatelessWidget {
  const BluetoothScanStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ConnectionModeProvider>().mode;

    final isScanning = mode == ConnectionMode.classic
        ? context.select<BluetoothProvider, bool>((p) => p.isScanning)
        : context.select<BleProvider, bool>((p) => p.isScanning);

    final devicesCount = mode == ConnectionMode.classic
        ? context.select<BluetoothProvider, int>((p) => p.discoveredDevices.length)
        : context.select<BleProvider, int>((p) => p.discoveredDevices.length);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF131315),
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (!isScanning) {
              Future.delayed(const Duration(milliseconds: 150), () {
                if (!context.mounted) return;
                _activeProvider(context).startScan();
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4FF47).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isScanning
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFFC4FF47),
                          ),
                        )
                      : const Icon(Icons.bluetooth, color: Color(0xFFC4FF47)),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isScanning ? "Scanning..." : "Scanning complete",
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isScanning
                            ? "Searching for your adapter..."
                            : "Found $devicesCount devices",
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isScanning)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC4FF47).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Color(0xFFC4FF47),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BluetoothDevicePanel extends StatelessWidget {
  const BluetoothDevicePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131315),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          BluetoothModeSwitcher(),
          Expanded(child: BluetoothDeviceList()),
        ],
      ),
    );
  }
}

class BluetoothModeSwitcher extends StatelessWidget {
  const BluetoothModeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final modeProvider = context.watch<ConnectionModeProvider>();

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => modeProvider.setMode(ConnectionMode.classic),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: modeProvider.isClassic
                    ? const Color(0xFFC4FF47)
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                "Classic",
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: modeProvider.isClassic ? Colors.black : Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => modeProvider.setMode(ConnectionMode.ble),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: modeProvider.isBle
                    ? const Color(0xFFC4FF47)
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                "BLE",
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: modeProvider.isBle ? Colors.black : Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BluetoothDeviceList extends StatelessWidget {
  const BluetoothDeviceList({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ConnectionModeProvider>().mode;

    if (mode == ConnectionMode.classic) {
      return const _ClassicDeviceList();
    } else {
      return const _BleDeviceList();
    }
  }
}

class _ClassicDeviceList extends StatelessWidget {
  const _ClassicDeviceList();

  @override
  Widget build(BuildContext context) {
    return Selector<BluetoothProvider, _BluetoothDeviceListState>(
      selector: (_, provider) {
        return _BluetoothDeviceListState(
          isScanning: provider.isScanning,
          devices: List<ObdDevice>.of(provider.discoveredDevices),
        );
      },
      shouldRebuild: (previous, next) {
        if (previous.isScanning != next.isScanning) return true;
        if (previous.devices.length != next.devices.length) return true;

        for (int i = 0; i < previous.devices.length; i++) {
          final oldDevice = previous.devices[i];
          final newDevice = next.devices[i];

          if (oldDevice.address != newDevice.address) return true;
          if (oldDevice.name != newDevice.name) return true;
        }

        return false;
      },
      builder: (context, state, child) {
        return _buildList(context, state);
      },
    );
  }

  Widget _buildList(BuildContext context, _BluetoothDeviceListState state) {
    if (state.devices.isEmpty && !state.isScanning) {
      return _emptyState(context);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.devices.length,
      separatorBuilder: (context, index) {
        return Divider(color: Colors.white.withAlpha(10), height: 1);
      },
      itemBuilder: (context, index) {
        final device = state.devices[index];

        return BluetoothDeviceTile(
          key: ValueKey(device.address),
          device: device,
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: const Color(0xFFC4FF47).withValues(alpha: 0.2),
          ),
          const SizedBox(height: 10),
          const Text(
            "No devices found",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Make sure the scanner is plugged in and the\nignition is turned on",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _activeProvider(context).startScan(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC4FF47),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                "Start Scanning",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BleDeviceList extends StatelessWidget {
  const _BleDeviceList();

  @override
  Widget build(BuildContext context) {
    return Selector<BleProvider, _BluetoothDeviceListState>(
      selector: (_, provider) {
        return _BluetoothDeviceListState(
          isScanning: provider.isScanning,
          devices: List<ObdDevice>.of(provider.discoveredDevices),
        );
      },
      shouldRebuild: (previous, next) {
        if (previous.isScanning != next.isScanning) return true;
        if (previous.devices.length != next.devices.length) return true;

        for (int i = 0; i < previous.devices.length; i++) {
          final oldDevice = previous.devices[i];
          final newDevice = next.devices[i];

          if (oldDevice.address != newDevice.address) return true;
          if (oldDevice.name != newDevice.name) return true;
        }

        return false;
      },
      builder: (context, state, child) {
        return _buildList(context, state);
      },
    );
  }

  Widget _buildList(BuildContext context, _BluetoothDeviceListState state) {
    if (state.devices.isEmpty && !state.isScanning) {
      return _emptyState(context);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.devices.length,
      separatorBuilder: (context, index) {
        return Divider(color: Colors.white.withAlpha(10), height: 1);
      },
      itemBuilder: (context, index) {
        final device = state.devices[index];

        return BluetoothDeviceTile(
          key: ValueKey(device.address),
          device: device,
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: const Color(0xFFC4FF47).withValues(alpha: 0.2),
          ),
          const SizedBox(height: 10),
          const Text(
            "No BLE devices found",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Make sure your BLE OBD adapter is powered\nand in range",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _activeProvider(context).startScan(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC4FF47),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                "Start Scanning",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BluetoothDeviceTile extends StatelessWidget {
  final ObdDevice device;

  const BluetoothDeviceTile({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ConnectionModeProvider>().mode;

    final connectedAddress = mode == ConnectionMode.classic
        ? context.select<BluetoothProvider, String?>(
            (p) => p.connectedDevice?.address,
          )
        : context.select<BleProvider, String?>(
            (p) => p.connectedDevice?.address,
          );

    final isConnected = connectedAddress == device.address;

    final isPaired = !isConnected;

    return ListTile(
      onTap: isConnected
          ? null
          : () {
              final provider = _activeProvider(context);
              _connectToAdapter(context, provider, device);
            },
      leading: Icon(
        device.isBle ? Icons.bluetooth_searching : Icons.bluetooth,
        color: isConnected ? const Color(0xFFC4FF47) : Colors.white54,
      ),
      title: Text(
        device.name,
        textScaler: TextScaler.noScaling,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        device.address,
        textScaler: TextScaler.noScaling,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isConnected ? const Color(0xFF334A12) : Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isConnected ? "Connected" : (isPaired ? "Paired" : "Available"),
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: isConnected ? const Color(0xFFC4FF47) : Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isConnected ? const Color(0xFFC4FF47) : Colors.white24,
                width: 2,
              ),
              color: isConnected ? const Color(0xFFC4FF47) : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _connectToAdapter(
  BuildContext context,
  BaseObdTransportProvider provider,
  ObdDevice device,
) async {
  bool isCanceled = false;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 60),
          backgroundColor: const Color(0xFF131315),
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
                      color: Color(0xFFC4FF47),
                    ),
                  ),

                  Selector<ConnectionModeProvider, String>(
                    selector: (_, modeProvider) {
                      final mode = modeProvider.mode;
                      return mode == ConnectionMode.classic
                          ? context.read<BluetoothProvider>().connectionMessage
                          : context.read<BleProvider>().connectionMessage;
                    },
                    builder: (context, message, child) {
                      return Text(
                        message,
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
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
                          provider.cancelConnection();

                          if (Navigator.of(dialogContext).canPop()) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC4FF47),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Text(
                          "Отмена",
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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

  final success = await provider.connectToDevice(device);

  if (isCanceled || !context.mounted) return;

  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }

  if (!success && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Ошибка: '${device.name}' не отвечает"),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _BluetoothDeviceListState {
  final bool isScanning;
  final List<ObdDevice> devices;

  const _BluetoothDeviceListState({
    required this.isScanning,
    required this.devices,
  });
}
