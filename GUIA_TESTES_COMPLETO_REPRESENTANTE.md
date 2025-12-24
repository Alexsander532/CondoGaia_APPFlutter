# 🧪 GUIA COMPLETO DE TESTES MANUAIS - REPRESENTANTE
## Módulos: Reserva, Portaria e Unidade/Morador

---

## 📋 PRÉ-REQUISITOS

- ✅ Aplicativo instalado e funcionando
- ✅ Representante logado no sistema
- ✅ Condomínio com dados cadastrados
- ✅ Ambientes e unidades criadas
- ✅ Conexão com internet ativa
- ✅ Base de dados Supabase acessível

---

## 🏢 PARTE 1: TESTES DO MÓDULO UNIDADE/MORADOR

### 1.1 Carregar Tela Inicial

**Passos:**
1. Abra o app e faça login como representante
2. Navegue até a seção "Unidades" no menu
3. Verifique o carregamento da tela

**Validações:**
- [ ] Tela carrega sem erros
- [ ] Lista de blocos e unidades aparece corretamente
- [ ] Campo de busca está funcional
- [ ] Spinner de carregamento desaparece após dados carregarem
- [ ] Mensagens de erro são claras (se houver)

---

### 1.2 Visualizar Blocos com Unidades

**Passos:**
1. Na tela de Unidades, verifique se os blocos estão listados
2. Clique em um bloco para expandir/retrair
3. Verifique as unidades dentro de cada bloco

**Validações:**
- [ ] Blocos são exibidos em ordem
- [ ] Cada bloco mostra o número de unidades
- [ ] Unidades expandem/contraem ao clicar
- [ ] Unidades mostram: número, bloco, tipo
- [ ] Ícone de expansão funciona corretamente

---

### 1.3 Buscar Unidades

**Passos:**
1. Use o campo "Buscar unidades" no topo
2. Digite diferentes números de unidades (ex: "101", "202", "A1")
3. Verifique os resultados
4. Limpe o campo e veja se volta à lista completa

**Validações:**
- [ ] Busca por número da unidade funciona
- [ ] Busca por bloco funciona (se houver)
- [ ] Filtros em tempo real sem delay excessivo
- [ ] Limpar busca mostra lista completa novamente
- [ ] Busca não diferencia maiúsculas/minúsculas

---

### 1.4 Visualizar Detalhes da Unidade

**Passos:**
1. Clique em uma unidade da lista
2. Verifique a tela de detalhes
3. Verifique todos os campos exibidos

**Validações:**
- [ ] Tela de detalhes abre corretamente
- [ ] Mostra: número, bloco, tipo, fração ideal, área
- [ ] Mostra informações de isenção (Total/Cota/Fundo Reserva)
- [ ] Exibe campo de observações
- [ ] Mostra QR Code (se disponível)
- [ ] Botões de ação funcionam (editar, excluir, gerar QR)

---

### 1.5 Criar Nova Unidade

**Passos:**
1. Clique no botão "Adicionar Unidade" ou "+Novo"
2. Preencha os campos:
   - Número da unidade (obrigatório)
   - Bloco (se houver)
   - Fração Ideal
   - Área em m²
   - Tipo de unidade
   - Observações
3. Selecione tipo de isenção
4. Configure nome do pagador (Proprietário ou Inquilino)
5. Clique em "Salvar"

**Validações:**
- [ ] Modal/tela de criação abre
- [ ] Validação: campo número é obrigatório
- [ ] Validação: números decimais aceitam pontos/vírgulas
- [ ] Isenção padrão é "Nenhum"
- [ ] Apenas uma isenção pode estar selecionada
- [ ] Ação Judicial tem checkbox padrão "Não"
- [ ] Correios tem checkbox padrão "Não"
- [ ] Salvar cria registro no banco
- [ ] Mensagem de sucesso aparece
- [ ] Unidade aparece na lista

**Teste de Validação:**
1. Tente criar unidade SEM preencher o número
2. Tente salvar com valores inválidos

**Validações:**
- [ ] Erro exibido claramente
- [ ] Impede salvamento inválido
- [ ] Mensagem de erro é específica

---

### 1.6 Editar Unidade

**Passos:**
1. Selecione uma unidade existente
2. Clique em "Editar" 
3. Altere os seguintes campos:
   - Número
   - Bloco
   - Tipo de unidade
   - Isenção (mude para outro tipo)
   - Observações
4. Clique em "Salvar"

**Validações:**
- [ ] Formulário de edição abre com dados preenchidos
- [ ] Todos os campos podem ser modificados
- [ ] Validações funcionam ao editar
- [ ] Alterações são salvas no banco
- [ ] Lista é atualizada com novos dados
- [ ] Histórico de alterações é mantido

