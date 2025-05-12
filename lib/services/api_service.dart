import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';
   final String snapTokenBaseUrl = 'http://localhost:26561/';

  Future<http.Response> postData(String endpoint, Map<String, dynamic> body, {String? token, bool useSnapTokenBaseUrl = false}) {
    final String fullUrl = useSnapTokenBaseUrl 
        ? '$snapTokenBaseUrl$endpoint' 
        : (endpoint.startsWith('/') ? '$baseUrl$endpoint' : '$baseUrl/$endpoint');

    return http.post(
      Uri.parse(fullUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await postData('/login', {'email': email, 'password': password});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await postData('/register', {'email': email, 'password': password});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<Map<String, dynamic>> logout(String token) async {
    final response = await postData('/logout', {}, token: token);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to logout');
    }
  }

  Future<List<dynamic>> getCourses(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<Map<String, dynamic>> getCourseDetails(String token, int courseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses/$courseId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load course details');
    }
  }

  Future<Map<String, dynamic>> showCheckout(String token, int courseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/checkout/$courseId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load checkout data');
    }
  }

    Future<Map<String, dynamic>> getSnapToken({
    required String token,
    required int courseId,
    required int hargaAwal,
    String? voucher,
    required String courseName,
  }) async {
    try {
      final response = await postData(
        '/get-snap-token', 
        {
          'course_id': courseId,
          'hargaAwal': hargaAwal,
          'voucher': voucher ?? '',
          'course_name': courseName,
        },
        token: token,
        useSnapTokenBaseUrl: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get snap token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching snap token: $e');
    }
  }

  Future<Map<String, dynamic>> saveTransaction(String token, Map<String, dynamic> transactionData) async {
    final response = await postData('/checkout/save', transactionData, token: token);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to save transaction');
    }
  }

  Future<Map<String, dynamic>> updateProfile(String token, Map<String, dynamic> profileData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/settings/profile'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(profileData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<Map<String, dynamic>> updatePassword(String token, Map<String, dynamic> passwordData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/settings/password'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(passwordData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update password');
    }
  }

  Future<List<dynamic>> getTransactions(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<Map<String, dynamic>> getTransaction(String token, int transactionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/$transactionId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load transaction');
    }
  }

  Future<Map<String, dynamic>> createTransaction(String token, Map<String, dynamic> transactionData) async {
    final response = await postData('/transactions', transactionData, token: token);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create transaction');
    }
  }

  Future<Map<String, dynamic>> updateTransaction(String token, int transactionId, Map<String, dynamic> transactionData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/$transactionId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(transactionData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update transaction');
    }
  }

  Future<Map<String, dynamic>> deleteTransaction(String token, int transactionId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/$transactionId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete transaction');
    }
  }
}
