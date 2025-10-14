import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/keranjang_page.dart';
import 'models/food_item.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Tambahkan model sederhana untuk meja
class Meja {
  final int id;
  final String nama;
  final int kapasitas;
  final String status;

  Meja({
    required this.id,
    required this.nama,
    required this.kapasitas,
    required this.status,
  });

  factory Meja.fromJson(Map<String, dynamic> json) {
    return Meja(
      id: json['id'],
      nama: json['nama_meja'],
      kapasitas: json['kapasitas'],
      status: json['status'],
    );
  }
}

class FoodItem {
  final int id;
  final String name;
  final String price;
  final String image;
  final String category;
  int quantity;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.quantity = 0,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['nama'],
      price: "Rp ${NumberFormat('#,###', 'id_ID').format(json['harga'])}",
      image: json['foto'] ?? "https://via.placeholder.com/150",
      category: json['kategori'] == "makanan" ? "Makanan" : "Minuman",
    );
  }
}

class FoodMenuPage extends StatefulWidget {
  const FoodMenuPage({super.key});

  @override
  State<FoodMenuPage> createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPage> {
  Future<void> fetchMenu() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.78.11.84:8000/api/makanan-minuman"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          menu = (data as List).map((e) => FoodItem.fromJson(e)).toList();
          isLoadingMenu = false;
        });
      } else {
        throw Exception("Gagal load menu");
      }
    } catch (e) {
      setState(() {
        isLoadingMenu = false;
      });
      print("Error fetch menu: $e");
    }
  }

  String? selectedTable;
  String activeCategory = "Semua";
  List<FoodItem> cartItems = [];

  List<Meja> mejas = [];
  bool isLoadingMeja = true;

  @override
  void initState() {
    super.initState();
    fetchMejas();
    fetchMenu();
  }

  Future<void> fetchMejas() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.78.11.84:8000/api/mejas"), // endpoint Laravel
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          mejas = (data as List).map((e) => Meja.fromJson(e)).toList();
          isLoadingMeja = false;
        });
      } else {
        throw Exception("Gagal load meja");
      }
    } catch (e) {
      setState(() {
        isLoadingMeja = false;
      });
      print("Error fetch meja: $e");
    }
  }

  final List<Color> menuGradient2 = [
    Colors.black,
    Color.fromARGB(255, 245, 180, 15),
  ];

  final List<String> categories = ["Semua", "Makanan", "Minuman"];

  List<FoodItem> menu = [];
  bool isLoadingMenu = true;

  // ✅ Tambah ke cart (kalau sudah ada, quantity ditambah)
  void addToCart(FoodItem item) async {
    setState(() {
      final index = cartItems.indexWhere((e) => e.name == item.name);
      if (index != -1) {
        cartItems[index].quantity++;
      } else {
        cartItems.add(
          FoodItem(
            id: item.id,
            name: item.name,
            price: item.price,
            image: item.image,
            category: item.category,
            quantity: 1,
          ),
        );
      }
    });

    // Kirim ke API Laravel
    try {
      final response = await http.post(
        Uri.parse('http://10.78.11.84:8000/api/temp-makanan-minuman'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'makanan_minuman_id': item.id,
          'harga': item.price.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          ), // ambil angka saja
          'jumlah': 1,
        }),
      );

      if (response.statusCode == 201) {
        print('✅ Item berhasil disimpan ke database');
      } else {
        print('❌ Gagal simpan ke database: ${response.body}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} ditambahkan ke keranjang'),
          backgroundColor: Colors.black,
        ),
      );
    } catch (e) {
      print('Error kirim data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMenu =
        activeCategory == "Semua"
            ? menu
            : menu.where((item) => item.category == activeCategory).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Menu Restoran",
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

        // 🔹 Custom tombol back dengan background emas
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

        // 🔹 Icon keranjang kanan atas
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CartPage(
                            cartItems: cartItems,
                            selectedTable: selectedTable, // 🔹 kirim meja
                          ),
                    ),
                  );
                },
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${cartItems.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body:
          isLoadingMenu
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      // 🔹 Dropdown Meja
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child:
                              isLoadingMeja
                                  ? const Text("Memuat meja...")
                                  : DropdownButton<String>(
                                    value: selectedTable,
                                    hint: const Text("Pilih Meja"),
                                    isExpanded: true,
                                    items:
                                        mejas.map((meja) {
                                          return DropdownMenuItem(
                                            value: meja.id.toString(),
                                            enabled:
                                                meja.status ==
                                                'kosong', // hanya bisa dipilih jika kosong
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "${meja.nama} (Kapasitas: ${meja.kapasitas})",
                                                  style: TextStyle(
                                                    color:
                                                        meja.status == 'kosong'
                                                            ? Colors.black
                                                            : Colors
                                                                .grey, // nonaktifkan warna teks
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        meja.status == 'kosong'
                                                            ? Colors.green
                                                            : meja.status ==
                                                                'dipesan'
                                                            ? Colors.orange
                                                            : Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    meja.status,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) async {
                                      // hanya ubah jika meja kosong
                                      final selected = mejas.firstWhere(
                                        (meja) => meja.id.toString() == value,
                                        orElse:
                                            () => Meja(
                                              id: 0,
                                              nama: '',
                                              kapasitas: 0,
                                              status: '',
                                            ),
                                      );

                                      if (selected.status != 'kosong') return;

                                      setState(() {
                                        selectedTable = value;
                                      });

                                      // 🔹 Update status ke "dipesan" di backend
                                      try {
                                        final response = await http.put(
                                          Uri.parse(
                                            "http://10.78.11.84:8000/api/mejas/$value/status",
                                          ),
                                          headers: {
                                            "Content-Type": "application/json",
                                          },
                                          body: jsonEncode({
                                            "status": "dipesan",
                                          }),
                                        );

                                        if (response.statusCode == 200) {
                                          print(
                                            "✅ Meja berhasil diperbarui menjadi 'dipesan'",
                                          );
                                        } else {
                                          print(
                                            "⚠️ Gagal update status meja: ${response.body}",
                                          );
                                        }
                                      } catch (e) {
                                        print("❌ Error update meja: $e");
                                      }
                                    },
                                  ),
                        ),
                      ),

                      // 🔹 Kategori
                      SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final active = activeCategory == cat;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  activeCategory = cat;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient:
                                      active
                                          ? const LinearGradient(
                                            colors: [
                                              Color(0xFF1C1C1C),
                                              Color(0xFFB8860B),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                          : null,
                                  color: active ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          active
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 🔹 Daftar Menu
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: filteredMenu.length,
                        itemBuilder: (context, index) {
                          final item = filteredMenu[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: Image.network(
                                      item.image,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          overflow:
                                              TextOverflow
                                                  .ellipsis, // kalau nama panjang
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.price,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () => addToCart(item),
                                            icon: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            label: const Text("Tambah"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.amber.shade700,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
