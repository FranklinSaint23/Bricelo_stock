import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class PiloAssistantScreen extends StatefulWidget {
  const PiloAssistantScreen({super.key});

  @override
  State<PiloAssistantScreen> createState() => _PiloAssistantScreenState();
}

class _PiloAssistantScreenState extends State<PiloAssistantScreen> {
  final _msgCtrl = TextEditingController();
  final List<Map<String, String>> _messages = [];

  final List<String> _prompts = [
    'Combien j\'ai vendu aujourd\'hui ?',
    'Comment enregistrer une vente à crédit ?',
    'Quel est mon stock bas ?',
    'Termine la configuration de ma boutique',
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });
    _msgCtrl.clear();

    // Réponse intelligente de Pilo
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final state = AppState.instance;
      String reply = '';
      final t = text.toLowerCase();
      if (t.contains('vendu') || t.contains('aujourd')) {
        reply = 'Aujourd\'hui, vous avez réalisé ${state.todaySalesCount} ventes pour un chiffre d\'affaires total de ${AppTheme.formatFCFA(state.todayRevenue)}.';
      } else if (t.contains('crédit') || t.contains('dette')) {
        reply = 'Pour enregistrer une vente à crédit : Rendez-vous dans Point de vente, ajoutez les articles au panier, touchez Payer puis sélectionnez Crédit / Dette client.';
      } else if (t.contains('stock') || t.contains('bas')) {
        reply = 'Votre inventaire compte actuellement ${state.products.length} articles référencés. Pensez à vérifier le seuil minimal de 5 unités dans l\'onglet Stock.';
      } else if (t.contains('configuration') || t.contains('termine')) {
        reply = 'Voici les étapes recommandées : 1. Personnaliser le profil d\'entreprise, 2. Configurer les moyens de paiement Mobile Money & Cash, 3. Inviter vos caissiers.';
      } else {
        reply = 'Bien reçu ! Je suis Pilo, votre assistant connecté à votre commerce. Que souhaitez-vous vérifier ensuite (ventes, inventaire, clients) ?';
      }

      setState(() {
        _messages.add({'sender': 'pilo', 'text': reply});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
            ),
          ),
        ),
        title: const Text(
          'Pilo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.feedback_outlined, color: Colors.white, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Donnez votre avis sur l\'assistant Pilo')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // AVATAR PILO SOURIANT VERT/NAVY
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryNavy,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F000000),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.sentiment_very_satisfied, color: AppTheme.accentGold, size: 40),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Salut, je suis Pilo',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Le copilote de votre boutique. Posez une question sur vos ventes, votre stock ou vos dettes — ou laissez-moi vous aider à la configurer.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
                        ),
                        const SizedBox(height: 28),

                        // PILULES DE QUESTIONS RAPIDES
                        for (final p in _prompts)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              onTap: () => _sendMessage(p),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFD1D5DB)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF374151)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        p,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, idx) {
                      final m = _messages[idx];
                      final isUser = m['sender'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                          decoration: BoxDecoration(
                            color: isUser ? AppTheme.primaryNavy : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: isUser ? null : Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            m['text']!,
                            style: TextStyle(
                              color: isUser ? Colors.white : const Color(0xFF1F2937),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // BARRE D'ENVOI BAS DE PAGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Écrivez un message...',
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => _sendMessage(_msgCtrl.text),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryNavy,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.send, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
