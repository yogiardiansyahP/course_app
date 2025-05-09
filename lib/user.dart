import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_akhir_app/checkout.dart';
import 'package:project_akhir_app/profil.dart';
import 'package:project_akhir_app/services/api_service.dart';

class CodeinCourseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codein Course',
      theme: ThemeData(fontFamily: 'Inter'),
      home: CourseHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CourseHomePage extends StatelessWidget {
  final String courseTitle = "Belajar Java Script Dari Nol";
  final int originalPrice = 2500000;
  final int discountedPrice = 250000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Row
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    IconButton(
      icon: Icon(Icons.person_outline),
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
            // Statistics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statCard("Total Kelas", "0"),
                _statCard("Sedang Berjalan", "0"),
                _statCard("Sertifikat", "0"),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Gabung Kelas Unggulan Codein Course",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            // Course Card (dipanggil dengan context)
            _courseCard(context, courseTitle, originalPrice, discountedPrice, token, courseId)
            const SizedBox(height: 12),
            _courseCard(context, courseTitle, originalPrice, discountedPrice, token, courseId)

            const SizedBox(height: 20),
            const Text("Progress Belajar", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Line Chart
            Container(
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
                        spots: [
                          FlSpot(0, 40),
                          FlSpot(1, 60),
                          FlSpot(2, 20),
                          FlSpot(3, 80),
                          FlSpot(4, 70),
                          FlSpot(5, 90),
                          FlSpot(6, 95),
                          FlSpot(7, 85),
                          FlSpot(8, 70),
                          FlSpot(9, 30),
                          FlSpot(10, 100),
                        ],
                        isCurved: true,
                        color: Colors.blue,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  static Widget _statCard(String title, String count) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade200,
          ),
          child: Text(count, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

Widget _courseCard(BuildContext context, String courseTitle, int originalPrice, int discountedPrice, String token, int courseId) {
  return GestureDetector(
    onTap: () async {
      // Fetch checkout data from the API
      ApiService apiService = ApiService();
      try {
        Map<String, dynamic> checkoutData = await apiService.showCheckout(token, courseId);
        // Navigate to the CheckoutPage with the fetched data
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CheckoutPage(token: token, checkoutData: checkoutData)),
        );
      } catch (e) {
        // Handle error (e.g., show a dialog or a snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load checkout data: $e')),
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              "assets/course.jpg",
              fit: BoxFit.cover,
              height: 150,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courseTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  "Rp. ${_formatRupiah(originalPrice)}",
                  style: const TextStyle(
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  "Rp. ${_formatRupiah(discountedPrice)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
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
