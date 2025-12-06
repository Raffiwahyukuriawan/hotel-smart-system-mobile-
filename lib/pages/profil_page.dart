import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/edit_profil_page.dart';
import 'package:flutter_application_2/pages/home_page.dart';
import 'package:flutter_application_2/pages/login_page.dart';
import 'package:flutter_application_2/pages/custom_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final List<Color> menuGradient2 = [
  Colors.black,
  Color.fromARGB(255, 245, 180, 15),
];

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? username;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username');
    setState(() {
      username = storedUsername ?? '-';
    });
  }

  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 1;

    try {
      final response = await http.get(
        Uri.parse('http://10.61.138.179:8000/api/profil/$userId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Gagal ambil profil: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error ambil profil: $e");
      setState(() => isLoading = false);
    }
  }

  /// 🔐 Fungsi logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // hapus semua data yang tersimpan

    // Arahkan ke halaman login dan hapus semua halaman sebelumnya
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color gold = const Color.fromARGB(255, 245, 180, 15);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: menuGradient2,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text("Data profil tidak ditemukan"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Foto profil
                      Center(
                        child: Card(
                          color: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundColor: gold.withOpacity(0.8),
                                  child: Text(
                                    userData!['nama_tamu'][0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  userData!['nama_tamu'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Info akun
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              buildInfoRow(
                                Icons.person,
                                "Username",
                                username ?? '-',
                                gold,
                              ),
                              const Divider(color: Color(0xFFDCDCDC)),
                              buildInfoRow(
                                Icons.phone,
                                "No. Telepon",
                                userData!['no_telp'] ?? '-',
                                gold,
                              ),
                              const Divider(color: Color(0xFFDCDCDC)),
                              buildInfoRow(
                                Icons.people,
                                "Jumlah Tamu",
                                "${userData!['jumlah_tamu']} Orang",
                                gold,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tombol Edit dan Logout
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfilPage(userData: userData!),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text(
                                "Edit Profil",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gold,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: logout, // 🔥 panggil fungsi logout
                              icon: const Icon(Icons.logout, color: Colors.white),
                              label: const Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget buildInfoRow(IconData icon, String title, String value, Color gold) {
    return Row(
      children: [
        Icon(icon, color: gold),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        Text(value, style: const TextStyle(color: Colors.black)),
      ],
    );
  }
}
