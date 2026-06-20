import 'package:dartvex/dartvex.dart' as dartvex;

class ConvexClient {
  static const String _deploymentUrl = String.fromEnvironment(
    'CONVEX_URL',
    defaultValue: 'http://10.0.2.2:3210',
  );
  static late final dartvex.ConvexClient _instance;

  static dartvex.ConvexClient get instance => _instance;

  static Future<void> init() async {
    _instance = dartvex.ConvexClient(_deploymentUrl);
  }

  Future<void> setAuth({required String? token}) async {
    await _instance.setAuth(token);
  }

  static const String httpUrl = _deploymentUrl;
}
