import 'dart:math';
import 'package:flutter/material.dart';

showSideSheet({
  BuildContext context,
  Widget Function(BuildContext) builder,
  bool rightSide = true,
}) {
  showGeneralDialog(
    barrierLabel: "Sheet Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    context: context,
    pageBuilder: (context, animation1, animation2) {
      final sheetWidth = min(320.0, MediaQuery.of(context).size.width - 56);

      return Align(
        alignment: (rightSide ? Alignment.centerRight : Alignment.centerLeft),
        child: SizedBox(
          height: double.infinity,
          width: sheetWidth,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: builder(context),
          ),
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 200),
    transitionBuilder: (context, animation1, animation2, child) {
      // TODO: Ease transition
      return SlideTransition(
        position: Tween(
          begin: Offset((rightSide ? 1 : -1), 0),
          end: Offset(0, 0),
        ).animate(animation1),
        child: child,
      );
    },
  );
}
