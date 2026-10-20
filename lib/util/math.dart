double number(Map<String, dynamic>? data, String key,) {
  final value = data?[key];
  return value is num ? value.toDouble() : 0;
}

String formatBytes(dynamic value) {
  if (value is! num) return '--';

  const units = ['B', 'KiB', 'MiB', 'GiB', 'TiB'];
  double size = value.toDouble();
  int unit = 0;

  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit++;
  }

  return '${size.toStringAsFixed(1)} ${units[unit]}';
}
