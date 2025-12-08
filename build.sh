#!/bin/bash

# Configurações
FLUTTER_VERSION="3.35.0"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

echo "🚀 Iniciando build do Flutter..."

# Baixar e instalar Flutter
echo "📦 Baixando Flutter ${FLUTTER_VERSION}..."
cd /tmp
curl -L -o flutter.tar.xz "$FLUTTER_URL"
tar -xf flutter.tar.xz

# Configurar PATH
export PATH="/tmp/flutter/bin:$PATH"

# Configurar Git para evitar problemas de permissão
git config --global --add safe.directory /vercel/path0
git config --global --add safe.directory /tmp/flutter

# Desabilitar analytics do Flutter
flutter config --no-analytics

# Desabilitar Wasm - usar JavaScript tradicional
export FLUTTER_WEB_USE_WASM=false

# Verificar versão do Flutter
echo "✅ Versão do Flutter:"
flutter --version

# Voltar para o diretório do projeto
cd /vercel/path0

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
flutter clean
rm -rf build/web

# Instalar dependências
echo "📚 Instalando dependências..."
flutter pub get

# Fazer build para web com JavaScript (não Wasm)
echo "🔨 Fazendo build para web..."
flutter build web --release --dart-define=FLUTTER_WEB_USE_WASM=false

echo "🎉 Build concluído com sucesso!"