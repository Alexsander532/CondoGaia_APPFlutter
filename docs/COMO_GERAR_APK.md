# Guia para Gerar APK de Release (Android)

Este guia explica como gerar o arquivo APK assinado para o aplicativo CondoGaia no ambiente Linux.

## Pré-requisitos
1.  **Keystore**: O arquivo `upload-keystore-condogaia.jks` deve estar na raiz do projeto.
2.  **Configuração de Assinatura**: O arquivo `android/key.properties` deve conter as senhas corretas e o caminho para o keystore (`../../upload-keystore-condogaia.jks`).
3.  **SDK do Android**: Certifique-se de que o SDK do Android esteja instalado e configurado corretamente no seu sistema.

## Passos para Gerar o APK

Abra o terminal na raiz do projeto e execute os seguintes comandos:

1.  **Limpar o projeto**:
    ```bash
    flutter clean
    ```

2.  **Obter as dependências**:
    ```bash
    flutter pub get
    ```

3.  **Gerar o APK de Release**:
    ```bash
    flutter build apk --release
    ```

## Onde encontrar o arquivo gerado?
Após a conclusão do comando acima, o APK estará localizado em:
`build/app/outputs/flutter-apk/app-release.apk`

---
> [!NOTE]
> Se você precisar de um **App Bundle** (para upload na Google Play Store), use:
> `flutter build appbundle --release`
