import 'dart:io';

import 'package:flutter/material.dart';

enum _DrawerAction { open, close }

enum _DrawerDragDirection { opening, closing }

class SlidingDrawerController {
  _SlidingDrawerState? _state;
  void open() => _state?._openDrawer();
  void close() => _state?._closeDrawer();
  void toggle() => _state?._toggleDrawer();
}

class SlidingDrawer extends StatefulWidget {
  final Widget drawer;
  final Widget body;
  final Duration animationDuration;
  final double openRatio;
  final double desktopOpenRatio;
  final double desktopMinDrawerWidth;
  final double desktopMaxDrawerWidth;
  final double swipeVelocityThreshold;
  final double dragPercentageThreshold;
  final void Function(bool isOpen)? onAnimationComplete;

  // Callback parameters.
  final VoidCallback? onFinishedOpening;
  final VoidCallback? onFinishedClosing;
  final VoidCallback? onStartedOpening;
  final VoidCallback? onStartedClosing;

  final double dividerWidth;
  final bool centerDivider;
  final SlidingDrawerController? controller;
  final double desktopDragAreaWidth;
  final Color scrimColor;
  final double scrimColorOpacity;
  final double scrimGradientStartOpacity;
  final double scrimGradientWidth;

  const SlidingDrawer({
    Key? key,
    required this.drawer,
    required this.body,
    this.animationDuration = const Duration(milliseconds: 60),
    this.openRatio = 0.80,
    this.desktopOpenRatio = 0.3,
    this.desktopMinDrawerWidth = 150.0,
    this.desktopMaxDrawerWidth = 400.0,
    this.swipeVelocityThreshold = 500.0,
    this.dragPercentageThreshold = 0.5,
    this.onAnimationComplete,
    this.onFinishedOpening,
    this.onFinishedClosing,
    this.onStartedOpening,
    this.onStartedClosing,
    this.dividerWidth = 5.0,
    this.centerDivider = true,
    this.controller,
    this.desktopDragAreaWidth = 10.0,
    this.scrimColor = Colors.black,
    this.scrimColorOpacity = 0.5,
    this.scrimGradientStartOpacity = 0.10,
    this.scrimGradientWidth = 6.0,
  }) : super(key: key);

  @override
  _SlidingDrawerState createState() => _SlidingDrawerState();
}

