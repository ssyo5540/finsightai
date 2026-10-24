import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../router.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/fs_icon.dart';
import '../widgets/gradients.dart';
import 'welcome_screen.dart';

/// Sign-in for the demo account. The design has no login screen, so this
/// one reuses the Welcome screen's gradient, glass fields and white pill.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _obscure = true;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await AppScope.read(context)
        .signIn(_email.text, _password.text);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
  }

  /// Fills in the demo account from `users.json`.
  void _useDemo() {
    final demo = AppScope.read(context).data.users.first;
    setState(() {
      _email.text = demo.email;
      _password.text = demo.password;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shift = context.topShift;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: GradientLayers(
            layers: [
              cssGlow(
                const Color(0x73FF9650),
                cx: 0.5,
                cy: 0.22,
                rx: 0.9,
                ry: 0.4,
              ),
              ...WelcomeScreen.background,
            ],
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 54 + shift, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                GlassIconButton(
                                  icon: FsIcons.chevronLeft,
                                  label: 'Back',
                                  onTap: () => AppRouter.back(context),
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 44),
                            Semantics(
                              header: true,
                              child: Text.rich(
                                TextSpan(
                                  style: inter(
                                    40,
                                    weight: FontWeight.w500,
                                    spacing: -1.4,
                                    height: 1.06,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Welcome\n',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: 'back.',
                                      style: TextStyle(color: glass(0.6)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Sign in to see your cards, budgets and AI agents.',
                              style: inter(15, height: 1.5, color: glass(0.88)),
                            ),
                            const SizedBox(height: 32),
                            _GlassField(
                              label: 'Email',
                              icon: FsIcons.mail,
                              controller: _email,
                              hint: 'you@example.com',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.username],
                            ),
                            const SizedBox(height: 14),
                            _GlassField(
                              label: 'Password',
                              icon: FsIcons.lock,
                              controller: _password,
                              hint: 'Your password',
                              obscure: _obscure,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              autofillHints: const [AutofillHints.password],
                              trailing: Tappable(
                                label: _obscure
                                    ? 'Show password'
                                    : 'Hide password',
                                onTap: () =>
                                    setState(() => _obscure = !_obscure),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: FsIcon(
                                    _obscure ? FsIcons.eye : FsIcons.eyeOff,
                                    size: 18,
                                    color: glass(0.85),
                                  ),
                                ),
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Semantics(
                                liveRegion: true,
                                child: Glass(
                                  fill: 0.14,
                                  border: 0.26,
                                  radius: 16,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      const FsIcon(
                                        FsIcons.alert,
                                        size: 16,
                                        color: Color(0xFFFFD08A),
                                        strokeWidth: 2,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _error!,
                                          style: inter(
                                            13,
                                            weight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            const SizedBox(height: 28),
                            PillButton(
                              label: 'Sign In',
                              style: PillStyle.light,
                              height: 56,
                              fontSize: 16,
                              busy: _busy,
                              onTap: _submit,
                            ),
                            const SizedBox(height: 10),
                            Tappable(
                              onTap: _useDemo,
                              child: Glass(
                                height: 50,
                                radius: 25,
                                fill: 0.14,
                                border: 0.3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const FsIcon(
                                      FsIcons.sparkle,
                                      size: 16,
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Use demo account',
                                      style: inter(
                                        15,
                                        weight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'MVP preview: no backend, all data ships with the app.',
                              textAlign: TextAlign.center,
                              style: inter(12, color: glass(0.75)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted input matching the card picker's search field.
class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.trailing,
    this.autofillHints,
  });

  final String label;
  final String icon;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: inter(12, color: glass(0.8))),
        const SizedBox(height: 8),
        Glass(
          height: 52,
          radius: 26,
          blur: 14,
          padding: const EdgeInsets.only(left: 18, right: 8),
          child: Row(
            children: [
              FsIcon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  label: label,
                  textField: true,
                  child: TextField(
                    controller: controller,
                    obscureText: obscure,
                    keyboardType: keyboardType,
                    textInputAction: textInputAction,
                    onSubmitted: onSubmitted,
                    autofillHints: autofillHints,
                    autocorrect: false,
                    enableSuggestions: !obscure,
                    cursorColor: Colors.white,
                    style: inter(
                      15,
                      weight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: inter(15, color: glass(0.55)),
                    ),
                  ),
                ),
              ),
              ?trailing,
              if (trailing == null) const SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }
}
