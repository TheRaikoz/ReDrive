enum ConnectionType { classic, ble }

class ObdDevice {
  final String name;
  final String address;
  final ConnectionType connectionType;

  const ObdDevice({
    required this.name,
    required this.address,
    this.connectionType = ConnectionType.classic,
  });

  bool get isBle => connectionType == ConnectionType.ble;

  @override
  String toString() {
    return 'ObdDevice(name: $name, address: $address, connectionType: $connectionType)';
  }
}
