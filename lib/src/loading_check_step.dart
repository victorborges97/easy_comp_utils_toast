// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class EasyCompLoadingSteps extends StatefulWidget {
  final List<LoadingStep> steps;
  final bool onCloseFinish;
  const EasyCompLoadingSteps(
      {super.key, required this.steps, this.onCloseFinish = false});
  @override
  State<EasyCompLoadingSteps> createState() => _EasyCompLoadingStepsState();
}

class _EasyCompLoadingStepsState extends State<EasyCompLoadingSteps> {
  int currentStep = 0;
  int? oldStep;
  dynamic e;

  @override
  void initState() {
    super.initState();

    checkItens();
  }

  Future tentarNovamente() async {
    e = null;
    oldStep = null;
    currentStep = 0;
    setState(() {});
    await checkItens();
  }

  Future checkItens() async {
    for (var i = 0; i < widget.steps.length; i++) {
      try {
        var item = widget.steps[i];
        currentStep = i;
        widget.steps[i].message = null;
        setState(() {});
        await item.check(
          (message) {
            if (message.type == LoadingStepMessageType.message) {
              widget.steps[i].message = message;
              setState(() {});
            } else {
              showToast(
                message.message,
                position: StyledToastPosition.top,
                context: context,
              );
            }
          },
        );
        oldStep = i;

        if (widget.onCloseFinish) {
          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.pop(context, true);
          });
        } else {
          if ((widget.steps.length - 1) == i &&
              widget.steps[i].message == null) {
            //ULTIMO
            Future.delayed(const Duration(milliseconds: 300), () {
              Navigator.pop(context, true);
            });
          }
        }
      } catch (e) {
        this.e = e;
        setState(() {});
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 38, fontWeight: FontWeight.w600);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: widget.steps.map((step) {
                    int index = widget.steps.indexOf(step);
                    if (currentStep != index) {
                      if ((oldStep != null && oldStep == index)) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 50),
                          child: AnimatedOpacity(
                            opacity: 0.4,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                            child: Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: FadeInUp(
                                    child: Text(
                                      step.title,
                                      style: textStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  step.title,
                                  style: textStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (e != null)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox.fromSize(size: const Size(50, 0)),
                                  Expanded(
                                    child: Text(
                                      "Error: $e",
                                      style: textStyle.copyWith(
                                        fontSize: 18,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (step.actionError != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => step.actionError!
                                          .onTap(tentarNovamente),
                                      child: Text(step.actionError!.text),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        Column(
                          children: [
                            if (step.message != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox.fromSize(size: const Size(50, 0)),
                                  Expanded(
                                    child: Text(
                                      step.message!.message,
                                      style: step.message!.textStyle ??
                                          textStyle.copyWith(
                                            fontSize: 18,
                                            color: Colors.grey.shade400,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            if (step.message != null &&
                                step.message!.onAction != null &&
                                step.message!.textAction != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => step
                                        .message!.onAction!(tentarNovamente),
                                    style: step.message!.buttonStyle,
                                    child: Text(step.message!.textAction!,
                                        style: step.message!.textActionStyle),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              if (e == null) SizedBox.fromSize(size: const Size(0, 50)),
              if (e == null)
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(
                    begin: 0,
                    end: (widget.steps.isEmpty)
                        ? 0.0
                        : (currentStep.toDouble() / (widget.steps.length - 1)),
                  ),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
              SizedBox.fromSize(size: const Size(0, 50)),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingStep {
  final String title;
  final Future<void> Function(
      void Function(LoadingStepMessage message) setMessage) check;
  final LoadingStepAction? actionError;
  LoadingStepMessage? message;
  LoadingStep({
    required this.title,
    required this.check,
    this.actionError,
  }) : message = null;
}

class LoadingStepAction {
  String text;
  Function(VoidCallback refresh) onTap;
  ButtonStyle? buttonStyle;
  TextStyle? textStyle;
  LoadingStepAction({
    required this.text,
    required this.onTap,
    this.buttonStyle,
    this.textStyle,
  });
}

class LoadingStepMessage {
  String message;
  String? textAction;
  Function(VoidCallback refresh)? onAction;
  ButtonStyle? buttonStyle;
  TextStyle? textStyle;
  TextStyle? textActionStyle;
  LoadingStepMessageType type;
  LoadingStepMessage({
    required this.message,
    this.onAction,
    this.textAction,
    this.buttonStyle,
    this.textStyle,
    this.textActionStyle,
    this.type = LoadingStepMessageType.message,
  });
}

enum LoadingStepMessageType {
  message,
  toast,
}
