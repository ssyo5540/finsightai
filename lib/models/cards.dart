import 'dart:ui';

import '../utils/format.dart';

enum RewardType { points, cashback, none }

/// Colours of a card's artwork: the face gradient, the slanted accent band
/// and the small thumbnail used in lists.
class CardArt {
  const CardArt({
    required this.background,
    required this.accent,
    required this.thumb,
  });

  factory CardArt.fromJson(Map<String, dynamic> json) => CardArt(
    background: _colors(json['background']),
    accent: _colors(json['accent']),
    thumb: _colors(json['thumb']),
  );

  final List<Color> background;
  final List<Color> accent;
  final List<Color> thumb;

  static List<Color> _colors(Object? list) => [
    for (final hex in list as List) hexColor(hex as String),
  ];
}

class PaymentCard {
  const PaymentCard({
    required this.id,
    required this.name,
    required this.last4,
    required this.expiry,
    required this.network,
    required this.isCredit,
    required this.kindLabel,
    required this.perks,
    required this.balance,
    required this.limit,
    required this.rewardType,
    required this.rates,
    required this.art,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) => PaymentCard(
    id: json['id'] as String,
    name: json['name'] as String,
    last4: json['last4'] as String,
    expiry: json['expiry'] as String,
    network: json['network'] as String,
    isCredit: json['isCredit'] as bool,
    kindLabel: json['kindLabel'] as String,
    perks: json['perks'] as String,
    balance: (json['balance'] as num).toDouble(),
    limit: (json['limit'] as num?)?.toDouble(),
    rewardType: RewardType.values.byName(json['rewardType'] as String),
    rates: {
      for (final e in (json['rates'] as Map<String, dynamic>).entries)
        e.key: (e.value as num).toDouble(),
    },
    art: CardArt.fromJson(json['art'] as Map<String, dynamic>),
  );

  final String id;
  final String name;
  final String last4;
  final String expiry;
  final String network;
  final bool isCredit;
  final String kindLabel;
  final String perks;

  /// Outstanding balance for credit cards, available funds for debit.
  final double balance;
  final double? limit;
  final RewardType rewardType;

  /// Points multiplier or cashback percent per reward category; `all`
  /// applies to every category.
  final Map<String, double> rates;
  final CardArt art;

  double rateFor(String category) => rates[category] ?? rates['all'] ?? 0;

  /// `4×` for points cards, `2%` for cashback cards.
  String rateLabel(String category) => switch (rewardType) {
    RewardType.points => '${trimNumber(rateFor(category))}×',
    RewardType.cashback => '${trimNumber(rateFor(category))}%',
    RewardType.none => '0×',
  };
}

/// What a purchase earns on one card.
class RewardQuote {
  const RewardQuote({
    required this.card,
    required this.points,
    required this.value,
  });

  /// Points are worth [pointValue] dollars each; cashback is paid in cash.
  factory RewardQuote.of(
    PaymentCard card,
    String category,
    double amount,
    double pointValue,
  ) {
    final rate = card.rateFor(category);
    return switch (card.rewardType) {
      RewardType.points => RewardQuote(
        card: card,
        points: (amount * rate).round(),
        value: (amount * rate).round() * pointValue,
      ),
      RewardType.cashback => RewardQuote(
        card: card,
        points: 0,
        value: amount * rate / 100,
      ),
      RewardType.none => RewardQuote(card: card, points: 0, value: 0),
    };
  }

  final PaymentCard card;
  final int points;
  final double value;

  /// Short label for a ledger row: `+256 pts`, `+$1.28 back` or the account.
  String get ledgerNote => switch (card.rewardType) {
    RewardType.points => '+${groupThousands(points)} pts',
    RewardType.cashback => '+${money(value)} back',
    RewardType.none => card.isCredit ? card.name : 'Checking',
  };
}

/// Ranks [cards] by reward value for a purchase, best first. Ties go to
/// cashback, which needs no redemption.
List<RewardQuote> rankCards(
  Iterable<PaymentCard> cards,
  String category,
  double amount,
  double pointValue,
) {
  final quotes = [
    for (final card in cards)
      RewardQuote.of(card, category, amount, pointValue),
  ];
  quotes.sort((a, b) {
    final byValue = b.value.compareTo(a.value);
    if (byValue != 0) return byValue;
    return (a.card.rewardType == RewardType.cashback ? 0 : 1).compareTo(
      b.card.rewardType == RewardType.cashback ? 0 : 1,
    );
  });
  return quotes;
}

/// Summary tiles at the top of the wallet.
class WalletStats {
  const WalletStats({
    required this.pointValue,
    required this.utilizationPct,
    required this.utilizationNote,
    required this.rewardsPoints,
    required this.rewardsValue,
    required this.rewardsThisMonth,
  });

  factory WalletStats.fromJson(Map<String, dynamic> json) => WalletStats(
    pointValue: (json['pointValue'] as num).toDouble(),
    utilizationPct: (json['utilizationPct'] as num).toDouble(),
    utilizationNote: json['utilizationNote'] as String,
    rewardsPoints: json['rewardsPoints'] as int,
    rewardsValue: (json['rewardsValue'] as num).toDouble(),
    rewardsThisMonth: json['rewardsThisMonth'] as int,
  );

  /// Dollar value of one reward point.
  final double pointValue;
  final double utilizationPct;
  final String utilizationNote;
  final int rewardsPoints;

  /// Cash value of [rewardsPoints] at the statement-credit rate.
  final double rewardsValue;
  final int rewardsThisMonth;
}
