import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Halaman Tentang: sumber data, kebijakan privasi, kontak.
/// ponytail: versi ditulis manual — samakan dengan pubspec saat rilis.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _version = '1.0.0';
  static const _policyUrl =
      'https://kyogree1.github.io/akuislam-app/privacy.html';
  static const _email = '11231036@student.itk.ac.id';

  Future<void> _open(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka tautan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F2),
      appBar: AppBar(title: const Text('Tentang')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/branding/app_logo.png',
                width: 84,
                height: 84,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'AkuIslam',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text(
              'Versi $_version',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aplikasi baca Al-Qur\'an 30 juz. Teks Al-Qur\'an tersimpan di dalam '
            'aplikasi sehingga dapat dibaca tanpa internet; koneksi hanya dipakai '
            'sebagai cadangan bila data lokal gagal dibuka. Bookmark dan riwayat '
            'baca disimpan di perangkat Anda dan tidak dikirim ke mana pun. Tidak '
            'ada data pribadi yang dikumpulkan dan tidak ada iklan.',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 24),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: Color(0xFF2E6F40),
                  ),
                  title: const Text('Kebijakan Privasi'),
                  subtitle: const Text('Buka versi lengkap di browser'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => _open(context, Uri.parse(_policyUrl)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.menu_book_outlined,
                    color: Color(0xFF2E6F40),
                  ),
                  title: const Text('Sumber Data'),
                  subtitle: const Text(
                    'Teks Al-Qur\'an dan terjemahan: equran.id, '
                    'Kementerian Agama RI',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.mail_outline,
                    color: Color(0xFF2E6F40),
                  ),
                  title: const Text('Hubungi Kami'),
                  subtitle: const Text(_email),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () =>
                      _open(context, Uri(scheme: 'mailto', path: _email)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
