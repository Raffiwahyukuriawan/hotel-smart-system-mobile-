import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

final List<Color> menuGradient = [
  Colors.black,
  Color.fromARGB(255, 245, 180, 15),
];

class _EditProfilPageState extends State<EditProfilPage> {
  late TextEditingController _namaController;
  late TextEditingController _usernameController;
  late TextEditingController _teleponController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.userData['nama_tamu']);
    _usernameController = TextEditingController(
      text: widget.userData['username'],
    );
    _teleponController = TextEditingController(
      text: widget.userData['no_telp'],
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  Future<void> _simpanPerubahan() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id'); // pastikan disimpan waktu login

    if (userId == null) {
      showResultDialog(
        context,
        success: false,
        message: "User ID tidak ditemukan di SharedPreferences",
      );
      setState(() => isLoading = false);
      return;
    }

    // URL API Laravel
    final url = Uri.parse('http://10.61.138.179:8000/api/tamu/update/$userId');

    final body = {
      'nama_tamu': _namaController.text,
      'username': _usernameController.text,
      'no_telp': _teleponController.text,
    };

    try {
      final res = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Status Code: ${res.statusCode}');
      print('Response Body: ${res.body}');

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        // simpan perubahan ke SharedPreferences
        await prefs.setString('username', _usernameController.text);
        await prefs.setString('nama_tamu', _namaController.text);
        await prefs.setString('no_telp', _teleponController.text);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "All done!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['message'] ?? "Profil berhasil diperbarui!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // tutup dialog
                      Navigator.pop(
                        context,
                        body,
                      ); // kembali ke profil sambil bawa data baru
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        showResultDialog(
          context,
          success: false,
          message: data['message'] ?? "Gagal memperbarui profil.",
        );
      }
    } catch (e) {
      print('Error saat update profil: $e');
      showResultDialog(context, success: false, message: "Terjadi error: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    Color gold = const Color.fromARGB(255, 245, 180, 15);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: menuGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildInputCard(
                      controller: _namaController,
                      label: 'Nama Tamu',
                      icon: MdiIcons.account,
                      themeColor: gold,
                    ),
                    const SizedBox(height: 16),
                    _buildInputCard(
                      controller: _usernameController,
                      label: 'Username',
                      icon: MdiIcons.account,
                      themeColor: gold,
                    ),
                    const SizedBox(height: 16),
                    _buildInputCard(
                      controller: _teleponController,
                      label: 'Nomor Telepon',
                      icon: MdiIcons.phone,
                      themeColor: gold,
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isLoading ? null : _simpanPerubahan,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.black, Color.fromARGB(255, 245, 180, 15)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "Simpan",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color themeColor,
  }) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey.shade800),
            prefixIcon: Icon(icon, color: themeColor),
            border: InputBorder.none,
          ),
          validator:
              (value) => value!.isEmpty ? '$label tidak boleh kosong' : null,
        ),
      ),
    );
  }
}

/// 🔹 Fungsi dialog sama persis seperti di halaman pesan kamar
void showResultDialog(
  BuildContext context, {
  required bool success,
  required String message,
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
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    },
  );
}
