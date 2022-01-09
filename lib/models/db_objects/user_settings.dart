class UserSettings {
  bool enableNotifications;
  // if null, show to all friends. If string, show to friend list of that id
  String? showStoryTo;
  bool publicAccount;
  List<String> blockedIds;

  UserSettings({
    required this.enableNotifications,
    required this.showStoryTo,
    required this.publicAccount,
    required this.blockedIds,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      enableNotifications: map['enableNotifications'],
      showStoryTo: map['showStoryTo'],
      publicAccount: map['publicAccount'],
      blockedIds: List<String>.from(map['blockedIds']),
    );
  }

  Map<String, dynamic> toMap() => {
        'enableNotifications': enableNotifications,
        'showStoryTo': showStoryTo,
        'publicAccount': publicAccount,
        'blockedIds': blockedIds,
      };
}
