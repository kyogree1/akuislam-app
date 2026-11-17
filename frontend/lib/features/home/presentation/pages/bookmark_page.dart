import 'package:flutter/material.dart';

import '../../../../core/database/app_db.dart';
import '../widgets/bottom_nav.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final _db = AppDB.instance;
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    var failed = false;
    var bookmarks = <Map<String, dynamic>>[];
    try {
      bookmarks = await _db.getAllBookmarks();
    } catch (_) {
      failed = true;
    }
    if (mounted) {
      setState(() {
        _bookmarks = bookmarks;
        _loadFailed = failed;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBookmark(Map<String, dynamic> bookmark) async {
    final id = bookmark['id'] as int;
    final index = _bookmarks.indexWhere((item) => item['id'] == id);
    if (index < 0) return;

    final removed = _bookmarks[index];
    // Optimistic: baris langsung hilang, tulis DB menyusul.
    setState(() => _bookmarks = List.of(_bookmarks)..removeAt(index));

    try {
      await _db.deleteBookmark(id);
    } catch (_) {
      if (!mounted) return;
      setState(
        () =>
            _bookmarks = List.of(_bookmarks)
              ..insert(index.clamp(0, _bookmarks.length), removed),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus bookmark')));
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bookmark dihapus'),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () => _restoreBookmark(removed),
        ),
      ),
    );
  }

  Future<void> _restoreBookmark(Map<String, dynamic> bookmark) async {
    try {
      await _db.addBookmark(
        surahId: bookmark['surah_id'] as int,
        surahName: bookmark['surah_name'] as String,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gagal mengurungkan')));
      return;
    }
    await _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pushReplacementNamed(context, '/');
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Bookmark Surah',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadFailed
            ? const Center(child: Text('Gagal memuat bookmark.'))
            : _bookmarks.isEmpty
            ? const Center(child: Text('Belum ada surah yang disimpan.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _bookmarks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final bookmark = _bookmarks[index];
                  return Card(
                    key: ValueKey(bookmark['id']),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFF0DD),
                        child: Icon(Icons.bookmark, color: Color(0xFFE67E22)),
                      ),
                      title: Text(
                        bookmark['surah_name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          '/isi-surah',
                          arguments: {
                            'namaSurah': bookmark['surah_name'],
                            'nomorSurah': bookmark['surah_id'],
                          },
                        );
                        await _loadBookmarks();
                      },
                      trailing: IconButton(
                        tooltip: 'Hapus bookmark',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteBookmark(bookmark),
                      ),
                    ),
                  );
                },
              ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: 2,
          onTap: (index) => Navigator.pushReplacementNamed(
            context,
            ['/', '/quran', '/bookmark', '/history'][index],
          ),
        ),
      ),
    );
  }
}
