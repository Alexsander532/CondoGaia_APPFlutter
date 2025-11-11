## 📸 Plano de Distribuição de Fotos de Proprietários e Inquilinos

### Widgets Criados:
- ✅ `FotoPerfilAvatar` - Avatar circular com foto (URL ou Base64)
- ✅ `PessoaListTile` - ListTile com foto + nome + subtitle
- ✅ `PessoaCardComFoto` - Card com foto grande

Arquivo: `lib/widgets/foto_perfil_avatar.dart`

---

### Lugares onde a foto DEVE aparecer:

#### 1. **Portaria do Representante** 
- File: `lib/screens/portaria_representante_screen.dart`
- Exibir fotos na lista de encomendas (Morador/Habitante)
- Mostra foto de proprietários e inquilinos para quem é o destinatário da encomenda

#### 2. **Mensagens (Chat Portaria)**
- File: `lib/screens/mensagem_portaria_screen.dart`
- Exibir foto no header das conversas
- Exibir foto nos bubbles de mensagem

#### 3. **Unidades e Moradores** 
- File: `lib/screens/unidade_morador_screen.dart`
- Exibir fotos de proprietários e inquilinos ao listar unidades
- Card ou ListTile com foto + nome

#### 4. **Listas da Portaria do Inquilino**
- File: `lib/screens/portaria_inquilino_screen.dart`
- Se houver seção de moradores/visitantes, exibir fotos

#### 5. **Qualquer outra tela que liste Proprietários/Inquilinos**
- Usar o widget `FotoPerfilAvatar` ou `PessoaListTile`

---

### Como Usar:

```dart
// Import
import '../widgets/foto_perfil_avatar.dart';

// Avatar simples
FotoPerfilAvatar(
  fotoUrl: proprietario.fotoPerfil,
  nome: proprietario.nome,
  radius: 25,
  backgroundColor: Colors.blue,
)

// ListTile com foto
PessoaListTile(
  fotoUrl: inquilino.fotoPerfil,
  nome: inquilino.nome,
  subtitle: inquilino.unidade?.numero,
  backgroundColor: Colors.purple,
  onTap: () { /* ... */ },
)

// Card com foto
PessoaCardComFoto(
  fotoUrl: proprietario.fotoPerfil,
  nome: proprietario.nome,
  cpfCnpj: proprietario.cpfCnpjFormatado,
  backgroundColor: Colors.blue,
)
```

---

### Status:
- [ ] Atualizar `portaria_representante_screen.dart`
- [ ] Atualizar `mensagem_portaria_screen.dart`
- [ ] Atualizar `unidade_morador_screen.dart`
- [ ] Atualizar `portaria_inquilino_screen.dart`
- [ ] Verificar outras screens que listam moradores
