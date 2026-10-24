import 'dart:ui';

import '../utils/format.dart';

/// A round or rounded badge: either short text (`WF`, `N`) or an icon name,
/// drawn in [foreground] on [background].
class Monogram {
  const Monogram({
    this.text,
    this.icon,
    required this.background,
    required this.foreground,
  });

  factory Monogram.fromJson(Map<String, dynamic> json) => Monogram(
    text: json['text'] as String?,
    icon: json['icon'] as String?,
    background: hexColor(json['bg'] as String),
    foreground: hexColor(json['fg'] as String),
  );

  final String? text;
  final String? icon;
  final Color background;
  final Color foreground;
}

class Transaction {
  const Transaction({
    required this.id,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
    required this.avatar,
    this.expenseCategoryId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    merchant: json['merchant'] as String,
    category: json['category'] as String,
    expenseCategoryId: json['expenseCategoryId'] as String?,
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
    note: json['note'] as String,
    avatar: Monogram.fromJson(json['avatar'] as Map<String, dynamic>),
  );

  final String id;
  final String merchant;

  /// Display label, e.g. `Groceries`.
  final String category;

  /// Which expense bucket this counts towards; null for income.
  final String? expenseCategoryId;

  /// Negative for spending, positive for income.
  final double amount;
  final DateTime date;

  /// Right-hand caption: points earned, cashback or the account used.
  final String note;
  final Monogram avatar;

  bool get isIncome => amount > 0;
}

class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.amount,
    this.icon,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) =>
      ExpenseCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        icon: json['icon'] as String?,
      );

  final String id;
  final String name;
  final double amount;
  final String? icon;

  ExpenseCategory copyWith({double? amount}) => ExpenseCategory(
    id: id,
    name: name,
    amount: amount ?? this.amount,
    icon: icon,
  );
}

class ExpenseSummary {
  const ExpenseSummary({
    required this.month,
    required this.previousMonthName,
    required this.previousMonthTotal,
    required this.categories,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) => ExpenseSummary(
    month: json['month'] as String,
    previousMonthName: json['previousMonthName'] as String,
    previousMonthTotal: (json['previousMonthTotal'] as num).toDouble(),
    categories: [
      for (final c in json['categories'] as List)
        ExpenseCategory.fromJson(c as Map<String, dynamic>),
    ],
  );

  final String month;
  final String previousMonthName;
  final double previousMonthTotal;
  final List<ExpenseCategory> categories;
}

class BudgetCategory {
  const BudgetCategory({
    required this.id,
    required this.name,
    required this.shortName,
    required this.spent,
    required this.limit,
    required this.expenseCategoryIds,
  });

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => BudgetCategory(
    id: json['id'] as String,
    name: json['name'] as String,
    shortName: json['shortName'] as String,
    spent: (json['spent'] as num).toDouble(),
    limit: (json['limit'] as num).toDouble(),
    expenseCategoryIds: [
      for (final id in json['expenseCategoryIds'] as List) id as String,
    ],
  );

  final String id;
  final String name;

  /// Used in agent alerts: "Dining at 92%".
  final String shortName;
  final double spent;
  final double limit;

  /// Expense buckets whose spending also counts against this budget.
  final List<String> expenseCategoryIds;

  double get progress => limit == 0 ? 0 : spent / limit;
  double get left => limit - spent;

  BudgetCategory copyWith({double? spent, double? limit}) => BudgetCategory(
    id: id,
    name: name,
    shortName: shortName,
    spent: spent ?? this.spent,
    limit: limit ?? this.limit,
    expenseCategoryIds: expenseCategoryIds,
  );
}

class BudgetPlan {
  const BudgetPlan({
    required this.month,
    required this.monthlyLimit,
    required this.daysLeft,
    required this.agentAdvice,
    required this.categories,
  });

  factory BudgetPlan.fromJson(Map<String, dynamic> json) => BudgetPlan(
    month: json['month'] as String,
    monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    daysLeft: json['daysLeft'] as int,
    agentAdvice: json['agentAdvice'] as String,
    categories: [
      for (final c in json['categories'] as List)
        BudgetCategory.fromJson(c as Map<String, dynamic>),
    ],
  );

  final String month;
  final double monthlyLimit;
  final int daysLeft;
  final String agentAdvice;
  final List<BudgetCategory> categories;
}

class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.renewsOn,
    required this.logo,
    this.lastUsedDaysAgo,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    renewsOn: DateTime.parse(json['renewsOn'] as String),
    lastUsedDaysAgo: json['lastUsedDaysAgo'] as int?,
    logo: Monogram.fromJson(json['logo'] as Map<String, dynamic>),
  );

  final String id;
  final String name;

  /// Monthly price.
  final double price;
  final DateTime renewsOn;

  /// Days since the service was last used, when the agent tracks it.
  final int? lastUsedDaysAgo;
  final Monogram logo;
}

class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.icon,
    required this.saved,
    required this.target,
    required this.monthly,
    required this.targetDate,
    required this.status,
    required this.highlight,
    required this.tip,
  });

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String,
    saved: (json['saved'] as num).toDouble(),
    target: (json['target'] as num).toDouble(),
    monthly: (json['monthly'] as num).toDouble(),
    targetDate: json['targetDate'] as String,
    status: json['status'] as String,
    highlight: json['highlight'] as bool,
    tip: json['tip'] as String,
  );

  final String id;
  final String name;
  final String icon;
  final double saved;
  final double target;
  final double monthly;
  final String targetDate;
  final String status;

  /// Draws the progress bar in the accent gradient instead of ink.
  final bool highlight;

  /// The Savings Agent's tip shown while this goal is featured.
  final String tip;

  double get progress => target == 0 ? 0 : (saved / target).clamp(0, 1);

  SavingsGoal copyWith({double? saved}) => SavingsGoal(
    id: id,
    name: name,
    icon: icon,
    saved: saved ?? this.saved,
    target: target,
    monthly: monthly,
    targetDate: targetDate,
    status: status,
    highlight: highlight,
    tip: tip,
  );
}
