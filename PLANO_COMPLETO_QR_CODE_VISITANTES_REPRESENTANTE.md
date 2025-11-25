# 🎯 PLANO COMPLETO: QR CODE PARA VISITANTES AUTORIZADOS DO REPRESENTANTE

## 📋 Sumário Executivo

Implementar QR Code para visitantes autorizados pelo representante, exibindo o QR Code em cada card de visitante autorizado. O QR Code será gerado **UMA VEZ** ao criar o visitante e reutilizado nas próximas aberturas.

---

## 🚀 ARQUITETURA GERAL

```
┌─────────────────────────────────────────────────────┐
│ VISITANTE AUTORIZADO DO REPRESENTANTE               │
├─────────────────────────────────────────────────────┤
│ 1. Usuário cria visitante autorizado                │
│ 2. Sistema gera QR Code (JSON com dados)            │
│ 3. Salva PNG em Supabase Storage (bucket: qr_codes) │
│ 4. Armazena URL na coluna qr_code_url               │
│ 5. Exibe QR em card do visitante                    │
│ 6. Próximas aberturas reutilizam URL                │
└─────────────────────────────────────────────────────┘
```

---

## 📌 FASE 1: BANCO DE DADOS (SQL)

### Arquivo: `SQL_ADICIONAR_QR_CODE_VISITANTES_REPRESENTANTE.sql`

**Comando:**
```sql
ALTER TABLE autorizados_visitantes_portaria_representante 
ADD COLUMN qr_code_url TEXT DEFAULT NULL;

COMMENT ON COLUMN autorizados_visitantes_portaria_representante.qr_code_url IS 
'URL pública da imagem QR Code em Supabase Storage';
```

**Resultado esperado:**
- ✅ Nova coluna `qr_code_url` (TEXT, nullable)
- ✅ Registros antigos terão NULL (OK, gerados sob demanda)

**Como executar:**
1. Acesse: https://supabase.com → seu projeto
2. Menu: SQL Editor → New Query
3. Cole o comando
4. Clique [Run]
5. Confirme com: `SELECT column_name FROM information_schema.columns WHERE table_name = 'autorizados_visitantes_portaria_representante' AND column_name = 'qr_code_url';`

---

## 📌 FASE 2: MODEL - VisitantePortaria

**Arquivo:** `lib/models/visitante_portaria.dart`

**Adições:**

### 2.1 - Campo na classe
```dart
class VisitantePortaria {
  // ... campos existentes ...
  final String? fotoUrl;
  final String? qrCodeUrl;  // ← NOVO! 🆕
  final bool ativo;
  // ... resto dos campos
}
```

### 2.2 - Construtor (adicione o campo)
```dart
const VisitantePortaria({
  // ... parâmetros existentes ...
  this.fotoUrl,
  this.qrCodeUrl,  // ← NOVO! 🆕
  this.ativo = true,
  // ... resto dos parâmetros
});
```

### 2.3 - fromJson (adicione a desserialização)
```dart
factory VisitantePortaria.fromJson(Map<String, dynamic> json) {
  return VisitantePortaria(
    // ... campos existentes ...
    fotoUrl: json['foto_url'] as String?,
    qrCodeUrl: json['qr_code_url'] as String?,  // ← NOVO! 🆕
    ativo: json['ativo'] as bool? ?? true,
    // ... resto dos campos
  );
}
```

### 2.4 - toJson (adicione a serialização)
```dart
Map<String, dynamic> toJson() {
  return {
    // ... campos existentes ...
    'foto_url': fotoUrl,
    'qr_code_url': qrCodeUrl,  // ← NOVO! 🆕
    'ativo': ativo,
    // ... resto dos campos
  };
}
```

