import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-type notification toggle preferences using SharedPreferences.
class NotificationPreferencesService {
  static const _kPush         = 'notif_push';
  static const _kBids         = 'notif_bids';
  static const _kAppointments = 'notif_appointments';
  static const _kMessages     = 'notif_messages';

  // Singleton
  static final NotificationPreferencesService _instance =
      NotificationPreferencesService._();
  factory NotificationPreferencesService() => _instance;
  NotificationPreferencesService._();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<NotificationPrefs> load() async {
    final p = await _prefs;
    return NotificationPrefs(
      push:         p.getBool(_kPush)         ?? true,
      bids:         p.getBool(_kBids)         ?? true,
      appointments: p.getBool(_kAppointments) ?? true,
      messages:     p.getBool(_kMessages)     ?? true,
    );
  }

  Future<void> save(NotificationPrefs prefs) async {
    final p = await _prefs;
    await p.setBool(_kPush,         prefs.push);
    await p.setBool(_kBids,         prefs.bids);
    await p.setBool(_kAppointments, prefs.appointments);
    await p.setBool(_kMessages,     prefs.messages);
  }
}

class NotificationPrefs {
  final bool push;
  final bool bids;
  final bool appointments;
  final bool messages;

  const NotificationPrefs({
    required this.push,
    required this.bids,
    required this.appointments,
    required this.messages,
  });

  NotificationPrefs copyWith({
    bool? push,
    bool? bids,
    bool? appointments,
    bool? messages,
  }) =>
      NotificationPrefs(
        push:         push         ?? this.push,
        bids:         bids         ?? this.bids,
        appointments: appointments ?? this.appointments,
        messages:     messages     ?? this.messages,
      );
}