---

### 1.7 Excluir Unidade

**Passos:**
1. Selecione uma unidade
2. Clique em "Excluir" ou ícone de lixeira
3. Confirme a exclusão no diálogo

**Validações:**
- [ ] Diálogo de confirmação aparece
- [ ] Mensagem avisa sobre exclusão permanente
- [ ] Opções "Cancelar" e "Confirmar" funcionam
- [ ] Ao confirmar, unidade é removida
- [ ] Unidade desaparece da lista
- [ ] Mensagem de sucesso aparece
- [ ] Relacionamentos são tratados corretamente

---

### 1.8 Gerar/Visualizar QR Code

**Passos:**
1. Selecione uma unidade
2. Clique em "Gerar QR Code" ou ícone de QR
3. Verifique se QR Code é gerado
4. Tente escanear o QR Code com outro dispositivo

**Validações:**
- [ ] QR Code é gerado corretamente
- [ ] QR Code contém dados da unidade (número, bloco)
- [ ] QR Code pode ser escaneado
- [ ] URL/dados no QR Code apontam para recurso correto
- [ ] Aviso se QR já foi gerado
- [ ] Opção de regenerar QR

---

### 1.9 Importar/Exportar Dados

**Passos:**
1. Procure por opção de importação/exportação
2. Se existir "Exportar", clique e verifique geração de arquivo
3. Se existir "Importar", selecione arquivo e processe

**Validações:**
- [ ] Botão de exportação funciona
- [ ] Arquivo é gerado em formato esperado (Excel, CSV)
- [ ] Arquivo contém todas as unidades
- [ ] Botão de importação aceita arquivo
- [ ] Validação de formato de arquivo
- [ ] Erros de importação são claros
- [ ] Dados são importados corretamente
- [ ] Duplicatas são tratadas

---

### 1.10 Atualizar Status "temBlocos"

**Passos:**
1. Procure por configuração ou flag "temBlocos"
2. Altere entre "Tem Blocos" / "Sem Blocos"
3. Recarregue a tela
4. Verifique mudanças na interface

**Validações:**
- [ ] Flag muda no banco
- [ ] Interface se adapta com/sem blocos
- [ ] Validações de entrada se ajustam
- [ ] Unidades continuam acessíveis

---

## 🚪 PARTE 2: TESTES DO MÓDULO PORTARIA REPRESENTANTE

### 2.1 Carregar Tela de Portaria

**Passos:**
1. Abra o app como representante
2. Navegue até "Portaria" no menu
3. Aguarde carregamento

**Validações:**
- [ ] Tela carrega sem erros
- [ ] Todas as abas aparecem
- [ ] Dados são carregados (visitantes, autorizados, etc)
- [ ] UI responsiva (mobile/tablet/web)

---

### 2.2 Abas Disponíveis

**Abas esperadas:**
1. Visitante
2. Unidade/Condomínio
3. Veículo
4. Prop/Inq (Proprietário/Inquilino)
5. Autorizados
6. Encomendas

**Validações:**
- [ ] Todas as 6 abas estão presentes
- [ ] Abas funcionam ao clicar
- [ ] Conteúdo muda ao trocar abas
- [ ] Scroll funciona em abas com muito conteúdo

---

### 2.3 ABA 1: CADASTRO DE VISITANTE

#### 2.3.1 Expandir/Retrair Seção

**Passos:**
1. Na aba Visitante, veja a seção de cadastro
2. Clique no botão de expandir/retrair

**Validações:**
- [ ] Seção expande e retrai
- [ ] Ícone de seta muda direção
- [ ] Conteúdo aparece/desaparece suavemente

#### 2.3.2 Preencher Dados do Visitante

**Passos:**
1. Expanda a seção "Cadastro de Visitante"
2. Preencha os campos:
   - Nome (obrigatório)
   - CPF ou CNPJ (validar formato)
   - Endereço
   - Telefone (11 dígitos)
   - Celular (11 dígitos)
   - Email (validar formato)
   - Observações

**Validações:**
- [ ] Campo Nome aceita texto normal
- [ ] Campo CPF/CNPJ formata automaticamente (ex: 123.456.789-00)
- [ ] Valida CPF/CNPJ (rejeita inválidos)
- [ ] Campo Telefone formata (ex: (11) 3000-0000)
- [ ] Campo Celular formata (ex: (11) 99999-9999)
- [ ] Email valida formato (@, domínio)
- [ ] Campos opcionais podem ficar em branco
- [ ] Máximo de caracteres é respeitado

