// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// TODO(dragostis): Missing functionality:
//   * mobile horizontal mode with adding/removing steps
//   * alternative labeling
//   * stepper feedback in the case of high-latency interactions

/// The state of a [CheckStep] which is used to control the style of the circle and
/// text.
///
/// See also:
///
///  * [CheckStep]
enum CheckStepState {
  indexed,

  /// A step that displays a tick icon in its circle.
  complete,
  completeStop,

  /// A step that is currently having an error. e.g. the user has submitted wrong
  /// input.
  error,
  errorStop,

  /// Loading future
  loading,

  warning,
}

/// Defines the [CheckStepper]'s main axis.
enum CheckStepperType {
  /// A vertical layout of the steps with their content in-between the titles.
  vertical,

  /// A horizontal layout of the steps with their content below the titles.
  horizontal,
}

/// Container for all the information necessary to build a Stepper widget's
/// forward and backward controls for any given step.
///
/// Used by [CheckStepper.controlsBuilder].
@immutable
class CheckControlsDetails {
  /// Creates a set of details describing the Stepper.
  const CheckControlsDetails({
    required this.currentStep,
    required this.stepIndex,
    this.onStepCancel,
    this.onStepContinue,
  });

  /// Index that is active for the surrounding [CheckStepper] widget. This may be
  /// different from [stepIndex] if the user has just changed steps and we are
  /// currently animating toward that step.
  final int currentStep;

  /// Index of the step for which these controls are being built. This is
  /// not necessarily the active index, if the user has just changed steps and
  /// this step is animating away. To determine whether a given builder is building
  /// the active step or the step being navigated away from, see [isActive].
  final int stepIndex;

  /// The callback called when the 'continue' button is tapped.
  ///
  /// If null, the 'continue' button will be disabled.
  final VoidCallback? onStepContinue;

  /// The callback called when the 'cancel' button is tapped.
  ///
  /// If null, the 'cancel' button will be disabled.
  final VoidCallback? onStepCancel;

  /// True if the indicated step is also the current active step. If the user has
  /// just activated the transition to a new step, some [CheckStepper.type] values will
  /// lead to both steps being rendered for the duration of the animation shifting
  /// between steps.
  bool get isActive => currentStep == stepIndex;
}

/// A builder that creates a widget given the two callbacks `onStepContinue` and
/// `onStepCancel`.
///
/// Used by [CheckStepper.controlsBuilder].
///
/// See also:
///
///  * [WidgetBuilder], which is similar but only takes a [BuildContext].
typedef CheckControlsWidgetBuilder = Widget Function(
    BuildContext context, CheckControlsDetails details);

const Color _kErrorLight = Colors.red;
final Color _kErrorDark = Colors.red.shade400;
const double _kStepSize = 28.0;

/// A material step used in [CheckStepper]. The step can have a title and subtitle,
/// an icon within its circle, some content and a state that governs its
/// styling.
///
/// See also:
///
///  * [CheckStepper]
///  * <https://material.io/archive/guidelines/components/steppers.html>
@immutable
class CheckStep {
  dynamic error;
  Future<CheckStepsErrorType> Function(dynamic error)? errorCallback;
  String errorCallbackText;

  /// Creates a step for a [CheckStepper].
  ///
  /// The [title], [content], and [state] arguments must not be null.
  CheckStep({
    required this.title,
    this.subtitle,
    this.checkStatus,
    this.state = CheckStepState.indexed,
    this.label,
    this.errorCallbackText = "Refresh",
    this.errorCallback,
  })  : assert(title != null),
        assert(state != null);

  /// The title of the step that typically describes it.
  final String title;

  /// The subtitle of the step that appears below the title and has a smaller
  /// font size. It typically gives more details that complement the title.
  ///
  /// If null, the subtitle is not shown.
  final Widget? subtitle;

  /// The state of the step which determines the styling of its components
  /// and whether steps are interactive.
  CheckStepState state;

  /// Whether or not the step is active. The flag only influences styling.
  bool isActive = false;

  /// Whether or not the step is active. The flag only influences styling.
  bool alreadyChecked = false;

  /// Only [CheckStepperType.horizontal], Optional widget that appears under the [title].
  /// By default, uses the `bodyLarge` theme.
  final Widget? label;

