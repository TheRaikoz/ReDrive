class ObdDevice {
  final String name; // Имя, например "OBDII" или "Vgate"
  final String address; // MAC-адрес (00:11:22:33:44:55)
  final bool isBle; // Флаг: это новый BLE или старый Classic?

  const ObdDevice({
    required this.name,
    required this.address,
    this.isBle = false, // По умолчанию считаем, что это старый ELM327
  });

  @override
  String toString() {
    return 'ObdDevice(name: $name, address: $address, isBle: $isBle)';
  }
}