#### 2.3.3 Adicionar Foto do Visitante

**Passos:**
1. Clique no botão "Selecionar Foto" ou ícone de câmera
2. Escolha uma imagem da galeria ou tire uma foto
3. Verifique a miniatura da imagem

**Validações:**
- [ ] Botão abre seletor de fotos/câmera
- [ ] Imagem selecionada é exibida em miniatura
- [ ] Formato: JPG, PNG (se houver restrição)
- [ ] Tamanho: máximo aceitável (ex: 5MB)
- [ ] Opção de remover foto funciona
- [ ] Em web, aceita upload de arquivo

#### 2.3.4 Validar Campos de Contato

**Passos:**
1. Digite CPF inválido (ex: "11111111111")
2. Clique em outro campo
3. Verifique mensagem de erro

**Passos (Email):**
1. Digite email sem "@" ou sem domínio
2. Clique em outro campo
3. Verifique mensagem de erro

**Validações:**
- [ ] CPF inválido mostra erro
- [ ] Email inválido mostra erro
- [ ] Mensagens de erro são claras
- [ ] Valida em tempo real ou ao sair do campo
- [ ] Botão de salvar é desabilitado se houver erros

#### 2.3.5 Selecionar Unidade/Condomínio

**Passos:**
1. Veja a seção "Seleção de Unidade/Condomínio"
2. Clique no toggle entre "Unidade" e "Condomínio"
3. Observe mudanças na interface

**Se Unidade:**
1. Clique em "Selecionar Unidade"
2. Procure e selecione uma unidade
3. Verifique se dados aparecem

**Se Condomínio:**
1. Verifique se apenas dados do condomínio aparecem

**Validações:**
- [ ] Toggle "Unidade/Condomínio" funciona
- [ ] Ao selecionar Unidade, modal de seleção abre
- [ ] Modal lista todas as unidades
- [ ] Busca no modal funciona
- [ ] Unidade selecionada aparece no campo
- [ ] Campo "Quem autorizou" aparece para unidade
- [ ] Modo Condomínio sem campo de unidade específica

#### 2.3.6 Salvar Visitante

**Passos:**
1. Preencha todos os campos obrigatórios
2. Clique em "Salvar Visitante" ou "Cadastrar"
3. Aguarde resposta

**Validações:**
- [ ] Valida campos antes de salvar
- [ ] Mostra spinner/loading durante salvamento
- [ ] Mensagem de sucesso aparece
- [ ] Visitante é registrado no banco
- [ ] Campos são limpos após sucesso
- [ ] Erro é mostrado se falhar
- [ ] Trata timeout/perda de conexão

---

### 2.4 ABA 2: UNIDADE/CONDOMÍNIO

**Passos:**
1. Clique na aba "Unidade/Condomínio"
2. Verifique o conteúdo

**Validações:**
- [ ] Aba abre corretamente
- [ ] Lista de unidades/condomínio carrega
- [ ] Informações são precisas

---

### 2.5 ABA 3: VEÍCULO

#### 2.5.1 Registrar Veículo

**Passos:**
1. Na aba Veículo, preencha:
   - Tipo (Carro, Moto)
   - Marca (Toyota, Honda, etc)
   - Placa (ABC-1234)
   - Modelo
   - Cor

**Validações:**
- [ ] Campo Tipo: dropdown com opções
- [ ] Campo Marca: lista completa ou busca
- [ ] Campo Placa: formata automaticamente (ABC-1234)
- [ ] Campo Modelo: aceita texto livre
- [ ] Campo Cor: dropdown com cores ou texto livre
- [ ] Validação de placa (rejeita duplicatas se houver)

#### 2.5.2 Salvar Veículo

**Passos:**
1. Preencha dados do veículo
2. Clique em "Salvar Veículo"

**Validações:**
- [ ] Valida placa obrigatória
- [ ] Salva no banco
- [ ] Mensagem de sucesso
- [ ] Veículo aparece associado ao visitante

---

### 2.6 ABA 4: PROP/INQ (PROPRIETÁRIO/INQUILINO)

#### 2.6.1 Carregar Lista

**Passos:**
1. Clique na aba "Prop/Inq"
2. Aguarde carregamento

**Validações:**
- [ ] Lista de proprietários carrega
- [ ] Lista de inquilinos carrega
- [ ] Mostra foto de perfil (se disponível)
- [ ] Mostra nome e unidade
- [ ] Mostra tipo (P = Proprietário, I = Inquilino)

#### 2.6.2 Buscar Proprietário/Inquilino

**Passos:**
1. Use o campo de busca
2. Digite nome, número da unidade, etc
3. Verifique resultados

