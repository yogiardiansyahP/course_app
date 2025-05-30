import 'package:flutter/material.dart';
import 'package:project_akhir_app/services/api_service.dart';
import 'package:project_akhir_app/user.dart';
import 'package:project_akhir_app/register.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Center(
              child: Text(
                'CodeIn Course\nIlmu Itu Seru, Yuk Mulai!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              margin: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Masukkan Password',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Kamu belum memiliki akun?'),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        child: const Text(
                          'Registrasi',
                          style: TextStyle(color: Color(0xFF2563EB)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final auth = ApiService();
                        final result = await auth.login(emailController.text, passwordController.text);

                        if (result['token'] != null) {
                          final token = result['token'];

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => CodeinCourseApp(token: token)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Login gagal')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
