# Planejamento de Implementação — Feature Boleto (Proprietário/Inquilino)

**Data:** 13/03/2026  
**Versão:** 1.1  
**Status Atual:** Fase 1 a Fase 5 parciais já entregues!

---

## Objetivo

Transformar a feature de Boleto do Proprietário/Inquilino de **UI com dados mock** para **funcionalidade 100% integrada com Supabase**, com etapas finais para visualização de leituras e balancetes reais.

---

## ✅ Fases Concluídas (1 a 4)
- **Fase 1 — Correção da Navegação:** `BoletoPropScreen` recebe `moradorId` sendo passado a partir da Home.
- **Fase 2 — Expandir Entity e Model:** Modelos e entidades completadas de acordo com as colunas reais da tabela `boletos` do Supabase.
- **Fase 3 — Implementar DataSource Supabase:** Chamadas para obter coleção de boletos, o boleto em si, composição de itens e os demonstrativos adicionados em código real, sem mocks.
- **Fase 4 — Conectar Cubit com Use Cases:** Injeção de dependência e `BoletoPropCubit` estruturado.

---

## 🏃 Fases em Andamento e Pendentes

## Fase 5 — Implementar Ações de UI (Pendente 1 item)

### 5.1 Implementar "Compartilhar Boleto"
**Arquivo:** `boleto_prop_cubit.dart`
- O plugin `share_plus` já está no pubspec.yaml.
- O código atual traz um placeholder (TODO comentado).
- O comportamento esperado é formatar um texto padrão utilizando o identificationField e acionar a tela de share nativa com o `await Share.share(texto)`.

### Entregável:
- [x] Ver Boleto (abre URL com pacote `url_launcher`)
- [x] Copiar código de barras
- [ ] Compartilhar com share_plus

---

## Fase 6 — Conectar Seções com Dados Reais (Leituras e Balancete Pendentes)

### 6.1 Composição do Boleto
- [x] Concluído: `secoes_expansiveis_widget.dart` recebe a informação e infla os campos de composição, descontos, total corretamente.

### 6.2 Implementar Leituras
- Precisa criar UseCase e Repository Methods para buscar leituras da tabela `leituras` para a unidade do morador naquele mês.
- Precisa atualizar `BoletoPropState` para armazenar `Map<String, dynamic>? leituras`.
- Chamar Supabase a partir de Request no DataSource:
```dart
final response = await supabase
    .from('leituras')
    .select('*')
    .eq('unidade_id', unidadeId)
    .gte('data_leitura', inicioMes)
    .lte('data_leitura', fimMes);
```
- Exibir dinamicamente no componente `_buildLeiturasConteudo` (SecoesExpansiveisWidget).

### 6.3 Implementar Balancete Online
- Criar fluxo (DataSource -> Repo -> UseCase -> State) de query em `balancetes` referenciando `condominioId`.
```dart
final response = await supabase
    .from('balancetes')
    .select('*')
    .eq('condominio_id', condominioId)
    .eq('mes', mes.toString())
    .eq('ano', ano.toString());
```
- Exibir os dados ou links de PDF da row recebida no widget `_buildBalanceteConteudo`.

### Entregável:
- [x] Composição do boleto
- [ ] Leituras integradas
- [ ] Balancete integrado

---

## Fase 7 — Testes Automatizados (2h)

### 7.1 Testes de Model e State
- Garantir round-trip em `fromJson()` e `toJson()`.
- Validar as filtragens `boletosFiltrados`.

### 7.2 Testes de Cubit
- Injetar instâncias de Use Cases mockadas (ex: mocktail) para ter confiabilidade das emissões de loading, valid states e treatment de errors.

### Entregável:
- [ ] Mínimo de 10 testes unitários.

---

## Fase 8 — Polimento e UX (1h)

### 8.1 Skeletons e Refresh
- Skeleton ou de shimmer states na tela pra quando a chamada de lista da API demorar;
- Pull-to-refresh em `boletos`.

### 8.2 Estado vazio (Empty state)
- Visual para estado onde não veio um único boleto (separando visualmente de erro de conexão).

### Entregável:
- [ ] Loading e listas vazias devidamente desenhados no app.