**Validações:**
- [ ] Busca por nome funciona
- [ ] Busca por unidade funciona
- [ ] Filtro em tempo real
- [ ] Limpar busca mostra lista completa

#### 2.6.3 Selecionar Para Encomenda

**Passos:**
1. Clique em um proprietário/inquilino
2. Use em uma encomenda (se integrado)

**Validações:**
- [ ] Seleção registra pessoa
- [ ] Dados aparecem preenchidos

---

### 2.7 ABA 5: AUTORIZADOS

#### 2.7.1 Carregar Lista de Autorizados

**Passos:**
1. Clique na aba "Autorizados"
2. Aguarde carregamento

**Validações:**
- [ ] Lista de autorizados por unidade carrega
- [ ] Mostra nome do autorizado
- [ ] Mostra unidade a qual está autorizado
- [ ] Mostra tipo (visitante, funcionário, etc)

#### 2.7.2 Autorizar Novo Visitante

**Passos:**
1. Procure por botão "Autorizar" ou "+"
2. Selecione unidade
3. Selecione visitante ou digite nome
4. Clique em "Autorizar"

**Validações:**
- [ ] Modal de autorização abre
- [ ] Lista de unidades disponível
- [ ] Lista de visitantes cadastrados disponível
- [ ] Autorização é salva
- [ ] Visitante aparece na lista de autorizados

#### 2.7.3 Remover Autorização

**Passos:**
1. Encontre autorizado na lista
2. Clique em "Remover" ou ícone de lixeira
3. Confirme

**Validações:**
- [ ] Diálogo de confirmação aparece
- [ ] Ao confirmar, autorização é removida
- [ ] Visitante desaparece da lista

---

### 2.8 ABA 6: ENCOMENDAS

#### 2.8.1 Abas Internas de Encomendas

**Passos:**
1. Na aba "Encomendas", verifique as sub-abas:
   - Registrar Encomenda
   - Histórico de Encomendas

**Validações:**
- [ ] Ambas as sub-abas estão presentes
- [ ] Conteúdo muda ao trocar sub-aba

#### 2.8.2 Registrar Nova Encomenda

**Passos:**
1. Na sub-aba "Registrar Encomenda"
2. Selecione ou digite:
   - Proprietário/Inquilino (obrigatório)
   - Descrição da encomenda
   - Transportadora (se houver)
   - Número de rastreamento
3. Clique em "Foto da Encomenda" para adicionar imagem
4. Clique em "Registrar Encomenda"

**Validações:**
- [ ] Dropdown/lista de pessoas funciona
- [ ] Campo de descrição aceita texto livre
- [ ] Campo de transportadora tem opções ou texto livre
- [ ] Campo de rastreamento formata corretamente
- [ ] Foto pode ser adicionada (câmera/galeria)
- [ ] Checkbox "Notificar Unidade" funciona
- [ ] Validação: pessoa obrigatória
- [ ] Encomenda é salva no banco
- [ ] Foto é salva (local ou remoto)
- [ ] Mensagem de sucesso

#### 2.8.3 Histórico de Encomendas

**Passos:**
1. Clique na sub-aba "Histórico de Encomendas"
2. Aguarde carregamento
3. Verifique lista

**Validações:**
- [ ] Lista de encomendas carrega
- [ ] Mostra data/hora de registro
- [ ] Mostra para quem foi a encomenda
- [ ] Mostra descrição
- [ ] Mostra foto (se houver)
- [ ] Ordena por data (mais recente primeiro)
- [ ] Pode filtrar por unidade/pessoa
- [ ] Pode buscar por descrição/rastreamento

#### 2.8.4 Visualizar Detalhes da Encomenda

**Passos:**
1. Clique em uma encomenda do histórico
2. Verifique detalhes

**Validações:**
- [ ] Modal/tela de detalhes abre
- [ ] Mostra todas as informações
- [ ] Foto é exibida em tamanho maior
- [ ] Data/hora é precisa
- [ ] Pode marcar como "Entregue" (se houver)
- [ ] Pode adicionar observações

---

### 2.9 Visitantes no Condomínio (Seção Adicional)

**Passos:**
1. Procure por seção "Visitantes no Condomínio" ou "Acessos"
2. Verifique lista

**Validações:**
- [ ] Lista visitantes que entraram
- [ ] Mostra hora de entrada
- [ ] Mostra hora de saída (se marcada)
- [ ] Mostra foto do visitante
- [ ] Mostra unidade visitada
- [ ] Pode filtrar por data/unidade
- [ ] Pode buscar por nome

---

### 2.10 Visitantes Cadastrados

