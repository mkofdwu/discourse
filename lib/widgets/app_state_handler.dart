import 'package:flutter/material.dart';

// use separate socket server?
// to monitor online / last seen state, currently open chat view etc

class AppStateHandler extends StatefulWidget {
  final Widget child;
  final Function() onStart;
  final Function() onExit;

  const AppStateHandler({
    Key? key,
    required this.child,
    required this.onStart,
    required this.onExit,
  }) : super(key: key);

  @override
  _AppStateHandlerState createState() => _AppStateHandlerState();
}

class _AppStateHandlerState extends State<AppStateHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.onExit();
    } else if (state == AppLifecycleState.resumed) {
      widget.onStart();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
