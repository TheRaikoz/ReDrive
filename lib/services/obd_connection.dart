abstract class ObdConnection {
  // Метод подключения. Возвращает true, если успешно
  Future<bool> connect(String address);

  // Метод отключения
  Future<void> disconnect();

  // Метод отправки команды (например, "010C") и получения ответа от ELM327
  Future<String> sendCommand(String command);
}
