import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iamport_webview_flutter/iamport_webview_flutter.dart';
import 'package:project_akhir_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_akhir_app/hubungi_kami.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CourseMaterialPage extends StatefulWidget {
  final String courseName;
  final List<Map<String, dynamic>> materials;
  final String currentSlug;
  final String status;
  final bool autoPlayVideoFromDashboard;

  const CourseMaterialPage({
    required this.courseName,
    required this.materials,
    required this.currentSlug,
    required this.status,
    this.autoPlayVideoFromDashboard = false,
    super.key,
  });

  @override
  State<CourseMaterialPage> createState() => _CourseMaterialPageState();
}

class _CourseMaterialPageState extends State<CourseMaterialPage> {
  late int currentIndex;
  late Map<String, dynamic> currentMaterial;
  bool isLoading = true;
  bool hasAccess = false;
  int? userId;
  bool isDone = false;
  bool isCompleting = false;

  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.materials.indexWhere((m) => m['slug'] == widget.currentSlug);
    currentMaterial = widget.materials[currentIndex];
    _initYoutubeControllerIfNeeded();

    ApiService().getUserId().then((id) {
      setState(() {
        userId = id;
      });
      checkTransactionAccess();
    });
  }

  void _initYoutubeControllerIfNeeded() {
    final url = currentMaterial['video_url'] ?? '';
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      final videoId = YoutubePlayer.convertUrlToId(url) ?? '';
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: widget.autoPlayVideoFromDashboard,
        ),
      );
    } else {
      _youtubeController = null;
    }
  }

  @override
  void didUpdateWidget(covariant CourseMaterialPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSlug != widget.currentSlug) {
      currentIndex = widget.materials.indexWhere((m) => m['slug'] == widget.currentSlug);
      currentMaterial = widget.materials[currentIndex];

      _youtubeController?.dispose();
      _initYoutubeControllerIfNeeded();
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    Fluttertoast.showToast(msg: message, gravity: ToastGravity.BOTTOM);
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<List<Map<String, dynamic>>> getUserTransactions(String token) async {
    final baseUrl = 'https://codeinko.com/api';
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

  Future<void> checkTransactionAccess() async {
    try {
      final token = await getToken();
      final transactions = await getUserTransactions(token);
      final matched = transactions.any((t) => t['course_name'] == widget.courseName);

      setState(() {
        hasAccess = matched;
        isLoading = false;
      });
    } catch (e) {
      showMessage("Gagal memeriksa transaksi.");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildVideoPlayer(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      if (_youtubeController == null) {
        return const Center(child: Text("Video tidak ditemukan"));
      }
      return YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
      );
    } else if (url.contains('vimeo.com')) {
      final vimeoId = url.split('/').last;
      final autoplayUrl = widget.autoPlayVideoFromDashboard
          ? 'https://player.vimeo.com/video/$vimeoId?autoplay=1'
          : 'https://player.vimeo.com/video/$vimeoId';

      return SizedBox(
        height: 315,
        child: WebView(
          initialUrl: autoplayUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      );
    } else {
      if (widget.autoPlayVideoFromDashboard) {
        Future.microtask(() async {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          }
        });
        return const Center(child: Text("Memutar video..."));
      }

      return ElevatedButton(
        onPressed: () async {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          }
        },
        child: const Text('Lihat Video'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!hasAccess) {
      return Scaffold(
        appBar: AppBar(title: Text("Materi: ${widget.courseName}")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Kamu belum menyelesaikan pembayaran."),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Kembali ke Daftar Kelas"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Materi: ${widget.courseName}")),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            DrawerHeader(
              child: Text("Materi Kursus", style: Theme.of(context).textTheme.titleLarge),
            ),
            for (var materi in widget.materials)
              ListTile(
                title: Text(materi['nama_materi'] ?? '-'),
                selected: materi['slug'] == widget.currentSlug,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseMaterialPage(
                        courseName: widget.courseName,
                        materials: widget.materials,
                        currentSlug: materi['slug']!,
                        status: widget.status,
                        autoPlayVideoFromDashboard: widget.autoPlayVideoFromDashboard,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userId != null)
              Text(
                "User ID: $userId",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            const SizedBox(height: 8),
            Text(currentMaterial['title'] ?? '-', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildVideoPlayer(currentMaterial['video_url'] ?? ''),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: isDone
                  ? null
                  : () async {
                      final token = await getToken();

                      bool success = await ApiService().saveProgress(currentMaterial['slug'], token);

                      if (success) {
                        setState(() {
                          isDone = true;
                        });
                        showMessage("Materi berhasil ditandai selesai.");
                      } else {
                        showMessage("Gagal menandai materi selesai.");
                      }
                    },
              icon: const Icon(Icons.check),
              label: Text(isDone ? "Sudah Ditandai Selesai" : "Tandai Materi Selesai"),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentIndex > 0
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseMaterialPage(
                                courseName: widget.courseName,
                                materials: widget.materials,
                                currentSlug: widget.materials[currentIndex - 1]['slug']!,
                                status: widget.status,
                                autoPlayVideoFromDashboard: widget.autoPlayVideoFromDashboard,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text("← Kembali"),
                ),
                currentIndex < widget.materials.length - 1
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseMaterialPage(
                                courseName: widget.courseName,
                                materials: widget.materials,
                                currentSlug: widget.materials[currentIndex + 1]['slug']!,
                                status: widget.status,
                                autoPlayVideoFromDashboard: widget.autoPlayVideoFromDashboard,
                              ),
                            ),
                          );
                        },
                        child: const Text("Selanjutnya →"),
                      )
                    : ElevatedButton(
                        onPressed: isCompleting
                            ? null
                            : () async {
                                final token = await getToken();
                                final courseId = await ApiService().getCourseIdByMaterialSlug(currentMaterial['slug'], token);

                                if (courseId == null) {
                                  showMessage("ID kursus tidak ditemukan dari materi.");
                                  return;
                                }

                                setState(() => isCompleting = true);
                                final success = await ApiService().completeCourseCertificate(courseId);
                                setState(() => isCompleting = false);

                                if (success) {
                                  showMessage("Kursus selesai! Sertifikat berhasil dibuat.");
                                } else {
                                  showMessage("Gagal memproses sertifikat.");
                                }
                              },
                        child: isCompleting
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Selesai & Dapatkan Sertifikat"),
                      ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HubungiKamiPage()),
    );
  },
  child: const Text("Ada issue dengan konten ini? Laporkan!"),
),

          ],
        ),
      ),
    );
  }
}
