## Componentes

1. CheckStepper
2. DialogHelper

## Instalação

1. Adicione a ultima versão ao arquivo pubspec.yaml (e rode 'dart pub get');

```yaml
dependencies:
    easy_comp_utils_dialog: ^0.0.1+1
```

2. Importe o pacote para usar no seu App Flutter

```dart
import 'package:easy_comp_utils_dialog/easy_comp_utils_dialog.dart';
```

## Modo de usar

-   Usando componente CheckStepper em um Dialog.

```dart
import 'package:flutter/material.dart';
import 'package:easy_comp_utils_dialog/easy_comp_utils_dialog.dart';

class EasyCompTeste extends StatelessWidget {
  const EasyCompTeste({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: TextButton(
            child: const Text("Teste"),
            onPressed: () {
                CheckStepper.show(
                    context: context,
                    checkItens: [
                        CheckStep(
                            title: "Validando",
                            checkStatus: (setMessage) async {
                            await Future.delayed(const Duration(seconds: 1));
                            // throw "Error teste";
                            return CheckStepState.complete;
                            },
                        ),
                        CheckStep(
                            title: "Emitindo Nota",
                            checkStatus: (setMessage) async {
                            await Future.delayed(const Duration(seconds: 1));
                            setMessage(
                                SetMessage.message(
                                    message:
                                        "HOUVE ERRO AO REALIZAR A VENDA\n\nErro: Data de Validade do Certificado jÂ. expirou: 20/01/2024\nNumero Série: 601\nNumero Nota: 199"),
                            );
                            return CheckStepState.warning;
                            },
                        ),
                        CheckStep(
                            title: "Finalizando venda",
                            checkStatus: (setMessage) async {
                            await Future.delayed(const Duration(seconds: 1));
                            return CheckStepState.complete;
                            },
                        ),
                        CheckStep(
                            title: "Gerando comprovante",
                            checkStatus: (setMessage) async {
                            await Future.delayed(const Duration(seconds: 1));
                            return CheckStepState.complete;
                            },
                        ),
                    ],
                );
            },
        ),
      ),
    );
  }
}
```