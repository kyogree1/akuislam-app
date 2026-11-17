import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/home/presentation/pages/bookmark_page.dart';
import 'features/home/presentation/pages/history_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/pages/isi_surah_page.dart';
import 'features/home/presentation/pages/quran_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Islamic App UI',
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
