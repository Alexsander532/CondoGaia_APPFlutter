# 🔧 INSTRUÇÕES: Remover MainActivity Antigo

## O Problema

Existem **2 MainActivity.kt**:

```
✅ CORRETO:   android/app/src/main/kotlin/br/com/condogaia/MainActivity.kt
              package br.com.condogaia

❌ ERRADO:    android/app/src/main/kotlin/com/example/condogaiaapp/MainActivity.kt
              package com.example.condogaiaapp
```

O build.gradle.kts espera em `br.com.condogaia`, então o arquivo antigo causa conflito!

---

## ✅ Solução

### 1. Deletar arquivo antigo MANUALMENTE:

```
Caminho a deletar:
android/app/src/main/kotlin/com/example/condogaiaapp/MainActivity.kt
```

**Como fazer no VS Code:**
1. Abra o Explorer (Ctrl+Shift+E)
2. Navegue para: `android/app/src/main/kotlin/com/example/condogaiaapp/`
3. Clique com botão direito em `MainActivity.kt`
4. Selecione "Delete" (ou "Deletar")
5. Confirme

**Ou via Terminal:**
```bash
rm -Force "android/app/src/main/kotlin/com/example/condogaiaapp/MainActivity.kt"
```

---

### 2. Verificar se a pasta `com/example/condogaiaapp` ficou vazia:

Se a pasta ficar vazia, delete ela também:
```bash
rm -Recurse "android/app/src/main/kotlin/com"
```

---

### 3. Verificar AndroidManifest.xml:

Abra e verifique se está assim:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    
    <application
        android:label="condogaiaapp"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            ...
```

✅ **Correto!** (Usa `.MainActivity` que Flutter resolve para o package correto)

---

### 4. Build Limpo:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

---

## ✅ Resultado Esperado

Após deletar arquivo antigo:

```
📁 android/app/src/main/kotlin/
└── 📁 br/
    └── 📁 com/
        └── 📁 condogaia/
            └── 📄 MainActivity.kt  ✅ ÚNICO (correto!)
```

**Sem:** `com/example/condogaiaapp/` ✅

---

## 🚀 Próximas Ações

1. **Deletar** `com/example/condogaiaapp/MainActivity.kt`
2. **Executar**: `flutter clean && flutter pub get`
3. **Build**: `flutter build appbundle --release`
4. **Upload**: Google Play Console

---

**Status**: Aguardando você deletar o arquivo antigo manualmente!
