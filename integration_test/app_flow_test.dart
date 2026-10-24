import 'package:finsight_ai/data/app_state.dart';
import 'package:finsight_ai/data/finsight_repository.dart';
import 'package:finsight_ai/main.dart';
import 'package:finsight_ai/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end walk through every screen with the demo account, run on a
/// simulator or device:
///   `flutter test integration_test -d <device id>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // The Tap to Pay pulse animates forever, so pumpAndSettle would never
  // return; pump real frames for a fixed time instead.
  Future<void> wait(WidgetTester tester, [int ms = 700]) async {
    for (var elapsed = 0; elapsed < ms; elapsed += 50) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Finder button(String label) =>
      find.byWidgetPredicate((w) => w is Tappable && w.label == label);

  Future<void> tap(WidgetTester tester, Finder finder, [int ms = 700]) async {
    final target = finder.first;
    final rect = tester.getRect(target);
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    // Only scroll when the target is hidden off-screen or under the nav pill.
    if (rect.top < 0 || rect.bottom > screen.height - 110) {
      await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
      await wait(tester, 300);
    }
    await tester.tap(target);
    await wait(tester, ms);
  }

  /// Taps the visible top strip of a card in the Tap to Pay stack.
  Future<void> tapStacked(WidgetTester tester, Finder finder) async {
    await tester.tapAt(
      tester.getRect(finder.first).topCenter + const Offset(0, 14),
    );
    await wait(tester);
  }

  Finder rich(String text) => find.text(text, findRichText: true);

  testWidgets('demo account walks every flow end to end', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final data = await FinSightRepository(rootBundle).load();
    final state = AppState(data: data, prefs: prefs)..restoreSession();
    await tester.pumpWidget(FinSightApp(state: state));
    await wait(tester, 1000);

    // Welcome → Sign in.
    expect(find.text('Get Started'), findsOneWidget);
    await tap(tester, find.text('Get Started'));
    expect(find.text('Sign In'), findsOneWidget);

    // Validation and wrong credentials.
    await tap(tester, find.text('Sign In'));
    expect(find.text('Enter your email and password.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'someone@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tap(tester, find.text('Sign In'));
    expect(find.text('Email or password is incorrect.'), findsOneWidget);

    // Demo account from users.json.
    await tap(tester, find.text('Use demo account'));
    await tap(tester, find.text('Sign In'), 1500);
    expect(find.text('Total Balance'), findsOneWidget);
    expect(rich(r'$12,680.42'), findsOneWidget);
    expect(find.text('Satwik'), findsOneWidget);
    expect(prefs.getString('session_user_id'), 'usr_demo');

    // Notifications → Budget.
    await tap(tester, button('Notifications'));
    expect(find.text('Dining budget at 92%'), findsOneWidget);
    await tap(tester, find.text('Dining budget at 92%'), 1000);
    expect(find.text('Budgets'), findsOneWidget);
    expect(find.text('Budget Agent: Dining at 92%'), findsOneWidget);
    await tap(tester, button('Home'), 1000);

    // Add an expense from Home.
    await tap(tester, find.text('Add Expense'));
    await tester.enterText(find.byType(TextField).at(0), '25');
    await tester.enterText(find.byType(TextField).at(1), 'Test Cafe');
    await tap(tester, find.text('Cafes & Restaurants'));
    await tap(tester, find.text('Save expense'), 1000);
    expect(find.text('Test Cafe'), findsOneWidget);
    expect(rich(r'$12,655.42'), findsOneWidget);
    await wait(tester, 2200); // let the toast clear

    // Wallet → Tap to Pay → switch cards → pay.
    await tap(tester, button('Wallet'), 1000);
    expect(find.text('Smart Wallet'), findsOneWidget);
    expect(find.text('points ≈ \$421.80'), findsOneWidget);
    await tap(tester, find.text('Tap to Pay'), 1000);
    expect(find.text('Hold Near Reader'), findsOneWidget);
    expect(find.text('AI picked your best card'), findsOneWidget);
    await tapStacked(tester, button('Switch to Sapphire Travel'));
    expect(find.text(r'You lose $2.56 vs Gold Dining'), findsOneWidget);
    await tapStacked(tester, button('Switch to Gold Dining'));
    await tap(tester, find.text(r'Pay $64.00 with Face ID'), 2000);
    expect(find.text('Paid at Sushi Zen'), findsOneWidget);
    expect(find.text('+256 points with Gold Dining'), findsOneWidget);
    expect(find.text('Dining budget now at 114%'), findsOneWidget);
    await tap(tester, find.text('Done'), 1000);
    expect(find.text('Sushi Zen'), findsOneWidget);

    // Expenses → View All → Budgets reflect both purchases.
    await tap(tester, button('Expenses'), 1000);
    expect(rich(r'$1,931.56'), findsOneWidget);
    await tap(tester, find.text('View All'), 1000);
    expect(find.text('Budgets'), findsOneWidget);
    expect(rich(r'$457 / $400'), findsOneWidget);

    // Card picker from the Home nudge: Travel favours Sapphire.
    await tap(tester, button('Home'), 1000);
    await tap(tester, find.text('You missed \$14.80 in rewards'), 1000);
    expect(find.text('Best Card Picker'), findsOneWidget);
    expect(find.text('Pay with Gold Dining'), findsOneWidget);
    await tap(tester, find.text('Travel'));
    expect(find.text('Pay with Sapphire Travel'), findsOneWidget);
    await tap(tester, button('Back'), 1000);

    // Insights → Apply suggestion.
    await tap(tester, button('Insights'), 1000);
    expect(find.text('AI Insights'), findsOneWidget);
    await tap(tester, find.text('Apply'));
    expect(find.text('Applied'), findsOneWidget);

    // Agents → toggle → create a custom agent.
    await tap(tester, button('AI Agents'), 1000);
    expect(
      find.text('5 active · 23 tasks automated this month'),
      findsOneWidget,
    );
    final billToggle = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'Toggle Bill Reminder',
    );
    await tap(tester, billToggle);
    expect(
      find.text('6 active · 23 tasks automated this month'),
      findsOneWidget,
    );
    await tap(tester, find.text('Create Custom Agent'), 1000);
    await tester.enterText(find.byType(TextField).first, 'Trip Guard');
    await tap(tester, find.text('Daily'));
    await tap(tester, find.text('Launch Agent'), 1000);
    expect(find.text('Trip Guard'), findsOneWidget);
    expect(find.text('Custom · daily alerts'), findsOneWidget);
    expect(
      find.text('7 active · 23 tasks automated this month'),
      findsOneWidget,
    );

    // Assistant: quick reply and a typed question.
    await wait(tester, 2200);
    await tap(tester, find.text('Ask AI'), 1000);
    expect(find.text('FinSight AI'), findsOneWidget);
    await tap(tester, find.text(r'Yes, move $30'), 1500);
    expect(find.textContaining('I moved', findRichText: true), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).last,
      'Where did I overspend?',
    );
    await tap(tester, button('Send'), 1500);
    expect(
      find.textContaining('Weekend delivery', findRichText: true),
      findsOneWidget,
    );
    await tap(tester, button('Back'), 1000);

    // Subscriptions via the Subscription Agent → cancel the unused gym.
    await tap(tester, find.text('Subscription Agent'), 1000);
    expect(find.text('Gym Pass unused for 41 days'), findsOneWidget);
    await tap(tester, find.text('Review'));
    await tap(tester, find.text('Cancel subscription'), 1000);
    expect(find.text(r'7 active · $1,235 per year'), findsOneWidget);
    await wait(tester, 2200);

    // Savings via Home's Transfer button → add money.
    await tap(tester, button('Home'), 1000);
    await tap(tester, button('Transfer'), 1000);
    expect(find.text('Savings Goals'), findsOneWidget);
    expect(find.text(r'$3,240'), findsOneWidget);
    await tap(tester, find.text('Add Money'));
    await tap(tester, find.text('Add money'), 1000);
    expect(find.text(r'$3,340'), findsOneWidget);
    await tap(tester, find.text('Emergency Fund'));
    expect(find.text(r'$9,200'), findsOneWidget);
    await wait(tester, 2200);
    await tap(tester, button('Back'), 1000);

    // Sign out returns to Welcome and forgets the session.
    await tap(tester, button('Account'));
    await tap(tester, find.text('Sign out'), 1000);
    expect(find.text('Get Started'), findsOneWidget);
    expect(prefs.getString('session_user_id'), isNull);
  });
}
