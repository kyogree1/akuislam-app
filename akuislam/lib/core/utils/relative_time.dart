/// Label waktu baca untuk kartu "Terakhir dibaca" dan halaman History.
String relativeReadTime(String? iso, {DateTime? now}) {
  if (iso == null) return '';
  final readAt = DateTime.tryParse(iso);
  if (readAt == null) return '';

  final current = now ?? DateTime.now();
  final days = DateTime(
    current.year,
    current.month,
    current.day,
  ).difference(DateTime(readAt.year, readAt.month, readAt.day)).inDays;

  if (days <= 0) return 'Dibaca hari ini';
  if (days == 1) return 'Dibaca kemarin';
  if (days < 7) return 'Dibaca $days hari lalu';

  final day = readAt.day.toString().padLeft(2, '0');
  final month = readAt.month.toString().padLeft(2, '0');
  return 'Dibaca $day/$month/${readAt.year}';
}
