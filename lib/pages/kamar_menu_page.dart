import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/form_pesan_kamar_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

String formatRupiah(int angka) {
  final formatter = NumberFormat('#,###', 'id_ID');
  return formatter.format(angka).replaceAll(',', '.');
}

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<Map<String, dynamic>> kamarList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchKamar();
  }

  Future<void> fetchKamar() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.61.138.179:8000/api/kamars"),
      ); // ganti sesuai URL API Laravel

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        setState(() {
          kamarList = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception("Gagal load kamar");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 1,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        title: const Text(
          "Pilih Kamar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : kamarList.isEmpty
              ? const Center(child: Text("Tidak ada kamar"))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: kamarList.length,
                itemBuilder: (context, index) {
                  final kamar = kamarList[index];
                  return buildKamarCard(kamar, context);
                },
              ),
    );
  }

  Widget buildKamarCard(Map<String, dynamic> kamar, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Bagian Gambar
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  kamar['foto_kamar'],
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    kamar['status'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 🔹 Bagian Detail
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kamar['nama_kamar'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // kamar['deskripsi'],
                  'Kamar kamar',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rp ${formatRupiah(int.tryParse(kamar['kategori']?['Harga'].toString() ?? '0') ?? 0)}",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Kapasitas: ${kamar['kategori']?['kapasitas'] ?? '-'} orang",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 14, 14, 14),
                        Colors.amber.shade700,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        kamar['status'] == 'terisi'
                            ? null // tombol nonaktif kalau status terisi
                            : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FormPesanKamarPage(kamar: kamar),
                                ),
                              );
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Pesan Sekarang"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
