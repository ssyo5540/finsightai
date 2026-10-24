import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';
import '../models/ai.dart';
import '../models/cards.dart';
import '../models/finance.dart';
import '../models/payment.dart';
import '../utils/format.dart';
import 'finsight_repository.dart';

/// App-wide state: the signed-in account plus everything the user changes
/// during a session (payments, toggled agents, goal deposits…).
///
/// The JSON files are never written to. Changes live in memory, and signing
/// out resets the demo to the data that ships with the app; only the session
/// itself is remembered between launches.
class AppState extends ChangeNotifier {
  AppState({required this.data, required this._prefs}) {
    _seed();
  }

  final FinSightData data;
  final SharedPreferences _prefs;

  static const _sessionKey = 'session_user_id';

  AppUser? _user;
  AppUser? get user => _user;
  bool get isSignedIn => _user != null;

  late List<Transaction> transactions;
  late List<ExpenseCategory> expenseCategories;
  late List<BudgetCategory> budgets;
  late List<Subscription> subscriptions;
  late List<SavingsGoal> goals;
  late String featuredGoalId;
  late List<Agent> agents;
  late List<ChatMessage> chat;
  late bool suggestionApplied;

  /// Card the user pinned for a reward category in the card picker.
  late Map<String, String> pinnedCards;
  late double _balanceDelta;
  var _nextId = 0;

  void _seed() {
    transactions = [...data.transactions];
    expenseCategories = [...data.expenses.categories];
    budgets = [...data.budgets.categories];
    subscriptions = [...data.subscriptions];
    goals = [...data.goals];
    featuredGoalId = goals.first.id;
    agents = [...data.agents];
    chat = [...data.assistant.conversation];
    suggestionApplied = false;
    pinnedCards = {};
    _balanceDelta = 0;
  }

  // ---------------------------------------------------------------- session

  void restoreSession() {
    final id = _prefs.getString(_sessionKey);
    _user = data.users.where((u) => u.id == id).firstOrNull;
  }

