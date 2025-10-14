import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class FormReservasiPage extends StatefulWidget {
  const FormReservasiPage({super.key});

  @override
  State<FormReservasiPage> createState() => _FormReservasiPageState();
}

class _FormReservasiPageState extends State<FormReservasiPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final Map<int, TextEditingController> jumlahTamuController = {};
  String _pilihanMakan = 'Restoran';
  DateTime? _tanggalReservasi;

  final List<Map<String, dynamic>> mejaList = [
    {'nomor': 1, 'kapasitas': 2, 'terisi': 0},
    {'nomor': 2, 'kapasitas': 4, 'terisi': 2},
    {'nomor': 3, 'kapasitas': 6, 'terisi': 0},
  ];

  final List<Color> menuGradient = [Colors.blue.shade800, Colors.teal.shade300];
final List<Color> menuGradient2 = [Colors.black, Color.fromARGB(255, 245, 180, 15)];

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    // Initialize controllers untuk tiap meja
    for (var meja in mejaList) {
      jumlahTamuController[meja['nomor']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    _confettiController.dispose();
    for (var controller in jumlahTamuController.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // Validasi tanggal jika restoran
    if (_pilihanMakan == 'Restoran' && _tanggalReservasi == null) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: 'Perhatian!',
        desc: 'Pilih tanggal reservasi terlebih dahulu.',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    // Validasi jumlah tamu jika restoran
    if (_pilihanMakan == 'Restoran') {
      var mejaDipilih =
          mejaList
              .map((meja) {
                var jumlah = jumlahTamuController[meja['nomor']]!.text;
                if (jumlah.isNotEmpty && int.tryParse(jumlah) != null) {
                  return {
                    'meja': meja['nomor'],
                    'jumlah_tamu': int.parse(jumlah),
                  };
                }
                return null;
              })
              .where((e) => e != null)
              .toList();

      if (mejaDipilih.isEmpty) {
        AwesomeDialog(
          context: context,
          dialogType:
              DialogType.warning, // warning otomatis kasih ikon segitiga
          animType: AnimType.scale,
          title: 'Perhatian!',
          desc: 'Isi jumlah tamu di meja yang ingin dipesan.',
          btnOkOnPress: () {},
        ).show();
        return;
      }

      debugPrint('Reservasi Restoran: $mejaDipilih');
    }

    if (_pilihanMakan == 'Kamar') {
      debugPrint('Reservasi Kamar');
    }

    // Sukses
    _confettiController.play();
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Berhasil!',
      desc: 'Pesanan berhasil dibuat.',
      btnOkOnPress: () {},
      showCloseIcon: true, // pastikan ini ada
    ).show();
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Tamu
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  hintText: 'Masukkan nama tamu',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Isi nama tamu' : null,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pilihan Makan
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilihan Makan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  RadioListTile(
                    title: const Text('Makan di Restoran'),
                    value: 'Restoran',
                    activeColor: Colors.blue,
                    groupValue: _pilihanMakan,
                    onChanged: (value) {
                      setState(() {
                        _pilihanMakan = value!;
                        _tanggalReservasi = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Form Restoran
          if (_pilihanMakan == 'Restoran') ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal Reservasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null)
                          setState(() => _tanggalReservasi = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _tanggalReservasi != null
                                  ? "${_tanggalReservasi!.day}/${_tanggalReservasi!.month}/${_tanggalReservasi!.year}"
                                  : 'Pilih Tanggal',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Meja & Jumlah Tamu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children:
                          mejaList.map((meja) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Meja ${meja['nomor']} (Kapasitas: ${meja['kapasitas']}, Terisi: ${meja['terisi']})",
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextFormField(
                                      controller:
                                          jumlahTamuController[meja['nomor']],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText: 'Jumlah',
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'Konfirmasi Detail Pemesanan',
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
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1C1C1C), // hitam elegan
                        Color.fromARGB(255, 245, 180, 15), // emas gelap
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black, // panah hitam
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildForm(),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                "Pesan Sekarang",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
            ],
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 20,
            minBlastForce: 5,
          ),
        ),
      ],
    );
  }
}
