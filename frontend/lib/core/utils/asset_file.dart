// Default (web): tidak ada akses filesystem, QuranDb tidak dipakai di sana.
Future<void> writeAssetBytes(String path, List<int> bytes) async {
  throw UnsupportedError('Akses file tidak tersedia di platform ini');
}
