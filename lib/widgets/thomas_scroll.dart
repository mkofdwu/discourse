// thomas is a customscrollview that preserves scroll offset at current item
// after adding new items to top/bottom

import 'package:flutter/material.dart';
import 'package:get/get.dart';

T rightIndex<T>(List<T> list, int index) => list[list.length - index - 1];

// copied from scroll_two package
class TopBottomList<T> {
  final _top = <T>[].obs; // top is reversed; in ui it is displayed correctly
  final _bottom = <T>[].obs;

  TopBottomList(List<T> values) {
    _bottom.addAll(values);
  }

  int get length => _top.length + _bottom.length;
  T get first => get(0);
  T get last => _bottom.isEmpty ? _top.first : _bottom.last;
  bool get isEmpty => _top.isEmpty && _bottom.isEmpty;

  void clear() {
    _top.clear();
    _bottom.clear();
  }

  void add(T data) {
    _bottom.add(data);
  }

  void addAll(Iterable<T> iterable) {
    _bottom.addAll(iterable);
  }

  void addTop(T data) {
    _top.add(data);
  }

  void addAllTop(Iterable<T> iterable) {
    // note: if necessary, reverse the list before passing
    _top.addAll(iterable);
  }

  T get(int index) {
    assert(index >= 0 && index < (_top.length + _bottom.length));
    if (index < _top.length) {
      return _top[_top.length - index - 1];
    } else {
      return _bottom[index - _top.length];
    }
  }

  int _topIndexToListIndex(int topIndex) => _top.length - topIndex - 1;

  int _bottomIndexToListIndex(int bottomIndex) => bottomIndex + _top.length;

  T operator [](int index) => get(index);
}

class ReverseThomasScroll<T> extends StatelessWidget {
  final TopBottomList<T> list;
  final Widget Function(BuildContext, int) itemBuilder;
  // other list view parameters
  final ScrollController scrollController;

  const ReverseThomasScroll({
    Key? key,
    required this.list,
    required this.itemBuilder,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const centerKey = ValueKey('second-sliver-list');
    return CustomScrollView(
      controller: scrollController,
      reverse: true,
      center: centerKey,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: SizedBox(height: 80), // hardcoded for message list
        ),
        // because scroll is reversed 'bottom' needs to be higher in the list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return itemBuilder(context, list._bottomIndexToListIndex(index));
            },
            childCount: list._bottom.length,
          ),
        ),
        SliverList(
          key: centerKey,
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return itemBuilder(context, list._topIndexToListIndex(index));
            },
            childCount: list._top.length,
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 40), // hardcoded for message list
        ),
      ],
    );
  }
}
