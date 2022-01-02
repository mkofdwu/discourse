import 'dart:math';
import 'dart:ui';

import 'package:discourse/models/user.dart';

enum ParticipantRole { member, admin, owner, removed }

class Participant {
  DiscourseUser user;
  Color color;
  ParticipantRole role;

  Participant({
    required this.user,
    required this.color,
    required this.role,
  });

  static const _colors = <Color>[
    Color(0xFF2C1ED0),
    Color(0xFF3978D6),
    Color(0xFF31C57E),
    Color(0xFF12A432),
    Color(0xFFD3DD5F),
    Color(0xFFDAAB06),
    Color(0xFFD1682D),
    Color(0xFFD63939),
    Color(0xFFC039D6),
  ];

  // temporary function, in the future come up with a predefined list of colors
  static Color _randomColor() => _colors[Random().nextInt(_colors.length)];

  factory Participant.create(
    DiscourseUser user, {
    role = ParticipantRole.member,
  }) {
    return Participant(
      user: user,
      color: _randomColor(),
      role: role,
    );
  }

  factory Participant.removed(DiscourseUser user) {
    return Participant(
      user: user,
      color: Color(0xFFDDDDDD),
      role: ParticipantRole.removed,
    );
  }

  Map<String, dynamic> toData() {
    return {
      'userId': user.id,
      'color': color.value,
      'role': ParticipantRole.values.indexOf(role),
    };
  }
}
