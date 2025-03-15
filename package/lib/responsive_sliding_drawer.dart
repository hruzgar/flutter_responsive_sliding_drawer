import 'package:flutter/material.dart';

class SlidingDrawer extends StatefulWidget {
  final Widget drawer;
  final Widget body;
  final Duration animationDuration;

  /// Fraction of the screen width that the drawer covers when fully open on phones.
  final double openRatio;

  /// Fraction of the screen width that the drawer covers when fully open on desktops.
  final double desktopOpenRatio;

  /// Minimum drawer width on desktop (in pixels).
  final double desktopMinDrawerWidth;

  /// Maximum drawer width on desktop (in pixels).
  final double desktopMaxDrawerWidth;

  /// Swipe velocity threshold in pixels per second.
  final double swipeVelocityThreshold;

  /// Drag percentage threshold to complete open/close when swipe velocity is low.
  final double dragPercentageThreshold;

  /// Callback that gets triggered when the drawer animation finishes.
  /// [isOpen] is true when the drawer finishes opening and false when it finishes closing.
  final void Function(bool isOpen)? onAnimationComplete;

  const SlidingDrawer({
    Key? key,
    required this.drawer,
    required this.body,
    this.animationDuration = const Duration(milliseconds: 60),
    this.openRatio = 0.75,
    this.desktopOpenRatio = 0.3,
    this.desktopMinDrawerWidth = 150.0,
    this.desktopMaxDrawerWidth = 400.0,
    this.swipeVelocityThreshold = 500.0,
    this.dragPercentageThreshold = 0.5,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  _SlidingDrawerState createState() => _SlidingDrawerState();
}

class _SlidingDrawerState extends State<SlidingDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double? _desktopDrawerWidth;

  /// Accumulates extra drag that exceeds the limits.
  double _resizeOvershoot = 0.0;

  /// Tracks whether the mouse is hovering over the divider.
  bool _isHoveringDivider = false;

  // We consider devices with width >= 600 as desktop.
  bool get isDesktop => MediaQuery.of(context).size.width >= 600;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Rebuild on every animation tick.
    _controller.addListener(() {
      setState(() {});
    });

    // Listen for animation status changes.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call(true);
      } else if (status == AnimationStatus.dismissed) {
        widget.onAnimationComplete?.call(false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isDesktop) {
      final screenWidth = MediaQuery.of(context).size.width;
      _desktopDrawerWidth ??= widget.desktopOpenRatio * screenWidth;
      _desktopDrawerWidth = _desktopDrawerWidth!.clamp(
        widget.desktopMinDrawerWidth,
        widget.desktopMaxDrawerWidth,
      );
    }
  }

  /// Toggles the drawer open/closed.
  void _toggleDrawer() {
    if (_controller.value >= 0.99) {
      _controller.animateTo(0.0, duration: widget.animationDuration);
    } else {
      _controller.animateTo(1.0, duration: widget.animationDuration);
    }
  }

