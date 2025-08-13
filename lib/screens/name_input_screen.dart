import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputNameScreen extends StatefulWidget {
  const InputNameScreen({super.key});

  @override
  State<InputNameScreen> createState() => _InputNameScreenState();
}

class _InputNameScreenState extends State<InputNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  Future<void> _submitName() async {
    final raw = _nameController.text.trim();
    if (raw.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final col = FirebaseFirestore.instance.collection('players');

      // Cari player dg nama yg sama (biar tidak dobel)
      final snap = await col.where('name', isEqualTo: raw).limit(1).get();

      late final String playerId;
      if (snap.docs.isNotEmpty) {
        playerId = snap.docs.first.id;
      } else {
        final ref = await col.add({
          'name': raw,
          'score': 0,
          'created_at': FieldValue.serverTimestamp(),
        });
        playerId = ref.id;
      }

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('playerName', raw);
      await prefs.setString('playerId', playerId);

      if (!mounted) return;
      setState(() => _isSaving = false);

      // Lanjut ke pilih grade
      Navigator.pushReplacementNamed(context, '/select-grade');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1CB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                'Enter Your Name',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submitName(),
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isSaving ? null : _submitName,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
