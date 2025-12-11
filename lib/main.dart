import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AbsensiApp());
}

class AbsensiApp extends StatelessWidget {
  const AbsensiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Absensi Mahasiswa",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2ECC71),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2ECC71),
          primary: const Color(0xFF2ECC71),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.green.shade50,
          prefixIconColor: const Color(0xFF2ECC71),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2ECC71)),
          ),
        ),
      ),
      home: const AbsensiPage(),
    );
  }
}

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  final formKey = GlobalKey<FormState>();

  final namaC = TextEditingController();
  final nimC = TextEditingController();
  final kelasC = TextEditingController();
  final jkC = TextEditingController();
  final deviceC = TextEditingController();

  bool loading = false;
  String? message;
  bool isError = false;

  Future<void> submitAbsensi() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      message = null;
      isError = false;
    });

    final url = Uri.parse(
      "https://absensi-mobile.primakarauniversity.ac.id/api/absensi",
    );

    final body = {
      "nama": namaC.text.trim(),
      "nim": nimC.text.trim(),
      "kelas": kelasC.text.trim(),
      "jenis_kelamin": jkC.text.trim(),
      "device": deviceC.text.trim(),
    };

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(res.body);

      if (data["status"] == "success") {
        setState(() {
          isError = false;
          message = data["message"];
        });
      } else {
        if (data["message"] is Map) {
          String combined = "";
          data["message"].forEach((key, value) {
            combined += "$key: ${value.join(', ')}\n";
          });

          setState(() {
            isError = true;
            message = combined.trim();
          });
        } else {
          setState(() {
            isError = true;
            message = data["message"];
          });
        }
      }
    } catch (e) {
      setState(() {
        isError = true;
        message = "Terjadi kesalahan: $e";
      });
    }

    setState(() => loading = false);
  }

  Widget field(String label, IconData icon, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        validator: (v) =>
            v == null || v.isEmpty ? "$label tidak boleh kosong" : null,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Absensi"),
        backgroundColor: const Color(0xFF2ECC71),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              field("Nama", Icons.person, namaC),
              field("NIM", Icons.numbers, nimC),
              field("Kelas", Icons.school, kelasC),
              field("Jenis Kelamin", Icons.people, jkC),
              field("Device", Icons.phone_android, deviceC),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.send, color: Colors.white),
                label: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text(
                        "Kirim Absensi",
                        style: TextStyle(fontSize: 16),
                      ),
                onPressed: loading ? null : submitAbsensi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              if (message != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isError
                        ? Colors.red.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isError ? Icons.error : Icons.check_circle,
                        color: isError ? Colors.red : Colors.green,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message!,
                          style: TextStyle(
                            color: isError ? Colors.red : Colors.green.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
