import 'package:akuislam/core/database/app_db.dart';
import 'package:akuislam/features/home/presentation/pages/history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  /// Beri waktu nyata agar I/O sqlite selesai di dalam zona fake-async.
  Future<void> settleIo(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
  }

  testWidgets('hapus semua riwayat langsung mengosongkan halaman', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await AppDB.instance.deleteAllHistory();
      await AppDB.instance.saveLastRead(surahId: 1, surahName: 'Al-Fatihah');
    });

    await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
    await settleIo(tester);
    expect(find.text('Al-Fatihah'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Hapus'));
    await settleIo(tester);
    await settleIo(tester);

    expect(find.text('Al-Fatihah'), findsNothing);
    expect(find.text('Belum ada riwayat baca.'), findsOneWidget);

    await tester.runAsync(() async {
      expect(await AppDB.instance.getHistory(), isEmpty);
    });
  });
}
