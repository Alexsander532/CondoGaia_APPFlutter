#!/bin/bash

# Script de build para Flutter na Vercel
echo "🚀 Iniciando build do Flutter..."

# Download e instalação do Flutter
echo "📦 Baixando Flutter 3.27.1..."
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.1-stable.tar.xz | tar -xJ

# Configuração do PATH
export PATH="$PWD/flutter/bin:$PATH"

# Correção de permissões Git
git config --global --add safe.directory /vercel/path0/flutter

# Desabilitar analytics
flutter config --no-analytics

# Verificar versão
echo "✅ Versão do Flutter:"
flutter --version

# Instalar dependências
echo "📚 Instalando dependências..."
flutter pub get

# Build para web
echo "🔨 Fazendo build para web..."
flutter build web --release

echo "🎉 Build concluído com sucesso!"