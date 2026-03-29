# 🚀 Plano de Ação e Implementação — Leitura de Consumo (Água e Gás)

> **Documento baseado na validação do sócio** · Março 2026  
> **Objetivo:** Definir as próximas etapas de desenvolvimento com base no feedback recebido sobre o fluxo de leitura de consumo.

---

## 1. Resumo da Validação (Feedback do Sócio)

O relatório inicial de regras de negócio foi analisado e validado com os seguintes retornos:

| Pergunta de Validação | Resposta do Sócio | Status / Decisão |
| :--- | :--- | :--- |
| As faixas de preço progressivas fazem sentido? | **SIM** | ✅ Validado. Manter implementação atual. |
| A diferenciação "Junto com Taxa" vs "Boleto Avulso" está clara? | **SIM** | ✅ Validado. Fluxo mantido. |
| Falta algum dado que deveria ser registrado? | **Está completo** | ✅ Validado. Estrutura de banco de dados aprovada. |
| O fluxo de leitura está prático para o zelador? | **SIM** | ✅ Validado. UI/UX do fluxo mantida. |
| A opção de anexar foto é suficiente ou precisa de algo mais? | **Anexar e tirar foto instantaneamente** | ⚠️ **Novo Requisito:** Implementar integração com a câmera nativa do aparelho. |
| Funcionalidade de "leitura em massa" via planilha? | **Não vejo necessidade nesse momento** | ⏳ **Adiado:** Removido do escopo do MVP. |
| Ter gráfico de histórico de consumo? | **Seria ótimo no menu relatórios** | ⚠️ **Novo Requisito:** Implementar gráfico analítico e tela de relatório. |

---

## 2. Escopo de Implementação (O que precisa ser feito)

Com base no feedback, temos **duas funcionalidades principais** que entram para a fila de desenvolvimento:

### 2.1. Captura de Foto Instantânea no Momento da Leitura
**Objetivo:** Permitir que o zelador abra a câmera do celular diretamente no aplicativo para registrar a foto do medidor na hora, além da opção de buscar na galeria.

**Requisitos Técnicos:**
- **UI/UX:** Ao clicar no botão de "Adicionar Foto/Comprovante" na lista de leituras, o sistema deve exibir um *BottomSheet* ou modal curto perguntando: "Tirar Foto (Câmera)" ou "Escolher da Galeria (Arquivos)".
- **Pacotes Flutter:** Utilizar o pacote `image_picker` (com as opções `ImageSource.camera` e `ImageSource.gallery`).
- **Compressão:** A imagem capturada deve ser comprimida (ex: `flutter_image_compress`) antes de ser enviada para não gastar franquia de dados do zelador e não ocupar espaço excessivo no *Supabase Storage*.
- **Permissões:** Garantir a adição de descrições e permissões de Câmera (`camera`) nos arquivos primários do Android (`AndroidManifest.xml`) e iOS (`Info.plist`).

### 2.2. Gráfico de Histórico de Consumo (Menu Relatórios)
**Objetivo:** Oferecer uma visualização gráfica dos últimos meses de consumo de cada unidade/condomínio na aba de relatórios do módulo de Leitura.

**Requisitos Técnicos:**
- **Localização:** Criar ou adaptar a seção de "Relatórios" (ou "Histórico") dentro da ferramenta de Leituras (Menu principal ou TabBar).
- **UI/UX:** Desenhar um gráfico de barras (recomendado) ou de linhas exibindo a evolução do consumo em Metros Cúbicos (m³) nos últimos 6 a 12 meses.
- **Filtros e Controles:** 
  - Condomínio / Bloco
  - Unidade Específica
  - Tipo (Água / Gás)
- **Pacotes Flutter:** Adicionar uma biblioteca de gráficos confiável (ex: `fl_chart` ou `syncfusion_flutter_charts`).
- **Banco de Dados (Supabase):** Implementar função ou query no controlador responsável buscando os dados ordenados cronologicamente, garantindo que o calculo base (`leitura_atual` - `leitura_anterior`) ou simplesmente a coluna `consumo` plotada não estoure a memória.
- **Métricas:** Abaixo do gráfico, apresentar *cards* de resumo com: "Média de Consumo", "Maior Consumo (Pico)" e "Consumo do Mês Atual".

---

## 3. Tarefas e Funcionalidades Descartadas

- ❌ **Importação por Planilha Excel (.csv / .xlsx):** Foi validado que não há necessidade neste momento. Mantemos o foco na simplicidade de uso mobile via celular do zelador (digitação rápida + foto instantânea).

---

## 4. Plano de Ação Técnico (Para o Desenvolvedor)

Para a equipe técnica e controle de progresso, aqui está a "lista de supermercado" do que vamos programar no Flutter:

- [ ] **Tarefa 1:** Instalar e configurar o `image_picker`.
- [ ] **Tarefa 2:** Adicionar permissões `<uses-permission android:name="android.permission.CAMERA" />` (Android) e `NSCameraUsageDescription` (iOS).
- [ ] **Tarefa 3:** Criar o *BottomSheet* na tela de *Leitura* que divide o clique em Câmera vs Galeria.
- [ ] **Tarefa 4:** Testar o envio da foto tirada da câmera no fluxo existente pro bucket do Supabase.
- [ ] **Tarefa 5:** Adicionar biblioteca `fl_chart`.
- [ ] **Tarefa 6:** Criar a tela `LeituraRelatoriosPage` com filtros de Bloco e Unidade.
- [ ] **Tarefa 7:** Criar query no backend (`getHistoricoConsumoUnidade`) para trazer mês a mês do Supabase.
- [ ] **Tarefa 8:** Renderizar o gráfico de barras.

> **Conclusão:** Após finalizar estes itens, o módulo de "Leitura de Consumo" estará blindado e 100% alinhado à visão estratégica de usabilidade da plataforma.