### 2.5 - copyWith (adicione o campo)
```dart
VisitantePortaria copyWith({
  // ... parâmetros existentes ...
  String? fotoUrl,
  String? qrCodeUrl,  // ← NOVO! 🆕
  bool? ativo,
  // ... resto dos parâmetros
}) {
  return VisitantePortaria(
    // ... campos existentes ...
    fotoUrl: fotoUrl ?? this.fotoUrl,
    qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,  // ← NOVO! 🆕
    ativo: ativo ?? this.ativo,
    // ... resto dos campos
  );
}
```

---

## 📌 FASE 3: SERVICE - VisitantePortariaService

**Arquivo:** `lib/services/visitante_portaria_service.dart`

### 3.1 - Método para buscar visitantes autorizados agrupados por unidade

**Adicione este novo método:**

```dart
/// Busca todos os visitantes autorizados de um condomínio agrupados por unidade
static Future<Map<String, List<Map<String, dynamic>>>>
getVisitantesAgrupadosPorUnidade(String condominioId) async {
  try {
    print('🔍 Buscando visitantes autorizados para condomínio: $condominioId');

    final response = await _client
        .from(_tableName)
        .select('''
          id,
          nome,
          cpf,
          celular,
          tipo_autorizacao,
          quem_autorizou,
          observacoes,
          data_visita,
          status_visita,
          veiculo_tipo,
          veiculo_marca,
          veiculo_modelo,
          veiculo_cor,
          veiculo_placa,
          foto_url,
          qr_code_url,
          unidades(
            id,
            numero,
            bloco,
            condominio_id
          )
        ''')
        .eq('condominio_id', condominioId)
        .eq('ativo', true)
        .order('created_at', ascending: false);

    print('🔍 Response recebido: ${response.length} registros');

    Map<String, List<Map<String, dynamic>>> visitantesPorUnidade = {};

    for (var item in response) {
      final unidade = item['unidades'];
      
      // Criar chave da unidade
      String chaveUnidade;
      if (unidade != null && unidade['bloco'] != null) {
        chaveUnidade = 'Bloco ${unidade['bloco']} - ${unidade['numero']}';
      } else if (unidade != null) {
        chaveUnidade = 'Unidade ${unidade['numero']}';
      } else {
        chaveUnidade = 'Condomínio';
      }

      // Formatar dados
      Map<String, dynamic> visitanteFormatado = {
        'id': item['id'],
        'nome': item['nome'] ?? 'N/A',
        'cpf': item['cpf'] ?? 'N/A',
        'celular': item['celular'] ?? 'N/A',
        'tipoAutorizacao': item['tipo_autorizacao'] ?? 'N/A',
        'quemAutorizou': item['quem_autorizou'] ?? 'N/A',
        'observacoes': item['observacoes'],
        'dataVisita': item['data_visita'],
        'statusVisita': item['status_visita'] ?? 'agendado',
        'veiculo': item['veiculo_placa'] != null
            ? '${item['veiculo_marca'] ?? ''} ${item['veiculo_modelo'] ?? ''} - ${item['veiculo_placa']}'
                  .trim()
            : null,
        'foto_url': item['foto_url'],
        'qr_code_url': item['qr_code_url'],  // ← INCLUIR URL DO QR!
      };

      if (!visitantesPorUnidade.containsKey(chaveUnidade)) {
        visitantesPorUnidade[chaveUnidade] = [];
      }
      visitantesPorUnidade[chaveUnidade]!.add(visitanteFormatado);
    }

    print('✅ Visitantes agrupados em ${visitantesPorUnidade.length} unidades');
    return visitantesPorUnidade;
  } catch (e) {
    print('❌ Erro ao buscar visitantes agrupados: $e');
    return {};
  }
}
```

### 3.2 - Modificar `insertVisitante()` para gerar QR Code

**Adicione ao final do método, antes do `return`:**

