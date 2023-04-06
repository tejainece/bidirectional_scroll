import 'dart:async';
import 'dart:math';
import 'dart:ui';

class ScrollerController {
  var _position = const Offset(0, 0);

  var _viewportSize = const Size(0, 0);

  var _contentOriginalSize = const Size(0, 0);

  var _contentSize = const Size(0, 0);

  final _controller = StreamController<ScrollerController>.broadcast();

  var scrollDelta = const Offset(50, 50);
  double zoomDelta = 0.1;
  double _scale = 1.0;

  late final Stream<ScrollerController> stream = _controller.stream;

  _Tracker? _tracker;

  ScrollerController({this.scrollDelta = const Offset(50, 50)});

  Offset get position => _position;

  Size get viewportSize => _viewportSize;

  Size get contentSize => _contentSize;

  double get widthProportion => viewportSize.width / contentSize.width;
  double get heightProportion =>
      viewportSize.height / contentSize.height;

  set viewportSize(Size value) {
    if (value == _viewportSize) return;
    _viewportSize = value;
    if (!_setPosition(_position)) {
      _controller.add(this);
    }
  }

  set contentOriginalSize(Size value) {
    _contentOriginalSize = value;
    _contentSize = _contentOriginalSize * scale;
    if (!_setPosition(_position)) {
      _controller.add(this);
    }
  }

  bool _setPosition(Offset newPosition) {
    newPosition = _clampOffset(
        newPosition,
        Offset(viewportSize.width - _contentSize.width,
            viewportSize.height - contentSize.height));
    if (newPosition == position) return false;
    _position = newPosition;
    _controller.add(this);
    return true;
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
    amount ??= scrollDelta.dy;
    double newY = position.dy + amount;
    animateTo(Offset(position.dx, newY));
  }

  void scrollDown({double? amount}) {
    amount ??= scrollDelta.dy;
    double newY = position.dy - amount;
    animateTo(Offset(position.dx, newY));
  }

  void scrollLeft({double? amount}) {
    amount ??= scrollDelta.dx;
    double newX = position.dx + amount;
    animateTo(Offset(newX, position.dy));
  }

  void scrollRight({double? amount}) {
    amount ??= scrollDelta.dy;
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

  double get scale => _scale;

  void zoomIn({double? amount}) {
    amount ??= zoomDelta;
    _scale += amount;
    contentOriginalSize = _contentOriginalSize;
    _controller.add(this);
    _setPosition(position);
  }

  void zoomOut({double? amount}) {
    amount ??= zoomDelta;
    _scale -= amount;
    contentOriginalSize = _contentOriginalSize;
    _controller.add(this);
    _setPosition(position);
  }

  void dispose() {
    _tracker?.cancel();
    _controller.close();
    _controller.add(this);
    _setPosition(position);
  }
}

double _clamp(double value, double threshold) {
  if (value < threshold) {
    value = threshold;
  }
  if (value > 0) {
    return 0;
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