**Passos:**
1. Procure por "Visitantes Cadastrados"
2. Use busca para filtrar
3. Verifique lista

**Validações:**
- [ ] Lista todos os visitantes já registrados
- [ ] Busca por nome funciona
- [ ] Mostra CPF/CNPJ
- [ ] Mostra foto
- [ ] Pode clicar para ver detalhes
- [ ] Pode editar informações
- [ ] Pode deletar visitante

---

## 📅 PARTE 3: TESTES DO MÓDULO RESERVAS

### 3.1 Carregar Tela de Reservas

**Passos:**
1. Abra o app como representante
2. Navegue até "Reservas"
3. Aguarde carregamento

**Validações:**
- [ ] Tela carrega sem erros
- [ ] Calendário é exibido
- [ ] Lista de ambientes carrega
- [ ] Formulário de reserva está pronto

---

### 3.2 Interface do Calendário

#### 3.2.1 Navegação de Meses

**Passos:**
1. Verifique mês e ano atual
2. Clique em seta "Próximo mês"
3. Clique em seta "Mês anterior"
4. Verifique o mês/ano mudam

**Validações:**
- [ ] Calendário mostra mês atual
- [ ] Navegação anterior/próximo funciona
- [ ] Mês e ano são exibidos corretamente
- [ ] Dias do mês estão corretos
- [ ] Setas de navegação são acessíveis

#### 3.2.2 Visualizar Dias com Reservas

**Passos:**
1. Verifique dias que têm reservas marcadas
2. Dias devem ser destacados visualmente

**Validações:**
- [ ] Dias com reservas têm cor diferente
- [ ] Marcação é clara
- [ ] Número do dia é legível
- [ ] Legenda explica o marcador (se houver)

#### 3.2.3 Selecionar Data para Reserva

**Passos:**
1. Clique em um dia do calendário
2. Verifique se data é selecionada
3. Clique em outro dia
4. Verifique mudança de seleção

**Validações:**
- [ ] Data selecionada é destacada
- [ ] Pode mudar data clicando em outro dia
- [ ] Data selecionada aparece no formulário
- [ ] Não permite datas passadas (se for regra)

---

### 3.3 Seleção de Ambiente

**Passos:**
1. Clique no dropdown de "Ambiente"
2. Verifique lista de ambientes

**Validações:**
- [ ] Dropdown abre corretamente
- [ ] Lista todos os ambientes cadastrados
- [ ] Cada ambiente mostra nome
- [ ] Primeiro ambiente é pré-selecionado
- [ ] Pode selecionar diferentes ambientes
- [ ] Nome do ambiente selecionado aparece no campo

---

### 3.4 Preencher Dados da Reserva

**Passos:**
1. Selecione uma data
2. Selecione um ambiente
3. Preencha:
   - Hora de Início (HH:MM)
   - Hora de Fim (HH:MM)
   - Valor da locação
   - Tipo: Condomínio ou Bloco/Unid
4. Se Bloco/Unid:
   - Selecione unidade
5. Preencha:
   - Lista de presentes (nomes dos presentes)
   - Termo de locação (checkbox)

**Validações:**
- [ ] Campo data é obrigatório
- [ ] Campo ambiente é obrigatório
- [ ] Hora de início é obrigatória
- [ ] Hora de fim é obrigatória
- [ ] Valor é pré-preenchido (R$ 100,00)
- [ ] Pode editar valor
- [ ] Radio buttons Condomínio/Bloco funcionam
- [ ] Ao selecionar Bloco/Unid, lista de unidades aparece
- [ ] Lista de presentes aceita múltiplas linhas
- [ ] Checkbox de termo é validado

---

### 3.5 Validações de Hora

**Passos:**
1. Tente deixar hora vazia
2. Tente colocar hora no formato incorreto (ex: "25:00")
3. Tente colocar hora de fim ANTES da hora de início
4. Clique em "Salvar"

**Validações:**
- [ ] Hora obrigatória mostra erro
- [ ] Formato HH:MM é validado
- [ ] Rejeita horas inválidas (>23, minutos >59)
- [ ] Rejeita hora fim <= hora início
- [ ] Mensagens de erro são claras

---

### 3.6 Validação do Termo de Locação

**Passos:**
1. Tente salvar sem marcar o termo
2. Verifique mensagem de erro
3. Marque o checkbox
4. Tente salvar novamente

**Validações:**
- [ ] Checkbox de termo é obrigatório
- [ ] Erro se não marcado
- [ ] Permite salvar quando marcado
- [ ] Mensagem explica por que é obrigatório (se houver)

---

### 3.7 Lista de Presentes

