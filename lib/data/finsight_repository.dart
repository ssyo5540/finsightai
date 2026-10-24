import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/account.dart';
import '../models/ai.dart';
import '../models/cards.dart';
import '../models/finance.dart';
import '../models/payment.dart';

/// Everything the app shows, parsed from the JSON files in `assets/data`.
/// This MVP has no backend, so this is the single source of data.
class FinSightData {
  const FinSightData({
    required this.users,
    required this.overview,
    required this.walletStats,
    required this.cards,
    required this.transactions,
    required this.expenses,
    required this.budgets,
    required this.subscriptions,
    required this.unusedAlertDays,
    required this.goals,
    required this.insights,
    required this.tasksAutomated,
    required this.agents,
    required this.agentBuilder,
    required this.assistant,
    required this.payment,
  });

  final List<AppUser> users;
  final Overview overview;
  final WalletStats walletStats;
  final List<PaymentCard> cards;
  final List<Transaction> transactions;
  final ExpenseSummary expenses;
  final BudgetPlan budgets;
  final List<Subscription> subscriptions;

  /// A subscription unused for this many days gets a cancel suggestion.
  final int unusedAlertDays;
  final List<SavingsGoal> goals;
  final InsightsData insights;
  final int tasksAutomated;
  final List<Agent> agents;
  final AgentBuilderDefaults agentBuilder;
  final AssistantScript assistant;
  final PendingPayment payment;
}

/// Reads the static JSON files bundled with the app.
class FinSightRepository {
  const FinSightRepository(this._bundle);

  final AssetBundle _bundle;

  Future<Map<String, dynamic>> _read(String name) async {
    final text = await _bundle.loadString('assets/data/$name.json');
    return jsonDecode(text) as Map<String, dynamic>;
  }

  Future<FinSightData> load() async {
    final files = await Future.wait([
      _read('users'),
      _read('overview'),
      _read('cards'),
      _read('transactions'),
      _read('expenses'),
      _read('budgets'),
      _read('subscriptions'),
      _read('savings'),
      _read('insights'),
      _read('agents'),
      _read('assistant'),
      _read('payment'),
    ]);
    final [
      users,
      overview,
      cards,
      transactions,
      expenses,
      budgets,
      subscriptions,
      savings,
      insights,
      agents,
      assistant,
      payment,
    ] = files;

    return FinSightData(
      users: [
        for (final u in users['users'] as List)
          AppUser.fromJson(u as Map<String, dynamic>),
      ],
      overview: Overview.fromJson(overview),
      walletStats: WalletStats.fromJson(cards),
      cards: [
        for (final c in cards['cards'] as List)
          PaymentCard.fromJson(c as Map<String, dynamic>),
      ],
      transactions: [
        for (final t in transactions['transactions'] as List)
          Transaction.fromJson(t as Map<String, dynamic>),
      ],
      expenses: ExpenseSummary.fromJson(expenses),
      budgets: BudgetPlan.fromJson(budgets),
      subscriptions: [
        for (final s in subscriptions['subscriptions'] as List)
          Subscription.fromJson(s as Map<String, dynamic>),
      ],
      unusedAlertDays: subscriptions['unusedAlertDays'] as int,
      goals: [
        for (final g in savings['goals'] as List)
          SavingsGoal.fromJson(g as Map<String, dynamic>),
      ],
      insights: InsightsData.fromJson(insights),
      tasksAutomated: agents['tasksAutomated'] as int,
      agents: [
        for (final a in agents['agents'] as List)
          Agent.fromJson(a as Map<String, dynamic>),
      ],
      agentBuilder: AgentBuilderDefaults.fromJson(
        agents['builder'] as Map<String, dynamic>,
      ),
      assistant: AssistantScript.fromJson(assistant),
      payment: PendingPayment.fromJson(payment),
    );
  }
}
