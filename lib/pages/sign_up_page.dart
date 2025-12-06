import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool _loading = false;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
  final nama_user = nameController.text.trim();
  final username = emailController.text.trim();
  final password = passController.text;
  final confirmPassword = confirmPassController.text;

  if (nama_user.isEmpty ||
      username.isEmpty ||
      password.isEmpty ||
      confirmPassword.isEmpty) {
    showResultDialog(
      context,
      success: false,
      message: "Semua field wajib diisi!",
    );
    return;
  }

  setState(() => _loading = true);

  final url = Uri.parse('http://10.61.138.179:8000/api/register');
  try {
    final response = await http.post(
      url,
      body: {
        'nama_tamu': nama_user,
        'username': username,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );

    if (response.statusCode == 201) {
      showResultDialog(
        context,
        success: true,
        message: "Registrasi berhasil! Silakan login.",
      );

      // setelah klik OK pindah ke login
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SignInScreen()),
        );
      });
    } else {
      final data = json.decode(response.body);
      String msg = data['message']?.toString() ?? 'Registrasi gagal';
      if (data['errors'] is Map) {
        msg = (data['errors'] as Map).values
            .expand((e) => (e as List).map((x) => x.toString()))
            .join('\n');
      }

      showResultDialog(context, success: false, message: msg);
    }
  } catch (_) {
    showResultDialog(
      context,
      success: false,
      message: "Tidak bisa terhubung ke server",
    );
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Color.fromARGB(255, 245, 180, 15)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
                  shadowColor: Colors.amberAccent.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        const Text(
                          'Create Your Account',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: nameController,
                          icon: Icons.person,
                          label: 'Your Name',
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: emailController,
                          icon: Icons.email_outlined,
                          label: 'Username',
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: passController,
                          icon: Icons.lock,
                          label: 'Password',
                          isPassword: true,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: confirmPassController,
                          icon: Icons.lock_outline,
                          label: 'Confirm Password',
                          isPassword: true,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 245, 180, 15),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: Color.fromARGB(255, 245, 180, 15),
                          ),
                          child:
                              _loading
                                  ? const CircularProgressIndicator(
                                    color: Colors.black,
                                  )
                                  : const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed:
                                _loading
                                    ? null
                                    : () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SignInScreen(),
                                      ),
                                    ),
                            child: const Text(
                              "Already have an account? Sign in.",
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
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      textInputAction: TextInputAction.next,
    );
  }
}


void showResultDialog(
  BuildContext context, {
  required bool success,
  required String message,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // biar gak bisa tutup klik luar
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
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    },
  );
}
