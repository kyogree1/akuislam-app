import 'dart:io';

/// Salin byte aset ke path tujuan (dipakai QuranDb saat pertama dibuka).
Future<void> writeAssetBytes(String path, List<int> bytes) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
}
