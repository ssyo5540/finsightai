import 'package:finsight_ai/data/finsight_repository.dart';
import 'package:finsight_ai/models/cards.dart';
import 'package:finsight_ai/utils/format.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FinSightData data;

  setUpAll(() async {
    data = await FinSightRepository(rootBundle).load();
  });

  PaymentCard card(String id) => data.cards.firstWhere((c) => c.id == id);

  group('static JSON data', () {
    test('loads every file with the values the design shows', () {
      expect(data.users, hasLength(1));
      expect(data.cards, hasLength(4));
      expect(data.overview.totalBalance, 12680.42);
      expect(data.subscriptions, hasLength(8));
      final subscriptions = data.subscriptions.fold<double>(
        0,
        (s, x) => s + x.price,
      );
      expect(subscriptions, closeTo(142.96, 0.001));
      final spent = data.expenses.categories.fold<double>(
        0,
        (s, c) => s + c.amount,
      );
      expect(spent, closeTo(1842.56, 0.001));
      expect(data.goals.first.name, 'Japan Trip');
      expect(data.agents.where((a) => a.enabled), hasLength(5));
    });
  });

  group('reward maths', () {
    test('matches the card picker for \$64 at a restaurant', () {
      final gold = RewardQuote.of(card('gold'), 'dining', 64, 0.02);
      expect(gold.points, 256);
      expect(gold.value, closeTo(5.12, 0.001));
      expect(
        RewardQuote.of(card('sapphire'), 'dining', 64, 0.02).value,
        closeTo(2.56, 0.001),
      );
      expect(
        RewardQuote.of(card('cash'), 'dining', 64, 0.02).value,
        closeTo(1.28, 0.001),
      );
      expect(RewardQuote.of(card('debit'), 'dining', 64, 0.02).value, 0);
    });

    test('ranks Sapphire first for travel and Gold first for dining', () {
      expect(
        rankCards(data.cards, 'travel', 64, 0.02).first.card.id,
        'sapphire',
      );
      expect(rankCards(data.cards, 'dining', 64, 0.02).first.card.id, 'gold');
    });

    test('labels points and cashback rates', () {
      expect(card('gold').rateLabel('dining'), '4×');
      expect(card('cash').rateLabel('online'), '2%');
    });
  });

  group('formatting', () {
    test('money', () {
      expect(money(1842.56), r'$1,842.56');
      expect(money(-86.4, signed: true), r'-$86.40');
      expect(money(3240, signed: true), r'+$3,240.00');
      expect(money(12000, cents: false), r'$12,000');
      expect(splitMoney(12680.42), (whole: r'$12,680', cents: '.42'));
    });

    test('compact targets', () {
      expect(compactMoney(12000), r'$12k');
      expect(compactMoney(2400), r'$2.4k');
      expect(compactMoney(40000), r'$40k');
    });
  });

  group('assistant script', () {
    test('answers by keyword and falls back otherwise', () {
      expect(
        data.assistant.replyTo('Where did I overspend?'),
        contains('Dining out'),
      );
      expect(
        data.assistant.replyTo('Bills due this week'),
        contains('Netflix'),
      );
      expect(data.assistant.replyTo('hello'), data.assistant.fallback);
    });
  });
}
