/// A FinSight account. The MVP ships one demo account in
/// `assets/data/users.json`; there is no backend.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
  );

  final String id;
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
}

/// A row in the notifications sheet; [route] is the screen it opens.
class AppNotification {
  const AppNotification({
    required this.icon,
    required this.title,
    required this.body,
    required this.route,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        icon: json['icon'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        route: json['route'] as String,
      );

  final String icon;
  final String title;
  final String body;
  final String route;
}

/// Headline numbers for the home screen.
class Overview {
  const Overview({
    required this.asOf,
    required this.totalBalance,
    required this.balanceChangePct,
    required this.featuredCardId,
    required this.nudgeTitle,
    required this.nudgeBody,
    required this.notifications,
  });

  factory Overview.fromJson(Map<String, dynamic> json) {
    final nudge = json['rewardsNudge'] as Map<String, dynamic>;
    return Overview(
      asOf: DateTime.parse(json['asOf'] as String),
      totalBalance: (json['totalBalance'] as num).toDouble(),
      balanceChangePct: (json['balanceChangePct'] as num).toDouble(),
      featuredCardId: json['featuredCardId'] as String,
      nudgeTitle: nudge['title'] as String,
      nudgeBody: nudge['body'] as String,
      notifications: [
        for (final n in json['notifications'] as List)
          AppNotification.fromJson(n as Map<String, dynamic>),
      ],
    );
  }

  /// The day the static data was captured. The app treats it as "today" so
  /// relative dates ("Today, 18:42", "Renews Mon") always line up.
  final DateTime asOf;
  final double totalBalance;
  final double balanceChangePct;
  final String featuredCardId;
  final String nudgeTitle;
  final String nudgeBody;
  final List<AppNotification> notifications;
}
