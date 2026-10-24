import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../router.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'common.dart';
import 'fs_icon.dart';

/// Opens [child] in the rounded white sheet used for every modal in the app.
Future<T?> showFinSightSheet<T>(BuildContext context, Widget child) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    barrierColor: const Color(0x66140500),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Brand.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}

/// Text field styled like the design's inputs (white, hairline border).
class SheetField extends StatelessWidget {
  const SheetField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.autofocus = false,
    this.prefix,
    this.large = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final String? prefix;

  /// Big amount entry.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final textStyle = large
        ? inter(34, weight: FontWeight.w500, spacing: -1.2, color: Brand.ink)
        : inter(15, color: Brand.ink);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: inter(12, color: Brand.muted)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Brand.border),
          ),
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: textStyle,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: textStyle.copyWith(color: Brand.faint),
              prefixText: prefix,
              prefixStyle: textStyle.copyWith(color: Brand.faint),
              contentPadding: EdgeInsets.symmetric(vertical: large ? 10 : 14),
            ),
          ),
        ),
      ],
    );
  }
}

/// Black or outlined chip used to pick one option.
class ChoiceChipPill extends StatelessWidget {
  const ChoiceChipPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      selected: selected,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? Brand.ink : Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: selected ? Brand.ink : Brand.border),
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
            label,
            style: inter(
              13,
              weight: FontWeight.w500,
              color: selected ? Colors.white : Brand.ink,
            ),
          ),
        ),
      ),
    );
  }
}

final _amountFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'^\d*\.?\d{0,2}'),
);

/// "Add Income" / "Add Expense" form. Saves into [AppState].
class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key, required this.income});

  final bool income;

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amount = TextEditingController();
  final _merchant = TextEditingController();
  String? _categoryId;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _merchant.dispose();
    super.dispose();
  }

  void _save() {
    final state = AppScope.read(context);
    final amount = double.tryParse(_amount.text) ?? 0;
    final categories = state.expenseCategories;
    if (amount <= 0) {
      setState(() => _error = 'Enter an amount above \$0.');
      return;
    }
    if (_merchant.text.trim().isEmpty) {
      setState(
        () => _error = widget.income
            ? 'Add where the money came from.'
            : 'Add where you spent it.',
      );
      return;
    }
    if (!widget.income && _categoryId == null) {
      setState(() => _error = 'Pick a category.');
      return;
    }
    final category = widget.income
        ? 'Income'
        : categories.firstWhere((c) => c.id == _categoryId).name;
    state.addTransaction(
      merchant: _merchant.text,
      category: category,
      expenseCategoryId: widget.income ? null : _categoryId,
      amount: widget.income ? amount : -amount,
      note: 'Checking',
    );
    Navigator.of(
      context,
    ).pop('${widget.income ? 'Income' : 'Expense'} of ${money(amount)} added');
  }

  @override
  Widget build(BuildContext context) {
    final categories = AppScope.of(context).expenseCategories;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.income ? 'Add Income' : 'Add Expense',
          style: inter(22, weight: FontWeight.w600, spacing: -0.6),
        ),
        const SizedBox(height: 16),
        SheetField(
          controller: _amount,
          label: 'Amount',
          hint: '0.00',
          prefix: '\$',
          large: true,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_amountFormatter],
        ),
        const SizedBox(height: 12),
        SheetField(
          controller: _merchant,
          label: widget.income ? 'From' : 'Merchant',
          hint: widget.income
              ? 'e.g. Acme Corp Payroll'
              : 'e.g. Whole Foods Market',
        ),
        if (!widget.income) ...[
          const SizedBox(height: 14),
          Text('Category', style: inter(12, color: Brand.muted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in categories)
                ChoiceChipPill(
                  label: c.name,
                  selected: _categoryId == c.id,
                  onTap: () => setState(() => _categoryId = c.id),
                ),
            ],
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: inter(13, weight: FontWeight.w500, color: Brand.rust),
          ),
        ],
        const SizedBox(height: 18),
        PillButton(
          label: widget.income ? 'Save income' : 'Save expense',
          onTap: _save,
          height: 52,
        ),
      ],
    );
  }
}

/// Opens [AddTransactionSheet] and confirms with a toast once saved.
Future<void> openAddTransaction(
  BuildContext context, {
  required bool income,
}) async {
  final message = await showFinSightSheet<String>(
    context,
    AddTransactionSheet(income: income),
  );
  if (message != null && context.mounted) showToast(context, message);
}

/// The bell on Home: agent alerts that link to their screens.
class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = AppScope.of(context).data.overview.notifications;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Notifications',
          style: inter(22, weight: FontWeight.w600, spacing: -0.6),
        ),
        const SizedBox(height: 8),
        for (final n in notifications)
          Tappable(
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.pushNamed(n.route);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Brand.peach,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: FsIcon(
                      FsIcons.byName(n.icon),
                      size: 18,
                      color: Brand.rust,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: inter(14, weight: FontWeight.w600),
                        ),
                        Text(n.body, style: inter(12, color: Brand.muted)),
                      ],
                    ),
                  ),
                  const FsIcon(
                    FsIcons.chevronRight,
                    size: 16,
                    color: Brand.rust,
                    strokeWidth: 2,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Account sheet behind the Home avatar, with sign-out.
class ProfileSheet extends StatelessWidget {
  const ProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.user;
    if (user == null) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD2B0), Color(0xFFF4A06A)],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            user.initials,
            style: inter(
              20,
              weight: FontWeight.w600,
              color: const Color(0xFF6E1D08),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.fullName,
          style: inter(20, weight: FontWeight.w600, spacing: -0.4),
        ),
        const SizedBox(height: 2),
        Text(user.email, style: inter(13, color: Brand.muted)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Brand.canvas,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const FsIcon(FsIcons.shield, size: 18, color: Brand.rust),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Demo account. Data comes from the app bundle and changes stay on this device until you sign out.',
                  style: inter(12, color: Brand.mutedWarm, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PillButton(
          label: 'Sign out',
          icon: FsIcons.logOut,
          height: 52,
          onTap: () async {
            // Leave the signed-in screens before the session is cleared so
            // nothing rebuilds without a user.
            Navigator.of(context)
                .pushNamedAndRemoveUntil(Routes.welcome, (_) => false);
            await state.signOut();
          },
        ),
      ],
    );
  }
}

/// Picks an amount to move into a savings goal.
class AddMoneySheet extends StatefulWidget {
  const AddMoneySheet({super.key, required this.goalName});

  final String goalName;

  @override
  State<AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<AddMoneySheet> {
  final _amount = TextEditingController(text: '100');

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add to ${widget.goalName}',
          style: inter(22, weight: FontWeight.w600, spacing: -0.6),
        ),
        const SizedBox(height: 4),
        Text(
          'Moves money from Checking.',
          style: inter(13, color: Brand.muted),
        ),
        const SizedBox(height: 16),
        SheetField(
          controller: _amount,
          label: 'Amount',
          prefix: '\$',
          large: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_amountFormatter],
        ),
        const SizedBox(height: 12),
        Row(
          spacing: 8,
          children: [
            for (final preset in const [50, 100, 250])
              ChoiceChipPill(
                label: '\$$preset',
                selected: _amount.text == '$preset',
                onTap: () => setState(() => _amount.text = '$preset'),
              ),
          ],
        ),
        const SizedBox(height: 18),
        PillButton(
          label: 'Add money',
          height: 52,
          onTap: () {
            final amount = double.tryParse(_amount.text) ?? 0;
            if (amount > 0) Navigator.of(context).pop(amount);
          },
        ),
      ],
    );
  }
}
