import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/custom_bottom_nav.dart';
import 'package:flutter_application_2/pages/home_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List kamar = [];
  List makanan = [];
  List minuman = [];
  bool isLoading = true;
  final List<Color> menuGradient2 = [
    Colors.black,
    Color.fromARGB(255, 245, 180, 15),
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final tamuId = prefs.getInt('tamu_id'); // fallback biar nggak null

    try {
      final resKamar = await http.get(
        Uri.parse('http://10.78.11.84:8000/api/riwayat/kamar/$tamuId'),
      );
      final resMenu = await http.get(
        Uri.parse('http://10.78.11.84:8000/api/riwayat/makanan-minuman/$tamuId'),
      );

      if (resKamar.statusCode == 200 && resMenu.statusCode == 200) {
        final kamarJson = jsonDecode(resKamar.body);
        final menuJson = jsonDecode(resMenu.body);

        // Pastikan ambil "data" kalau ada wrapper
        final kamarData = kamarJson is List ? kamarJson : kamarJson['data'];
        final menuData = menuJson is List ? menuJson : menuJson['data'];

        setState(() {
          kamar = kamarData ?? [];
          makanan =
              (menuData ?? [])
                  .where(
                    (item) =>
                        item['kategori']?.toString().toLowerCase() == 'makanan',
                  )
                  .toList();
          minuman =
              (menuData ?? [])
                  .where(
                    (item) =>
                        item['kategori']?.toString().toLowerCase() == 'minuman',
                  )
                  .toList();
          isLoading = false;
        });
      } else {
        print("❌ Gagal ambil data dari server");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("🔥 Error ambil data riwayat: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // hanya 3 tab
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Riwayat Pesanan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Kamar"),
              Tab(text: "Makanan"),
              Tab(text: "Minuman"),
            ],
          ),
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                  color: Colors.grey[100],
                  child: TabBarView(
                    children: [
                      buildListRiwayat(kamar),
                      buildListRiwayat(makanan),
                      buildListRiwayat(minuman),
                    ],
                  ),
                ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      ),
    );
  }

  Widget buildListRiwayat(List data) {
    if (data.isEmpty) {
      return const Center(child: Text("Belum ada riwayat"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        String status = item['status'].toString().toLowerCase();

        Color statusColor;
        IconData statusIcon;
        switch (status) {
          case "selesai":
          case "checkout":
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
            break;
          case "ditempati":
          case "aktif":
            statusColor = Colors.blue;
            statusIcon = Icons.hotel; // atau Icons.home
            break;
          case "diproses":
            statusColor = Colors.orange;
            statusIcon = Icons.hourglass_bottom;
            break;
          case "batal":
          case "dibatalkan":
            statusColor = Colors.red;
            statusIcon = Icons.cancel;
            break;
          default:
            statusColor = Colors.grey;
            statusIcon = Icons.help_outline;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(statusIcon, color: statusColor),
            ),
            title: Text(
              item['nama'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("Tanggal: ${item['tanggal']}"),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Status: ${item['status']}",
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