```dart
// Gerar QR Code UMA VEZ ao criar
try {
  final dadosQR = jsonEncode({
    'id': novoId,
    'nome': visitanteData['nome'],
    'cpf': visitanteData['cpf'],
    'celular': visitanteData['celular'],
    'tipo': 'visitante_portaria',
    'condominio': visitanteData['condominio_id'],
    'unidade': visitanteData['unidade_id'],
    'data_visita': visitanteData['data_visita'],
    'timestamp': DateTime.now().toIso8601String(),
  });

  // Gerar QR Code
  final qrImage = QrImage(
    data: dadosQR,
    version: QrVersions.auto,
    size: 300.0,
  );

  // Converter para bytes PNG
  final imagem = await qrImage.toImageAsBytes();

  // Salvar no Supabase Storage
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final nomeArquivo = 'qr_${visitanteData['nome']}_$timestamp.png';
  
  await _client.storage.from('qr_codes').uploadBinary(
    nomeArquivo,
    imagem!,
    fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
  );

  // Obter URL pública
  final urlQr = _client.storage
      .from('qr_codes')
      .getPublicUrl(nomeArquivo);

  // Salvar URL no banco
  await _client
      .from(_tableName)
      .update({'qr_code_url': urlQr})
      .eq('id', novoId);

  print('✅ QR Code gerado e salvo: $urlQr');
} catch (e) {
  print('⚠️ Erro ao gerar QR Code: $e');
  // Continua mesmo se QR falhar
}
```

---

## 📌 FASE 4: SCREEN - Integração na UI

**Arquivo:** `lib/screens/portaria_representante_screen.dart`

### 4.1 - Adição de imports
```dart
import 'dart:convert';
import 'package:condogaiaapp/widgets/qr_code_widget.dart';
```

### 4.2 - Variável para armazenar visitantes agrupados
```dart
Map<String, List<Map<String, dynamic>>> _visitantesAgrupadosPorUnidade = {};
bool _isLoadingVisitantesAgrupados = false;
```

### 4.3 - Método para carregar visitantes autorizados
```dart
Future<void> _carregarVisitantesAutorizados() async {
  if (widget.condominioId == null) return;

  setState(() {
    _isLoadingVisitantesAgrupados = true;
  });

  try {
    final visitantes =
        await VisitantePortariaService.getVisitantesAgrupadosPorUnidade(
          widget.condominioId!,
        );

    setState(() {
      _visitantesAgrupadosPorUnidade = visitantes;
    });
  } catch (e) {
    print('❌ Erro ao carregar visitantes autorizados: $e');
  } finally {
    setState(() {
      _isLoadingVisitantesAgrupados = false;
    });
  }
}
```

### 4.4 - Chamar método no initState
```dart
@override
void initState() {
  super.initState();
  _carregarDadosPropInq();
  _carregarAutorizados();
  _carregarVisitantesAutorizados();  // ← ADICIONAR
  // ... resto do initState
}
```

### 4.5 - Widget para exibir visitante autorizado com QR Code

**Adicione novo método:**

```dart
Widget _buildVisitanteAutorizadoCard(Map<String, dynamic> visitante) {
  // Gerar dados JSON para QR Code
  final dados = jsonEncode({
    'id': visitante['id'] ?? '',
    'nome': visitante['nome'] ?? '',
    'cpf': visitante['cpf'] ?? '',
    'celular': visitante['celular'] ?? '',
    'tipo': 'visitante_portaria',
    'condominio': widget.condominioId,
    'data_visita': visitante['dataVisita'] ?? '',
  });

  return Column(
    children: [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: Avatar + Nome
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                  ),
                  child: Center(
                    child: Text(
                      visitante['nome']
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          'V',
                      style: const TextStyle(
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nome
                Expanded(
                  child: Text(
                    visitante['nome'] ?? 'Visitante',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Informações
            _buildInfoLine('CPF:', visitante['cpf'] ?? 'N/A'),
            const SizedBox(height: 6),
            _buildInfoLine('Celular:', visitante['celular'] ?? 'N/A'),
            const SizedBox(height: 6),
            _buildInfoLine('Status:', visitante['statusVisita'] ?? 'N/A'),
            
            // QR Code
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE0E0E0)),
            const SizedBox(height: 16),
            
            // Exibir QR Code se existir URL, senão gerar novo
            if (visitante['qr_code_url'] != null && 
                (visitante['qr_code_url'] as String).isNotEmpty)
              // Exibir URL salva
              Center(
                child: Image.network(
                  visitante['qr_code_url'] as String,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('Erro ao carregar QR'),
                      ),
                    );
                  },
                ),
              )
            else
              // Gerar novo QR Code
              Center(
                child: QrImageView(
                  data: dados,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
```

