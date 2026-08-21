class ApiConfig {
  ApiConfig._();

  static const String _productionUrl =
      'https://wastraquest-production.up.railway.app';
  static const String _localUrl = 'http://10.188.54.148:8000';
  static const bool useLocal = false;
  static String get baseUrl => useLocal ? _localUrl : _productionUrl;
}