  Future<CheckStepState> Function(Function(SetMessage setMessage) setMessage)?
      checkStatus;

  SetMessage? message;
}

/// A material stepper widget that displays progress through a sequence of
/// steps. Steppers are particularly useful in the case of forms where one step
/// requires the completion of another one, or where multiple steps need to be
/// completed in order to submit the whole form.
///
/// The widget is a flexible wrapper. A parent class should pass [currentStep]
/// to this widget based on some logic triggered by the three callbacks that it
/// provides.
///
/// {@tool dartpad}
/// An example the shows how to use the [CheckStepper], and the [CheckStepper] UI
/// appearance.
///
/// ** See code in examples/api/lib/material/stepper/stepper.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [CheckStep]
///  * <https://material.io/archive/guidelines/components/steppers.html>
class CheckStepper extends StatefulWidget {
  /// Creates a stepper from a list of steps.
  ///
  /// This widget is not meant to be rebuilt with a different list of steps
  /// unless a key is provided in order to distinguish the old stepper from the
  /// new one.
  ///
  /// The [steps], [type], and [currentStep] arguments must not be null.
  const CheckStepper._({
    super.key,
    required this.steps,
    this.physics,
    this.type = CheckStepperType.vertical,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.controlsBuilder,
    this.elevation,
    this.margin,
    this.onSave,
    this.onTente,
  })  : assert(steps != null),
        assert(type != null);

  /// The steps of the stepper whose titles, subtitles, icons always get shown.
  ///
  /// The length of [steps] must not change.
  final List<CheckStep> steps;

  /// How the stepper's scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to
  /// animate after the user stops dragging the scroll view.
  ///
  /// If the stepper is contained within another scrollable it
  /// can be helpful to set this property to [ClampingScrollPhysics].
  final ScrollPhysics? physics;

  /// The type of stepper that determines the layout. In the case of
  /// [CheckStepperType.horizontal], the content of the current step is displayed
  /// underneath as opposed to the [CheckStepperType.vertical] case where it is
  /// displayed in-between.
  final CheckStepperType type;

  /// The callback called when a step is tapped, with its index passed as
  /// an argument.
  final ValueChanged<int>? onStepTapped;

  /// The callback called when the 'continue' button is tapped.
  ///
  /// If null, the 'continue' button will be disabled.
  final VoidCallback? onStepContinue;

  /// The callback called when the 'cancel' button is tapped.
  ///
  /// If null, the 'cancel' button will be disabled.
  final VoidCallback? onStepCancel;

  /// The callback for creating custom controls.
  ///
  /// If null, the default controls from the current theme will be used.
  ///
  /// This callback which takes in a context and a [CheckControlsDetails] object, which
  /// contains step information and two functions: [onStepContinue] and [onStepCancel].
  /// These can be used to control the stepper. For example, reading the
  /// [CheckControlsDetails.currentStep] value within the callback can change the text
  /// of the continue or cancel button depending on which step users are at.
  ///
  /// {@tool dartpad}
  /// Creates a stepper control with custom buttons.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return Stepper(
  ///     controlsBuilder:
  ///       (BuildContext context, ControlsDetails details) {
  ///          return Row(
  ///            children: <Widget>[
  ///              TextButton(
  ///                onPressed: details.onStepContinue,
  ///                child: Text('Continue to Step ${details.stepIndex + 1}'),
  ///              ),
  ///              TextButton(
  ///                onPressed: details.onStepCancel,
  ///                child: Text('Back to Step ${details.stepIndex - 1}'),
  ///              ),
  ///            ],
  ///          );
  ///       },
  ///     steps: const <Step>[
  ///       Step(
  ///         title: Text('A'),
  ///         content: SizedBox(
  ///           width: 100.0,
  ///           height: 100.0,
  ///         ),
  ///       ),
  ///       Step(
  ///         title: Text('B'),
  ///         content: SizedBox(
  ///           width: 100.0,
  ///           height: 100.0,
  ///         ),
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  /// ** See code in examples/api/lib/material/stepper/stepper.controls_builder.0.dart **
  /// {@end-tool}
  final CheckControlsWidgetBuilder? controlsBuilder;

