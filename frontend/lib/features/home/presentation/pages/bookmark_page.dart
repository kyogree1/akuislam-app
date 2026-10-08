import 'package:flutter/material.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../../home/presentation/pages/list_surah_page.dart';
import '../../../home/presentation/widgets/bottom_nav.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmark')),
      body: const Center(child: Text('Belum ada ayat yang disimpan.')),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(builder: (_) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(builder: (_) => const QuranPage()),
            );
          }
        },
      ),
    );
  }
}
