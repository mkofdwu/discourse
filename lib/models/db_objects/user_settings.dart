class UserSettings {
  bool enableNotifications;
  // if null, show to all friends. If string, show to friend list of that id
  String? showStoryTo;
  bool publicAccount;

  UserSettings({
    required this.enableNotifications,
    required this.showStoryTo,
    required this.publicAccount,
  });

  factory UserSettings.defaultSettings() {
    return UserSettings(
      enableNotifications: true,
      showStoryTo: null,
      publicAccount: true, // for now to let everyone find each other
    );
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      enableNotifications: map['enableNotifications'],
      showStoryTo: map['showStoryTo'],
      publicAccount: map['publicAccount'],
    );
  }

  Map<String, dynamic> toMap() => {
        'enableNotifications': enableNotifications,
        'showStoryTo': showStoryTo,
        'publicAccount': publicAccount,
      };
}
