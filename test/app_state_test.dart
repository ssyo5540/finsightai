import 'package:finsight_ai/data/app_state.dart';
import 'package:finsight_ai/data/finsight_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FinSightData data;
  late AppState state;

  setUpAll(() async {
    data = await FinSightRepository(rootBundle).load();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    state = AppState(data: data, prefs: await SharedPreferences.getInstance());
  });

  group('sign-in', () {
    test('rejects empty and wrong credentials', () async {
      expect(await state.signIn('', ''), 'Enter your email and password.');
      expect(
        await state.signIn('someone@example.com', 'nope'),
        'Email or password is incorrect.',
      );
      expect(state.isSignedIn, isFalse);
    });

    test('accepts the demo account and remembers the session', () async {
      final demo = data.users.single;
      expect(
        await state.signIn(' ${demo.email.toUpperCase()} ', demo.password),
        isNull,
      );
      expect(state.user?.firstName, 'Satwik');

      final restored = AppState(
        data: data,
        prefs: await SharedPreferences.getInstance(),
      )..restoreSession();
      expect(restored.isSignedIn, isTrue);

      await state.signOut();
      final afterSignOut = AppState(
        data: data,
        prefs: await SharedPreferences.getInstance(),
      )..restoreSession();
      expect(afterSignOut.isSignedIn, isFalse);
    });
  });

  test('paying Sushi Zen updates balance, ledger, expenses and budget', () {
    final receipt = state.completePayment(state.cardById('gold'));
    expect(receipt.quote.points, 256);
    expect(receipt.budgetProgress, closeTo(1.08, 0.001));
    expect(state.transactions.first.merchant, 'Sushi Zen');
    expect(state.transactions.first.note, '+256 pts');
    expect(state.totalBalance, closeTo(12680.42 - 64, 0.001));
    expect(state.monthSpent, closeTo(1842.56 + 64, 0.001));
    expect(state.budgetById('dining').spent, 432);
  });

  test('moving budget, cancelling, saving and toggling agents', () {
    state.moveBudget('shopping', 'dining', 30);
    expect(state.budgetById('dining').limit, 430);
    expect(state.budgetById('shopping').limit, 420);

    expect(state.unusedSubscription?.id, 'gym');
    state.cancelSubscription('gym');
    expect(state.subscriptions, hasLength(7));
    expect(state.unusedSubscription, isNull);

    state.addToGoal('japan', 100);
    expect(state.featuredGoal.saved, 3340);
    state.featureNextGoal();
    expect(state.featuredGoal.id, 'emergency');

    expect(state.activeAgents, 5);
    state.toggleAgent('bills');
    expect(state.activeAgents, 6);
    state.addAgent(name: 'Trip Guard', frequency: 'Daily');
    expect(state.agents.last.status, 'Custom · daily alerts');
  });

  test('quick replies replace the buttons and fill in the live budget', () {
    final source = state.chat.firstWhere((m) => m.actions.isNotEmpty);
    final reply = state.answerAction(source, source.actions.first);
    expect(state.chat.any((m) => m.actions.isNotEmpty), isFalse);
    expect(state.chat.last.text, 'Yes, move \$30');
    expect(reply, contains(r'$62.00'));
  });
}
