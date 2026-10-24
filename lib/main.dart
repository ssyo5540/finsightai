import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_state.dart';
import 'data/finsight_repository.dart';
import 'router.dart';
import 'theme.dart';

/// Entry point of FinSight AI. Loads the bundled JSON data, restores the
/// signed-in demo account if there is one, and starts the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final data = await FinSightRepository(rootBundle).load();
  final prefs = await SharedPreferences.getInstance();
  final state = AppState(data: data, prefs: prefs)..restoreSession();
  runApp(FinSightApp(state: state));
}

/// Root widget: shares [AppState] with every screen and opens Home when a
/// session exists, otherwise the Welcome screen.
class FinSightApp extends StatelessWidget {
  const FinSightApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'FinSight',
        debugShowCheckedModeBanner: false,
        theme: buildFinSightTheme(),
        initialRoute: state.isSignedIn ? Routes.home : Routes.welcome,
        // One initial route only; the default would also push "/" under
        // "/home" because route names are split on slashes.
        onGenerateInitialRoutes: (name) => [
          AppRouter.onGenerateRoute(RouteSettings(name: name))!,
        ],
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
