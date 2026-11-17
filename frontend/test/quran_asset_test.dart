import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quran.db dibundel dan berformat SQLite', () {
    final file = File('assets/quran.db');
    expect(file.existsSync(), isTrue, reason: 'assets/quran.db belum dibangun');
    expect(
      file.lengthSync(),
      greaterThan(1 << 20),
      reason: 'ukuran < 1 MB, kemungkinan build gagal',
    );
    final header = file.openSync()..setPositionSync(0);
    final bytes = header.readSync(16);
    header.closeSync();
    expect(String.fromCharCodes(bytes), startsWith('SQLite format 3'));
  });
}
