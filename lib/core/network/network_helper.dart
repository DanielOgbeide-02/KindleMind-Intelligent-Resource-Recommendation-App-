import 'dart:convert';
import 'package:http/http.dart';

class NetworkHelper {
  final String url;
  final Map<String, String>? headers;

  NetworkHelper(this.url, {this.headers});

  Future<dynamic> getData() async {
    final uri = Uri.parse(url);
    final response = await get(uri, headers: headers);
    if (response.statusCode == 200) {
      print('body returned successfully');
      return jsonDecode(response.body);
    } else {
      print('couldn’t fetch data: ${response.statusCode}');
      return null;
    }
  }
}
