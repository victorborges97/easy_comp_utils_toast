## Componentes

1. EasyCompUtilsToast

## Instalação

1. Adicione a ultima versão ao arquivo pubspec.yaml (e rode 'dart pub get');

```yaml
dependencies:
    easy_comp_utils_toast: ^0.0.2
```

2. Inicialize a lib passando o [NavigatorState]

```dart
import 'package:easy_comp_utils_toast/easy_comp_utils_toast.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final navigatorKeyGlobal = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    EasyCompUtilsToast.init(navigatorKeyGlobal);
    return MaterialApp(
        title: 'MyApp',
        navigatorKey: navigatorKeyGlobal,
    );
  }
}
```

3. Importe o pacote para usar no seu App Flutter

```dart
import 'package:easy_comp_utils_toast/easy_comp_utils_toast.dart';
```

## Modo de usar

-   Usando componente EasyCompUtilsToast.

```dart
import 'package:flutter/material.dart';
import 'package:easy_comp_utils_toast/easy_comp_utils_toast.dart';

class EasyCompTeste extends StatelessWidget {
  const EasyCompTeste({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: TextButton(
            child: const Text("Teste"),
            onPressed: () async {
                EasyCompUtilsToast.success(
                    message: "success !",
                );
                await Future.delayed(const Duration(seconds: 2));
                EasyCompUtilsToast.info(
                    message: "info !",
                );
                await Future.delayed(const Duration(seconds: 2));
                EasyCompUtilsToast.error(
                    message: "error !",
                );
            },
        ),
      ),
    );
  }
}
```