**Passos:**
1. Clique no campo "Lista de Presentes"
2. Abra modal/diálogo
3. Digite ou selecione nomes
4. Formatos testados:
   - Um por linha: "João\nMaria\nPedro"
   - Separados por vírgula: "João, Maria, Pedro"
   - Numerados: "1. João\n2. Maria"
5. Clique em "Salvar"

**Validações:**
- [ ] Modal de lista abre
- [ ] Aceita múltiplos formatos
- [ ] Valida nomes (não vazio)
- [ ] Formata corretamente para exibição
- [ ] Salva lista no banco como array/string
- [ ] Ao visualizar, mostra numerado

---

### 3.8 Upload de Arquivo de Presentes

**Passos:**
1. Se houver opção de "Importar Lista de Presentes"
2. Clique em "Escolher Arquivo"
3. Selecione arquivo Excel/CSV com nomes
4. Verifique carregamento

**Validações:**
- [ ] Aceita Excel/CSV
- [ ] Valida formato do arquivo
- [ ] Extrai nomes corretamente
- [ ] Mostra preview dos nomes importados
- [ ] Aviso se arquivo inválido
- [ ] Nomes importados preenchem campo

---

### 3.9 Salvar Reserva (Completa)

**Passos:**
1. Preencha todos os campos corretamente:
   - Data: hoje ou futura
   - Ambiente: selecionado
   - Hora início: 10:00
   - Hora fim: 12:00
   - Valor: R$ 150,00
   - Para: Condomínio
   - Termo: marcado
2. Clique em "Salvar Reserva"

**Validações:**
- [ ] Spinner de carregamento aparece
- [ ] Reserva é salva no banco
- [ ] ID da reserva é gerado
- [ ] Mensagem de sucesso
- [ ] Dia do calendário é marcado
- [ ] Formulário é limpo (opcional)
- [ ] Nova reserva aparece nas buscas

---

### 3.10 Visualizar Reserva Criada

**Passos:**
1. Após criar reserva, localize no calendário
2. Clique no dia
3. Verifique informações

**Validações:**
- [ ] Dia com reserva é destacado
- [ ] Clicando no dia, mostra lista de reservas
- [ ] Reserva criada aparece na lista
- [ ] Todas as informações estão corretas
- [ ] Pode ver detalhes completos

---

### 3.11 Editar Reserva Existente

**Passos:**
1. Clique em uma reserva existente
2. Clique em "Editar"
3. Altere alguns campos:
   - Hora fim
   - Valor
   - Lista de presentes
4. Clique em "Salvar Alterações"

**Validações:**
- [ ] Formulário abre com dados preenchidos
- [ ] Todos os campos estão editáveis
- [ ] Pode alterar data (abre calendário)
- [ ] Validações funcionam ao editar
- [ ] Alterações são salvas
- [ ] Histórico de atualização é mantido
- [ ] Mensagem de sucesso

---

### 3.12 Cancelar/Deletar Reserva

**Passos:**
1. Selecione uma reserva
2. Clique em "Deletar" ou "Cancelar"
3. Confirme a ação

**Validações:**
- [ ] Diálogo de confirmação aparece
- [ ] Avisa sobre exclusão permanente
- [ ] Pode cancelar ação
- [ ] Ao confirmar, reserva é removida
- [ ] Dia do calendário volta ao normal
- [ ] Mensagem de sucesso

---

### 3.13 Filtrar Reservas

**Passos:**
1. Procure por campo de filtro/busca
2. Filtre por:
   - Ambiente
   - Data/período
   - Representante

**Validações:**
- [ ] Filtros funcionam independentemente
- [ ] Combinação de filtros funciona
- [ ] Lista é atualizada em tempo real
- [ ] Pode limpar filtros
- [ ] Mostra número de resultados

---

### 3.14 Exportar Reservas

**Passos:**
1. Se houver opção "Exportar"
2. Selecione período (mês/período customizado)
3. Clique em "Exportar para Excel"

**Validações:**
- [ ] Arquivo Excel é gerado
- [ ] Contém dados de todas as reservas
- [ ] Formatação é profissional
- [ ] Colunas: Data, Ambiente, Hora início, Hora fim, Valor, Local, etc.
- [ ] Arquivo pode ser aberto

---

### 3.15 Testes de Integridade de Dados

**Passos:**
1. Crie 3 reservas em datas diferentes
2. Altere uma reserva
3. Delete uma reserva
4. Recarregue a tela (F5 ou refresh)

**Validações:**
- [ ] Dados persistem após recarregar
- [ ] Alterações foram salvas corretamente
- [ ] Deletada não reaparece
- [ ] Calendário está em sincronia

---

### 3.16 Testes de Tipo de Reserva

