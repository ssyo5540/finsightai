import 'cards.dart';

class RewardCategory {
  const RewardCategory({
    required this.id,
    required this.label,
    required this.noun,
  });

  final String id;

  /// Chip label, e.g. `Dining`.
  final String label;

  /// Used in "4× points on restaurants".
  final String noun;
}

/// The purchase the phone has detected nearby (Sushi Zen in the design).
class PendingPayment {
  const PendingPayment({
    required this.merchant,
    required this.merchantType,
    required this.amount,
    required this.rewardCategory,
    required this.expenseCategoryId,
    required this.expenseCategoryName,
    required this.budgetCategoryId,
    required this.budgetOffer,
    required this.rewardCategories,
  });

  factory PendingPayment.fromJson(Map<String, dynamic> json) => PendingPayment(
    merchant: json['merchant'] as String,
    merchantType: json['merchantType'] as String,
    amount: (json['amount'] as num).toDouble(),
    rewardCategory: json['rewardCategory'] as String,
    expenseCategoryId: json['expenseCategoryId'] as String,
    expenseCategoryName: json['expenseCategoryName'] as String,
    budgetCategoryId: json['budgetCategoryId'] as String,
    budgetOffer: json['budgetOffer'] as String,
    rewardCategories: [
      for (final c in json['rewardCategories'] as List)
        RewardCategory(
          id: (c as Map<String, dynamic>)['id'] as String,
          label: c['label'] as String,
          noun: c['noun'] as String,
        ),
    ],
  );

  final String merchant;
  final String merchantType;
  final double amount;
  final String rewardCategory;
  final String expenseCategoryId;
  final String expenseCategoryName;
  final String budgetCategoryId;
  final String budgetOffer;
  final List<RewardCategory> rewardCategories;

  RewardCategory categoryById(String id) =>
      rewardCategories.firstWhere((c) => c.id == id);
}

/// What the payment-complete screen shows.
class PaymentReceipt {
  const PaymentReceipt({
    required this.merchant,
    required this.amount,
    required this.quote,
    required this.categoryName,
    required this.budgetName,
    required this.budgetProgress,
    required this.budgetOffer,
  });

  final String merchant;
  final double amount;
  final RewardQuote quote;
  final String categoryName;
  final String budgetName;

  /// Budget used after this payment, 1.0 = 100 %.
  final double budgetProgress;
  final String budgetOffer;
}
