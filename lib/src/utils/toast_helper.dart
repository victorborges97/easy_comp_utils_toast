import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

/// Toast Length
/// Only for Android Platform
enum Toast {
  /// Show Short toast for 1 sec
  LENGTH_SHORT,

  /// Show Long toast for 5 sec
  LENGTH_LONG
}

/// ToastGravity
/// Used to define the position of the Toast on the screen
enum ToastGravity {
  TOP,
  BOTTOM,
  CENTER,
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT,
  CENTER_LEFT,
  CENTER_RIGHT,
  SNACKBAR,
  NONE
}

/// Signature for a function to buildCustom Toast
typedef PositionedToastBuilder = Widget Function(
    BuildContext context, Widget child);

/// Runs on dart side this has no interaction with the Native Side
/// Works with all platforms just in two lines of code
/// final fToast = FToast().init(context)
/// fToast.showToast(child)
///
class EasyCompUtilsToast {
  static BuildContext? _context;

  static EasyCompUtilsToast _instance = EasyCompUtilsToast._internal();

  /// Prmary Constructor for FToast
  factory EasyCompUtilsToast() {
    return _instance;
  }

  /// Take users Context and saves to avariable
  static void init(GlobalKey<NavigatorState> navigatorState) {
    Future.delayed(const Duration(seconds: 1), () {
      _context = navigatorState.currentState!.context;
      _instance = EasyCompUtilsToast._internal();
    });
  }

  EasyCompUtilsToast._internal();

  static OverlayEntry? _entry;
  static List<_ToastEntry> _overlayQueue = [];
  static Timer? _timer;
  static Timer? _fadeTimer;
  static ToastGravity position = ToastGravity.TOP;
  static BoxDecoration decoration =
      BoxDecoration(borderRadius: BorderRadius.circular(10.0), boxShadow: [
    BoxShadow(
      color: Colors.black26,
      offset: Offset(0, 8),
      spreadRadius: 1,
      blurRadius: 30,
    ),
  ]);

  /// Internal function which handles the adding
  /// the overlay to the screen
  ///
  static _showOverlay() {
    if (_overlayQueue.length == 0) {
      _entry = null;
      return;
    }
    if (_context == null) {
      /// Need to clear queue
      removeQueuedCustomToasts();
      throw ("Error: Context is null, Please call init(context) before showing toast.");
    }

    /// To prevent exception "Looking up a deactivated widget's ancestor is unsafe."
    /// which can be thrown if context was unmounted (e.g. screen with given context was popped)
    /// TODO: revert this change when envoirment will be Flutter >= 3.7.0
    // if (context?.mounted != true) {
    //   if (kDebugMode) {
    //     print(
    //         'FToast: Context was unmuted, can not show ${_overlayQueue.length} toast.');
    //   }

    //   /// Need to clear queue
    //   removeQueuedCustomToasts();
    //   return; // Or maybe thrown error too
    // }
    var _overlay;
    try {
      _overlay = Overlay.of(_context!);
    } catch (err) {
      removeQueuedCustomToasts();
      throw ("""Error: Overlay is null. 
      Please don't use top of the widget tree context (such as Navigator or MaterialApp) or 
      create overlay manually in MaterialApp builder.
      More information 
        - https://github.com/ponnamkarthik/FlutterToast/issues/393
        - https://github.com/ponnamkarthik/FlutterToast/issues/234""");
    }
    if (_overlay == null) {
      /// Need to clear queue
      removeQueuedCustomToasts();
      throw ("""Error: Overlay is null. 
      Please don't use top of the widget tree context (such as Navigator or MaterialApp) or 
      create overlay manually in MaterialApp builder.
      More information 
        - https://github.com/ponnamkarthik/FlutterToast/issues/393
        - https://github.com/ponnamkarthik/FlutterToast/issues/234""");
    }

    /// Create entry only after all checks
    _ToastEntry _toastEntry = _overlayQueue.removeAt(0);
    _entry = _toastEntry.entry;
    _overlay.insert(_entry!);

    _timer = Timer(_toastEntry.duration, () {
      _fadeTimer = Timer(_toastEntry.fadeDuration, () {
        removeCustomToast();
      });
    });
  }

