import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class BriceloAssistantScreen extends StatefulWidget {
  const BriceloAssistantScreen({super.key});

  @override
  State<BriceloAssistantScreen> createState() => _BriceloAssistantScreenState();
}

class _BriceloAssistantScreenState extends State<BriceloAssistantScreen> {
  final _msgCtrl = TextEditingController();
  final List<Map<String, String>> _messages = [];

  List<String> get _prompts {
    final isEn = AppState.instance.currentLanguage == 'en';
    if (isEn) {
      return [
        'How much did I sell today?',
        'How to record a credit sale?',
        'Which items are low on stock?',
        'Complete my store setup',
      ];
    }
    return [
      'Combien j\'ai vendu aujourd\'hui ?',
      'Comment enregistrer une vente à crédit ?',
      'Quel est mon stock bas ?',
      'Termine la configuration de ma boutique',
    ];
  }

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

    // Réponse intelligente de Bricelo
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final state = AppState.instance;
      final isEn = state.currentLanguage == 'en';
      String reply = '';
      final t = text.toLowerCase();

      if (t.contains('vendu') || t.contains('aujourd') || t.contains('sell') || t.contains('today')) {
        if (isEn) {
          reply = 'Today, you completed ${state.todaySalesCount} sales for a total revenue of ${AppTheme.formatFCFA(state.todayRevenue)}.';
        } else {
          reply = 'Aujourd\'hui, vous avez réalisé ${state.todaySalesCount} ventes pour un chiffre d\'affaires total de ${AppTheme.formatFCFA(state.todayRevenue)}.';
        }
      } else if (t.contains('crédit') || t.contains('dette') || t.contains('credit') || t.contains('debt')) {
        if (isEn) {
          reply = 'To record a credit sale: Go to Point of Sale, add items to cart, tap Checkout then select Customer Debt / Credit.';
        } else {
          reply = 'Pour enregistrer une vente à crédit : Rendez-vous dans Point de vente, ajoutez les articles au panier, touchez Payer puis sélectionnez Crédit / Dette client.';
        }
      } else if (t.contains('stock') || t.contains('bas') || t.contains('low')) {
        if (isEn) {
          reply = 'Your catalog currently has ${state.products.length} registered products. Be sure to check the minimum threshold of 5 units in the Inventory tab.';
        } else {
          reply = 'Votre inventaire compte actuellement ${state.products.length} articles référencés. Pensez à vérifier le seuil minimal de 5 unités dans l\'onglet Stock.';
        }
      } else if (t.contains('configuration') || t.contains('termine') || t.contains('setup')) {
        if (isEn) {
          reply = 'Recommended steps: 1. Customize your Company Profile, 2. Configure Mobile Money & Cash payments, 3. Invite your team/cashiers.';
        } else {
          reply = 'Voici les étapes recommandées : 1. Personnaliser le profil d\'entreprise, 2. Configurer les moyens de paiement Mobile Money & Cash, 3. Inviter vos caissiers.';
        }
      } else {
        if (isEn) {
          reply = 'Understood! I am Bricelo, your intelligent AI assistant connected to your store. What would you like to inspect next (sales, inventory, debts)?';
        } else {
          reply = 'Bien reçu ! Je suis Bricelo, votre assistant intelligent connecté à votre commerce. Que souhaitez-vous vérifier ensuite (ventes, inventaire, clients) ?';
        }
      }

      setState(() {
        _messages.add({'sender': 'bricelo', 'text': reply});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEn = AppState.instance.currentLanguage == 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        title: Text(
          'Assistant Bricelo'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEn
                      ? 'Ask your questions to Bricelo, your smart assistant'
                      : 'Posez vos questions à Bricelo, votre assistant intelligent',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // En-tête Bricelo AI
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.smart_toy_outlined, color: AppTheme.accentGold, size: 40),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isEn ? 'Hello, I\'m Bricelo' : 'Salut, je suis Bricelo',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isEn
                          ? 'Your store\'s smart copilot. Ask me about your sales, inventory or debts.'
                          : 'Le copilote intelligent de votre boutique Bricelo. Posez une question sur vos ventes, votre stock ou vos dettes.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Questions suggérées
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _prompts.map((p) {
                    return ActionChip(
                      label: Text(p, style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937))),
                      backgroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      onPressed: () => _sendMessage(p),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Historique des messages
                ..._messages.map((m) {
                  final isUser = m['sender'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      decoration: BoxDecoration(
                        color: isUser ? AppTheme.primaryNavy : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isUser ? null : Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Text(
                        m['text'] ?? '',
                        style: TextStyle(
                          color: isUser ? Colors.white : const Color(0xFF1F2937),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Barre de saisie
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: isEn ? 'Ask Bricelo a question...' : 'Posez une question à Bricelo...',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryNavy,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: AppTheme.accentGold, size: 20),
                      onPressed: () => _sendMessage(_msgCtrl.text),
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
