import 'package:flutter/material.dart';

class BluetoothWaitingWidget extends StatelessWidget {
  final VoidCallback onActivate;

  const BluetoothWaitingWidget({super.key, required this.onActivate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              onPressed: onActivate,
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
