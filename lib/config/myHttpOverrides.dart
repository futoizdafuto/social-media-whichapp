import 'dart:io';
import 'package:http/http.dart' as http;

void allowSelfSignedCertificate() {
  HttpOverrides.global = new MyHttpOverrides();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true; // Bỏ qua chứng chỉ không hợp lệ
    return client;
  }
}


