import 'dart:math';
import 'dart:ui';

import 'package:discourse/models/db_objects/user.dart';

enum MemberRole { member, admin, owner, removed }

class Member {
  final DiscourseUser user;
  Color color;
  MemberRole role;

  Member({
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

  factory Member.create(
    DiscourseUser user, {
    role = MemberRole.member,
  }) {
    return Member(
      user: user,
      color: _randomColor(),
      role: role,
    );
  }

  factory Member.removed(DiscourseUser user) {
    return Member(
      user: user,
      color: Color(0xFFDDDDDD),
      role: MemberRole.removed,
    );
  }

  Map<String, dynamic> toData() {
    // user id is the actual doc id
    return {
      'color': color.value,
      'role': role.index,
    };
  }
}
