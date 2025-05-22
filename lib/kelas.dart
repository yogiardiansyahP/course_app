import 'package:flutter/material.dart';
import 'package:project_akhir_app/services/api_service.dart';
import 'package:project_akhir_app/checkout.dart';

class KelasPage extends StatefulWidget {
  final String token;

  const KelasPage({super.key, required this.token});

  @override
  State<KelasPage> createState() => _KelasPageState();
}

class _KelasPageState extends State<KelasPage> {
  late Future<List<dynamic>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchCourses();
  }

  Future<List<dynamic>> _fetchCourses() async {
    try {
      ApiService apiService = ApiService();
      return await apiService.getCoursesFromApi(widget.token);
    } catch (e) {
      throw Exception('Gagal memuat course: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kembali', style: TextStyle(color: Colors.black)),
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Kelas yang tersedia',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Jelajahi berbagai pilihan kelas dan tingkatkan keterampilan anda.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final String courseTitle = course['name'] ?? 'Tanpa Judul';
                      final dynamic priceData = course['price'];
                      final int originalPrice = priceData is int
                          ? priceData
                          : int.tryParse(priceData.toString()) ?? 0;
                      final int discountedPrice = (originalPrice - 30000).clamp(0, originalPrice);
                      final String thumbnail = course['thumbnail'] ?? '';
                      final String mentor = course['mentor'] ?? 'Mentor Tidak Diketahui';
                      final String imageUrl = 'https://codeinko.com/storage/$thumbnail';

                      return _buildCourseItem(
                        context,
                        imageUrl,
                        courseTitle,
                        originalPrice,
                        discountedPrice,
                        mentor,
                        widget.token,
                        key: ValueKey('$courseTitle-$index'),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseItem(
    BuildContext context,
    String imageUrl,
    String title,
    int originalPrice,
    int discountedPrice,
    String mentor,
    String token, {
    Key? key, // Tambahkan key sebagai parameter opsional
  }) {
    final Map<String, dynamic> checkoutData = {
      'course_name': title,
      'hargaAwal': originalPrice,
      'hargaDiskon': discountedPrice,
      'voucher': 'CODEINCOURSEIDNBGR',
      'mentor': mentor,
    };

    return Container(
      key: key, // Gunakan key di sini
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp. ${originalPrice.toString()}',
                  style: const TextStyle(
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Rp. $discountedPrice',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Beli',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
