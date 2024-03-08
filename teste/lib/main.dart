import 'package:easy_comp_utils_dialog/easy_comp_utils_dialog.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.purple,
    ),
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teste"),
      ),
      body: Column(
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
                        StepMessage.message(
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
          TextButton(
            child: const Text("Nubank"),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (c) => EasyCompLoadingSteps(
                    steps: [
                      LoadingStep(
                        title: 'Validação',
                        check: (setMessage) async {
                          await Future.delayed(const Duration(seconds: 2));
                        },
                      ),
                      LoadingStep(
                        title: 'Iniciando sua cobrança',
                        check: (setMessage) async {
                          await Future.delayed(const Duration(seconds: 2));
                          // throw "Error simulação de como vai ficar, se vai quebra ou algo do tipo";
                        },
                        actionError: LoadingStepAction(
                          text: "Voltar",
                          onTap: (refresh) {
                            refresh();
                          },
                        ),
                      ),
                      LoadingStep(
                        title: 'Emitindo a Nota',
                        check: (setMessage) async {
                          await Future.delayed(const Duration(seconds: 2));
                          setMessage(LoadingStepMessage(
                            message:
                                "HOUVE ERRO AO REALIZAR A VENDA\n\nErro: Data de Validade do Certificado jÂ. expirou: 20/01/2024\nNumero Série: 601\nNumero Nota: 199",
                            type: LoadingStepMessageType.toast,
                          ));
                          // throw "Error simulação de como vai ficar, se vai quebra ou algo do tipo";
                        },
                        actionError: LoadingStepAction(
                          text: "Voltar",
                          onTap: (refresh) {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      LoadingStep(
                        title: 'Finalizando venda',
                        check: (setMessage) async {
                          await Future.delayed(const Duration(seconds: 2));
                          // throw "Error simulação de como vai ficar, se vai quebra ou algo do tipo";
                        },
                        actionError: LoadingStepAction(
                          text: "Voltar",
                          onTap: (refresh) {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      LoadingStep(
                        title: 'Gerando o comprovante',
                        check: (setMessage) async {
                          setMessage(LoadingStepMessage(
                            message: "Acesse o comprovante",
                            onAction: (onTente) {
                              Navigator.of(context).pop();
                            },
                            textAction: "Acessar",
                          ));

                          await Future.delayed(const Duration(seconds: 2));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