### 4.6 - Adicionar seção na tela para exibir visitantes autorizados

**Adicione na área de Autorizados (ex: um ExpansionTile ou seção dedicated):**

```dart
// Seção de Visitantes Autorizados
if (_visitantesAgrupadosPorUnidade.isNotEmpty)
  Card(
    margin: const EdgeInsets.all(16),
    child: ExpansionTile(
      title: const Text(
        'Visitantes Autorizados',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E3A59),
        ),
      ),
      children: _visitantesAgrupadosPorUnidade.entries.map((entry) {
        String unidade = entry.key;
        List<Map<String, dynamic>> visitantes = entry.value;

        return ExpansionTile(
          title: Text(unidade),
          children: visitantes
              .map((visitante) => _buildVisitanteAutorizadoCard(visitante))
              .toList(),
        );
      }).toList(),
    ),
  ),
```

---

## 📌 FASE 5: TESTES

### 5.1 - Teste de Criação
```
1. Abra a tela de Portaria Representante
2. Crie um novo visitante autorizado
3. Preencha todos os dados
4. Clique em "Salvar"
5. Verifique no console: ✅ QR Code gerado e salvo: [URL]
6. Confirme que a URL foi salva no banco
```

### 5.2 - Teste de Reutilização
```
1. Após criar, reabra a tela
2. Procure pelo visitante em "Visitantes Autorizados"
3. Verifique que o QR Code aparece ✅
4. Feche a tela e reabra
5. Confirme que o MESMO QR Code aparece (não regenerou)
```

### 5.3 - Teste de URL
```
1. Copie a URL do QR Code do banco
2. Abra em um navegador
3. Confirme que a imagem PNG aparece
```

---

## 📌 FASE 6: DEPLOY

### 6.1 - Checklist Final
- ✅ SQL executado e coluna criada
- ✅ Model atualizado com campo `qrCodeUrl`
- ✅ Service com método `getVisitantesAgrupadosPorUnidade()`
- ✅ Service com geração de QR ao criar visitante
- ✅ Screen integrando o widget de QR
- ✅ Testes completos passando
- ✅ Git commit com mensagem descritiva

### 6.2 - Rollback (se necessário)
```sql
-- Remover coluna
ALTER TABLE autorizados_visitantes_portaria_representante 
DROP COLUMN qr_code_url;
```

---

## 📊 COMPARAÇÃO: ANTES vs DEPOIS

### ANTES:
```
Visitante autorizado (sem QR)
├─ Nome: João Silva
├─ CPF: 123.456.789-00
├─ Celular: (11) 98765-4321
└─ Status: Agendado
```

### DEPOIS:
```
Visitante autorizado (com QR)
├─ Nome: João Silva
├─ CPF: 123.456.789-00
├─ Celular: (11) 98765-4321
├─ Status: Agendado
└─ QR Code: [████████████████]
           [████████████████]
           [████████████████]
           [████████████████]
```

---

## 🎯 RESULTADO FINAL

✅ Visitantes autorizados agora exibem QR Code no card
✅ QR Code gerado UMA VEZ ao criar
✅ URL reutilizada em próximas aberturas
✅ Sem regeneração desnecessária
✅ Consistente com implementação dos autorizados de inquilinos

---

## 📞 SUPORTE

Se houver erros durante a implementação:
1. Verifique se a coluna `qr_code_url` foi criada no Supabase
2. Confirme que o bucket `qr_codes` existe em Storage
3. Verifique os logs do console para mensagens de erro
4. Teste cada fase isoladamente antes de prosseguir
