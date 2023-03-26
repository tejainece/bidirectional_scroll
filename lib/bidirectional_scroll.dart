import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ScrollViewport extends StatefulWidget {
  final List<Widget> children;

  final Widget child;

  final BidirectionalScrollController controller;

  const ScrollViewport(this.child,
      {Key? key, required this.controller, this.children = const []})
      : super(key: key);

  @override
  State<ScrollViewport> createState() => _ScrollViewportState();
}

class _ScrollViewportState extends State<ScrollViewport> {
  late final BidirectionalScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller.stream.listen((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
            left: controller.position.dx,
            top: controller.position.dy,
            child: widget.child),
        ...widget.children,
      ],
    );
  }
}

class DesktopScrollWatcher extends StatefulWidget {
  final BidirectionalScrollController controller;

  const DesktopScrollWatcher({required this.controller, Key? key}) : super(key: key);

  @override
  State<DesktopScrollWatcher> createState() => _DesktopScrollWatcherState();
}

class _DesktopScrollWatcherState extends State<DesktopScrollWatcher> {
  final _focusNode = FocusNode();

  bool _isShiftKeyPressed = false;

  BidirectionalScrollController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (value) {
          _isShiftKeyPressed = value.isShiftPressed;

          if(value.logicalKey == LogicalKeyboardKey.arrowUp) {
            // TODO
          } else if(value.logicalKey == LogicalKeyboardKey.arrowDown) {
            // TODO
          } else if(value.logicalKey == LogicalKeyboardKey.pageUp) {
            // TODO
          } else if(value.logicalKey == LogicalKeyboardKey.pageDown) {
            // TODO
          } else if(value.logicalKey == LogicalKeyboardKey.arrowLeft) {
            // TODO
          } else if(value.logicalKey == LogicalKeyboardKey.arrowRight) {
            // TODO
          } else if(value.logicalKey == LogicalKeyboardKey.home) {
            // TODO
          } else if(value.logicalKey == LogicalKeyboardKey.end) {
            // TODO
          }
        },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              // TODO
              print(event.scrollDelta);
            }
          },
        ),
      ),
    );
  }
}

class BidirectionalScrollController {
  var _position = Offset(0, 0);

  final _controller = StreamController<Offset>();

  late final Stream<Offset> stream = _controller.stream;

  _Tracker? _tracker;

  Offset get position => _position;

  void _setPosition(Offset position) {
    // TODO validate position
    _position = position;
    _controller.add(position);
  }

  void jumpTo(Offset position) {
    _tracker?.cancel();
    _tracker = null;
    _setPosition(position);
  }

  void animateTo(Offset position) {
    _tracker?.cancel();
    _tracker = _Tracker(
      start: _position,
      target: position,
      callback: (pos) {
        _setPosition(pos);
      },
    );
  }

  void dispose() {
    _tracker?.cancel();
    _controller.close();
  }
}

class _Tracker {
  final Offset start;
  final Offset target;
  late final Timer timer;
  final void Function(Offset position) callback;

  _Tracker(
      {required this.start, required this.target, required this.callback}) {
    timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      callback(Offset.lerp(start, target, timer.tick / 20)!);
      if (timer.tick >= 20) {
        timer.cancel();
      }
    });
  }

  void cancel() {
    timer.cancel();
  }
}
