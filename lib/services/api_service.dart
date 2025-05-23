import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://codeinko.com/api';
   final String snapTokenBaseUrl = 'https://codeinko.com/';
   final storage = FlutterSecureStorage();

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


  Future<Map<String, double>> getChartProgress(String token, List<dynamic> courses) async {
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

      Map<String, double> progressMapLocal = {};
      for (int i = 0; i < courses.length; i++) {
        String courseName = courses[i]['name'] ?? 'Unknown Course';
        double progress = 0.0;

        if (i < data.length) {
          final value = data[i];
          if (value is String) {
            progress = double.tryParse(value) ?? 0.0;
          } else if (value is num) {
            progress = value.toDouble();
          }
        }

        progressMapLocal[courseName] = progress;
      }

      return progressMapLocal;
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

  Future<int?> getCourseIdByMaterialSlug(String slug, String token) async {
  try {
    List<dynamic> courses = await getCoursesFromApi(token);
    for (var course in courses) {
      List<dynamic> materials = course['materials'] ?? [];
      if (materials.any((m) => m['slug'] == slug)) {
        return course['id'];
      }
    }
    return null;
  } catch (e) {
    throw Exception("Gagal mendapatkan course_id: $e");
  }
}

Future<List<dynamic>> fetchCertificates(String token) async {
  final url = Uri.parse('$baseUrl/certificates');
  final response = await http.get(
    url,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data is Map && data['certificates'] != null) {
      return data['certificates'];
    }
    return [];
  } else {
    throw Exception('Failed to load certificates, status code: ${response.statusCode}');
  }
}

 Future<Map<String, dynamic>> fetchCertificateById(String token, int id) async {
  final url = Uri.parse('$baseUrl/certificates/$id');
  final response = await http.get(
    url,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data is Map && data['certificate'] != null) {
      return data['certificate'];
    }
    throw Exception('Key "certificate" tidak ditemukan di response');
  } else {
    throw Exception('Failed to load certificate, status code: ${response.statusCode}');
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

Future<int> getUserId({bool fromUserIdKey = true}) async {
  final prefs = await SharedPreferences.getInstance();

  // Pilih key sesuai mode
  final key = fromUserIdKey ? 'user_id' : 'id';
  final id = prefs.getInt(key);

  if (id == null || id == 0) {
    throw Exception('$key tidak ditemukan atau 0');
  }
  return id;
}


    Future<bool> saveProgress(String slug, String token) async {
    final url = Uri.parse('$baseUrl/materi/save/$slug');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Progress saved: ${data['message']}');
        return true;
      } else {
        print('Failed to save progress: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error saving progress: $e');
      return false;
    }
  }

    Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<bool> completeCourseCertificate(int courseId) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/certificates/complete/$courseId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data['message']);
      return true;
    } else {
      final data = json.decode(response.body);
      print(data['message']);
      return false;
    }
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

    // Pastikan key-nya sesuai dengan yang Laravel butuhkan:
    final body = {
      'order_id': transactionData['order_id'],
      'user_id': transactionData['user_id'],
      'hargaAwal': transactionData['harga_awal'] ?? transactionData['hargaAwal'] ?? 0,
      'hargaDiskon': transactionData['harga_diskon'] ?? transactionData['hargaDiskon'] ?? 0,
      'voucher': transactionData['voucher'] ?? '',
      'course_name': transactionData['course_name'] ?? '',
      'status': transactionData['status'] ?? '',
    };

    final response = await postData('/checkout/save', body, token: token);

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

    Future<List<Map<String, dynamic>>> getUserTransactions(String token) async {
    final url = Uri.parse('$baseUrl/transactions');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> transactions = jsonResponse['transactions'];

      return transactions
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();
    } else {
      throw Exception('Failed to load transactions. Status: ${response.statusCode}');
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
