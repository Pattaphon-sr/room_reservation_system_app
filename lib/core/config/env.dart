class Env {
  // base URL ของ backend ex. http://10.0.2.2:3000 for Android emulator
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://172.25.15.84:3000',
  );
}
