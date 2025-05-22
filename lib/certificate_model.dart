class Certificate {
  final int id;
  final String title;
  final String courseName;
  final String issuedAt;
  final String certificatePath;

  Certificate({
    required this.id,
    required this.title,
    required this.courseName,
    required this.issuedAt,
    required this.certificatePath,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      title: json['title'],
      courseName: json['course']['name'],
      issuedAt: json['issued_at'],
      certificatePath: json['certificate_path'],
    );
  }
}
