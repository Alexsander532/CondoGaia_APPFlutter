# 📱 Justificativas de Permissões - Google Play Console

## Permissão: READ_MEDIA_IMAGES (Leitura de Fotos)

### Justificativa para o Google Play Console:

```
O aplicativo CondoGaia requer acesso a fotos com frequência porque:

1. FUNCIONALIDADE PRINCIPAL
   - Permite que moradores façam upload de fotos de identificação para verificação de residência
   - Permite que representantes capturem fotos de documentos (RG, CPF, comprovante de endereço)
   - Permite que administradores selecionem imagens para perfil e configurações do condomínio

2. CASOS DE USO FREQUENTES
   - Upload de foto de perfil do usuário
   - Upload de documentos (cópia de RG/CPF para validação)
   - Seleção de fotos imobiliárias para cada unidade
   - Anexação de evidências para reservas e solicitações

3. ACESSO À GALERIA
   - O usuário abre intencionalmente a galeria de fotos do dispositivo
   - Seleciona uma ou mais imagens
   - O app processa e envia para servidor seguro (Supabase)

4. SEGURANÇA E PRIVACIDADE
   - As fotos são armazenadas em servidor seguro
   - Apenas usuários autenticados conseguem acessar seus próprios dados
   - Não compartilhamos fotos sem consentimento explícito

5. ALTERNATIVAS CONSIDERADAS
   - Consideramos usar Camera Intent exclusivamente, mas usuários precisam também de fotos existentes
   - O seletor de fotos do Android é utilizado quando disponível
   - READ_MEDIA_IMAGES é necessário para compatibilidade com Android 9-12

Conclusão: Esta permissão é essencial e usada com frequência para a funcionalidade central do aplicativo.
```

---

## Permissão: READ_MEDIA_VIDEO (Leitura de Vídeos)

### Justificativa para o Google Play Console:

```
O aplicativo CondoGaia requer acesso a vídeos porque:

1. FUNCIONALIDADE SECUNDÁRIA
   - Permite que moradores façam upload de vídeos de identificação/autenticação
   - Permite que representantes anexem vídeos como evidência em reclamações
   - Possibilita documentação por vídeo de problemas estruturais/manutenção

2. CASOS DE USO
   - Upload de vídeo de tour do apartamento para novas unidades
   - Anexação de vídeos em solicitações de manutenção
   - Documentação de incidentes para gestão

3. ACESSO À GALERIA DE VÍDEOS
   - Usuário abre intencionalmente a galeria de vídeos
   - Seleciona um vídeo existente
   - App processa e envia para servidor seguro

4. FREQUÊNCIA DE USO
   - Usada com menos frequência que fotos, mas essencial quando necessária
   - Usuários com frequência usam para documentação de problemas

5. SEGURANÇA
   - Vídeos são armazenados em servidor seguro (Supabase)
   - Apenas usuários autenticados acessam seus dados
   - Acesso controlado por permissões de usuário (morador/representante/admin)

6. ALTERNATIVAS
   - Seletor de vídeos do Android é utilizado quando disponível
   - READ_MEDIA_VIDEO é necessário para Android 9-12

Conclusão: Esta permissão é importante para a funcionalidade de documentação multimídia do aplicativo.
```

---

## Como Adicionar no Google Play Console

### Passo 1: Acessar Play Console
```
1. Acesse: https://play.google.com/apps/publish
2. Selecione: CondoGaia
3. Menu: App content → Permissions and API declarations
```

### Passo 2: Adicionar Justificativas
```
4. Role para: "Sensitive Permissions" ou "Permissions"
5. Procure por: READ_MEDIA_IMAGES
6. Clique: "Edit justification" ou "Declare use"
7. Cole a justificativa acima
```

### Passo 3: Repetir para Vídeos
```
8. Procure por: READ_MEDIA_VIDEO
9. Repita o processo
10. Salve as alterações
```

---

## Texto Alternativo Mais Resumido

Se o Google pedir um texto menor:

### READ_MEDIA_IMAGES (Curto)
```
O app CondoGaia utiliza READ_MEDIA_IMAGES porque os usuários 
precisam selecionar fotos frequentemente para:
- Upload de identificação
- Upload de documentos
- Fotos de perfil
- Evidências de incidentes

O acesso à galeria é fundamental para a funcionalidade de 
upload de documentos do aplicativo.
```

### READ_MEDIA_VIDEO (Curto)
```
O app CondoGaia utiliza READ_MEDIA_VIDEO para permitir que 
usuários façam upload de vídeos para:
- Documentação de problemas
- Evidências de incidentes
- Tours de unidades

Esta permissão é necessária para a funcionalidade de 
documentação multimídia.
```

---

## ✅ Checklist Após Adicionar

- [ ] Acessou Google Play Console
- [ ] Encontrou "Permissions and API declarations"
- [ ] Adicionou justificativa para READ_MEDIA_IMAGES
- [ ] Adicionou justificativa para READ_MEDIA_VIDEO
- [ ] Clicou "Save" ou "Submit"
- [ ] Aguardou revisão (pode levar 24-48h)

---

## 📝 Notas Importantes

1. **Sinceridade**: Google analisa se a justificativa é honesta
2. **Frequência**: Deixe claro que é uso frequente (não ocasional)
3. **Alternativas**: Mostre que considerou outras opções
4. **Funcionalidade**: Conecte a permissão com features do app

---

**Copie e cole um dos textos acima no Google Play Console!** ✅
