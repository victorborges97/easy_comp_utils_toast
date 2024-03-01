import 'package:easy_comp_utils_dialog/easy_comp_utils_dialog.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        title: const Text("Teste"),
      ),
      backgroundColor: Colors.grey.shade500,
      body: Builder(builder: (context) {
        print("Init");
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
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
          ],
        );
      }),
    ),
  ));
}