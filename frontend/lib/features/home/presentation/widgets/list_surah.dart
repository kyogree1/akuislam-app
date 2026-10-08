import 'package:flutter/material.dart';

import '../../data/models/surah_model.dart';

class SurahListWidget extends StatelessWidget {
  final List<SurahModel> surahs;
  final Function(int nomor, String nama)? onTap;

  const SurahListWidget({super.key, required this.surahs, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (surahs.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: surahs.map((surah) {
          final nomor = surah.nomor;
          final namaLatin = surah.namaLatin;
          final jumlahAyat = surah.jumlahAyat;

          return GestureDetector(
            onTap: () {
              if (onTap != null) {
                onTap!(nomor, namaLatin);
              }
            },
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F0EA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$nomor',
                      style: const TextStyle(
                        color: Color(0xFF2E6F40),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    namaLatin,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$jumlahAyat ayat',
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
