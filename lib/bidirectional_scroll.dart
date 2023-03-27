import 'dart:async';
import 'dart:math';
import 'package:bidirectional_scroll/src/measure_size.dart';
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
    return LayoutBuilder(builder: (ctx, constraint) {
      controller.viewportSize = Size(constraint.maxWidth, constraint.maxHeight);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
              left: controller.position.dx,
              top: controller.position.dy,
              child: MeasureSize(
                  onChange: (value) {
                    controller.contentSize = value;
                  },
                  child: widget.child)),
          ...widget.children,
        ],
      );
    });
  }
}

class DesktopScrollWatcher extends StatefulWidget {
  final BidirectionalScrollController controller;

  const DesktopScrollWatcher({required this.controller, Key? key})
      : super(key: key);

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

          if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
            controller.scrollUp();
          } else if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
            controller.scrollDown();
          } else if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
            controller.scrollLeft();
          } else if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
            controller.scrollRight();
          } else if (value.logicalKey == LogicalKeyboardKey.pageUp) {
            if (_isShiftKeyPressed) {
              controller.pageLeft();
            } else {
              controller.pageUp();
            }
          } else if (value.logicalKey == LogicalKeyboardKey.pageDown) {
            if (_isShiftKeyPressed) {
              controller.pageRight();
            } else {
              controller.pageDown();
            }
          } else if (value.logicalKey == LogicalKeyboardKey.home) {
            if (_isShiftKeyPressed) {
              controller.scrollBegin();
            } else {
              controller.scrollTop();
            }
          } else if (value.logicalKey == LogicalKeyboardKey.end) {
            if (_isShiftKeyPressed) {
              controller.scrollEnd();
            } else {
              controller.scrollBottom();
            }
          }
        },
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              if (event.scrollDelta.dy.isNegative) {
                if (_isShiftKeyPressed) {
                  controller.scrollLeft();
                } else {
                  controller.scrollUp();
                }
              } else {
                if (_isShiftKeyPressed) {
                  controller.scrollRight();
                } else {
                  controller.scrollDown();
                }
              }
            }
          },
          onPointerDown: (event) {
            _focusNode.requestFocus();
            _panTracker =
                _PanTracker(anchor: controller.position, start: event.position);
          },
          onPointerMove: (event) {
            if (event.down && _panTracker != null) {
              controller.animateTo(
                  _panTracker!.anchor + (event.position - _panTracker!.start));
            }
          },
          onPointerUp: (event) {
            _panTracker = null;
          },
        ),
      ),
    );
  }

  _PanTracker? _panTracker;
}

class _PanTracker {
  final Offset anchor;
  final Offset start;
  _PanTracker({required this.anchor, required this.start});
}

class BidirectionalScrollController {
  var _position = const Offset(0, 0);

  var _viewportSize = const Size(0, 0);

  var _contentSize = const Size(0, 0);

  final _controller = StreamController<Offset>();

  var delta = const Point<double>(50, 50);

  late final Stream<Offset> stream = _controller.stream;

  _Tracker? _tracker;

  BidirectionalScrollController({this.delta = const Point<double>(50, 50)});

  Offset get position => _position;

  Size get viewportSize => _viewportSize;

  Size get contentSize => _contentSize;

  set viewportSize(Size value) {
    _viewportSize = value;
    _setPosition(_position);
  }

  set contentSize(Size value) {
    _contentSize = value;
    _setPosition(_position);
  }

  void _setPosition(Offset newPosition) {
    newPosition = _clampOffset(
        newPosition,
        Offset(viewportSize.width - contentSize.width,
            viewportSize.height - contentSize.height));
    if (newPosition == position) return;
    _position = newPosition;
    _controller.add(newPosition);
  }

  void jumpTo(Offset newPosition) {
    _tracker?.cancel();
    _tracker = null;
    _setPosition(newPosition);
  }

  void animateTo(Offset newPosition) {
    _tracker?.cancel();
    newPosition = _clampOffset(
        newPosition,
        Offset(viewportSize.width - contentSize.width,
            viewportSize.height - contentSize.height));
    if (newPosition == position) return;
    _tracker = _Tracker(
      start: _position,
      target: newPosition,
      callback: (pos) {
        _setPosition(pos);
      },
    );
  }

  void scrollTop() {
    animateTo(Offset(position.dx, 0));
  }

  void scrollBottom() {
    animateTo(Offset(position.dx, viewportSize.height - contentSize.height));
  }

  void scrollBegin() {
    animateTo(Offset(0, position.dy));
  }

  void scrollEnd() {
    animateTo(Offset(viewportSize.width - contentSize.width, position.dy));
  }

  void scrollUp({double? amount}) {
    amount ??= delta.y;
    double newY = position.dy + amount;
    animateTo(Offset(position.dx, newY));
  }

  void scrollDown({double? amount}) {
    amount ??= delta.y;
    double newY = position.dy - amount;
    animateTo(Offset(position.dx, newY));
  }

  void scrollLeft({double? amount}) {
    amount ??= delta.x;
    double newX = position.dx + amount;
    animateTo(Offset(newX, position.dy));
  }

  void scrollRight({double? amount}) {
    amount ??= delta.y;
    double newX = position.dx - amount;
    animateTo(Offset(newX, position.dy));
  }

  void pageUp() {
    scrollUp(amount: viewportSize.height);
  }

  void pageDown() {
    scrollDown(amount: viewportSize.height);
  }

  void pageLeft() {
    scrollLeft(amount: viewportSize.width);
  }

  void pageRight() {
    scrollRight(amount: viewportSize.width);
  }

  void dispose() {
    _tracker?.cancel();
    _controller.close();
  }
}

double _clamp(double value, double threshold) {
  if (value > 0) {
    return 0;
  }
  if (value < threshold) {
    return threshold;
  }
  return value;
}

Offset _clampOffset(Offset value, Offset threshold) {
  return Offset(_clamp(value.dx, threshold.dx), _clamp(value.dy, threshold.dy));
}

class _Tracker {
  final Offset start;
  final Offset target;
  late final Timer timer;
  final void Function(Offset position) callback;

  _Tracker(
      {required this.start, required this.target, required this.callback}) {
    final distance = (start - target).distance;
    timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final pos =
          Offset.lerp(start, target, min(timer.tick / (distance / 25), 1))!;
      // print('${timer.tick/(distance/25)} $start $target $pos');
      callback(pos);
      if (pos == target) {
        timer.cancel();
      }
    });
  }

  void cancel() {
    timer.cancel();
  }
}
