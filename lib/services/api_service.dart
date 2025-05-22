import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://codeinko.com/api';
   final String snapTokenBaseUrl = 'https://codeinko.com/';

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

Future<List<double>> getChartProgress(String token) async {
  final response = await http.post(
    Uri.parse('$baseUrl/progress-chart'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  
  if (response.statusCode == 200) {
    try {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
    } catch (e) {
      throw Exception('Failed to decode progress data: $e');
    }
  } else {
    throw Exception('Failed to load progress chart. Status: ${response.statusCode}');
  }
}

  Future<List<dynamic>> getCoursesFromApi(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api-datacourse'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> courses = responseData['data'];
          return courses.map((course) {
            return {
              'id': course['id'],
              'name': course['name'],
              'thumbnail': course['thumbnail'],
              'mentor': course['mentor'],
              'price': course['price'],
              'materials': course['materials'] ?? [],
            };
          }).toList();
        } else {
          throw Exception('Failed to load courses');
        }
      } catch (e) {
        throw Exception('Failed to decode courses data: $e');
      }
    } else {
      throw Exception('Failed to load courses. Status: ${response.statusCode}');
    }
  }

    Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await postData('/login', {'email': email, 'password': password});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', data['token']);
      if (data['user'] != null && data['user']['id'] != null) {
        prefs.setInt('user_id', data['user']['id']);
      }

      return data;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    if (id == null || id == 0) {
      throw Exception('user_id tidak ditemukan atau 0');
    }
    return id;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String passwordConfirmation) async {
    if (password != passwordConfirmation) {
      throw Exception('Passwords do not match');
    }

    final response = await postData('/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 422) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<bool> logout(String token) async {
    final url = Uri.parse('https://codeinko.com/api/logout');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Logout failed with status: ${response.statusCode}');
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
    required int hargaAwal,
    required String courseName,
    required String voucher,
    required int courseId,
  }) async {
    final url = Uri.parse('$baseUrl/checkout/token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'hargaAwal': hargaAwal,
          'course_name': courseName,
          'voucher': voucher,
          'course_id': courseId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('token') && data.containsKey('order_id')) {
          return {
            'token': data['token'],
            'order_id': data['order_id'],
          };
        } else {
          throw Exception('Response tidak mengandung token atau order_id');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Gagal mengambil Snap Token: ${error['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil Snap Token: $e');
    }
  }


  Future<Map<String, dynamic>> saveTransaction(String token, Map<String, dynamic> transactionData) async {
    try {
      if (!transactionData.containsKey('user_id')) {
        transactionData['user_id'] = await getUserId();
      }

      final response = await postData('/checkout/save', transactionData, token: token);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Response error: ${response.body}');
        throw Exception('Failed to save transaction');
      }
    } catch (e) {
      throw Exception('Error occurred while saving transaction: $e');
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
