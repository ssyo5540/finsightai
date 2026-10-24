import 'dart:ui';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Groups the integer part with commas: 12680 → "12,680".
String groupThousands(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Formats [amount] as US dollars, e.g. `$1,842.56`. Pass [cents] false to
/// drop the decimals and [signed] true to always show `+` or `-`.
String money(double amount, {bool cents = true, bool signed = false}) {
  final sign = amount < 0 ? '-' : (signed ? '+' : '');
  final parts = splitMoney(amount.abs());
  return '$sign${parts.whole}${cents ? parts.cents : ''}';
}

/// Splits an amount into `$1,842` and `.56` so the cents can be styled
/// lighter, the way every large figure in the design is drawn.
({String whole, String cents}) splitMoney(double amount) {
  final totalCents = (amount.abs() * 100).round();
  final whole = groupThousands(totalCents ~/ 100);
  final cents = (totalCents % 100).toString().padLeft(2, '0');
  return (whole: '\$$whole', cents: '.$cents');
}

/// `$12k`, `$2.4k`, `$40k` – the compact targets on the savings screen.
String compactMoney(double amount) {
  if (amount < 1000) return money(amount, cents: false);
  final thousands = amount / 1000;
  final text = thousands == thousands.roundToDouble()
      ? thousands.toStringAsFixed(0)
      : thousands.toStringAsFixed(1);
  return '\$${text}k';
}

/// `4` instead of `4.0`, `2.5` stays `2.5`.
String trimNumber(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

String monthDay(DateTime date) => '${_months[date.month - 1]} ${date.day}';

String weekdayShort(DateTime date) => _weekdays[date.weekday - 1];

String clock(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Parses `#RRGGBB` from the JSON files.
Color hexColor(String hex) {
  final value = int.parse(hex.replaceFirst('#', ''), radix: 16);
  return Color(0xFF000000 | value);
}
