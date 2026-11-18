import 'package:flutter/material.dart';

import '../../../../core/database/app_db.dart';
import '../../../../core/utils/relative_time.dart';
import '../widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _db = AppDB.instance;
  late Future<Map<String, dynamic>?> _lastRead;

  @override
  void initState() {
    super.initState();
    _lastRead = _db.getLastRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan greeting dan avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/branding/app_logo.png',
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assalamu\'alaikum',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Selamat Membaca',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28),

              // Banner utama
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E6F40),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mulai membaca hari ini',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Al-Qur\'an menemani\nlangkahmu.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28),

              // Menu utama
              Text(
                'Menu utama',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MenuCard(
                      color: const Color(0xFFE2F0EA),
                      iconColor: const Color(0xFF2E6F40),
                      icon: Icons.menu_book_rounded,
                      title: 'Al-Qur\'an',
                      subtitle: 'Baca surah',
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/quran'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MenuCard(
                      color: const Color(0xFFFFF0DD),
                      iconColor: const Color(0xFFE67E22),
                      icon: Icons.bookmark_rounded,
                      title: 'Bookmark',
                      subtitle: 'Ayat tersimpan',
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/bookmark'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28),

              // Terakhir dibaca
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Terakhir dibaca',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/history'),
                    child: Text('Lihat semua'),
                  ),
                ],
              ),
              SizedBox(height: 12),
              FutureBuilder<Map<String, dynamic>?>(
                future: _lastRead,
                builder: (context, snapshot) => _lastReadCard(snapshot.data),
              ),

              SizedBox(height: 28),

              // Quote card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E4D0),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: const Color(0xFF2E6F40),
                      size: 28,
                    ),
                    SizedBox(height: 12),
                    Text(
                      '"Sesungguhnya dengan mengingat Allah hati menjadi tenteram."',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'QS. Ar-Ra\'d: 28',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushReplacementNamed(context, '/quran');
          if (index == 2) Navigator.pushReplacementNamed(context, '/bookmark');
          if (index == 3) Navigator.pushReplacementNamed(context, '/history');
        },
      ),
    );
  }

  Widget _lastReadCard(Map<String, dynamic>? lastRead) {
    final surahId = lastRead?['surah_id'] as int?;
    final namaSurah = lastRead?['surah_name'] as String?;
    final hasHistory = surahId != null && namaSurah != null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: hasHistory
            ? () => Navigator.pushNamed(
                context,
                '/isi-surah',
                arguments: {'namaSurah': namaSurah, 'nomorSurah': surahId},
              )
            : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE1E5E2)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE2F0EA),
                child: Icon(Icons.history_rounded, color: Color(0xFF2E6F40)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaSurah ?? 'Belum ada riwayat baca',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasHistory
                          ? relativeReadTime(
                              lastRead?['last_read_at'] as String?,
                            )
                          : 'Mulai baca dari daftar surah',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (hasHistory)
                const Icon(Icons.chevron_right, color: Color(0xFF2E6F40)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color color;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 30),
              SizedBox(height: 18),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
