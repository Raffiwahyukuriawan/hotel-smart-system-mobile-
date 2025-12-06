import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/history_page.dart';
import 'package:flutter_application_2/pages/tentang_hotel.dart';
import 'package:flutter_application_2/pages/custom_bottom_nav.dart';
import 'package:flutter_application_2/pages/food_menu_page.dart';
import 'package:flutter_application_2/pages/kamar_menu_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  String? foto;
  String namaHotel = "Hotel Smart System";
  String deskripsi = "Pengalaman menginap yang tak terlupakan";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward(); // mulai animasi saat halaman dibuka

    fetchHotelData();

    fetchSummaryData();
  }

  String kamarKosong = "0";
  String kamarTerisi = "0";
  String totalMenu = "0";

  Future<void> fetchSummaryData() async {
    try {
      final res = await http.get(
        Uri.parse('http://192.168.1.2:8000/api/dashboard/info'),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print("📸 FOTO URL: ${data['foto']}");
        final info = data['data'];
        setState(() {
          kamarKosong = info['kamar_kosong'].toString();
          kamarTerisi = info['kamar_terisi'].toString();
          totalMenu = info['total_menu'].toString();
        });
      } else {
        debugPrint('Gagal ambil data dashboard (${res.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetchSummaryData: $e');
    }
  }

  Future<void> fetchHotelData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.2:8000/api/about-hss/hss'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hotel = data['data']; // ambil isi object "data"

        print("📸 FOTO URL: ${hotel['foto']}"); // cek ulang

        setState(() {
          foto = hotel['foto'];
          namaHotel = hotel['nama_hotel'] ?? namaHotel;
          deskripsi = hotel['deskripsi'] ?? deskripsi;
        });
      } else {
        debugPrint('Gagal mengambil data hotel (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetchHotelData: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black, // 🔹 warna dasar elegan
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 200,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image:
                foto != null
                    ? DecorationImage(
                      image: NetworkImage(foto!),
                      fit: BoxFit.cover,
                    )
                    : null,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: Colors.black.withOpacity(0.55), // overlay biar teks jelas
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Selamat Datang di",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "Hotel Smart System ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  "Pengalaman menginap yang tak terlupakan",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white, // 🔹 konten utama tetap putih bersih
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1), // dari bawah sedikit
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOut),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 10), // jarak dari header
                  // 🔹 Grid Menu Utama
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      menuItem(
                        context,
                        Icons.bed,
                        "Pilih Kamar",
                        "Temukan kamar ideal Anda",
                        BookingPage(),
                      ),
                      menuItem(
                        context,
                        Icons.restaurant,
                        "Pesan Makanan",
                        "Nikmati kuliner terbaik",
                        FoodMenuPage(),
                      ),
                      menuItem(
                        context,
                        Icons.receipt_long,
                        "Riwayat",
                        "Riwayat Pesanan",
                        HistoryPage(),
                      ),
                      menuItem(
                        context,
                        Icons.info,
                        "Tentang HSS",
                        "Informasi aplikasi",
                        InfoHotelPage(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 🔹 Ringkasan Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: infoCard(kamarKosong, "Kamar\nKosong")),
                      Expanded(child: infoCard(kamarTerisi, "Kamar\nTerisi")),
                      Expanded(child: infoCard(totalMenu, "Menu\nRestaurant")),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  /// 🔹 Widget Menu Utama
  Widget menuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), // kotak rounded
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1C1C1C), // hitam elegan
                    Color.fromARGB(255, 245, 180, 15), // emas gelap
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Widget Ringkasan Info
  Widget infoCard(String value, String label) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color:
                    label.contains("Menu")
                        ? Colors.amber.shade700
                        : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