#### 3.16.1 Reserva para Condomínio

**Passos:**
1. Crie reserva com "Para: Condomínio"
2. Não selecione unidade específica
3. Salve

**Validações:**
- [ ] Campo de unidade fica oculto
- [ ] Reserva é para todo condomínio
- [ ] Descrição "Local" reflete isso

#### 3.16.2 Reserva para Bloco/Unidade

**Passos:**
1. Crie reserva com "Para: Bloco/Unid"
2. Selecione unidade específica
3. Salve

**Validações:**
- [ ] Campo de unidade fica visível
- [ ] Obrigatório selecionar unidade
- [ ] Reserva é associada à unidade
- [ ] Histórico mostra apenas para aquela unidade

---

### 3.17 Testes de Termos e Condições

**Passos:**
1. Clique em "Visualizar Termo" (se houver)
2. Leia o conteúdo
3. Volte e marque checkbox

**Validações:**
- [ ] Modal com termo abre
- [ ] Texto é legível
- [ ] Pode fazer scroll
- [ ] Botão "Aceitar" fecha modal
- [ ] Checkbox é marcado automaticamente

---

## 🔄 TESTES DE INTEGRAÇÃO ENTRE MÓDULOS

### 4.1 Portaria → Reservas

**Passos:**
1. Cadastre visitante na Portaria
2. Use esse visitante para registrar uma encomenda
3. Vá até Reservas e crie uma reserva

**Validações:**
- [ ] Visitante cadastrado aparece em lista
- [ ] Dados estão sincronizados
- [ ] Referências de IDs são corretas

---

### 4.2 Unidade → Portaria

**Passos:**
1. Crie/edite unidade em Unidade/Morador
2. Vá até Portaria
3. Tente usar aquela unidade em um registro

**Validações:**
- [ ] Unidade modificada aparece atualizada
- [ ] Dados sincronizam
- [ ] Dados inválidos causam erro

---

### 4.3 Portaria → Unidade

**Passos:**
1. Cadastre visitante em unidade específica
2. Vá para Unidade/Morador
3. Veja se unidade mostra visitantes

**Validações:**
- [ ] Dados aparecem sincronizados
- [ ] Contagem é precisa

---

### 4.4 Reserva → Unidade

**Passos:**
1. Crie reserva para Bloco/Unidade
2. Vá até Unidade/Morador
3. Procure por informações de reserva

**Validações:**
- [ ] Unidade mostra reservas associadas
- [ ] Dados integrados corretamente

---

## 🌐 TESTES DE RESPONSIVIDADE

### 5.1 Mobile (iPhone/Android)

**Tela: Unidades**
- [ ] Layout se adapta
- [ ] Busca é acessível
- [ ] Botões são clicáveis
- [ ] Scroll funciona

**Tela: Portaria**
- [ ] Abas estão acessíveis
- [ ] Formulários são navegáveis
- [ ] Fotos podem ser tiradas/importadas

**Tela: Reservas**
- [ ] Calendário é usável
- [ ] Formulário é preenchível
- [ ] Seletor de data funciona

### 5.2 Tablet

- [ ] Layout aproveita espaço maior
- [ ] Dois painéis lado a lado (se houver)
- [ ] Toque funciona corretamente

### 5.3 Web (Desktop)

- [ ] Mouse e teclado funcionam
- [ ] Tab navigation funciona
- [ ] Drag-and-drop (se houver)

---

## 🔐 TESTES DE PERMISSÕES E SEGURANÇA

### 6.1 Permissões de Câmera/Galeria

**Passos:**
1. Clique em "Selecionar Foto" na Portaria
2. Ao pedir permissão, aceite
3. Tirar foto/escolher galeria

**Validações:**
- [ ] Permissão é solicitada (primeira vez)
- [ ] Foto é capturada/selecionada
- [ ] Funciona corretamente

**Passos (Denegar Permissão):**
1. Vá para Configurações do App
2. Remova permissão de câmera
3. Tente usar câmera novamente

**Validações:**
- [ ] Mensagem clara pedindo acesso
- [ ] Link para settings funciona

### 6.2 Validação de Entrada

**Passos:**
1. Tente injetar scripts em campos de texto
2. Tente copiar/colar valores inválidos

**Validações:**
- [ ] Campos sanitizam entrada
- [ ] SQL Injection é prevenido
- [ ] XSS é prevenido

---

## 🔌 TESTES DE CONECTIVIDADE

### 7.1 Sem Conexão

**Passos:**
1. Desative internet do dispositivo
2. Tente carregar dados

**Validações:**
- [ ] Mensagem de erro clara
- [ ] Sugerir reconectar
- [ ] Botão de "Tentar Novamente"

