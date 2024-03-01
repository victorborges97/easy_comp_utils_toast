import 'package:flutter/material.dart';

class DialogHelper {
  DialogHelper._();
  static DialogHelperState of(BuildContext context) =>
      DialogHelperState._(context);

  static Future<T?> showHelper<T>({
    required BuildContext context,
    Widget? message,
    VoidCallback? onSim,
    VoidCallback? onNao,
    Color? textColorSim,
    Color? textColorNao,
    String? textSim,
    String? textNao,
    Color? buttonColorSim,
    Color? buttonColorNao,
    Color? backgroundColor,
    EdgeInsetsGeometry? contentPadding,
    Widget? title,
    double? radius,
    EdgeInsetsGeometry? titlePadding,
    TextStyle? titleTextStyle,
    ShapeBorder? shape,
    bool scrollable = false,
  }) {
    final h = DialogHelperState._(context);
    return h.showHelper(
      message: message,
      backgroundColor: backgroundColor,
      buttonColorNao: buttonColorNao,
      buttonColorSim: buttonColorSim,
      contentPadding: contentPadding,
      onNao: onNao,
      onSim: onSim,
      radius: radius,
      scrollable: scrollable,
      shape: shape,
      textColorNao: textColorNao,
      textColorSim: textColorSim,
      textNao: textNao,
      textSim: textSim,
      title: title,
      titlePadding: titlePadding,
      titleTextStyle: titleTextStyle,
    );
  }
}

class DialogHelperState {
  final BuildContext _context;
  const DialogHelperState._(this._context);

  Future<T?> showHelper<T>({
    Widget? message,
    VoidCallback? onSim,
    VoidCallback? onNao,
    Color? textColorSim,
    Color? textColorNao,
    String? textSim,
    String? textNao,
    Color? buttonColorSim,
    Color? buttonColorNao,
    Color? backgroundColor,
    EdgeInsetsGeometry? contentPadding,
    Widget? title,
    double? radius,
    EdgeInsetsGeometry? titlePadding,
    TextStyle? titleTextStyle,
    ShapeBorder? shape,
    bool scrollable = false,
  }) {
    return showDialog<T>(
      context: _context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: scrollable,
          contentPadding: contentPadding ??
              const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          title: title,
          titlePadding: titlePadding,
          titleTextStyle: titleTextStyle,
          backgroundColor: backgroundColor,
          shape: radius != null
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius))
              : shape,
          content:
              message ?? const Text("Você deseja realmente excluir esse item?"),
          actions: <Widget>[
            if (onNao != null)
              MaterialButton(
                color: buttonColorNao ?? Colors.redAccent,
                onPressed: onNao,
                child: Text(
                  textNao ?? "Não",
                  style: TextStyle(
                    color: textColorNao ?? Colors.white,
                  ),
                ),
              ),
            if (onSim != null)
              MaterialButton(
                color: buttonColorSim ?? Theme.of(context).primaryColor,
                onPressed: onSim,
                child: Text(
                  textSim ?? 'Sim',
                  style: TextStyle(
                    color: textColorSim ?? Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
