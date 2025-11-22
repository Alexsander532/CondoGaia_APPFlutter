# 🚀 Guia Rápido de Testes - Upload de Fotos e PDFs na Criação de Pastas

**Tempo Estimado:** 15-20 minutos por plataforma

---

## ✅ Checklist de Teste Rápido

### Setup Inicial (5 min)
- [ ] `flutter clean`
- [ ] `flutter pub get`
- [ ] Verificar sem erros: `flutter analyze`

### Android (10-15 min)
```bash
flutter run -d emulator
```

**Testes:**
- [ ] 1. Abrir "Criar Pasta"
- [ ] 2. Clique "📸 Tirar Foto" → Câmera abre ✓
- [ ] 3. Tire uma foto → Aparece em "Fotos Selecionadas" ✓
- [ ] 4. Clique "📸" novamente → Segunda foto adicionada ✓
- [ ] 5. Clique "📄 PDF" → File picker abre (filtro .pdf) ✓
- [ ] 6. Selecione um PDF → Aparece em "PDFs Selecionados" ✓
- [ ] 7. Clique "✕" em uma foto → Remove da lista ✓
- [ ] 8. Clique "✕" no PDF → Remove da lista ✓
- [ ] 9. Selecione 2 fotos + 1 PDF novamente
- [ ] 10. Preencha "Nome da Pasta"
- [ ] 11. Clique "Criar Pasta" → Aguarde upload
- [ ] 12. SnackBar mostra sucesso com detalhes ✓
- [ ] 13. Volta à tela anterior ✓
- [ ] 14. Reabra "Criar Pasta" → Listas vazias (limpeza OK) ✓

### iOS (10-15 min)
```bash
flutter run -d iphone
```

**Testes:** (Mesmos passos de Android)
- [ ] Foto via câmera
- [ ] Foto via galeria
- [ ] Seleção de PDF
- [ ] Remoção de arquivos
- [ ] Upload com sucesso
- [ ] Permissões funcionam

### Web (10-15 min)
```bash
flutter run -d chrome
```

**Testes:** (Sem câmera)
- [ ] Abrir "Criar Pasta"
- [ ] Clique "📸 Tirar Foto" → Seleciona arquivo de imagem ✓
- [ ] Clique "📄 PDF" → Seleciona PDF ✓
- [ ] Visualizar fotos/PDFs selecionados ✓
- [ ] Remover arquivos ✓
- [ ] Criar pasta com upload ✓
- [ ] Feedback de sucesso ✓

---

## 🎯 Casos de Teste Essenciais

### Teste 1: Happy Path (Tudo OK)
```
1. Criar pasta com: Nome + 2 Fotos + 1 PDF
2. Esperado: Sucesso em todos os uploads
3. Resultado: ✅ Pasta com 3 arquivos
```

### Teste 2: Retrocompatibilidade
```
1. Criar pasta com: APENAS Nome (sem arquivos)
2. Esperado: Funciona como antes
3. Resultado: ✅ Pasta criada sem problemas
```

### Teste 3: Remoção de Erro
```
1. Selecionar foto errada
2. Remover via "✕"
3. Selecionar foto correta
4. Criar pasta
5. Resultado: ✅ Apenas foto correta foi salva
```

### Teste 4: Múltiplos Arquivos
```
1. Adicionar 3+ fotos + 2+ PDFs
2. Criar pasta
3. Resultado: ✅ Todos uploaded
```

### Teste 5: Feedback de Sucesso
```
1. Criar com: Nome + Foto + Link + PDF
2. Esperado SnackBar: 
   "Pasta criada com sucesso! Link adicionado. 
    Fotos enviadas. PDFs enviados."
3. Resultado: ✅ Mensagem exata aparece
```

---

## 🐛 Problemas Conhecidos & Soluções

| Problema | Causa | Solução |
|----------|-------|---------|
| Câmera não abre | Permissão negada | Liberar em Configurações |
| PDF não copia | Sem espaço | Liberar espaço em disco |
| Upload falha | Sem internet | Verificar WiFi/dados |
| Foto não aparece | Bug de UI | `flutter clean` |
| Layout errado | Versão antiga | `flutter pub upgrade` |

---

## 📱 Resultado Esperado (Screenshots)

### Tela Inicial
```
Nome: [Minha Pasta]
Privacidade: ◎ Público
Link: [https://...]
[📸 Tirar Foto] [📄 PDF]
```

### Após Selecionar Fotos
```
Fotos Selecionadas:
┌─ 🖼️ foto_123.jpg ✕
└─ 🖼️ foto_124.jpg ✕
```

### Após Selecionar PDFs
```
PDFs Selecionados:
┌─ 📄 documento.pdf ✕
└─ 📄 contrato.pdf  ✕
```

### Após Criar
```
✓ "Pasta criada com sucesso! 
   Link adicionado. 
   Fotos enviadas. 
   PDFs enviados."
```

---

## 🔍 Debug Commands

```bash
# Ver logs completos
flutter run -v

# Verificar permissões (Android)
adb shell pm list permissions | grep -i camera

# Verificar arquivos temp (Android)
adb shell ls /data/data/[package_name]/app_flutter/

# Clear cache
flutter clean && flutter pub get

# Compilar sem otimização
flutter run --debug

# Compilar otimizado
flutter run --release
```

---

## ✨ Validação Final

Antes de marcar como "Completo", confirme:

- [ ] Nenhum erro de compilação
- [ ] Nenhum warning
- [ ] UI renderiza corretamente
- [ ] Botões respondem ao clique
- [ ] Câmera/galeria abrem
- [ ] File picker abre
- [ ] Arquivos aparecem na lista
- [ ] Upload funciona
- [ ] Feedback aparece
- [ ] Volta à tela anterior
- [ ] Funciona 3x seguidas (sem memory leak)

---

## 📊 Resultado do Teste

```
Data: ___/___/_____
Testador: _________________
Plataforma: ☐ Android  ☐ iOS  ☐ Web

Resultado Geral:
☐ ✅ PASSOU - Tudo funciona
☐ ⚠️  PASSOU COM RESSALVAS - Pequenos bugs
☐ ❌ FALHOU - Problemas críticos

Problemas Encontrados:
1. _________________________________
2. _________________________________
3. _________________________________

Observações:
________________________________
```

---

## 🎉 Conclusão

Quando todos os testes passarem:

```
✅ Feature está pronta para produção
✅ Implementação 100% completa
✅ Documentação gerada
✅ Código sem erros
✅ UX validada
```

---

*Guia criado em: 22 de Novembro de 2025*  
*Tempo estimado: 15-20 min por plataforma*  
*Prioridade: ALTA - Feature solicitada pelo usuário*
