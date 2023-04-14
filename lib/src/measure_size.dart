import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class MeasureSize extends StatefulWidget {
  final Widget child;

  final Function(Size) onChange;

  const MeasureSize({
    required this.onChange,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  final widgetKey = GlobalKey();

  Size? oldSize;

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize || newSize == null) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}
