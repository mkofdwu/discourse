import 'package:flutter/material.dart';

// for some reason cannot use generics here, so using dynamic
class ListAnimationController {
  final key = GlobalKey<AnimatedListState>();

  Widget Function(int, dynamic)? listTileBuilder;

  void animateInsert(int index) {
    key.currentState!.insertItem(index);
  }

  void animateRemove(int index, dynamic item) {
    key.currentState!.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: listTileBuilder!(index, item),
        ),
      ),
    );
  }
}

class MyAnimatedList extends StatefulWidget {
  final ListAnimationController controller;
  final List initialList;
  final Widget Function(int, dynamic) listTileBuilder;

  const MyAnimatedList({
    Key? key,
    required this.controller,
    required this.initialList,
    required this.listTileBuilder,
  }) : super(key: key);

  @override
  State<MyAnimatedList> createState() => _MyAnimatedListState();
}

class _MyAnimatedListState<T> extends State<MyAnimatedList> {
  @override
  void initState() {
    super.initState();
    widget.controller.listTileBuilder = widget.listTileBuilder;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: widget.controller.key,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      initialItemCount: widget.initialList.length,
      itemBuilder: (context, i, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(
            opacity: animation,
            child: widget.listTileBuilder(i, widget.initialList[i]),
          ),
        );
      },
    );
  }
}