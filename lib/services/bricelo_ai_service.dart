import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class BriceloAIService {
  BriceloAIService._();
  static final BriceloAIService instance = BriceloAIService._();

  static const String _groqApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
  static const String _groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _primaryModel = 'openai/gpt-oss-120b';
  static const String _fallbackModel = 'openai/gpt-oss-20b';

  /// Construit le System Prompt dynamique avec tout le contexte réel de la boutique
  String _buildSystemPrompt() {
    final appState = AppState.instance;

    final storeName = appState.displayCompanyName;
    final activity = appState.companyActivity.isNotEmpty ? appState.companyActivity : 'Commerce général et distribution';
    final city = appState.brandCity.isNotEmpty ? appState.brandCity : 'Cameroun / Afrique';
    final tone = appState.brandTone.isNotEmpty ? appState.brandTone : 'Dynamique et chaleureux';
    final addressing = appState.brandAddressing.isNotEmpty ? appState.brandAddressing : '« vous »';
    final goodWords = appState.brandGoodWords.isNotEmpty ? appState.brandGoodWords : '';
    final badWords = appState.brandBadWords.isNotEmpty ? appState.brandBadWords : '';

    final categories = appState.categories.map((c) => c.name).take(20).join(', ');
    final sampleProducts = appState.products
        .take(35)
        .map((p) => '${p.name} (${AppTheme.formatFCFA(p.price)}, stock: ${p.stock})')
        .join(', ');

    final todaySales = appState.todaySalesCount;
    final todayRev = AppTheme.formatFCFA(appState.todayRevenue);

    return '''
Tu es Bricelo, l'assistant d'intelligence artificielle officiel et copilote commercial de la boutique "$storeName".
Tu t'adresses au commerçant avec le vouvoiement ($addressing) et un ton $tone.

--- FICHE D'IDENTITÉ DE LA BOUTIQUE DU COMMERÇANT ---
• Nom de l'enseigne : $storeName
• Activité principale : $activity
• Ville / Emplacement : $city
• Catégories en magasin : ${categories.isNotEmpty ? categories : "Général"}
• Échantillon des produits actuellement en rayon : ${sampleProducts.isNotEmpty ? sampleProducts : "Aucun article enregistré pour l'instant"}
• Total articles au catalogue : ${appState.products.length} références
• Performance du jour : $todaySales vente(s) enregistrée(s) pour un chiffre d'affaires de $todayRev
${goodWords.isNotEmpty ? "• Mots de marque favoris : $goodWords" : ""}
${badWords.isNotEmpty ? "• Mots à proscrire absolument : $badWords" : ""}

--- RÈGLES STRICTES DE SÉCURITÉ ET DE COMPORTEMENT ---
1. GARDE-FOUS DE SÉCURITÉ & CENSURE POLIE :
Si l'utilisateur pose une question intime, sexuelle, anatomique (ex: pénis, sexe, organes génitaux, pornographie), vulgaire, politique, religieuse ou médicale :
Tu dois impérativement et catégoriquement refuser de répondre. Tu le fais de manière très polie et professionnelle, en rappelant ton identité :
"Je suis Bricelo, votre assistant dédié exclusivement à la gestion de votre boutique, de vos stocks et de vos ventes. Je ne peux pas répondre à cette question, mais je reste à votre entière disposition pour vos articles, vos chiffres et votre commerce."

2. CONSCIENCE DU CATALOGUE MÉTIER :
Si l'utilisateur pose une question sur un objet, aliment, légume, fruit ou concept (exemple classique : "c'est quoi une banane ?", "définis une mangue", "combien coûte un costume") :
- Fournis une définition ou explication concise (1 à 2 phrases).
- Ensuite, vérifie IMMÉDIATEMENT si cet article correspond à l'activité de la boutique ("$activity") et aux produits en stock.
- Si la boutique ne vend PAS cet article (ex: une quincaillerie qui ne vend pas de bananes, ou une pharmacie qui ne vend pas de ciment), signale-le OBLIGATOIREMENT et clairement :
"💡 Note boutique : Votre établissement ($activity) ne commercialise pas cet article dans son catalogue actuel."

3. AIDE AU PRÉREMPLISSAGE & DESCRIPTIONS :
Si le commerçant te demande de rédiger ou préremplir une fiche produit ou une description :
Rédige un texte commercial percutant, valorisant, adapté au marché local africain (qualité, durabilité, prix juste).

4. DÉTECTION D'INTENTION D'AJOUT DE PRODUIT :
Si l'utilisateur demande explicitement d'ajouter un produit dans son stock (ex: "Ajoute 10 perceuses à 25000", "Ajoute un sac de riz 50kg à 22000 F"), en plus de ta réponse amicale, termine TOUJOURS ton message avec ce bloc JSON exact sur une ligne séparée :
[ACTION_ADD_PRODUCT:{"name":"Nom du produit","price":25000,"buyPrice":20000,"quantity":10,"category":"Outillage"}]
''';
  }

  /// Envoie un message de discussion à Bricelo avec historique
  Future<String> chat({
    required String userMessage,
    List<Map<String, String>> history = const [],
  }) async {
    final systemPrompt = _buildSystemPrompt();

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    // Inclut jusqu'à 6 messages d'historique récent
    final recentHistory = history.length > 6 ? history.sublist(history.length - 6) : history;
    for (final h in recentHistory) {
      final role = h['sender'] == 'user' ? 'user' : 'assistant';
      final text = h['text'] ?? '';
      if (text.isNotEmpty) {
        messages.add({'role': role, 'content': text});
      }
    }

    messages.add({'role': 'user', 'content': userMessage});

    // 1. Tente le modèle principal (120B reasoning) via Edge Function ou Groq direct
    try {
      final reply = await _callAI(messages: messages, model: _primaryModel);
      if (reply != null && reply.trim().isNotEmpty) return reply.trim();
    } catch (e) {
      debugPrint('Erreur primaryModel ($_primaryModel): $e');
    }

    // 2. Fallback sur le modèle secondaire (20B instant)
    try {
      final fallbackReply = await _callAI(messages: messages, model: _fallbackModel);
      if (fallbackReply != null && fallbackReply.trim().isNotEmpty) return fallbackReply.trim();
    } catch (e) {
      debugPrint('Erreur fallbackModel ($_fallbackModel): $e');
    }

    return "Désolé, je rencontre une légère perturbation de connexion avec mes serveurs. Veuillez réessayer dans un instant.";
  }

  /// Génère une description commerciale percutante pour l'ajout ou la modification d'un produit
  Future<String?> generateProductDescription({
    required String productName,
    String? category,
  }) async {
    final appState = AppState.instance;
    final activity = appState.companyActivity.isNotEmpty ? appState.companyActivity : 'Commerce de détail';
    final tone = appState.brandTone.isNotEmpty ? appState.brandTone : 'Professionnel';

    final prompt = '''
Rédige une description commerciale courte (2 à 3 phrases percutantes), vendeuse et professionnelle pour ce produit :
Produit : "$productName"
${category != null && category.isNotEmpty ? "Catégorie : $category" : ""}
Secteur de la boutique : $activity
Ton : $tone

Règles :
- Mets en valeur l'utilité, la robustesse ou le bénéfice pour le client.
- Pas de blabla inutile, pas d'introduction (commence directement la description).
- Format prêt à coller dans une fiche article d'application de caisse.
''';

    final messages = [
      {'role': 'system', 'content': 'Tu es un expert en merchandising et rédaction de fiches produits pour le commerce en Afrique.'},
      {'role': 'user', 'content': prompt},
    ];

    try {
      final reply = await _callAI(messages: messages, model: _primaryModel, maxTokens: 180);
      return reply?.trim();
    } catch (_) {
      try {
        final fallback = await _callAI(messages: messages, model: _fallbackModel, maxTokens: 180);
        return fallback?.trim();
      } catch (_) {
        return null;
      }
    }
  }

  /// Exécution IA unifiée : Tente d'abord l'Edge Function Supabase, puis bascule sur Groq direct
  Future<String?> _callAI({
    required List<Map<String, String>> messages,
    required String model,
    int maxTokens = 600,
  }) async {
    // 1. Tente l'Edge Function Supabase (si déployée en production)
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'bricelo-ai',
        body: {
          'messages': messages,
          'model': model,
          'max_tokens': maxTokens,
        },
      ).timeout(const Duration(seconds: 15));

      if (res.status == 200 && res.data != null) {
        final Map<String, dynamic> data = res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : (res.data is String ? jsonDecode(res.data as String) : {});
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>?;
          final content = message?['content']?.toString();
          if (content != null && content.isNotEmpty) return content;
        }
      }
    } catch (e) {
      debugPrint('Supabase Edge Function non joignable ($e), bascule automatique sur API Groq directe.');
    }

    // 2. Fallback direct vers Groq
    return _callGroq(messages: messages, model: model, maxTokens: maxTokens);
  }

  /// Appel HTTP à l'API Groq
  Future<String?> _callGroq({
    required List<Map<String, String>> messages,
    required String model,
    int maxTokens = 600,
  }) async {
    if (_groqApiKey.isEmpty) {
      return null;
    }

    final response = await http.post(
      Uri.parse(_groqEndpoint),
      headers: {
        'Authorization': 'Bearer $_groqApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': 0.4,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      final choices = data['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final message = choices[0]['message'] as Map<String, dynamic>?;
        final content = message?['content']?.toString();
        return content;
      }
    }
    return null;
  }

  /// Détecte si la réponse contient une action d'ajout de produit
  Map<String, dynamic>? extractProductAction(String text) {
    try {
      final regExp = RegExp(r'\[ACTION_ADD_PRODUCT:(.*?)\]');
      final match = regExp.firstMatch(text);
      if (match != null) {
        final jsonStr = match.group(1);
        if (jsonStr != null) {
          return jsonDecode(jsonStr) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint('Erreur extraction produit: $e');
    }
    return null;
  }

  /// Nettoie le texte affiché en retirant la balise JSON d'action
  String cleanDisplayText(String text) {
    return text.replaceAll(RegExp(r'\[ACTION_ADD_PRODUCT:.*?\]'), '').trim();
  }
}

