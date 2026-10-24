import 'package:finsight_ai/data/app_state.dart';
import 'package:finsight_ai/data/finsight_repository.dart';
import 'package:finsight_ai/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<AppState> freshState() async {
    final data = await FinSightRepository(rootBundle).load();
    return AppState(data: data, prefs: await SharedPreferences.getInstance())
      ..restoreSession();
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('opens on Welcome without a session', (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    final state = await tester.runAsync(freshState);
    await tester.pumpWidget(FinSightApp(state: state!));
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('opens on Home when the demo account is signed in', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    final state = await tester.runAsync(() async {
      final s = await freshState();
      await s.signIn(s.data.users.single.email, s.data.users.single.password);
      return s;
    });
    await tester.pumpWidget(FinSightApp(state: state!));
    await tester.pumpAndSettle();
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text(r'$12,680.42', findRichText: true), findsOneWidget);
    expect(find.text('Whole Foods Market'), findsOneWidget);
  });
}
