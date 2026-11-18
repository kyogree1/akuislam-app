import 'package:akuislam/main.dart';
import 'package:akuislam/core/utils/relative_time.dart';
import 'package:akuislam/features/home/presentation/pages/bookmark_page.dart';
import 'package:akuislam/features/home/presentation/pages/history_page.dart';
import 'package:akuislam/features/home/presentation/pages/home_page.dart';
import 'package:akuislam/features/home/presentation/pages/isi_surah_page.dart';
import 'package:akuislam/features/home/presentation/pages/quran_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _testSizes = [
  Size(320, 568),
  Size(360, 800),
  Size(411, 915),
  Size(600, 1024),
  Size(800, 600),
  Size(1024, 768),
];

void main() {
  testWidgets('renders every UI page at common portrait sizes', (tester) async {
    final pages = <Widget>[
      const HomePage(),
      const QuranPage(),
      const BookmarkPage(),
      const HistoryPage(),
      const IsiSurahPage(namaSurah: 'Al-Fatihah', nomorSurah: 1),
    ];

    for (final size in _testSizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;

      for (final page in pages) {
        await tester.pumpWidget(MaterialApp(home: page));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${page.runtimeType} failed at ${size.width}x${size.height}',
        );
      }
    }

    tester.view.reset();
  });

  testWidgets('home page is the initial route', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(HomePage), findsOneWidget);
  });

  test('relative read time labels', () {
    final now = DateTime(2026, 11, 15, 12);
    String format(DateTime readAt) =>
        relativeReadTime(readAt.toIso8601String(), now: now);

    expect(format(DateTime(2026, 11, 15, 8)), 'Dibaca hari ini');
    expect(format(DateTime(2026, 11, 14, 23)), 'Dibaca kemarin');
    expect(format(DateTime(2026, 11, 12)), 'Dibaca 3 hari lalu');
    expect(format(DateTime(2026, 11, 1)), 'Dibaca 01/11/2026');
    expect(relativeReadTime(null), '');
    expect(relativeReadTime('bukan tanggal'), '');
  });
}
