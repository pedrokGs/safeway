import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/common/widgets/custom_drawer.dart';

class HelpItem {
  final String pergunta;
  final String resposta;

  HelpItem(this.pergunta, this.resposta);
}

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  HelpScreenState createState() => HelpScreenState();
}

class HelpScreenState extends ConsumerState<HelpScreen> {
  // controla dropdowns das categorias
  final Map<String, bool> open = {
    "Dúvidas Frequentes": false,
    "Minha Conta e Perfil": false,
    "Rotas e Navegação": false,
    "Recursos de Segurança": false,
  };

  // controla dropdowns das perguntas
  final Map<String, bool> questionOpen = {};

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: colors.primaryContainer,
        title: Text("Central de Ajuda",
            style: Theme.of(context).textTheme.titleMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------
            // TÍTULO
            // -------------------------------
            Text(
              "Como podemos ajudar",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // -------------------------------
            // LISTA DE CATEGORIAS + PERGUNTAS
            // -------------------------------
            _buildCategory(
              context,
              title: "Dúvidas Frequentes",
              isOpen: open["Dúvidas Frequentes"]!,
              onTap: () => setState(() {
                open["Dúvidas Frequentes"] = !open["Dúvidas Frequentes"]!;
              }),
              questions: [
                HelpItem(
                  "O SafeWay é gratuito?",
                  "Sim! O aplicativo é totalmente gratuito para uso e sempre será.",
                ),
                HelpItem(
                  "Como reportar um problema?",
                  "Acesse a aba Alertas e toque em 'Reportar'. Preencha as informações e envie.",
                ),
                HelpItem(
                  "O app funciona offline?",
                  "As funções principais requerem conexão, porém seus últimos dados permanecem salvos.",
                ),
              ],
            ),

            _buildCategory(
              context,
              title: "Minha Conta e Perfil",
              isOpen: open["Minha Conta e Perfil"]!,
              onTap: () => setState(() {
                open["Minha Conta e Perfil"] = !open["Minha Conta e Perfil"]!;
              }),
              questions: [
                HelpItem(
                  "Como faço para editar minhas informações?",
                  "Vá em Perfil > Editar Perfil, altere os dados desejados e toque em Salvar.",
                ),
                HelpItem(
                  "Como redefinir minha senha?",
                  "Em Configurações > Segurança toque em Redefinir Senha. Você receberá um código por e-mail.",
                ),
                HelpItem(
                  "Como alterar minha foto de perfil?",
                  "Na aba Perfil toque sobre sua foto atual e escolha uma nova imagem da galeria.",
                ),
              ],
            ),

            _buildCategory(
              context,
              title: "Rotas e Navegação",
              isOpen: open["Rotas e Navegação"]!,
              onTap: () => setState(() {
                open["Rotas e Navegação"] = !open["Rotas e Navegação"]!;
              }),
              questions: [
                HelpItem(
                  "Como criar uma rota?",
                  "Na aba Mapa digite o endereço de destino no campo de busca e confirme.",
                ),
                HelpItem(
                  "Posso mudar o modo de transporte?",
                  "Sim! Basta escolher entre Carro, Bicicleta ou Caminhar abaixo do campo de busca.",
                ),
              ],
            ),

            _buildCategory(
              context,
              title: "Recursos de Segurança",
              isOpen: open["Recursos de Segurança"]!,
              onTap: () => setState(() {
                open["Recursos de Segurança"] =
                !open["Recursos de Segurança"]!;
              }),
              questions: [
                HelpItem(
                  "Como funcionam os alertas?",
                  "O mapa mostra alertas enviados por usuários e avaliados por modelos automáticos.",
                ),
                HelpItem(
                  "Como ativar notificações de risco?",
                  "Vá em Configurações > Notificações e selecione quais tipos deseja receber.",
                ),
              ],
            ),

            const SizedBox(height: 32),

            // -------------------------------
            // SEÇÃO DE AJUDA EXTRA
            // -------------------------------
            Text(
              "Precisa de Mais Ajuda?",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSupportCard(
                    context,
                    icon: Icons.chat_bubble_outline_rounded,
                    title: "Fale Conosco",
                    subtitle: "Converse conosco",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSupportCard(
                    context,
                    icon: Icons.phone_in_talk_outlined,
                    title: "Ligar para Suporte",
                    subtitle: "Fale por ligação conosco",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------
  // COMPONENTE DE CATEGORIA
  // ---------------------------------------------
  Widget _buildCategory(
      BuildContext context, {
        required String title,
        required bool isOpen,
        required List<HelpItem> questions,
        required VoidCallback onTap,
      }) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    turns: isOpen ? 0.5 : 0,
                    child: Icon(Icons.expand_more, color: colors.primary),
                  )
                ],
              ),
            ),
          ),

          if (isOpen)
            Column(
              children: questions.map((item) {
                return _buildQuestionItem(context, item);
              }).toList(),
            )
        ],
      ),
    );
  }

  // ---------------------------------------------
  // COMPONENTE DE PERGUNTA + RESPOSTA
  // ---------------------------------------------
  Widget _buildQuestionItem(BuildContext context, HelpItem item) {
    final colors = Theme.of(context).colorScheme;
    final isOpen = questionOpen[item.pergunta] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.primary.withOpacity(0.25), width: 0.6),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                questionOpen[item.pergunta] = !isOpen;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.pergunta,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    turns: isOpen ? 0.5 : 0,
                    child: Icon(Icons.expand_more,
                        size: 22, color: colors.primary),
                  ),
                ],
              ),
            ),
          ),

          if (isOpen)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                item.resposta,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(0.75),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------
  // CARTÕES DE SUPORTE
  // ---------------------------------------------
  Widget _buildSupportCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
      }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withOpacity(0.4)),
        color: colors.surfaceContainerHighest.withOpacity(0.2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: colors.primary),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colors.onSurface.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
