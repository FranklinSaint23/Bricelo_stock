import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/bricelo_ai_service.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class BriceloAssistantScreen extends StatefulWidget {
  const BriceloAssistantScreen({super.key});

  @override
  State<BriceloAssistantScreen> createState() => _BriceloAssistantScreenState();
}

class _BriceloAssistantScreenState extends State<BriceloAssistantScreen> {
  final _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  List<String> get _prompts {
    final isEn = AppState.instance.currentLanguage == 'en';
    if (isEn) {
      return [
        'How much did I sell today?',
        'Which items are low on stock?',
        'What is a hammer?',
        'Write a description for a power drill',
      ];
    }
    return [
      'Combien j\'ai vendu aujourd\'hui ?',
      'Quel est mon stock actuel ?',
      'C\'est quoi une perceuse ?',
      'C\'est quoi une banane ?',
      'Rédige une description pour un produit',
    ];
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': query});
      _isLoading = true;
    });
    _msgCtrl.clear();
    _scrollToBottom();

    try {
      final history = _messages
          .map((m) => {
                'sender': (m['sender'] ?? '').toString(),
                'text': (m['text'] ?? '').toString(),
              })
          .toList();

      final response = await BriceloAIService.instance.chat(
        userMessage: query,
        history: history,
      );

      final cleanText = BriceloAIService.instance.cleanDisplayText(response);
      final productAction = BriceloAIService.instance.extractProductAction(response);

      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'bricelo',
            'text': cleanText,
            'productAction': productAction,
            'isProductAdded': false,
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'bricelo',
            'text': 'Une erreur est survenue lors de la communication. Veuillez vérifier votre connexion.',
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _addProductFromChat(Map<String, dynamic> actionData, int messageIndex) {
    try {
      final name = (actionData['name'] ?? 'Nouveau produit').toString();
      final price = (actionData['price'] as num?)?.toDouble() ?? 1000.0;
      final buyPrice = (actionData['buyPrice'] as num?)?.toDouble() ?? (price * 0.7);
      final quantity = (actionData['quantity'] as num?)?.toInt() ?? 1;
      final category = (actionData['category'] ?? 'Général').toString();

      final newProduct = Product(
        id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        category: category,
        barcode: '690${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
        buyPrice: buyPrice,
        sellPrice: price,
        stock: quantity,
        minStockAlert: 5,
        unit: 'Pièce',
      );

      AppState.instance.addProduct(newProduct);

      setState(() {
        _messages[messageIndex]['isProductAdded'] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produit "$name" ($quantity unités) ajouté au stock avec succès !'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur ajout produit: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = AppState.instance.currentLanguage == 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Assistant Bricelo'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
              tooltip: 'Effacer la conversation',
              onPressed: () {
                setState(() => _messages.clear());
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                // En-tête Bricelo AI
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.auto_awesome, color: AppTheme.accentGold, size: 36),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isEn ? 'Hello, I\'m Bricelo' : 'Salut, je suis Bricelo',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEn
                            ? 'Your store\'s smart copilot. I can draft descriptions, add items or inspect your sales.'
                            : 'Copilote intelligent connecté à votre boutique. Je rédige des descriptions, aide à l\'ajout de produits et analyse votre commerce.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Questions suggérées
                if (_messages.isEmpty) ...[
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
                ],

                // Messages
                for (int i = 0; i < _messages.length; i++) ...[
                  Builder(builder: (_) {
                    final m = _messages[i];
                    final isUser = m['sender'] == 'user';
                    final productAction = m['productAction'] as Map<String, dynamic>?;
                    final isAdded = m['isProductAdded'] as bool? ?? false;

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                        decoration: BoxDecoration(
                          color: isUser ? AppTheme.primaryNavy : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: isUser ? null : Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isUser ? 0.08 : 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome, size: 14, color: AppTheme.accentGold),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Bricelo IA',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: m['text'] ?? ''));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Texte copié')),
                                      );
                                    },
                                    child: const Icon(Icons.copy, size: 14, color: Color(0xFF9CA3AF)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],
                            SelectableText(
                              m['text'] ?? '',
                              style: TextStyle(
                                color: isUser ? Colors.white : const Color(0xFF1F2937),
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                            ),
                            // Action Card si l'IA propose un ajout de produit
                            if (productAction != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFBBF7D0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.add_shopping_cart, size: 18, color: Color(0xFF16A34A)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            (productAction['name'] ?? 'Produit').toString(),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF166534)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Prix de vente : ${AppTheme.formatFCFA((productAction['price'] as num?)?.toDouble() ?? 0)} · Quantité : ${productAction['quantity'] ?? 1}',
                                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF15803D)),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isAdded ? const Color(0xFF6B7280) : const Color(0xFF16A34A),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        icon: Icon(isAdded ? Icons.check : Icons.add, size: 16),
                                        label: Text(
                                          isAdded ? 'Article déjà ajouté' : 'Confirmer l\'ajout au stock',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: isAdded ? null : () => _addProductFromChat(productAction, i),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],

                // Indicateur de chargement
                if (_isLoading)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentGold),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Bricelo réfléchit...',
                            style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                        hintText: isEn ? 'Ask Bricelo a question...' : 'Posez une question ou demandez d\'ajouter un article...',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
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
                      icon: const Icon(Icons.send_rounded, color: AppTheme.accentGold, size: 20),
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
