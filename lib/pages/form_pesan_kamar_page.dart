import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/kamar_menu_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final List<Color> menuGradient2 = [
  Colors.black,
  Color.fromARGB(255, 245, 180, 15),
];

class FormPesanKamarPage extends StatelessWidget {
  final Map<String, dynamic> kamar; // data kamar dari BookingPage

  FormPesanKamarPage({super.key, required this.kamar});
  final TextEditingController checkInController = TextEditingController();
  final TextEditingController checkOutController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  final TextEditingController noTelpController = TextEditingController();
  String? jumlahTamu; // simpan pilihan dropdown

  // hitung lama menginap
  int _hitungLamaMenginap() {
    if (checkInController.text.isEmpty || checkOutController.text.isEmpty) {
      return 1; // default 1 malam
    }
    DateTime checkIn = DateTime.parse(checkInController.text);
    DateTime checkOut = DateTime.parse(checkOutController.text);
    return checkOut.difference(checkIn).inDays == 0
        ? 1
        : checkOut.difference(checkIn).inDays;
  }

  String formatRupiah(int angka) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(angka).replaceAll(',', '.');
  }

  // hitung total harga
  int _hitungTotalHarga() {
    int hargaPerMalam =
        int.tryParse(kamar['kategori']?['Harga'].toString() ?? '0') ?? 0;
    int lamaMenginap = _hitungLamaMenginap();

    int subtotal = hargaPerMalam * lamaMenginap;
    int pajak = (subtotal * 0.1).toInt(); // pajak 10%
    return subtotal + pajak;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Form Pemesanan Kamar',
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
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white, // panah hitam
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Card Kamar
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      kamar['foto_kamar'] ?? '', // ambil dari API
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kamar['nama_kamar'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text("Status: ${kamar['status']}"),
                        const SizedBox(height: 8),
                        Text(
                          "Rp ${formatRupiah(int.tryParse(kamar['kategori']?['Harga'].toString() ?? '0') ?? 0)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        Text(
                          "Kapasitas: ${kamar['kategori']?['kapasitas'] ?? '-'} orang",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Detail Pemesanan
            _sectionCard(
              "Detail Pemesanan",
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _dateField(
                          "Check-in",
                          checkInController,
                          context,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dateField(
                          "Check-out",
                          checkOutController,
                          context,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: jumlahTamu,
                    decoration: InputDecoration(
                      labelText: "Jumlah Tamu",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items:
                        ["1", "2", "3", "4"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (value) {
                      jumlahTamu = value; // simpan hasil pilih
                    },
                  ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: noTelpController,
                    keyboardType:
                        TextInputType.number, // ✅ muncul keyboard angka
                    decoration: InputDecoration(
                      labelText: "Nomor Telepon",
                      hintText: "+62 xxx xxx xxx",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),
                  _textField(
                    "Permintaan Khusus",
                    hint: "Contoh: Kamar lantai tinggi, extra bed, dll.",
                    controller: catatanController,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Ringkasan Pembayaran
            // 🔹 Ringkasan Pembayaran
            _sectionCard(
              "Ringkasan Pembayaran",
              StatefulBuilder(
                builder: (context, setState) {
                  int harga =
                      int.tryParse(
                        kamar['kategori']?['Harga'].toString() ?? '0',
                      ) ??
                      0;
                  int malam = _hitungLamaMenginap();
                  int subtotal = harga * malam;
                  int pajak = (subtotal * 0.1).toInt();
                  int total = subtotal + pajak;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _summaryRow(
                        "Harga kamar ($malam malam)",
                        "Rp ${formatRupiah(subtotal)}",
                      ),
                      _summaryRow(
                        "Pajak & Layanan (10%)",
                        "Rp ${formatRupiah(pajak)}",
                      ),
                      const Divider(),
                      _summaryRow(
                        "Total",
                        "Rp ${formatRupiah(total)}",
                        highlight: true,
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),

      // 🔹 Tombol Konfirmasi
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity, // biar full lebar
          height: 50, // atur tinggi tombol
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero, // jangan ada padding lagi
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              int? userId = prefs.getInt('user_id'); // ambil dari session login
              int? tamuId = prefs.getInt('tamu_id'); // ambil dari session login
              String? token = prefs.getString('token');

              final response = await http.post(
                Uri.parse("http://10.78.11.84:8000/api/booking"),
                headers: {
                  "Content-Type": "application/json",
                  "Authorization":
                      "Bearer $token", // kirim token biar Laravel validasi
                },
                body: jsonEncode({
                  "kamar_id": kamar['id'],
                  "user_id": userId, // ✅ otomatis sesuai user yang login
                  "tamu_id": tamuId, // ✅ otomatis sesuai user yang login
                  "check_in": checkInController.text,
                  "check_out": checkOutController.text,
                  "catatan_khusus": catatanController.text,
                  "no_telp": noTelpController.text,
                  "jumlah_tamu": jumlahTamu,
                  "total_harga": _hitungTotalHarga(),
                }),
              );

              if (response.statusCode == 201) {
                showResultDialog(
                  context,
                  success: true,
                  message: "Pemesanan berhasil dibuat!",
                );
              } else {
                showResultDialog(
                  context,
                  success: false,
                  message: "Gagal melakukan pemesanan.\n${response.body}",
                );
              }
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 20, 20, 20),
                    Colors.amber.shade700,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "Konfirmasi Pemesanan",
                  style: TextStyle(
                    fontSize: 16,
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

  // 🔹 Widget Helper
  static Widget _sectionCard(String title, Widget child) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  static Widget _textField(
    String label, {
    String? hint,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  static Widget _dateField(
    String label,
    TextEditingController controller,
    BuildContext context,
  ) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: "yyyy-mm-dd",
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          controller.text = "${picked.toLocal()}".split(' ')[0];
          (context as Element)
              .markNeedsBuild(); // refresh UI agar total terupdate
        }
      },
    );
  }

  static Widget _dropdownField(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) {},
    );
  }
}

class _summaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _summaryRow(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 16 : 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.amber.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
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
    barrierDismissible: false, // biar gak bisa ditutup klik luar
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
                Navigator.pop(context); // tutup dialog dulu
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BookingPage()),
                ); // lalu arahkan ke halaman KamarPage
              },
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    },
  );
}
