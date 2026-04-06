class NotificationSettingsModel {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool sound;
  final bool vibration;

  final bool newAnswers;
  final bool votes;
  final bool bestAnswer;


  final bool quietHoursEnabled;
  final String quietStart;
  final String quietEnd;

  NotificationSettingsModel({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.sound,
    required this.vibration,
    required this.newAnswers,
    required this.votes,
    required this.bestAnswer,
    required this.quietHoursEnabled,
    required this.quietStart,
    required this.quietEnd,
  });

  factory NotificationSettingsModel.defaultSettings() {
    return NotificationSettingsModel(
      pushEnabled: true,
      emailEnabled: false,
      sound: true,
      vibration: true,
      newAnswers: true,
      votes: true,
      bestAnswer: true,
      quietHoursEnabled: false,
      quietStart: '22:00',
      quietEnd: '07:00',
    );
  }

  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsModel(
      pushEnabled: map['pushEnabled'] ?? true,
      emailEnabled: map['emailEnabled'] ?? false,
      sound: map['sound'] ?? true,
      vibration: map['vibration'] ?? true,
      newAnswers: map['newAnswers'] ?? true,
      votes: map['votes'] ?? true,
      bestAnswer: map['bestAnswer'] ?? true,
      quietHoursEnabled: map['quietHoursEnabled'] ?? false,
      quietStart: map['quietStart'] ?? '22:00',
      quietEnd: map['quietEnd'] ?? '07:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'sound': sound,
      'vibration': vibration,
      'newAnswers': newAnswers,
      'votes': votes,
      'bestAnswer': bestAnswer,
      'quietHoursEnabled': quietHoursEnabled,
      'quietStart': quietStart,
      'quietEnd': quietEnd,
    };
  }

  NotificationSettingsModel copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? sound,
    bool? vibration,
    bool? newAnswers,
    bool? votes,
    bool? bestAnswer,
    bool? quietHoursEnabled,
    String? quietStart,
    String? quietEnd,
  }) {
    return NotificationSettingsModel(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      newAnswers: newAnswers ?? this.newAnswers,
      votes: votes ?? this.votes,
      bestAnswer: bestAnswer ?? this.bestAnswer,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
    );
  }
}