  /// The elevation of this stepper's [Material] when [type] is [CheckStepperType.horizontal].
  final double? elevation;

  /// custom margin on vertical stepper.
  final EdgeInsetsGeometry? margin;

  final VoidCallback? onTente;
  final VoidCallback? onSave;

  @override
  State<CheckStepper> createState() => _CheckStepperState();

  static Future<void> show({
    required BuildContext context,
    required List<CheckStep> checkItens,
    VoidCallback? onSave,
    VoidCallback? onTente,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: CheckStepper._(
              steps: checkItens,
              onSave: onSave,
              onTente: onTente,
            ),
          ),
        );
      },
    );
  }
}

class _CheckStepperState extends State<CheckStepper>
    with TickerProviderStateMixin {
  /// The index into [steps] of the current step whose content is displayed.
  int currentStep = 0;
  late List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _keys = List<GlobalKey>.generate(
      widget.steps.length,
      (int i) => GlobalKey(),
    );

    widget.steps[0].isActive = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startCheck();
    });
  }

  Future startCheck() async {
    for (var i = 0; i < widget.steps.length; i++) {
      print("===============");
      print(
          "i($i) < widget.steps.length(${widget.steps.length}) = ${i < widget.steps.length}");
      var s = widget.steps[i];
      int nextIndex = i + 1;
      print("isRunnig: $i");
      currentStep = i;
      widget.steps[i].state = CheckStepState.loading;
      setState(() {});

      if (s.isActive) {
        print("isActive: $i");

        if (!s.alreadyChecked && widget.steps[i].checkStatus != null) {
          print("alreadyChecked: $i");
          late CheckStepState value;

          try {
            value = await widget.steps[i].checkStatus!(
              (war) {
                widget.steps[i].message = war;
              },
            );
          } catch (e) {
            value = CheckStepState.errorStop;
            widget.steps[i].error = e;
          }

          widget.steps[i].alreadyChecked = true;

          if (value == CheckStepState.complete) {
            //Success
            widget.steps[i].state = CheckStepState.complete;
          } else if (value == CheckStepState.errorStop) {
            widget.steps[i].state = CheckStepState.errorStop;
            setState(() {});
            break;
          } else if (value == CheckStepState.error) {
            //Error
            widget.steps[i].state = CheckStepState.error;
          } else if (value == CheckStepState.warning) {
            //Warning
            widget.steps[i].state = CheckStepState.warning;
          } else if (value == CheckStepState.completeStop) {
            widget.steps[i].state = CheckStepState.completeStop;
            setState(() {});
            break;
          }
        } else {
          widget.steps[i].alreadyChecked = true;
          widget.steps[i].state = CheckStepState.complete;
        }

        //Final
        if (i < widget.steps.length && ((nextIndex) < widget.steps.length)) {
          print("isRunnig.last: ${_isLast(nextIndex)} => $nextIndex");
          widget.steps[nextIndex].isActive = true;
        }
        setState(() {});
      } else {
        print("isNotActive: $i");
        //break;
      }
    }
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps.length - 1 == index;
  }

  bool _isCurrent(int index) {
    return currentStep == index;
  }

  bool _isDark() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  bool _isLabel() {
    for (final CheckStep step in widget.steps) {
      if (step.label != null) {
        return true;
      }
    }
    return false;
  }

  Widget _buildLine(bool visible) {
    return Container(
      width: visible ? 1.0 : 0.0,
      height: 0.0,
      color: Colors.grey.shade400,
    );
  }

  Widget _buildCircleChild(int index) {
    final CheckStepState state = widget.steps[index].state;
    switch (state) {
      case CheckStepState.indexed:
      case CheckStepState.complete:
      case CheckStepState.completeStop:
      case CheckStepState.error:
      case CheckStepState.errorStop:
      case CheckStepState.warning:
        return Icon(
          state.icon,
          color: state.color(),
          size: 24.0,
        );
      case CheckStepState.loading:
        return const CircularProgressIndicator.adaptive();
    }
  }

  Widget _buildIcon(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: _kStepSize,
      height: _kStepSize,
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: kThemeAnimationDuration,
        child: Center(
          child: _buildCircleChild(index),
        ),
      ),
    );
  }

  Widget _buildVerticalContent(int stepIndex) {
    if (widget.controlsBuilder != null) {
      return widget.controlsBuilder!(
        context,
        CheckControlsDetails(
          currentStep: currentStep,
          onStepContinue: widget.onStepContinue,
          onStepCancel: widget.onStepCancel,
          stepIndex: stepIndex,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 0.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 0.0),
        child: Row(
          // The Material spec no longer includes a Stepper widget. The continue
          // and cancel button styles have been configured to match the original
          // version of this widget.
          children: <Widget>[
            // TextButton(
            //   onPressed: widget.onStepContinue,
            //   style: ButtonStyle(
            //     foregroundColor: MaterialStateProperty.resolveWith<Color?>(
            //         (Set<MaterialState> states) {
            //       return states.contains(MaterialState.disabled)
            //           ? null
            //           : (_isDark()
            //               ? colorScheme.onSurface
            //               : colorScheme.onPrimary);
            //     }),
            //     backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            //         (Set<MaterialState> states) {
            //       return _isDark() || states.contains(MaterialState.disabled)
            //           ? null
            //           : colorScheme.primary;
            //     }),
            //     padding: const MaterialStatePropertyAll<EdgeInsetsGeometry>(
            //         buttonPadding),
            //     shape:
            //         const MaterialStatePropertyAll<OutlinedBorder>(buttonShape),
            //   ),
            //   child: Text(themeData.useMaterial3
            //       ? localizations.continueButtonLabel
            //       : localizations.continueButtonLabel.toUpperCase()),
            // ),
            // Container(
            //   margin: const EdgeInsetsDirectional.only(start: 8.0),
            //   child: TextButton(
            //     onPressed: widget.onStepCancel,
            //     style: TextButton.styleFrom(
            //       foregroundColor: cancelColor,
            //       padding: buttonPadding,
            //       shape: buttonShape,
            //     ),
            //     child: Text(themeData.useMaterial3
            //         ? localizations.cancelButtonLabel
            //         : localizations.cancelButtonLabel.toUpperCase()),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  TextStyle _titleStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    switch (widget.steps[index].state) {
      case CheckStepState.indexed:
      case CheckStepState.loading:
        return textTheme.bodyLarge!;
      case CheckStepState.complete:
      case CheckStepState.completeStop:
        return textTheme.bodyLarge!.copyWith(
          color: widget.steps[index].state.color(),
        );
      case CheckStepState.warning:
        return textTheme.bodyLarge!.copyWith(
          color: Colors.orangeAccent.shade400,
        );
      case CheckStepState.error:
      case CheckStepState.errorStop:
        return textTheme.bodyLarge!.copyWith(
          color: _isDark() ? _kErrorDark : _kErrorLight,
        );
    }
  }

  TextStyle _subtitleStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    switch (widget.steps[index].state) {
      case CheckStepState.indexed:
      case CheckStepState.complete:
      case CheckStepState.completeStop:
      case CheckStepState.loading:
        return textTheme.bodySmall!;
      case CheckStepState.warning:
        return textTheme.bodyLarge!.copyWith(
          color: Colors.orangeAccent.shade400,
        );
      case CheckStepState.error:
      case CheckStepState.errorStop:
        return textTheme.bodySmall!.copyWith(
          color: _isDark() ? _kErrorDark : _kErrorLight,
        );
    }
  }

  TextStyle _labelStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    switch (widget.steps[index].state) {
      case CheckStepState.indexed:
      case CheckStepState.complete:
      case CheckStepState.completeStop:
      case CheckStepState.loading:
        return textTheme.bodyLarge!;
      case CheckStepState.warning:
        return textTheme.bodyLarge!.copyWith(
          color: Colors.orangeAccent.shade400,
        );
      case CheckStepState.error:
      case CheckStepState.errorStop:
        return textTheme.bodyLarge!.copyWith(
          color: _isDark() ? _kErrorDark : _kErrorLight,
        );
    }
  }

  Widget _buildWidgetStatus(int index) {
    switch (widget.steps[index].state) {
      case CheckStepState.error:
      case CheckStepState.errorStop:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${widget.steps[index].error}",
            ),
            if (widget.steps[index].errorCallback != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);

                      final type = await widget.steps[index]
                          .errorCallback!(widget.steps[index].error);
                      if (type == CheckStepsErrorType.close) {
                        navigator.pop();
                      } else {
                        widget.steps[index].alreadyChecked = false;
                        startCheck();
                      }
                    },
                    child: Text(widget.steps[index].errorCallbackText),
                  ),
                ],
              ),
          ],
        );
      case CheckStepState.complete:
      case CheckStepState.warning:
      case CheckStepState.completeStop:
        return widget.steps[index].message != null
            ? SetMessageWidget(
                item: widget.steps[index].message!,
                status: widget.steps[index].state,
              )
            : const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeaderText(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedDefaultTextStyle(
          style: _titleStyle(index),
          duration: kThemeAnimationDuration,
          curve: Curves.fastOutSlowIn,
          child: Text(
            widget.steps[index].title,
            style: _titleStyle(index),
          ),
        ),
        if (widget.steps[index].subtitle != null)
          Container(
            margin: const EdgeInsets.only(top: 2.0),
            child: AnimatedDefaultTextStyle(
              style: _subtitleStyle(index),
              duration: kThemeAnimationDuration,
              curve: Curves.fastOutSlowIn,
              child: widget.steps[index].subtitle!,
            ),
          ),
      ],
    );
  }

  Widget _buildLabelText(int index) {
    if (widget.steps[index].label != null) {
      return AnimatedDefaultTextStyle(
        style: _labelStyle(index),
        duration: kThemeAnimationDuration,
        child: widget.steps[index].label!,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildVerticalHeader(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              // Line parts are always added in order for the ink splash to
              // flood the tips of the connector lines.
              _buildLine(!_isFirst(index)),
              _buildIcon(index),
              _buildLine(!_isLast(index)),
            ],
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsetsDirectional.only(start: 12.0),
              child: _buildHeaderText(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBody(int index) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          start: 24.0,
          top: 0.0,
          bottom: 0.0,
          child: SizedBox(
            width: 24.0,
            child: Center(
              child: SizedBox(
                width: _isLast(index) ? 0.0 : 1.0,
                child: Container(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0.0),
          secondChild: Container(
            margin: widget.margin ??
                const EdgeInsetsDirectional.only(
                  start: 60.0,
                  end: 24.0,
                  bottom: 24.0,
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildWidgetStatus(index),
                _buildVerticalContent(index),
              ],
            ),
          ),
          firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
          secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: widget.steps[index].isActive
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: kThemeAnimationDuration,
        ),
      ],
    );
  }

  Widget _buildVertical() {
    return ListView(
      shrinkWrap: true,
      physics: widget.physics,
      children: <Widget>[
        for (int i = 0; i < widget.steps.length; i += 1)
          Visibility(
            visible: widget.steps[i].isActive,
            replacement: const SizedBox.shrink(),
            child: Column(
              key: _keys[i],
              children: <Widget>[
                _buildVerticalHeader(i),
                _buildVerticalBody(i),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Builder(
              builder: (_) {
                if (widget.onTente != null) {
                  return TextButton(
                    onPressed: () async {
                      for (var i = 0; i < widget.steps.length; i++) {
                        widget.steps[i].alreadyChecked = false;
                        widget.steps[i].isActive = false;
                      }
                      widget.steps[0].isActive = true;
                      setState(() {});
                      startCheck();
                    },
                    child: const Text("TENTAR NOVAMENTE"),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            TextButton(
              onPressed: () async {
                if (widget.onSave != null) widget.onSave!();
                Navigator.of(context).pop();
              },
              child: const Text("Fechar"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHorizontal() {
    final List<Widget> children = <Widget>[
      for (int i = 0; i < widget.steps.length; i += 1) ...<Widget>[
        InkResponse(
          onTap: () {
            widget.onStepTapped?.call(i);
          },
          child: Row(
            children: <Widget>[
              SizedBox(
                height: _isLabel() ? 104.0 : 72.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (widget.steps[i].label != null)
                      const SizedBox(
                        height: 24.0,
                      ),
                    Center(child: _buildIcon(i)),
                    if (widget.steps[i].label != null)
                      SizedBox(
                        height: 24.0,
                        child: _buildLabelText(i),
                      ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(start: 12.0),
                child: _buildHeaderText(i),
              ),
            ],
          ),
        ),
        if (!_isLast(i))
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 1.0,
              color: Colors.grey.shade400,
            ),
          ),
      ],
    ];

    final List<Widget> stepPanels = <Widget>[];
    for (int i = 0; i < widget.steps.length; i += 1) {
      // stepPanels.add(
      //   Visibility(
      //     maintainState: true,
      //     visible: i == currentStep,
      //     child: widget.steps[i].content,
      //   ),
      // );
    }

    return Column(
      children: <Widget>[
        Material(
          elevation: widget.elevation ?? 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: children,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            physics: widget.physics,
            padding: const EdgeInsets.all(24.0),
            children: <Widget>[
              AnimatedSize(
                curve: Curves.fastOutSlowIn,
                duration: kThemeAnimationDuration,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: stepPanels),
              ),
              _buildVerticalContent(currentStep),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(() {
      if (context.findAncestorWidgetOfExactType<CheckStepper>() != null) {
        throw FlutterError(
          'Steppers must not be nested.\n'
          'The material specification advises that one should avoid embedding '
          'steppers within steppers. '
          'https://material.io/archive/guidelines/components/steppers.html#steppers-usage',
        );
      }
      return true;
    }());

    return LayoutBuilder(
      builder: (context, c) {
        switch (widget.type) {
          case CheckStepperType.vertical:
            return Container(
              width: kIsWeb && (MediaQuery.of(context).size.width >= 768)
                  ? 400
                  : c.maxWidth,
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _buildVertical(),
            );
          case CheckStepperType.horizontal:
            return _buildHorizontal();
        }
      },
    );
  }
}

class SetMessageWidget extends StatelessWidget {
  final SetMessage item;
  final CheckStepState status;
  const SetMessageWidget({super.key, required this.item, required this.status});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.message,
          style: const TextStyle().copyWith(),
        ),
        if (item.onTap != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: const ButtonStyle().copyWith(
                  backgroundColor: MaterialStateProperty.all(status.color()),
                ),
                onPressed: () async {
                  if (item.onTap != null) {
                    item.onTap!();
                  }
                },
                child: Text(
                  item.textOnTap ?? "",
                  style: const TextStyle().copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class SetMessage {
  String message;
  VoidCallback? onTap;
  String? textOnTap = "Ok";
  double heightLine = 20;
  SetMessage._({required this.message});

  SetMessage.message({required this.message, this.heightLine = 20});
  SetMessage.messageWithAction(
      {required this.message,
      required this.onTap,
      required this.textOnTap,
      this.heightLine = 20});
}

enum CheckStepsErrorType {
  close,
  refreshAction,
}

extension CheckStatusTypeExtension on CheckStepState {
  double heightLine(String? message) {
    switch (this) {
      case CheckStepState.error:
        return 70;
      case CheckStepState.warning:
        return 70;
      default:
        return 20;
    }
  }

  Color color() {
    switch (this) {
      case CheckStepState.errorStop:
      case CheckStepState.error:
        return Colors.redAccent;
      case CheckStepState.complete:
      case CheckStepState.completeStop:
        return Colors.green.shade400;
      case CheckStepState.warning:
        return Colors.orange.shade400;
      case CheckStepState.loading:
      case CheckStepState.indexed:
        return const Color(0x00232323);
    }
  }

  bool get hasError =>
      this == CheckStepState.error; // || this == CheckStepState.errorStop;
  bool get hasWarning => this == CheckStepState.warning;
  bool get hasSuccess =>
      this == CheckStepState.complete; // || this == CheckStepState.successStop;

  IconData get icon {
    switch (this) {
      case CheckStepState.error:
      case CheckStepState.errorStop:
        return Icons.error;

      case CheckStepState.complete:
      case CheckStepState.completeStop:
        return Icons.check_circle_rounded;

      case CheckStepState.warning:
        return Icons.warning;

      default:
        return Icons.minimize_sharp;
    }
  }
}