class _SlidingDrawerState extends State<SlidingDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double? _desktopDrawerWidth;
  double _resizeOvershoot = 0.0;
  bool _isHoveringDivider = false;
  bool _isResizing = false;

  bool _isOpen = false;

  bool? _dragStartedWhenOpen;
  _DrawerDragDirection? _dragDirection;
  _DrawerAction? _lastAction;

  bool _hasStartedDragCallback = false;

  bool get isDesktop => MediaQuery.of(context).size.width >= 600;

  @override
  void initState() {
    super.initState();
    _isOpen = false; // initially closed
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _controller.addListener(() => setState(() {}));
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(covariant SlidingDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
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

  void _toggleDrawer() {
    if (_isOpen) {
      _closeDrawer();
    } else {
      _openDrawer();
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _dragStartedWhenOpen = _isOpen;
    _dragDirection = null;
    _hasStartedDragCallback = false;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isResizing) return;

    if (_dragDirection == null) {
      if (_dragStartedWhenOpen == false && details.primaryDelta! > 0) {
        _dragDirection = _DrawerDragDirection.opening;
        _lastAction = _DrawerAction.open;
        if (!_hasStartedDragCallback) {
          widget.onStartedOpening?.call();
          _hasStartedDragCallback = true;
        }
      } else if (_dragStartedWhenOpen == true && details.primaryDelta! < 0) {
        _dragDirection = _DrawerDragDirection.closing;
        _lastAction = _DrawerAction.close;
        if (!_hasStartedDragCallback) {
          widget.onStartedClosing?.call();
          _hasStartedDragCallback = true;
        }
      } else {
        return;
      }
    }
    final effectiveWidth = _currentDrawerWidth;
    double delta = details.primaryDelta! / effectiveWidth;
    _controller.value += delta;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isResizing || _dragDirection == null) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity.abs() >= widget.swipeVelocityThreshold) {
      if (velocity > 0) {
        _lastAction = _DrawerAction.open;
        _openDrawer();
      } else {
        _lastAction = _DrawerAction.close;
        _closeDrawer();
      }
    } else {
      if (_controller.value >= widget.dragPercentageThreshold) {
        _lastAction = _DrawerAction.open;
        _openDrawer();
      } else {
        _lastAction = _DrawerAction.close;
        _closeDrawer();
      }
    }
    _dragStartedWhenOpen = null;
    _dragDirection = null;
    _hasStartedDragCallback = false;
  }

  void _openDrawer() {
    _lastAction = _DrawerAction.open;
    if (_dragDirection == null) {
      widget.onStartedOpening?.call();
    }
    if (_controller.value >= 1.0 - 0.001) {
      _isOpen = true;
      widget.onAnimationComplete?.call(true);
      widget.onFinishedOpening?.call();
      return;
    }
    _controller.animateTo(1.0, duration: widget.animationDuration).then((_) {
      _isOpen = true;
      widget.onAnimationComplete?.call(true);
      widget.onFinishedOpening?.call();
    });
  }

  void _closeDrawer() {
    _lastAction = _DrawerAction.close;
    // Only call onStartedClosing if not already triggered by a drag.
    if (_dragDirection == null) {
      widget.onStartedClosing?.call();
    }
    if (_controller.value <= 0.0 + 0.001) {
      _isOpen = false;
      widget.onAnimationComplete?.call(false);
      widget.onFinishedClosing?.call();
      return;
    }
    _controller.animateTo(0.0, duration: widget.animationDuration).then((_) {
      _isOpen = false;
      widget.onAnimationComplete?.call(false);
      widget.onFinishedClosing?.call();
    });
  }

  double get _currentDrawerWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    return isDesktop
        ? (_desktopDrawerWidth ?? (widget.desktopOpenRatio * screenWidth))
        : widget.openRatio * screenWidth;
  }

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
    final bool drawerFullyOpen = _controller.value >= 1.0 - 0.001;

    if (isDesktop) {
      return Stack(
        children: [
          // Main body that slides (no drag gestures here on desktop).
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final leftOffset = drawerWidth * _controller.value;
              return Positioned(
                left: leftOffset,
                top: 0,
                right: 0,
                bottom: 0,
                child: widget.body,
              );
            },
          ),
          // The drawer (without drag gestures here).
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final dx = -drawerWidth * (1 - _controller.value);
              return Transform.translate(
                offset: Offset(dx, 0),
                child: GestureDetector(
                  onHorizontalDragStart: _handleDragStart,
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
          // Desktop drag area (the only draggable region on desktop).
          Positioned(
            left: _controller.value < 0.5 ? 0 : drawerWidth,
            top: 0,
            bottom: 0,
            width: widget.desktopDragAreaWidth,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: _handleDragStart,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
            ),
          ),
          if (drawerFullyOpen)
            Positioned(
              left:
                  widget.centerDivider
                      ? drawerWidth - widget.dividerWidth / 2
                      : drawerWidth,
              top: 0,
              bottom: 0,
              width: widget.dividerWidth,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHoveringDivider = true),
                onExit: (_) => setState(() => _isHoveringDivider = false),
                cursor: SystemMouseCursors.resizeColumn,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity:
                      (_isHoveringDivider || _resizeOvershoot != 0.0)
                          ? 1.0
                          : 0.0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (_) {
                      setState(() {
                        _isResizing = true;
                        _resizeOvershoot = 0.0;
                      });
                    },
                    onPanUpdate: _handleDividerPanUpdate,
                    onPanEnd: (_) {
                      setState(() {
                        _isResizing = false;
                        _resizeOvershoot = 0.0;
                      });
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
        ],
      );
    } else {
      // Mobile layout: The whole main area is draggable.
      return Stack(
        children: [
          // if (Platform.isAndroid || Platform.isIOS)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final dx = drawerWidth * _controller.value;
              return Transform.translate(
                offset: Offset(dx, 0),
                child: GestureDetector(
                  // Tapping the main area when the drawer is open should close it.
                  onTap: () {
                    if (drawerFullyOpen) _toggleDrawer();
                  },
                  onHorizontalDragStart:
                      Platform.isAndroid || Platform.isIOS
                          ? _handleDragStart
                          : null,
                  onHorizontalDragUpdate:
                      Platform.isAndroid || Platform.isIOS
                          ? _handleDragUpdate
                          : null,
                  onHorizontalDragEnd:
                      Platform.isAndroid || Platform.isIOS
                          ? _handleDragEnd
                          : null,
                  child: widget.body,
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final dx = drawerWidth * _controller.value;
              return Transform.translate(
                offset: Offset(dx, 0),
                child: IgnorePointer(
                  ignoring: _controller.value == 0,
                  child: GestureDetector(
                    onTap: () {
                      if (drawerFullyOpen) _toggleDrawer();
                    },
                    onHorizontalDragStart: _handleDragStart,
                    onHorizontalDragUpdate: _handleDragUpdate,
                    onHorizontalDragEnd: _handleDragEnd,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        color: widget.scrimColor.withValues(
                          alpha: widget.scrimColorOpacity * _controller.value,
                        ),
                      ),
                      // child: Stack(
                      //   children: [
                      //     Positioned(
                      //       left: 0,
                      //       top: 0,
                      //       bottom: 0,
                      //       width: widget.scrimGradientWidth,
                      //       child: IgnorePointer(
                      //         child: Container(
                      //           decoration: BoxDecoration(
                      //             gradient: LinearGradient(
                      //               begin: Alignment.centerLeft,
                      //               end: Alignment.centerRight,
                      //               colors: [
                      //                 widget.scrimColor.withValues(
                      //                   alpha: 0.3 * _controller.value,
                      //                 ),
                      //                 widget.scrimColor.withValues(alpha: 0),
                      //                 // Colors.transparent,
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ),
                  ),
                ),
              );
            },
          ),
          // if (Platform.isAndroid || Platform.isIOS)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final dx = -drawerWidth * (1 - _controller.value);
              return Transform.translate(
                offset: Offset(dx, 0),
                child: GestureDetector(
                  onHorizontalDragStart: _handleDragStart,
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
        ],
      );
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    _controller.dispose();
    super.dispose();
  }
}
