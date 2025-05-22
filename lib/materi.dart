import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:project_akhir_app/hubungi_kami.dart';

class VideoLessonPage extends StatefulWidget {
  final String courseName;
  final String title;
  final String description;
  final String videoUrl;
  final bool hasAccess;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final bool hasPrev;
  final bool hasNext;

  const VideoLessonPage({
    super.key,
    required this.courseName,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.hasAccess,
    this.onPrev,
    this.onNext,
    this.hasPrev = false,
    this.hasNext = false,
  });

  @override
  State<VideoLessonPage> createState() => _VideoLessonPageState();
}

class _VideoLessonPageState extends State<VideoLessonPage> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();

    if (_isYoutubeUrl(widget.videoUrl)) {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: false),
        );
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  bool _isYoutubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: Colors.black),
  onPressed: () {
    Navigator.pop(context); // Kembali ke halaman sebelumnya
  },
),
        title: Text(
          'Materi Kursus - ${widget.courseName}',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: widget.hasAccess
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Color(0xFF3366FF),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    if (_youtubeController != null)
                      YoutubePlayer(
                        controller: _youtubeController!,
                        showVideoProgressIndicator: true,
                      )
                    else
                      TextButton(
                        onPressed: () {
                          // Bisa pakai url_launcher jika mau buka videoUrl
                        },
                        child: const Text("Lihat Video"),
                      ),
                    const SizedBox(height: 16),
                    Row(
  children: [
    const Text("Ada masalah dengan konten ini? "),
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HubungiKamiPage(), // Ganti dengan nama kelas halaman kontak kamu
          ),
        );
      },
      child: const Text(
        "Laporkan",
        style: TextStyle(
          color: Colors.red,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
  ],
),

                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: widget.hasPrev ? widget.onPrev : null,
                          child: const Text("Kembali"),
                        ),
                        widget.hasNext
                            ? ElevatedButton.icon(
                                onPressed: widget.onNext,
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text("Selanjutnya"),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Selesaikan Kursus"),
                                      content: const Text("Kamu yakin ingin menyelesaikan kursus dan membuat sertifikat?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Batal"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            // Logika submit dan redirect ke halaman sertifikat
                                          },
                                          child: const Text("Ya"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text("Selesai"),
                              ),
                      ],
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Kamu belum menyelesaikan pembayaran atau belum mendaftar pada kursus ini.",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/list-kelas');
                        },
                        child: const Text("Kembali ke Daftar Kelas"),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