  /// Returns the current drawer width.
  double get _currentDrawerWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    return isDesktop
        ? _desktopDrawerWidth ?? (widget.desktopOpenRatio * screenWidth)
        : widget.openRatio * screenWidth;
  }

  /// Common drag update handler for both body and drawer.
  void _handleDragUpdate(DragUpdateDetails details) {
    final effectiveWidth = _currentDrawerWidth;
    double delta = details.primaryDelta! / effectiveWidth;
    _controller.value += delta;
  }

  /// Common drag end handler for both body and drawer.
  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity.abs() >= widget.swipeVelocityThreshold) {
      if (velocity > 0) {
        _controller.animateTo(1.0, duration: widget.animationDuration);
      } else {
        _controller.animateTo(0.0, duration: widget.animationDuration);
      }
    } else {
      if (_controller.value >= widget.dragPercentageThreshold) {
        _controller.animateTo(1.0, duration: widget.animationDuration);
      } else {
        _controller.animateTo(0.0, duration: widget.animationDuration);
      }
    }
  }

  /// Handles drag updates on the divider.
  void _handleDividerPanUpdate(DragUpdateDetails details) {
    if (_controller.value < 0.99) return;
    double delta = details.delta.dx;
    double newWidth = _desktopDrawerWidth! + delta;

    if (_desktopDrawerWidth! >= widget.desktopMaxDrawerWidth && delta > 0) {
      _resizeOvershoot += delta;
    } else if (_desktopDrawerWidth! <= widget.desktopMinDrawerWidth &&
        delta < 0) {
      _resizeOvershoot += delta;
    } else {
      if (_resizeOvershoot != 0.0) {
        if ((_resizeOvershoot > 0 && delta < 0) ||
            (_resizeOvershoot < 0 && delta > 0)) {
          if (delta.abs() >= _resizeOvershoot.abs()) {
            double remaining = delta.abs() - _resizeOvershoot.abs();
            _resizeOvershoot = 0.0;
            _desktopDrawerWidth = (_desktopDrawerWidth! +
                    (delta > 0 ? remaining : -remaining))
                .clamp(
                  widget.desktopMinDrawerWidth,
                  widget.desktopMaxDrawerWidth,
                );
          } else {
            _resizeOvershoot += delta;
          }
        } else {
          _resizeOvershoot += delta;
        }
      } else {
        _desktopDrawerWidth = newWidth.clamp(
          widget.desktopMinDrawerWidth,
          widget.desktopMaxDrawerWidth,
        );
      }
    }

    _desktopDrawerWidth = _desktopDrawerWidth!.clamp(
      widget.desktopMinDrawerWidth,
      widget.desktopMaxDrawerWidth,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth = _currentDrawerWidth;
    // We consider the drawer fully open if the controller's value is 0.99 or above.
    final bool drawerOpen = _controller.value >= 0.99;

    return Stack(
      children: [
        // Drawer layer.
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final dx = -drawerWidth * (1 - _controller.value);
            return Transform.translate(
              offset: Offset(dx, 0),
              child: GestureDetector(
                onHorizontalDragUpdate: _handleDragUpdate,
                onHorizontalDragEnd: _handleDragEnd,
                child: Container(
                  width: drawerWidth,
                  height: MediaQuery.of(context).size.height,
                  child: widget.drawer,
                ),
              ),
            );
          },
        ),
        // Body layer.
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final dx = drawerWidth * _controller.value;
            return Transform.translate(
              offset: Offset(dx, 0),
              // On mobile, the body remains interactive (to tap and close).
              // On desktop, we intentionally leave the body without horizontal gestures.
              child:
                  isDesktop
                      ? widget.body
                      : GestureDetector(
                        onTap: () {
                          if (drawerOpen) _toggleDrawer();
                        },
                        onHorizontalDragUpdate: _handleDragUpdate,
                        onHorizontalDragEnd: _handleDragEnd,
                        child: widget.body,
                      ),
            );
          },
        ),
        // Desktop left-edge drag area.
        // When the drawer is mostly closed, it covers the left edge (x = 0).
        // When the drawer is fully open, we shift it right so that it doesn't block the drawer's content,
        // yet still lets you swipe left on the body to close the drawer.
        if (isDesktop)
          Positioned(
            left: _controller.value < 0.5 ? 0 : drawerWidth,
            top: 0,
            bottom: 0,
            width: 50,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
            ),
          ),
        // Draggable divider – only on desktop and when the drawer is open.
        // This remains on top so that if you drag near the edge of the open drawer, it takes priority.
        if (isDesktop && drawerOpen)
          Positioned(
            top: 0,
            bottom: 0,
            left: drawerWidth - 10,
            width: 20,
            child: MouseRegion(
              onEnter: (_) {
                setState(() {
                  _isHoveringDivider = true;
                });
              },
              onExit: (_) {
                setState(() {
                  _isHoveringDivider = false;
                });
              },
              cursor: SystemMouseCursors.resizeColumn,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity:
                    (_isHoveringDivider || _resizeOvershoot != 0.0) ? 1.0 : 0.0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) {
                    _resizeOvershoot = 0.0;
                  },
                  onPanUpdate: _handleDividerPanUpdate,
                  onPanEnd: (details) {
                    _resizeOvershoot = 0.0;
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 4,
                      height: double.infinity,
                      color: const Color.fromARGB(255, 103, 103, 103),
                    ),
                  ),
                ),
              ),
            ),
          ),
        // Left-edge drag area for mobile remains unchanged.
        if (!isDesktop && _controller.value == 0.0)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 20,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
