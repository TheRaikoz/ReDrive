import 'package:flutter/material.dart';
import 'package:redrive/widget/connection/bluetooth/bluetooth_tab.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  /// 0 - Bluetooth, 1 - Wi-Fi, 2 - USB
  int _selectedTabIndex = 0;

  bool _isBluetoothActivated = false;

  void _onTabSelected(int index) async {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _activateBluetooth() {
    setState(() {
      _isBluetoothActivated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Connection",
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.8,
                  height: 1.0,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),

              const SizedBox(height: 14),

              /// tabs
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      alignment: Alignment(
                        _selectedTabIndex == 0
                            ? -1.0
                            : (_selectedTabIndex == 1 ? 0.0 : 1.0),
                        0,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 1 / 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        _buildTab(
                          index: 0,
                          icon: Icons.bluetooth,
                          label: "Bluetooth",
                          colorScheme: colorScheme,
                        ),
                        _buildTab(
                          index: 1,
                          icon: Icons.wifi,
                          label: "Wi-Fi",
                          colorScheme: colorScheme,
                        ),
                        _buildTab(
                          index: 2,
                          icon: Icons.usb,
                          label: "USB",
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Expanded(child: _buildTabContent(colorScheme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
  }) {
    final isActive = _selectedTabIndex == index;
    final contentColor = isActive
        ? colorScheme.onPrimary
        : colorScheme.onSurface.withValues(alpha: 0.4);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: contentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: contentColor,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(ColorScheme colorScheme) {
    return IndexedStack(
      index: _selectedTabIndex,
      children: [
        _isBluetoothActivated
            ? const BluetoothTab()
            : _buildBluetoothPrompt(colorScheme: colorScheme),
        const Center(
          child: Text(
            "Wi-Fi подключение в разработке",
            style: TextStyle(color: Colors.white54),
          ),
        ),
        const Center(
          child: Text(
            "USB подключение в разработке",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }

  Widget _buildBluetoothPrompt({required ColorScheme colorScheme}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_searching,
            size: 80,
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            "Bluetooth Connection",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Connect your OBD2 adapter to see\nreal-time vehicle data.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: _activateBluetooth,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                "Start Scanning",
                style: TextStyle(
                  color: colorScheme.onPrimary,
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
