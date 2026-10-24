import 'package:flutter/material.dart';

import 'models/payment.dart';
import 'screens/agents_screen.dart';
import 'screens/assistant_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/card_picker_screen.dart';
import 'screens/create_agent_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/pay_done_screen.dart';
import 'screens/pay_screen.dart';
import 'screens/savings_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/subscriptions_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/welcome_screen.dart';

abstract final class Routes {
  static const welcome = '/';
  static const signIn = '/sign-in';
  static const home = '/home';
  static const wallet = '/wallet';
  static const cardPicker = '/card-picker';
  static const pay = '/pay';
  static const payDone = '/pay-done';
  static const expenses = '/expenses';
  static const budget = '/budget';
  static const subscriptions = '/subscriptions';
  static const savings = '/savings';
  static const insights = '/insights';
  static const agents = '/agents';
  static const createAgent = '/create-agent';
  static const assistant = '/assistant';
}

/// The five destinations of the floating navigation pill.
enum NavTab {
  home(Routes.home, 'Home'),
  wallet(Routes.wallet, 'Wallet'),
  expenses(Routes.expenses, 'Expenses'),
  agents(Routes.agents, 'AI Agents'),
  insights(Routes.insights, 'Insights');

  const NavTab(this.route, this.label);

  final String route;
  final String label;
}

/// Arguments for [Routes.pay]: which card to start with.
class PayArgs {
  const PayArgs({this.cardId});

  final String? cardId;
}

abstract final class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      Routes.welcome => _fade(settings, const WelcomeScreen()),
      Routes.signIn => _slide(settings, const SignInScreen()),
      Routes.home => _fade(settings, const HomeScreen()),
      Routes.wallet => _slide(settings, const WalletScreen()),
      Routes.cardPicker => _slide(settings, const CardPickerScreen()),
      Routes.pay => _slide(
        settings,
        PayScreen(args: settings.arguments as PayArgs? ?? const PayArgs()),
        fullscreenDialog: true,
      ),
      Routes.payDone => _fade(
        settings,
        PayDoneScreen(receipt: settings.arguments! as PaymentReceipt),
      ),
      Routes.expenses => _slide(settings, const ExpensesScreen()),
      Routes.budget => _slide(settings, const BudgetScreen()),
      Routes.subscriptions => _slide(settings, const SubscriptionsScreen()),
      Routes.savings => _slide(settings, const SavingsScreen()),
      Routes.insights => _slide(settings, const InsightsScreen()),
      Routes.agents => _slide(settings, const AgentsScreen()),
      Routes.createAgent => _slide(settings, const CreateAgentScreen()),
      Routes.assistant => _slide(settings, const AssistantScreen()),
      _ => null,
    };
  }

  static Route<dynamic> _slide(
    RouteSettings settings,
    Widget child, {
    bool fullscreenDialog = false,
  }) {
    return MaterialPageRoute(
      settings: settings,
      fullscreenDialog: fullscreenDialog,
      builder: (_) => child,
    );
  }

  static Route<dynamic> _fade(RouteSettings settings, Widget child) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, _, _) => child,
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  /// Switches to [tab] from the navigation pill: everything above Home is
  /// replaced, so Back from any tab returns to Home. Tapping the tab that is
  /// already open scrolls it back to the top, as on iOS.
  static void openTab(BuildContext context, NavTab tab) {
    final navigator = Navigator.of(context);
    if (ModalRoute.of(context)?.settings.name == tab.route) {
      final scroll = PrimaryScrollController.maybeOf(context);
      if (scroll != null && scroll.hasClients) {
        scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      return;
    }
    bool isHome(Route<dynamic> r) =>
        r.settings.name == Routes.home || r.isFirst;
    if (tab == NavTab.home) {
      navigator.popUntil(isHome);
      return;
    }
    navigator.pushAndRemoveUntil(
      _fade(RouteSettings(name: tab.route), _tabScreen(tab)),
      isHome,
    );
  }

  static Widget _tabScreen(NavTab tab) => switch (tab) {
    NavTab.home => const HomeScreen(),
    NavTab.wallet => const WalletScreen(),
    NavTab.expenses => const ExpensesScreen(),
    NavTab.agents => const AgentsScreen(),
    NavTab.insights => const InsightsScreen(),
  };

  /// Back buttons pop, falling back to Home if the screen was opened first.
  static void back(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(Routes.home);
    }
  }
}
