import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_akhir_app/services/api_service.dart';
import 'package:project_akhir_app/profil.dart';
import 'package:project_akhir_app/checkout.dart';

class CodeinCourseApp extends StatelessWidget {
  final String token;

  const CodeinCourseApp({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codein Course',
      theme: ThemeData(fontFamily: 'Inter'),
      home: CourseHomePage(token: token),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CourseHomePage extends StatefulWidget {
  final String token;

  const CourseHomePage({super.key, required this.token});

  @override
  _CourseHomePageState createState() => _CourseHomePageState();
}

class _CourseHomePageState extends State<CourseHomePage> {
  late Future<List<double>> _progressData;
  late Future<List<dynamic>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    print("Token: ${widget.token}");
    _progressData = _fetchProgressData();
    _coursesFuture = _fetchCourses();
  }

  Future<List<double>> _fetchProgressData() async {
    try {
      ApiService apiService = ApiService();
      final progressData = await apiService.getChartProgress(widget.token);
      return progressData;
    } catch (e) {
      throw Exception('Failed to load progress data: $e');
    }
  }

  Future<List<dynamic>> _fetchCourses() async {
    try {
      ApiService apiService = ApiService();
      final courses = await apiService.getCoursesFromApi(widget.token);
      return courses;
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Gabung Kelas Unggulan Codein Course", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            FutureBuilder<List<dynamic>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("Tidak ada course tersedia");
                } else {
                  final courses = snapshot.data!;
                  return Column(
                    children: courses.map<Widget>((course) {
                      final String courseTitle = course['name'] ?? 'Course Tanpa Nama';
                      final int originalPrice = course['price'] ?? 0;
                      final int discountedPrice = (originalPrice - 30000).clamp(0, originalPrice);
                      final String thumbnail = course['thumbnail'] ?? '';
                      final String mentor = course['mentor'] ?? 'Mentor Tidak Diketahui';

                      return _courseCard(
                        context,
                        courseTitle,
                        originalPrice,
                        discountedPrice,
                        thumbnail,
                        mentor,
                        widget.token,
                      );
                    }).toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            const Text("Progress Belajar", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FutureBuilder<List<double>>(
              future: _progressData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  List<double> progressData = snapshot.data!;
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, _) {
                                  const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                                  return Text(months[value.toInt() % months.length]);
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(progressData.length, (index) {
                                return FlSpot(index.toDouble(), progressData[index]);
                              }),
                              isCurved: true,
                              color: Colors.blue,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: Text('No progress data available'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

Widget _courseCard(
  BuildContext context,
  String courseTitle,
  int originalPrice,
  int discountedPrice,
  String thumbnail,
  String mentor,
  String token,
) {
  final Map<String, dynamic> checkoutData = {
    'course_name': courseTitle,
    'hargaAwal': originalPrice,
    'hargaDiskon': discountedPrice,
    'voucher': 'CODEINCOURSEIDNBGR',
    'mentor': mentor,
  };

  final String imageUrl = 'http://127.0.0.1:8000/storage/$thumbnail';
  print('🖼️ Attempting to load image from: $imageUrl');

  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            token: token,
            checkoutData: checkoutData,
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: thumbnail.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        print("✅ Image loaded successfully: $imageUrl");
                        return child;
                      } else {
                        print("🔄 Loading image... ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}");
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print("❌ Failed to load image: $imageUrl");
                      print("Error: $error");
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courseTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  mentor,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "Rp. ${_formatRupiah(originalPrice)}",
                      style: const TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Rp. ${_formatRupiah(discountedPrice)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  static String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}