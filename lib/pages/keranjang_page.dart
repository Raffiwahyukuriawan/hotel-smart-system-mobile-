import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/food_menu_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  final List<FoodItem> cartItems;
  final String? selectedTable;

  const CartPage({super.key, required this.cartItems, this.selectedTable});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    _loadUserData(); // 🔹 panggil fungsi ini saat halaman dimuat
  }

  void showResultDialog(
    BuildContext context, {
    required bool success,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // tidak bisa ditutup klik luar
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                  Navigator.pop(context); // tutup dialog
                  if (success) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const FoodMenuPage()),
                    );
                  }
                },
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  int getSubtotal() {
    int subtotal = 0;
    for (var item in widget.cartItems) {
      final harga =
          int.tryParse(item.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      subtotal += harga * item.quantity; // dikali quantity
    }
    return subtotal;
  }

  final List<Color> menuGradient2 = [
    Colors.black,
    Color.fromARGB(255, 245, 180, 15),
  ];

  Future<void> updateJumlahPesanan(FoodItem item) async {
    try {
      final response = await http.put(
        Uri.parse("http://10.61.138.179:8000/api/pesanan/${item.id}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"jumlah_dipesan": item.quantity}),
      );

      if (response.statusCode == 200) {
        print("✅ Jumlah pesanan diperbarui untuk ${item.name}");
      } else {
        print("❌ Gagal update jumlah: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error update jumlah: $e");
    }
  }

  void _hapusItemDariKeranjang(FoodItem item) {
    setState(() {
      widget.cartItems.remove(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item.name} telah dihapus dari keranjang."),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> kirimPesananKeServer() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Ambil ID tamu dari SharedPreferences (pastikan kamu simpan sebelumnya saat login)
      final int? namaTamuId = prefs.getInt('tamu_id');
      final String jumlahTamu = selectedJumlahTamu ?? "1";
      final String jamMakan =
          selectedTime != null ? selectedTime!.format(context) : "";
      final String mejaId = widget.selectedTable ?? "1";

      // Gunakan tanggal hari ini
      final String tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());

      int biayaLayanan = 15000;

      bool semuaBerhasil = true;

      for (var item in widget.cartItems) {
        // Ambil harga dari item
        final harga =
            int.tryParse(item.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final totalHarga = (harga * item.quantity) + biayaLayanan;

        final prefs = await SharedPreferences.getInstance();
        final tamuId = prefs.getInt('tamu_id');

        final response = await http.post(
          Uri.parse("http://10.61.138.179:8000/api/riwayat-pesanan/store"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "nama_tamu_id": namaTamuId,
            "tamu_id": tamuId,
            "makanan_minuman_id": item.id,
            "tanggal": tanggal,
            "jam_makan": jamMakan,
            "meja_id": int.parse(mejaId),
            "jumlah_tamu": int.parse(jumlahTamu),
            "jumlah_dipesan": item.quantity,
            "total_harga": totalHarga,
            "biaya_layanan": biayaLayanan,
            "status": "diproses",
            "no_telp": _telpController.text, // ✅ tambahkan ini
          }),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          semuaBerhasil = false;
          print("❌ Gagal menyimpan pesanan: ${response.body}");
        }
      }

      if (semuaBerhasil) {
        showResultDialog(
          context,
          success: true,
          message: "Semua pesanan berhasil dikirim ke server!",
        );
      } else {
        showResultDialog(
          context,
          success: false,
          message: "Beberapa pesanan gagal dikirim. pastikan form sudah dilengkapi atau coba lagi nanti!.",
        );
      }
    } catch (e) {
      showResultDialog(
        context,
        success: false,
        message: "Terjadi kesalahan: $e",
      );
    }
  }

  TimeOfDay? selectedTime;

  String? selectedJumlahTamu;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaController.text = prefs.getString('nama_tamu') ?? '';
      _telpController.text = prefs.getString('no_telp') ?? '';
    });
  }

  String formatRupiah(int angka) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(angka).replaceAll(',', '.');
  }

  @override
  Widget build(BuildContext context) {
    int subtotal = getSubtotal();
    int biayaLayanan = 15000;
    int total = subtotal + biayaLayanan;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Konfirmasi Pesanan",
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Item Pesanan
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Item Pesanan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.cartItems.map((item) {
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Image.network(
                            item.image,
                            width: 50,
                            height: 50,
                          ),
                          title: Text(item.name),
                          subtitle: Text(item.price),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tombol hapus item
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  _hapusItemDariKeranjang(item);
                                },
                              ),
                              // Tombol kurangi jumlah
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () async {
                                  if (item.quantity > 1) {
                                    setState(() => item.quantity--);
                                    await updateJumlahPesanan(item);
                                  }
                                },
                              ),
                              Text("${item.quantity}"),
                              // Tombol tambah jumlah
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () async {
                                  setState(() => item.quantity++);
                                  await updateJumlahPesanan(item);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // 🔹 Informasi Meja & Tamu
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Judul + Icon dalam 1 baris
                    Row(
                      children: const [
                        Icon(Icons.people, color: Colors.orange, size: 22),
                        SizedBox(width: 8),
                        Text(
                          "Informasi Meja & Tamu",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Meja yang dipilih dikirim dari FoodMenuPage
                    if (widget.selectedTable != null)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Meja ${widget.selectedTable}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Text(
                        "Belum memilih meja",
                        style: TextStyle(color: Colors.red),
                      ),

                    const SizedBox(height: 16),

                    // 🔹 Jumlah tamu
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Jumlah Tamu",
                        hintText: "Pilih jumlah tamu",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: selectedJumlahTamu,
                      items: List.generate(10, (index) {
                        return DropdownMenuItem(
                          value: (index + 1).toString(), // hanya angka
                          child: Text(
                            "${index + 1} Orang",
                          ), // tampilannya tetap ada tulisan
                        );
                      }),
                      onChanged: (val) {
                        setState(() {
                          selectedJumlahTamu = val;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // 🔹 Waktu penyajian
                    // 🔹 Jam Makan
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Jam Makan",
                        hintText: "Pilih jam makan",
                        prefixIcon: const Icon(Icons.access_time),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: TextEditingController(
                        text:
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : "",
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16), // 🔹 Informasi Pemesan
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.person, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Informasi Pemesan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _namaController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Nama Pemesan",
                        prefixIcon: const Icon(Icons.account_circle),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _telpController,
                      keyboardType: TextInputType.number,
                      readOnly: false,
                      decoration: InputDecoration(
                        labelText: "Nomor Telepon",
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Ringkasan Pesanan (terhubung)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.receipt_long,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Ringkasan Pesanan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Subtotal",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "Rp ${formatRupiah(subtotal)}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Biaya Layanan",
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                        Text(
                          "Rp ${formatRupiah(biayaLayanan)}",
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pajak (10%)",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "Rp ${formatRupiah(total)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  await kirimPesananKeServer();
                  // ⛔️ Tidak perlu SnackBar dan Navigator di sini
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.black, Color.fromARGB(255, 231, 170, 14)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "Konfirmasi Pesanan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