  /// If any active toast present
  /// call removeCustomToast to hide the toast immediately
  static removeCustomToast() {
    _timer?.cancel();
    _fadeTimer?.cancel();
    _timer = null;
    _fadeTimer = null;
    _entry?.remove();
    _entry = null;
    _showOverlay();
  }

  /// FToast maintains a queue for every toast
  /// if we called showToast for 3 times we all to queue
  /// and show them one after another
  ///
  /// call removeCustomToast to hide the toast immediately
  static removeQueuedCustomToasts() {
    _timer?.cancel();
    _fadeTimer?.cancel();
    _timer = null;
    _fadeTimer = null;
    _overlayQueue.clear();
    _entry?.remove();
    _entry = null;
  }

  static void success({
    required String message,
    IconData? icon,
    Color? bgColor = const Color(0xFF00CC62),
    int seconds = 2,
    double? width,
  }) {
    removeQueuedCustomToasts();
    Widget toast = InkWell(
      onTap: () => removeCustomToast(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        width: width,
        decoration: decoration.copyWith(
          color: bgColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.check, color: Colors.white),
            const SizedBox(
              width: 12.0,
            ),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    _show(
      child: toast,
      gravity: position,
      toastDuration: Duration(seconds: seconds),
    );
  }

  static void error({
    required String message,
    IconData? icon,
    Color? bgColor = const Color(0xFFEE293B),
    int seconds = 4,
    double? width,
  }) {
    removeQueuedCustomToasts();
    Widget toast = InkWell(
      onTap: () => removeCustomToast(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        width: width,
        decoration: decoration.copyWith(
          color: bgColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.close, color: Colors.white),
            const SizedBox(
              width: 12.0,
            ),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    _show(
      child: toast,
      gravity: position,
      toastDuration: Duration(seconds: seconds),
    );
  }

  static void info({
    required String message,
    IconData? icon,
    Color? bgColor = const Color(0xFFCC9900),
    int seconds = 2,
    double? width,
  }) {
    removeQueuedCustomToasts();
    Widget toast = InkWell(
      onTap: () => removeCustomToast(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        width: width,
        decoration: decoration.copyWith(
          color: bgColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.error_outline, color: Colors.white),
            const SizedBox(
              width: 12.0,
            ),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    _show(
      child: toast,
      gravity: position,
      toastDuration: Duration(seconds: seconds),
    );
  }

  /// showToast accepts all the required paramenters and prepares the child
  /// calls _showOverlay to display toast
  ///
  /// Paramenter [child] is requried
  /// toastDuration default is 2 seconds
  /// fadeDuration default is 350 milliseconds
  static void _show({
    required Widget child,
    PositionedToastBuilder? positionedToastBuilder,
    Duration toastDuration = const Duration(seconds: 2),
    ToastGravity? gravity,
    Duration fadeDuration = const Duration(milliseconds: 350),
  }) {
    if (_context == null)
      throw ("Error: Context is null, Please call init(context) before showing toast.");
    Widget newChild = _ToastStateFul(child, toastDuration, fadeDuration);

    /// Check for keyboard open
    /// If open will ignore the gravity bottom and change it to center
    if (gravity == ToastGravity.BOTTOM) {
      if (MediaQuery.of(_context!).viewInsets.bottom != 0) {
        gravity = ToastGravity.CENTER;
      }
    }

    OverlayEntry newEntry = OverlayEntry(builder: (context) {
      if (positionedToastBuilder != null)
        return positionedToastBuilder(context, newChild);
      return _getPostionWidgetBasedOnGravity(newChild, gravity);
    });
    _overlayQueue.add(_ToastEntry(
        entry: newEntry, duration: toastDuration, fadeDuration: fadeDuration));
    if (_timer == null) _showOverlay();
  }

  /// _getPostionWidgetBasedOnGravity generates [Positioned] [Widget]
  /// based on the gravity  [ToastGravity] provided by the user in
  /// [showToast]
  static _getPostionWidgetBasedOnGravity(Widget child, ToastGravity? gravity) {
    switch (gravity) {
      case ToastGravity.TOP:
        return Positioned(top: 100.0, left: 24.0, right: 24.0, child: child);
      case ToastGravity.TOP_LEFT:
        return Positioned(top: 100.0, left: 24.0, child: child);
      case ToastGravity.TOP_RIGHT:
        return Positioned(top: 100.0, right: 24.0, child: child);
      case ToastGravity.CENTER:
        return Positioned(
            top: 50.0, bottom: 50.0, left: 24.0, right: 24.0, child: child);
      case ToastGravity.CENTER_LEFT:
        return Positioned(top: 50.0, bottom: 50.0, left: 24.0, child: child);
      case ToastGravity.CENTER_RIGHT:
        return Positioned(top: 50.0, bottom: 50.0, right: 24.0, child: child);
      case ToastGravity.BOTTOM_LEFT:
        return Positioned(bottom: 50.0, left: 24.0, child: child);
      case ToastGravity.BOTTOM_RIGHT:
        return Positioned(bottom: 50.0, right: 24.0, child: child);
      case ToastGravity.SNACKBAR:
        return Positioned(
            bottom: MediaQuery.of(_context!).viewInsets.bottom,
            left: 0,
            right: 0,
            child: child);
      case ToastGravity.NONE:
        return Positioned.fill(child: child);
      case ToastGravity.BOTTOM:
      default:
        return Positioned(bottom: 50.0, left: 24.0, right: 24.0, child: child);
    }
  }
}

/// Simple builder method to create a [TransitionBuilder]
/// and for the use in MaterialApp builder method
// ignore: non_constant_identifier_names
TransitionBuilder EasyCompUtilsToastBuilder() {
  return (context, child) {
    log("[EasyCompToast]: INIT 🚀");
    return _EasyCompUtilsToastHolder(
      child: child!,
    );
  };
}

/// Simple StatelessWidget which holds the child
/// and creates an [Overlay] to display the toast
/// which returns the Directionality widget with [TextDirection.ltr]
/// and [Overlay] widget
class _EasyCompUtilsToastHolder extends StatelessWidget {
  const _EasyCompUtilsToastHolder({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Overlay overlay = Overlay(
      initialEntries: <OverlayEntry>[
        OverlayEntry(
          builder: (BuildContext ctx) {
            return child;
          },
        ),
      ],
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: overlay,
    );
  }
}

/// internal class [_ToastEntry] which maintains
/// each [OverlayEntry] and [Duration] for every toast user
/// triggered
class _ToastEntry {
  final OverlayEntry entry;
  final Duration duration;
  final Duration fadeDuration;

  _ToastEntry({
    required this.entry,
    required this.duration,
    required this.fadeDuration,
  });
}

/// internal [StatefulWidget] which handles the show and hide
/// animations for [EasyCompUtilsToast]
class _ToastStateFul extends StatefulWidget {
  _ToastStateFul(this.child, this.duration, this.fadeDuration, {Key? key})
      : super(key: key);

  final Widget child;
  final Duration duration;
  final Duration fadeDuration;

  @override
  ToastStateFulState createState() => ToastStateFulState();
}

/// State for [_ToastStateFul]
class ToastStateFulState extends State<_ToastStateFul>
    with SingleTickerProviderStateMixin {
  /// Start the showing animations for the toast
  showIt() {
    _animationController!.forward();
  }

  /// Start the hidding animations for the toast
  hideIt() {
    _animationController!.reverse();
    _timer?.cancel();
  }

  /// Controller to start and hide the animation
  AnimationController? _animationController;
  late Animation _fadeAnimation;

  Timer? _timer;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController!, curve: Curves.easeIn);
    super.initState();

    showIt();
    _timer = Timer(widget.duration, () {
      hideIt();
    });
  }

  @override
  void deactivate() {
    _timer?.cancel();
    _animationController!.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation as Animation<double>,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}