### 7.2 Conexão Lenta

**Passos:**
1. Use throttling (conexão 3G)
2. Carregue dados

**Validações:**
- [ ] Spinner de loading aparece
- [ ] Não congela UI
- [ ] Timeout é tratado (se houver)

### 7.3 Reconectar Após Desconexão

**Passos:**
1. Desconecte internet
2. Reconecte
3. Tente operação novamente

**Validações:**
- [ ] Detecta reconexão
- [ ] Operação continua ou permite tentar novamente

---

## 📊 TESTES DE PERFORMANCE

### 8.1 Carregamento de Listas Grandes

**Passos:**
1. Carregue tela com 500+ unidades
2. Carregue tela com 1000+ visitantes
3. Use busca/filtro

**Validações:**
- [ ] Não congela UI
- [ ] Scroll é suave
- [ ] Busca é rápida (<1s)
- [ ] Usa paginação ou lazy loading (se houver)

### 8.2 Salvar Dados Grandes

**Passos:**
1. Crie lista de presentes com 100 nomes
2. Anexe foto grande (10MB)
3. Salve

**Validações:**
- [ ] Não congela durante save
- [ ] Mostra progresso
- [ ] Trata timeout se arquivo muito grande

---

## ✅ CHECKLIST FINAL

### Funcionalidades Críticas

**Unidade/Morador:**
- [ ] CRUD completo (Create, Read, Update, Delete)
- [ ] Busca funciona
- [ ] QR Code funciona
- [ ] Validações funcionam

**Portaria:**
- [ ] Cadastro de visitante completo
- [ ] Fotos funcionam
- [ ] Encomendas funcionam
- [ ] Autorizados funcionam
- [ ] 6 abas todas funcionando

**Reservas:**
- [ ] Calendário funciona
- [ ] CRUD de reservas
- [ ] Validação de horários
- [ ] Termo de locação
- [ ] Lista de presentes

### Qualidade Geral

- [ ] Sem crashes
- [ ] Sem console errors
- [ ] UI responsiva
- [ ] Mensagens claras
- [ ] Dados sincronizam
- [ ] Performance aceitável
- [ ] Offline handling
- [ ] Permissões funcionam

---

## 📝 TEMPLATE DE TESTE

Para cada teste realizado, documente:

```
### Teste: [Nome do Teste]

**Data:** DD/MM/YYYY
**Testador:** [Nome]
**Ambiente:** Mobile/Web/Tablet
**Versão do App:** X.X.X

**Resultado:**
- [ ] PASSOU
- [ ] FALHOU
- [ ] FALHOU PARCIALMENTE

**Observações:**
[Descrever qualquer comportamento anômalo, tempo de execução, bugs encontrados]

**Bugs Encontrados:**
1. [Descrição do bug]
2. [Descrição do bug]
```

---

## 🐛 REPORTE DE BUGS

Para cada bug encontrado, preencha:

```
### Bug Report

**Severidade:** 🔴 Crítica / 🟠 Alta / 🟡 Média / 🟢 Baixa

**Módulo:** Unidades / Portaria / Reservas

**Descrição:**
[O que aconteceu vs. o esperado]

**Passos para Reproduzir:**
1. ...
2. ...
3. ...

**Resultado Esperado:**
[O que deveria acontecer]

**Resultado Obtido:**
[O que aconteceu]

**Screenshots/Logs:**
[Anexar evidências]

**Ambiente:**
- SO: iOS/Android/Web
- Versão: X.X.X
- Dispositivo: [Modelo]
```

---

## 📌 NOTAS IMPORTANTES

1. **Sequência Recomendada de Testes:**
   - Comece por Unidade/Morador (base de dados)
   - Depois Portaria (usa unidades)
   - Por fim Reservas (usa ambientes)

2. **Testes Devem Ser Independentes:**
   - Cada teste deve ser executável isoladamente
   - Limpe dados de teste após conclusão

3. **Ambiente de Teste:**
   - Use condomínio/dados de teste
   - Não use dados de produção
   - Criar conta de teste dedicada

4. **Documentação:**
   - Fotografe/filme comportamentos anômalo
   - Salve logs de erro
   - Note timestamps de testes

5. **Versão Mínima Android:**
   - Teste em múltiplas versões
   - Incluir Android 8.0+ obrigatoriamente

6. **Integrações Externas:**
   - Supabase: Verifique conexão
   - Câmera: Permissões ativas
   - Galeria: Acesso funcionando

---

**Criado em:** 20/12/2025
**Último Atualizado:** 20/12/2025
**Versão do Guia:** 1.0
