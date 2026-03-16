# Relatório Atualizado — Feature Boleto (Proprietário/Inquilino)

**Data:** 13/03/2026  
**Versão:** 1.1  
**Status Geral:** 🟡 Parcialmente Funcional — Integração Backend Implementada, necessitando de finalização de componentes.

---

## 1. Visão Geral

A feature de Boleto para Proprietário/Inquilino (Prop/Inq) permite que moradores visualizem seus boletos de condomínio, filtrem por status, vejam a composição, demonstrativo financeiro, leituras e balancete online. A tela é acessada via a Home do Inquilino/Proprietário (`inquilino_home_screen.dart`).

### Fluxo de Navegação
```
Home (Prop/Inq) → Boletos → BoletoPropScreen
```
- Recebe `condominioId` e `moradorId` (id do inquilino ou proprietário) de maneira correta para injeção de dependência.

---

## 2. Arquitetura Atual

A feature segue **Clean Architecture** com 3 camadas:

```
boleto/
├── data/
│   ├── datasources/
│   │   └── boleto_prop_remote_datasource.dart    ← Supabase queries implementadas!
│   ├── models/
│   │   └── boleto_prop_model.dart                ← Model alinhado aos campos completos do Supabase
│   └── repositories/
│       └── boleto_prop_repository_impl.dart      
├── domain/
│   ├── entities/
│   │   └── boleto_prop_entity.dart                ← Contém os 30+ campos reais da arquitetura
│   ├── repositories/
│   │   └── boleto_prop_repository.dart            
│   └── usecases/
│       └── boleto_prop_usecases.dart              ← Casos de uso de boletos, composicao e demonstrativo.
└── ui/
    ├── cubit/
    │   ├── boleto_prop_cubit.dart                 ← Conectado aos Use Cases! (Ver Boleto, Copiar já implementados, Compartilhar pendente).
    │   └── boleto_prop_state.dart                 ← Estado atualizado com entidades reais. Faltam atributos para leituras/balancetes.
    ├── screens/
    │   └── boleto_prop_screen.dart                ← Inicialização e injeção do Cubit funcionando perfeitamente.
    └── widgets/
        ├── boleto_card_widget.dart                
        ├── boleto_acoes_expandidas.dart           
        ├── boleto_filtro_dropdown.dart             
        ├── demonstrativo_financeiro_widget.dart    
        └── secoes_expansiveis_widget.dart          ← Composição com dados reais. Leituras e balancetes ainda usando texto hardcoded.
```

---

## 3. O Que Funciona (UI e Backend Integrados)

| Funcionalidade | Status | Observações |
|---|---|---|
| Dropdown filtro Vencido/A Vencer vs Pago | ✅ Funcional | Usa dados do banco (status!=Pago / status==Pago) |
| Lista de boletos com cards expansíveis | ✅ Funcional | Conectada ao Supabase via query principal. |
| Injeção do morador na navegação | ✅ Funcional | A tela Home repassa o Id real do morador logado. |
| Composição do Boleto (real) | ✅ Funcional | Valores puxados através de chamadas exclusivas (R$ reais do banco) |
| Ver boleto | ✅ Funcional | `url_launcher` implementado para baixar PDF ASAAS |
| Copiar código de barras | ✅ Funcional | Prioriza `identification_field` sobre o `bar_code` |
| Demonstrativo Financeiro | ✅ Funcional | Buscando pelo backend o consolidativo com somatórias. |

---

## 4. O Que NÃO Funciona / Pendências

| Funcionalidade | Status | Problema |
|---|---|---|
| **Compartilhar Boleto** | ❌ Pendente | O método `compartilharBoleto` está como um TODO no cubit (embora o pacote `share_plus` exista). |
| **Leituras do período** | ❌ Sem integração | Mensagem "Nenhuma leitura disponível" sem chamadas ao Supabase. |
| **Balancete Online** | ❌ Sem integração | Mensagem "Balancete online não disponível..." sem chamadas. |
| **Estados Vazio e Skeletons** | ❌ Ausentes | Não existe feedback super elaborado de lista vazia ou loading, UX pode melhorar. |
| **Testes automatizados** | ❌ Nenhum teste | Zero cobertura |

---

## 5. Resumo Executivo

Grande avanço foi feito desde o último levantamento! A feature Boleto Prop/Inq abandonou 80% do mock e se baseia na Clean Architecture para consultar dados 100% no Supabase. Os boletos são listados pelo morador validado, visualização em PDF foi implementada e a Composição reflete a verdade do backend.

**Próximos passos necessários:**
1. Descomentar e testar o `share_plus` em `boleto_prop_cubit.dart`.
2. Expandir DataSources, Repositories e UseCases para aceitar queries nas tabelas de `leituras` e `balancetes`.
3. Ajustar o `secoes_expansiveis_widget.dart` e o `BoletoPropState` para armazenar `leituras` e `balancetes` em vez de texto fixo.
4. Adicionar os Testes Automatizados cruciais para Models e Cubit.
5. Embelezar e testar edge-cases (Skeleton Loading e State de Boletos sem PDF ou sem Código de barras).
