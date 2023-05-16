import 'package:bidirectional_scroll/bidirectional_scroll.dart';
import 'package:bidirectional_scroll/src/measure_size.dart';
import 'package:flutter/material.dart';

typedef ControlMaker = Widget Function(ScrollerController controller);

class ScrollViewport extends StatefulWidget {
  final List<ControlMaker> children;

  final Widget child;

  final ScrollerController controller;

  final bool disposeController;

  const ScrollViewport(
      {Key? key,
      required this.controller,
      this.children = const [],
      required this.child,
      this.disposeController = false})
      : super(key: key);

  factory ScrollViewport.basic(
      {Key? key,
      ScrollerController? controller,
      List<ControlMaker> children = const [],
      required Widget child}) {
    final c =
        controller ?? ScrollerController(marginBottom: 25, marginRight: 25);
    return ScrollViewport(
        key: key,
        controller: c,
        children: [
          (c) => ScrollerCanvas(controller: c),
          (c) => VerticalScrollbar(c),
          (c) => HorizontalScrollbar(c),
          ...children,
        ],
        disposeController: controller == null,
        child: child);
  }

  @override
  State<ScrollViewport> createState() => _ScrollViewportState();
}

class _ScrollViewportState extends State<ScrollViewport> {
  late final ScrollerController controller;

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
      controller.viewportOriginalSize =
          Size(constraint.maxWidth, constraint.maxHeight);
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          StreamBuilder(
            stream: controller.stream,
            builder: (ctx, _) => Positioned(
              left: controller.position.dx,
              top: controller.position.dy,
              child: Transform.scale(
                scale: controller.scale,
                alignment: Alignment.topLeft,
                child: MeasureSize(
                    onChange: (value) {
                      controller.contentOriginalSize = value;
                    },
                    child: widget.child),
              ),
            ),
          ),
          ...widget.children.map((e) => e(controller)),
        ],
      );
    });
  }

  @override
  void dispose() {
    if (widget.disposeController) {
      controller.dispose();
    }
    super.dispose();
  }
}