  /// Checks the credentials against `users.json`. Returns an error message,
  /// or null when the user is signed in.
  Future<String?> signIn(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || password.isEmpty) {
      return 'Enter your email and password.';
    }
    final match = data.users
        .where(
          (u) => u.email.toLowerCase() == normalized && u.password == password,
        )
        .firstOrNull;
    if (match == null) return 'Email or password is incorrect.';
    _user = match;
    await _prefs.setString(_sessionKey, match.id);
    notifyListeners();
    return null;
  }

  Future<void> signOut() async {
    _user = null;
    await _prefs.remove(_sessionKey);
    _seed();
    notifyListeners();
  }

  // ------------------------------------------------------------- overview

  /// "Today" in the demo world: the data's as-of date at the current time.
  DateTime now() {
    final asOf = data.overview.asOf;
    final clockNow = DateTime.now();
    return DateTime(
      asOf.year,
      asOf.month,
      asOf.day,
      clockNow.hour,
      clockNow.minute,
    );
  }

  double get totalBalance => data.overview.totalBalance + _balanceDelta;

  PaymentCard cardById(String id) => data.cards.firstWhere((c) => c.id == id);
  PaymentCard get featuredCard => cardById(data.overview.featuredCardId);

  // ------------------------------------------------------------- spending

  double get monthSpent =>
      expenseCategories.fold(0, (sum, c) => sum + c.amount);

  BudgetCategory budgetById(String id) => budgets.firstWhere((b) => b.id == id);

  /// The budget closest to (or furthest over) its limit.
  BudgetCategory get tightestBudget =>
      budgets.reduce((a, b) => b.progress > a.progress ? b : a);

  /// Records spending (negative [amount]) or income (positive) and updates
  /// the balance, the expense breakdown and any matching budget.
  void addTransaction({
    required String merchant,
    required String category,
    required double amount,
    required String note,
    String? expenseCategoryId,
  }) {
    final words = merchant.trim().split(RegExp(r'\s+'));
    final initials = words
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0])
        .join()
        .toUpperCase();
    transactions.insert(
      0,
      Transaction(
        id: 'session_${_nextId++}',
        merchant: merchant.trim(),
        category: category,
        expenseCategoryId: expenseCategoryId,
        amount: amount,
        date: now(),
        note: note,
        avatar: amount > 0
            ? Monogram(
                text: initials,
                background: const Color(0xFFE3F7EA),
                foreground: const Color(0xFF1F7A4D),
              )
            : Monogram(
                text: initials,
                background: const Color(0xFFFFF1E7),
                foreground: const Color(0xFFB8470F),
              ),
      ),
    );
    _balanceDelta += amount;
    if (amount < 0 && expenseCategoryId != null) {
      expenseCategories = [
        for (final c in expenseCategories)
          c.id == expenseCategoryId ? c.copyWith(amount: c.amount - amount) : c,
      ];
      budgets = [
        for (final b in budgets)
          b.expenseCategoryIds.contains(expenseCategoryId)
              ? b.copyWith(spent: b.spent - amount)
              : b,
      ];
    }
    notifyListeners();
  }

  /// Pays the detected merchant with [card] and returns the receipt.
  PaymentReceipt completePayment(PaymentCard card) {
    final payment = data.payment;
    final quote = RewardQuote.of(
      card,
      payment.rewardCategory,
      payment.amount,
      data.walletStats.pointValue,
    );
    addTransaction(
      merchant: payment.merchant,
      category: payment.categoryById(payment.rewardCategory).label,
      expenseCategoryId: payment.expenseCategoryId,
      amount: -payment.amount,
      note: quote.ledgerNote,
    );
    final budget = budgetById(payment.budgetCategoryId);
    return PaymentReceipt(
      merchant: payment.merchant,
      amount: payment.amount,
      quote: quote,
      categoryName: payment.expenseCategoryName,
      budgetName: payment.categoryById(payment.rewardCategory).label,
      budgetProgress: budget.progress,
      budgetOffer: payment.budgetOffer,
    );
  }

  /// Moves [amount] of budget from one category to another.
  void moveBudget(String fromId, String toId, double amount) {
    budgets = [
      for (final b in budgets)
        if (b.id == fromId)
          b.copyWith(limit: b.limit - amount)
        else if (b.id == toId)
          b.copyWith(limit: b.limit + amount)
        else
          b,
    ];
    notifyListeners();
  }

  // -------------------------------------------------------- subscriptions

  double get subscriptionsMonthly =>
      subscriptions.fold(0, (sum, s) => sum + s.price);

  /// Subscriptions sorted by renewal date.
  List<Subscription> get upcomingRenewals =>
      [...subscriptions]..sort((a, b) => a.renewsOn.compareTo(b.renewsOn));

  /// The subscription unused the longest, if any crosses the alert threshold.
  Subscription? get unusedSubscription {
    final unused =
        subscriptions
            .where((s) => (s.lastUsedDaysAgo ?? 0) >= data.unusedAlertDays)
            .toList()
          ..sort((a, b) => b.lastUsedDaysAgo!.compareTo(a.lastUsedDaysAgo!));
    return unused.firstOrNull;
  }

  void cancelSubscription(String id) {
    subscriptions = subscriptions.where((s) => s.id != id).toList();
    notifyListeners();
  }

  // -------------------------------------------------------------- savings

  SavingsGoal get featuredGoal =>
      goals.firstWhere((g) => g.id == featuredGoalId);
  List<SavingsGoal> get otherGoals =>
      goals.where((g) => g.id != featuredGoalId).toList();

  void featureGoal(String id) {
    featuredGoalId = id;
    notifyListeners();
  }

  /// Features the goal after the current one, wrapping around.
  void featureNextGoal() {
    final index = goals.indexWhere((g) => g.id == featuredGoalId);
    featureGoal(goals[(index + 1) % goals.length].id);
  }

  void addToGoal(String id, double amount) {
    goals = [
      for (final g in goals)
        g.id == id ? g.copyWith(saved: g.saved + amount) : g,
    ];
    _balanceDelta -= amount;
    notifyListeners();
  }

  // --------------------------------------------------------------- agents

  int get activeAgents => agents.where((a) => a.enabled).length;

  void toggleAgent(String id) {
    agents = [
      for (final a in agents) a.id == id ? a.copyWith(enabled: !a.enabled) : a,
    ];
    notifyListeners();
  }

  void addAgent({required String name, required String frequency}) {
    agents = [
      ...agents,
      Agent(
        id: 'custom_${_nextId++}',
        name: name.trim(),
        status: frequency == 'Instantly'
            ? 'Custom · instant alerts'
            : 'Custom · ${frequency.toLowerCase()} alerts',
        pausedStatus: 'Paused',
        icon: 'sparkle',
        tile: const Color(0xFF2A1A14),
        ink: const Color(0xFFFFB386),
        enabled: true,
      ),
    ];
    notifyListeners();
  }

  // ------------------------------------------------------- insights, cards

  void applySuggestion() {
    suggestionApplied = true;
    notifyListeners();
  }

  /// Pins [cardId] as the default for [category], or unpins it.
  void togglePinnedCard(String category, String cardId) {
    if (pinnedCards[category] == cardId) {
      pinnedCards.remove(category);
    } else {
      pinnedCards[category] = cardId;
    }
    notifyListeners();
  }

  // ------------------------------------------------------------ assistant

  void addChatMessage(ChatMessage message) {
    chat = [...chat, message];
    notifyListeners();
  }

  /// Answers a quick-reply button: the buttons disappear, the choice shows
  /// as the user's message, and the returned text is the assistant's reply.
  String answerAction(ChatMessage source, ChatAction action) {
    chat = [
      for (final m in chat)
        if (!identical(m, source)) m,
      ChatMessage(fromUser: true, text: action.label),
    ];
    if (action.id == 'move_budget') moveBudget('shopping', 'dining', 30);
    notifyListeners();
    return action.reply.replaceAll(
      '{diningLeft}',
      money(budgetById('dining').left),
    );
  }
}

/// Makes [AppState] available to every screen.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Reads the state without rebuilding when it changes; for callbacks.
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
