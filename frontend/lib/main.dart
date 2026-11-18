import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/database/app_db.dart';
import 'features/home/presentation/pages/bookmark_page.dart';
import 'features/home/presentation/pages/history_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/pages/isi_surah_page.dart';
import 'features/home/presentation/pages/quran_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    // Buka DB sebelum UI tampil supaya aksi pertama tidak menanggung biaya init.
    await AppDB.instance.database;
  } catch (_) {
    // Gagal buka DB tidak boleh menghalangi app start; fitur simpan yang error.
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AkuIslam',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E6F40)),
        scaffoldBackgroundColor: const Color(0xFFF7F7F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F7F2),
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case '/quran':
            page = const QuranPage();
            break;
          case '/bookmark':
            page = const BookmarkPage();
            break;
          case '/history':
            page = const HistoryPage();
            break;
          case '/isi-surah':
            final data = settings.arguments as Map<String, dynamic>;
            page = IsiSurahPage(
              namaSurah: data['namaSurah'] as String,
              nomorSurah: data['nomorSurah'] as int,
            );
            break;
          case '/':
          default:
            page = const HomePage();
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, _, _) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      },
    );
  }
}
