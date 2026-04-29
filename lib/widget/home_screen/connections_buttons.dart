import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xFFBDF343);

class ConnectionButtons extends StatelessWidget {
  final VoidCallback onConnect;
  final VoidCallback onViewDemo;
  final bool isConnected;
  final bool isDemoMode;

  const ConnectionButtons({
    super.key,
    required this.onConnect,
    required this.onViewDemo,
    required this.isConnected,
    required this.isDemoMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AnimatedConnectButton(isConnected: isConnected, onPressed: onConnect),
        const SizedBox(height: 12),
        _AnimatedDemoButton(isDemoMode: isDemoMode, onPressed: onViewDemo),
      ],
    );
  }
}

class _AnimatedConnectButton extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onPressed;

  const _AnimatedConnectButton({
    required this.isConnected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: isConnected ? 72.0 : 56.0,
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: isConnected
                ? _buildConnectedState(key: const ValueKey('connected'))
                : _buildDisconnectedState(key: const ValueKey('disconnected')),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedState({required Key key}) {
    return Row(
      key: key,
      children: [
        const SizedBox(width: 16),
        const Icon(Icons.track_changes_rounded, color: Colors.black, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "CONNECTED",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                "Vehicle is connected",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: _primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildDisconnectedState({required Key key}) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.tune_rounded, color: Colors.black, size: 24),
        SizedBox(width: 10),
        Text(
          "CONNECT",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _AnimatedDemoButton extends StatelessWidget {
  final bool isDemoMode;
  final VoidCallback onPressed;

  const _AnimatedDemoButton({
    required this.isDemoMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          side: const BorderSide(color: _primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildStateRow(
            key: ValueKey(isDemoMode),
            icon: isDemoMode ? Icons.stop_rounded : Icons.play_arrow_rounded,
            text: isDemoMode ? "DISCONNECT" : "VIEW DEMO",
          ),
        ),
      ),
    );
  }

  Widget _buildStateRow({
    required Key key,
    required IconData icon,
    required String text,
  }) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: _primaryColor, size: 24),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: _primaryColor,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}
