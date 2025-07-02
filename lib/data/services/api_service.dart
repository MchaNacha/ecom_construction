import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './auth_service.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  //static const String baseUrl = 'http://127.0.0.1:8000/api'; // not suitable for android emulator
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<http.Response> delete(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return response;
  }



  static Future<http.StreamedResponse> multipartRequest(
      String endpoint, {
        required String? token,
        required Map<String, String> fields,
        Map<String, File>? fileField,
        String method = 'POST',
      }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final request = http.MultipartRequest(method, uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    if (fileField != null) {
      for (final entry in fileField.entries) {
        final file = await http.MultipartFile.fromPath(entry.key, entry.value.path);
        request.files.add(file);
      }
    }

    return await request.send();
  }


  static Future<dynamic> putMultipart({
    required String endpoint,
    required Map<String, String> fields,
    required String fileField,
    File? file,
  }) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/$endpoint');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json'
      ..fields.addAll(fields)
      ..fields['_method'] = 'PUT';

    if (file != null) {
      final mimeType = lookupMimeType(file.path)?.split('/');
      if (mimeType != null && mimeType.length == 2) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fileField,
            file.path,
            contentType: MediaType(mimeType[0], mimeType[1]),
          ),
        );
      }
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(responseBody);
    } else {
      throw Exception(
          'PUT multipart request failed with status: ${response.statusCode}, body: $responseBody');
    }
  }

  static Future<Map<String, dynamic>> getUri(Uri uri) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('GET failed with status ${response.statusCode}');
    }
  }


  static Future<List<dynamic>> getWishlist() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/wishlist'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['wishlist'] ?? []; // adjust key if needed
    } else {
      throw Exception('Failed to load wishlist');
    }
  }

  static Future<void> addToWishlist(int productId) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/wishlist'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'product_id': productId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add to wishlist');
    }
  }

  static Future<void> removeFromWishlist(int productId) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/wishlist/$productId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove from wishlist');
    }
  }

  static Future<List<dynamic>> fetchBuyerOrders() async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$baseUrl/orders');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['orders']; // assuming backend returns orders inside a key
    } else {
      throw Exception('Failed to fetch orders. Status: ${response.statusCode}');
    }
  }

  static Future<dynamic> placeOrder(List<Map<String, dynamic>> products) async {
    final token = await AuthService.getToken(); // get token from shared prefs
    final url = Uri.parse('$baseUrl/orders');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'products': products}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('POST orders failed with status: ${response.statusCode}');
    }
  }


  static Future<dynamic> get(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('GET $endpoint failed with status: ${response.statusCode}');
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('POST $endpoint failed with status: ${response.statusCode}');
    }
  }
}
