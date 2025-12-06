import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/home_page.dart';
import '../pages/sign_up_page.dart';

// 🔹 Dialog Notifikasi (biar sama dengan SignUp)
void showResultDialog(
  BuildContext context, {
  required bool success,
  required String message,
  VoidCallback? onOk,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: success ? Colors.green : Colors.red,
              child: Icon(
                success ? Icons.check : Icons.close,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              success ? "All done!" : "Oops!",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: success ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                if (onOk != null) onOk();
              },
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    },
  );
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passController = TextEditingController();
  bool _loading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    usernameController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://192.168.1.2:8000/api/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      }
    }
  }

  Future<void> loginUser() async {
    setState(() => _loading = true);
    try {
      final url = Uri.parse('http://192.168.1.2:8000/api/login');
      final response = await http.post(
        url,
        body: {
          'username': usernameController.text,
          'password': passController.text,
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // 🔍 Cetak seluruh respons ke console
        print('=== LOGIN RESPONSE BODY ===');
        print(response.body);

        if (responseData['success'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          final user = responseData['user'];
          final tamu = user['tamu'];

          // 🔹 Cetak isi user dan tamu untuk debug
          print('=== USER DATA ===');
          print(user);
          print('=== TAMU DATA ===');
          print(tamu);

          // 🔹 Simpan data user utama
          await prefs.setString('token', responseData['token'] ?? '');
          await prefs.setInt('user_id', user['id'] ?? 0);
          await prefs.setString('username', user['username'] ?? '');
          await prefs.setString('email', user['email'] ?? '');

          // 🔹 Simpan data tamu (kalau ada)
          if (tamu != null) {
            await prefs.setInt('tamu_id', tamu['id'] ?? 0);
            await prefs.setString('nama_tamu', tamu['nama_tamu'] ?? '');
            await prefs.setString('no_telp', tamu['no_telp'] ?? '');
            await prefs.setInt('jumlah_tamu', tamu['jumlah_tamu'] ?? 0);
          }

          // 🔹 Tampilkan dialog sukses dan arahkan ke HomePage
          showResultDialog(
            context,
            success: true,
            message: "Login berhasil! Selamat datang ${user['username']}.",
            onOk: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          );
        } else {
          print('=== LOGIN FAILED ===');
          print(response.body);

          showResultDialog(
            context,
            success: false,
            message: responseData['message'] ?? "Login gagal. Coba lagi.",
          );
        }
      } else {
        print('=== LOGIN ERROR (${response.statusCode}) ===');
        print(response.body);

        showResultDialog(
          context,
          success: false,
          message: "Terjadi kesalahan server (${response.statusCode})",
        );
      }
    } catch (e) {
      showResultDialog(
        context,
        success: false,
        message: "Gagal terhubung ke server: $e",
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    Color gold = Colors.black;
    Color black = Colors.black;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Color.fromARGB(255, 245, 180, 15)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 12,
                  shadowColor: gold.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: gold,
                          size: 60,
                        ), // header icon
                        const SizedBox(height: 12),
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: usernameController,
                          icon: Icons.person,
                          label: 'Username',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: passController,
                          icon: Icons.lock,
                          label: 'Password',
                          isPassword: true,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loading ? null : loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 245, 180, 15),
                            foregroundColor: black,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                          ),
                          child:
                              _loading
                                  ? const CircularProgressIndicator(
                                    color: Colors.black,
                                  )
                                  : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Don't have an account? Sign up",
                              style: TextStyle(
                                color: Color.fromARGB(255, 245, 180, 15),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool isPassword = false,
  }) {
    Color gold = Colors.black;

    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: gold),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold, width: 2),
        ),
      ),
      textInputAction: TextInputAction.next,
    );
  }
}
