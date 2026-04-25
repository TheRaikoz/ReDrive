import 'package:flutter/material.dart';
import '../widget/connection/bluetooth_panel.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 3, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    textScaler: TextScaler.noScaling,
                    "Подключение",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                ),

                const SizedBox(height: 10),

                const BluetoothPanel(),

                const SizedBox(height: 20),

                // const WifiPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
