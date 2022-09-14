import 'package:discourse/constants/palette.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackBarType { info, success, error }

const icons = <SnackBarType, IconData>{
  SnackBarType.info: FluentIcons.info_20_regular,
  SnackBarType.success: FluentIcons.checkmark_20_filled,
  SnackBarType.error: FluentIcons.dismiss_20_filled,
};

const colors = <SnackBarType, Color>{
  SnackBarType.info: Palette.orange,
  SnackBarType.success: Palette.green,
  SnackBarType.error: Palette.red,
};

void showSnackBar({required SnackBarType type, required String message}) {
  Get.rawSnackbar(
    icon: Icon(icons[type]!, size: 20, color: Colors.white),
    shouldIconPulse: false,
    message: message,
    backgroundColor: colors[type]!,
  );
  // Get.rawSnackbar(
  //   backgroundColor: Colors.transparent,
  //   snackPosition: SnackPosition.TOP,
  //   margin: const EdgeInsets.only(top: 28),
  //   messageText: Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.all(6),
  //         decoration: BoxDecoration(
  //           color: Palette.black3,
  //           borderRadius: BorderRadius.circular(30),
  //           border: Border.all(color: Colors.white.withOpacity(0.1)),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.6),
  //               blurRadius: 30,
  //               offset: const Offset(0, 16),
  //             ),
  //           ],
  //         ),
  //         child: Row(
  //           children: [
  //             Container(
  //               width: 36,
  //               height: 36,
  //               decoration: BoxDecoration(
  //                 color: Color(0xff3a3a3a),
  //                 borderRadius: BorderRadius.circular(18),
  //               ),
  //               child: Center(
  //                 child: Icon(
  //                   icons[type],
  //                   size: 20,
  //                   color: colors[type],
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: 12),
  //             Text(
  //               message,
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontFamily: 'Avenir',
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //             SizedBox(width: 14),
  //           ],
  //         ),
  //       ),
  //     ],
  //   ),
  // );
}
