import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:condogaiaapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Fluxo de login do Representante navega para fora da tela de Login', (tester) async {
    app.main();
    // Aguarda a splash screen aparecer e desaparecer (3 segundos)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Encontra os campos de email, senha e botão de envio
    final emailField = find.byKey(const Key('login_email'));
    final passwordField = find.byKey(const Key('login_password'));
    final submitButton = find.byKey(const Key('login_submit'));

    // Valida que todos os elementos existem
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(submitButton, findsOneWidget);

    // Preenche os campos com credenciais de teste
    // TODO: Substituir com credenciais de staging ou carregar de variáveis de ambiente
    await tester.enterText(emailField, 'alex@gmail.com');
    await tester.enterText(passwordField, '123456');

    // Clica no botão de entrada
    await tester.tap(submitButton);
    // Aguarda as requisições de autenticação completarem (até 8 segundos)
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // Valida que não estamos mais na tela de login
    // Se saiu da tela, o botão "Entrar" não deve existir mais
    expect(find.byKey(const Key('login_submit')), findsNothing);
  });
}
