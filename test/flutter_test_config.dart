import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled Inter font before every test file, so widget tests lay
/// text out with real glyph widths instead of the test font's square boxes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final inter = FontLoader('Inter');
  for (final weight in [
    'Light',
    'Regular',
    'Medium',
    'SemiBold',
    'Bold',
    'ExtraBold',
  ]) {
    inter.addFont(rootBundle.load('assets/fonts/Inter-$weight.ttf'));
  }
  await inter.load();
  await testMain();
}
