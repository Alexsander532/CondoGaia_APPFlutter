# 🔑 ERRO: Keystore Não Encontrado

## ❌ Problema

O Gradle está procurando por:
```
C:\Users\Alexsander\Desktop\Aplicativos\APPflutter\upload-keystore-condogaia.jks
```

Mas o arquivo **NÃO ESTÁ** nesse local.

---

## ✅ Solução

### Passo 1: Localize o arquivo `upload-keystore-condogaia.jks`

Você mencionou que criou ontem. Procure em:
- 📁 Desktop
- 📁 Downloads
- 📁 Documentos
- 📁 Pasta do projeto

### Passo 2: Copie para o local correto

**Opção A (Recomendado):** Colocar na raiz do projeto

```
c:\Users\Alexsander\Desktop\Aplicativos\APPflutter\condogaiaapp\
  └── upload-keystore-condogaia.jks  ← Copie aqui
```

Então atualize `android/key.properties`:
```properties
storeFile=C:\\Users\\Alexsander\\Desktop\\Aplicativos\\APPflutter\\condogaiaapp\\upload-keystore-condogaia.jks
```

**Opção B:** Deixar onde está (se estiver em outro lugar)

Se o arquivo está em:
```
c:\Users\Alexsander\Desktop\Aplicativos\APPflutter\upload-keystore-condogaia.jks
```

Então o `key.properties` ESTÁ correto.

---

## 📋 Passos Rápidos

### Se o arquivo está no Desktop:

1. Abra: `C:\Users\Alexsander\Desktop`
2. Procure por: `upload-keystore-condogaia.jks`
3. Copie o arquivo
4. Vá para: `C:\Users\Alexsander\Desktop\Aplicativos\APPflutter\condogaiaapp`
5. Cole aqui
6. Atualize `android/key.properties` (veja abaixo)

### Se encontrou o arquivo:

Execute no terminal:
```bash
cd c:\Users\Alexsander\Desktop\Aplicativos\APPflutter\condogaiaapp
flutter build appbundle --release
```

---

## 🔍 Verificar Onde Está o Arquivo

Abra PowerShell e execute:

```powershell
# Procurar em Desktop
Get-ChildItem -Path "$env:USERPROFILE\Desktop" -Filter "*keystore*" -Recurse

# Procurar em Downloads
Get-ChildItem -Path "$env:USERPROFILE\Downloads" -Filter "*keystore*" -Recurse

# Procurar em Documentos
Get-ChildItem -Path "$env:USERPROFILE\Documents" -Filter "*keystore*" -Recurse

# Procurar em todo o disco (pode levar tempo!)
Get-ChildItem -Path "C:\" -Filter "*condogaia*.jks" -Recurse -ErrorAction SilentlyContinue
```

---

## 📝 Atualizar `android/key.properties`

Depois de encontrar o arquivo, abra `android/key.properties` e atualize o caminho:

**Se está na raiz do projeto:**
```properties
storeFile=C:\\Users\\Alexsander\\Desktop\\Aplicativos\\APPflutter\\condogaiaapp\\upload-keystore-condogaia.jks
```

**Se está em outro lugar (substitua pelo caminho real):**
```properties
storeFile=C:\\Caminho\\Completo\\upload-keystore-condogaia.jks
```

⚠️ **Importante:** Use `\\` (dupla barra invertida) no Windows!

---

## 🚀 Após Atualizar

Execute:
```bash
flutter clean
flutter build appbundle --release
```

---

## ❓ Não encontrou o arquivo?

Duas opções:

### Opção 1: Você ainda não criou o keystore

Se não criou ainda, execute:
```bash
keytool -genkey -v -keystore "C:\Users\Alexsander\Desktop\Aplicativos\APPflutter\condogaiaapp\upload-keystore-condogaia.jks" ^
  -keyalg RSA ^
  -keysize 2048 ^
  -validity 10000 ^
  -alias upload
```

### Opção 2: Recuperar do backup

Se perdeu, refaça o processo de geração de keystore.

---

## 📞 Próximos Passos

1. Localize o arquivo `.jks`
2. Copie para o local correto (ou anote o caminho real)
3. Atualize `android/key.properties`
4. Execute: `flutter clean && flutter build appbundle --release`

Avise quando conseguir localizar o arquivo!
