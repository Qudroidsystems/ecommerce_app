import 'package:get_storage/get_storage.dart';

class TLocalStorage {
  static final TLocalStorage _instance = TLocalStorage._internal();

  factory TLocalStorage() => _instance;

  TLocalStorage._internal() {
    init('app');
  }

  late GetStorage _storage;

  // Initialize GetStorage with a specific container name
  void init(String container) {
    GetStorage.init(container);
    _storage = GetStorage(container);
  }

  // Write data to storage
  Future<void> writeData<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  // Read data from storage
  T? readData<T>(String key) {
    return _storage.read<T>(key);
  }

  // Remove data from storage
  Future<void> removeData(String key) async {
    await _storage.remove(key);
  }

  // Clear all data in storage
  Future<void> clearAll() async {
    await _storage.erase();
  }
}