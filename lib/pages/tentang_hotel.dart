import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfoHotelPage extends StatefulWidget {
  const InfoHotelPage({super.key});

  @override
  State<InfoHotelPage> createState() => _InfoHotelPageState();
}

class _InfoHotelPageState extends State<InfoHotelPage> {
  Map<String, dynamic>? hotel;
  bool isLoading = true;

  final List<Color> menuGradient2 = [
    Colors.black,
    const Color.fromARGB(255, 245, 180, 15),
  ];

  // 🔹 Fetch data dari API
  Future<void> fetchHotelInfo() async {
    final response = await http.get(
      Uri.parse("http://10.78.11.84:8000/api/about-hss"),
    );

    if (response.statusCode == 200) {
      setState(() {
        hotel = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception("Gagal ambil data hotel");
    }
  }

  // 🔹 Helper buat baris info
  Widget buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color.fromARGB(255, 231, 170, 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchHotelInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tentang HSS",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : hotel == null
              ? const Center(child: Text("Data hotel tidak tersedia"))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Card 1 - Foto & Deskripsi
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            hotel!['foto'] ??
                                "https://via.placeholder.com/400x200.png?text=No+Image",
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hotel!['nama_hotel'] ?? "-",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hotel!['deskripsi'] ?? "-",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Card 2 - Info Hotel
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Informasi Hotel",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),

                            buildInfoRow(
                              Icons.location_on,
                              "Alamat",
                              hotel!['alamat'] ?? "-",
                            ),
                            buildInfoRow(
                              Icons.phone,
                              "Telepon",
                              hotel!['no_telp'] ?? "-",
                            ),
                            buildInfoRow(
                              Icons.email,
                              "Email",
                              hotel!['email'] ?? "-",
                            ),
                            buildInfoRow(
                              Icons.star,
                              "Kelas Hotel",
                              hotel!['kelas'] ?? "-",
                            ),
                            buildInfoRow(
                              Icons.access_time,
                              "Check-in / Check-out",
                              "14:00 / 12:00",
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Footer
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            "HSS Mobile App v2.0.0\n© 2025 Grand Luxury Hotel",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
