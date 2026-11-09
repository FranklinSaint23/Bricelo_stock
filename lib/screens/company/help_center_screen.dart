import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/dashboard/bricelo_assistant_screen.dart';
import 'package:stock_prime/widgets/widgets.dart';

class HelpArticle {
  final String category;
  final String title;
  final String description;
  final IconData icon;
  final List<String> steps;

  const HelpArticle({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
  });
}

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final appState = AppState.instance;
  final _searchCtrl = TextEditingController();

  final List<HelpArticle> _allArticles = const [
    // 1. Pour commencer
    HelpArticle(
      category: 'Pour commencer',
      title: 'Enregistrer ma première vente',
      description: 'Ajouter des produits au panier, encaisser, partager le reçu.',
      icon: Icons.add_shopping_cart,
      steps: [
        '1. Allez dans l\'onglet "Vente" depuis la barre du bas.',
        '2. Touchez les produits à ajouter au panier ou utilisez le lecteur de code-barres.',
        '3. Ajustez les quantités si nécessaire avec les boutons + ou -.',
        '4. Cliquez sur "Encaisser", choisissez le mode de règlement (Espèces, Orange Money, MTN MoMo, Carte).',
        '5. Validez pour enregistrer la vente et imprimer ou partager le ticket reçu par WhatsApp.',
      ],
    ),
    HelpArticle(
      category: 'Pour commencer',
      title: 'Créer un produit (avec ou sans variantes)',
      description: 'Bien renseigner un produit : prix, coût, variantes, stock initial.',
      icon: Icons.inventory_2_outlined,
      steps: [
        '1. Rendez-vous dans l\'onglet "Produits".',
        '2. Touchez le bouton "+ Ajouter un produit".',
        '3. Renseignez le nom, la catégorie, le prix d\'achat unitaire et le prix de vente.',
        '4. Saisissez la quantité initiale en stock pour activer le suivi.',
        '5. Ajoutez éventuellement des variantes (ex: Tailles, Couleurs) et enregistrez.',
      ],
    ),
    HelpArticle(
      category: 'Pour commencer',
      title: 'Comment fonctionne Bricelo Stock',
      description: 'Ventes, stock, dettes, dépenses, achats, rapports et comptabilité : la vue d\'ensemble.',
      icon: Icons.info_outline,
      steps: [
        'Bricelo Stock unifie toute votre gestion commerciale en temps réel :',
        '• Vos ventes déduisent immédiatement les articles du stock.',
        '• Vos marges bénéficiaires se calculent automatiquement à partir des coûts d\'achat.',
        '• Les crédits clients et dettes fournisseurs sont suivis au centime près.',
        '• Chaque opération alimente les rapports financiers et la comptabilité SYSCOHADA.',
      ],
    ),
    HelpArticle(
      category: 'Pour commencer',
      title: 'La boutique en ligne, en bref',
      description: 'Catalogue public, commandes sans paiement en ligne, catalogues WhatsApp, promotions, commandes externes et Studio vidéo.',
      icon: Icons.storefront_outlined,
      steps: [
        '1. Activez votre boutique dans "Promotion & boutique" > "Boutique en ligne".',
        '2. Personnalisez votre lien unique (ex: bricelo.app/s/votre-magasin).',
        '3. Vos clients parcourent votre vitrine sur smartphone sans installer d\'application.',
        '4. Ils passent commande directement, vous recevez les notifications dans "Commandes en ligne".',
      ],
    ),

    // 2. Ventes & POS
    HelpArticle(
      category: 'Ventes & POS',
      title: 'Sessions de caisse (shifts)',
      description: 'Ouvrir et fermer un shift, saisir le fond de caisse, responsabiliser chaque caissier.',
      icon: Icons.point_of_sale_outlined,
      steps: [
        '1. Définissez le fond de caisse d\'ouverture le matin.',
        '2. Encaissez les ventes tout au long de la journée.',
        '3. En fin de service, effectuez la clôture de caisse avec le comptage physique.',
        '4. Bricelo compare automatiquement le montant théorique et le réel pour détecter les écarts.',
      ],
    ),
    HelpArticle(
      category: 'Ventes & POS',
      title: 'Analyse des ventes',
      description: 'KPIs, tendance du chiffre d\'affaires, meilleures ventes et compte de résultat — tout en un écran. Fonctionnalité Pro.',
      icon: Icons.bar_chart_outlined,
      steps: [
        '1. Accédez à "Ventes & clients" > "Analyse des ventes".',
        '2. Filtrez par période (Jour, Semaine, Mois, Année).',
        '3. Consultez le Chiffre d\'Affaires, le Panier Moyen et le Top 5 des articles les plus rentables.',
      ],
    ),
    HelpArticle(
      category: 'Ventes & POS',
      title: 'Historique des ventes',
      description: 'Retrouver une vente passée, consulter ou partager un reçu, filtrer par période ou statut.',
      icon: Icons.receipt_long_outlined,
      steps: [
        '1. Consultez l\'historique complet des tickets émis.',
        '2. Filtrez par date, par caissier ou par mode de paiement.',
        '3. Réimprimez un reçu ou envoyez-le par SMS / WhatsApp à votre client.',
      ],
    ),

    // 3. Stock & inventaire
    HelpArticle(
      category: 'Stock & inventaire',
      title: 'Ajuster le stock après un comptage',
      description: 'Quand utiliser un ajustement plutôt qu\'un inventaire.',
      icon: Icons.assignment_outlined,
      steps: [
        '1. Allez dans "Stock" > "Ajustement de stock".',
        '2. Sélectionnez l\'article concerné.',
        '3. Saisissez la quantité réelle constatée en rayon et le motif de régularisation.',
      ],
    ),
    HelpArticle(
      category: 'Stock & inventaire',
      title: 'Casse, vol, périmé : enregistrer une perte',
      description: 'Comment retirer du stock sans fausser vos rapports de vente.',
      icon: Icons.delete_outline,
      steps: [
        '1. Rendez-vous dans "Stock" > "Pertes & dépréciations".',
        '2. Déclarez la marchandise perdue ou avariée.',
        '3. La perte est imputée au coût d\'exploitation sans impacter les ventes réelles.',
      ],
    ),
    HelpArticle(
      category: 'Stock & inventaire',
      title: 'Transférer du stock entre deux boutiques',
      description: 'Déplacer des produits sans erreur de comptage.',
      icon: Icons.swap_horiz,
      steps: [
        '1. Ouvrez "Stock" > "Transferts de stock".',
        '2. Choisissez le dépôt expéditeur et le magasin destinataire.',
        '3. Validez l\'expédition puis confirmez la bonne réception à l\'arrivée.',
      ],
    ),

    // 4. Achats & fournisseurs
    HelpArticle(
      category: 'Achats & fournisseurs',
      title: 'Bon de commande et réception',
      description: 'Commander auprès d\'un fournisseur, réceptionner les marchandises.',
      icon: Icons.assignment_turned_in_outlined,
      steps: [
        '1. Dans "Achats & dépenses", créez un "Nouveau bon d\'achat".',
        '2. Suivez les 4 étapes : Fournisseur, Destination, Articles, Récapitulatif.',
        '3. Dès réception des colis, validez la rentrée en stock automatique.',
      ],
    ),
    HelpArticle(
      category: 'Achats & fournisseurs',
      title: 'Pourquoi les fournisseurs sont indispensables',
      description: 'Trois choses que les fournisseurs débloquent dans Bricelo Stock.',
      icon: Icons.local_shipping_outlined,
      steps: [
        '1. Historique d\'achat et négociation des meilleurs prix de revient.',
        '2. Traçabilité des bons de commande et réceptions partielles.',
        '3. Suivi précis des dettes et acomptes sans risque de double paiement.',
      ],
    ),
    HelpArticle(
      category: 'Achats & fournisseurs',
      title: 'Dettes fournisseurs & factures',
      description: 'Voir en un coup d\'œil tout ce que vous devez à chaque fournisseur, enregistrer vos paiements et gérer les acomptes.',
      icon: Icons.description_outlined,
      steps: [
        '1. Allez dans "Achats & dépenses" > "Dettes fournisseurs".',
        '2. Visualisez le total dû aux créanciers et les dates d\'échéance.',
        '3. Cliquez sur "Régler" pour saisir un paiement partiel ou total.',
      ],
    ),
    HelpArticle(
      category: 'Achats & fournisseurs',
      title: 'Coût d\'achat réel (landed cost)',
      description: 'Comprendre comment le transport, la douane et les autres frais s\'ajoutent au prix d\'achat pour donner votre vraie marge.',
      icon: Icons.balance_outlined,
      steps: [
        'Le landed cost intègre le prix usine + fret + douane + manutention.',
        'Bricelo répartit ces coûts additionnels sur chaque article pour vous assurer un prix de vente toujours rentable.',
      ],
    ),
    HelpArticle(
      category: 'Achats & fournisseurs',
      title: 'Approvisionnement — réception de marchandises',
      description: 'Enregistrer l\'arrivée de stock en une seule étape : fournisseur, articles, frais et facture, tout en même temps.',
      icon: Icons.move_to_inbox_outlined,
      steps: [
        '1. Sélectionnez le fournisseur livreur.',
        '2. Pointez les quantités physiquement déchargées.',
        '3. Validez : le stock augmente et la facture d\'achat est comptabilisée.',
      ],
    ),

    // 5. Finances
    HelpArticle(
      category: 'Finances',
      title: 'Enregistrer une dépense',
      description: 'Loyer, électricité, salaires : tout ce qui réduit votre profit.',
      icon: Icons.payments_outlined,
      steps: [
        '1. Rendez-vous dans "Achats & dépenses" > "Dépenses".',
        '2. Choisissez la catégorie (Loyer, Frais de livraison, Salaires, Électricité).',
        '3. Saisissez le montant et le mode de règlement pour actualiser votre solde de caisse.',
      ],
    ),

    // 6. Comptabilité
    HelpArticle(
      category: 'Comptabilité',
      title: 'Journal & activation de la comptabilité',
      description: 'Activez la comptabilité SYSCOHADA pour que chaque vente génère automatiquement des écritures comptables.',
      icon: Icons.menu_book_outlined,
      steps: [
        '1. Dans "Comptabilité & trésorerie", cochez l\'activation du journal.',
        '2. Les écritures de débit/crédit respectent la norme OHADA en vigueur.',
        '3. Exportez votre grand livre pour votre expert-comptable en un clic.',
      ],
    ),
    HelpArticle(
      category: 'Comptabilité',
      title: 'La balance générale',
      description: 'Vérifiez l\'équilibre de votre comptabilité en consultant les soldes débit et crédit par compte.',
      icon: Icons.account_balance_outlined,
      steps: [
        'Consultez la synthèse des comptes de classe 1 à 7 pour vous assurer de l\'exacte égalité Débit = Crédit.',
      ],
    ),
    HelpArticle(
      category: 'Comptabilité',
      title: 'Le compte de résultat',
      description: 'Mesurez votre bénéfice réel en comparant vos produits (recettes) et vos charges (dépenses) sur une période.',
      icon: Icons.analytics_outlined,
      steps: [
        'Visualisez le résultat net d\'exploitation : Chiffre d\'affaires moins Achats consommés et Charges courantes.',
      ],
    ),
    HelpArticle(
      category: 'Comptabilité',
      title: 'Le bilan comptable',
      description: 'Visualisez la santé financière de votre commerce : ce que vous possédez (actif) face à ce que vous devez (passif).',
      icon: Icons.feed_outlined,
      steps: [
        'L\'Actif regroupe vos stocks, créances et disponibilités en caisse.',
        'Le Passif détaille vos capitaux propres et vos dettes fournisseurs.',
      ],
    ),
    HelpArticle(
      category: 'Comptabilité',
      title: 'La TVA — collectée, déductible et à reverser',
      description: 'Calculez la TVA que vous devez reverser à l\'État en un coup d\'œil, et préparez votre déclaration périodique.',
      icon: Icons.receipt_outlined,
      steps: [
        '1. La TVA collectée sur vos ventes est calculée automatiquement (ex: 19,25%).',
        '2. Bricelo déduit la TVA payée sur vos achats professionnels.',
        '3. Le solde net à reverser est affiché en direct pour votre déclaration fiscale.',
      ],
    ),
    HelpArticle(
      category: 'Comptabilité',
      title: 'Clôturer une période comptable',
      description: 'Verrouillez une période terminée pour figer vos chiffres et protéger vos états financiers contre toute modification accidentelle.',
      icon: Icons.calendar_month_outlined,
      steps: [
        '1. Rendez-vous dans "Comptabilité & trésorerie" > "Clôture de période".',
        '2. Choisissez la période à verrouiller (Mois, Trimestre ou Exercice annuel).',
        '3. Une fois clôturée, aucune écriture rétroactive ne peut altérer les comptes validés.',
      ],
    ),
    HelpArticle(
      category: 'Comptabilité',
      title: 'Immobilisations & amortissements',
      description: 'Enregistrer un véhicule, un frigo ou un équipement et répartir son coût dans le temps.',
      icon: Icons.apartment_outlined,
      steps: [
        '1. Déclarez vos immobilisations corporelles (matériel, agencement, véhicules).',
        '2. Définissez la durée d\'amortissement (ex: 3 ans, 5 ans).',
        '3. Les dotations aux amortissements sont calculées automatiquement dans vos charges.',
      ],
    ),
    HelpArticle(
      category: 'Comptabilité',
      title: 'La paie : bulletins, CNPS et ITS',
      description: 'Générer les bulletins de salaire, calculer les cotisations CNPS et l\'impôt ITS en quelques clics.',
      icon: Icons.badge_outlined,
      steps: [
        '1. Configurez les salaires de base de vos collaborateurs.',
        '2. Les retenues salariales (CNPS, ITS, Crédit Foncier) sont calculées automatiquement selon le barème officiel.',
        '3. Émettez les bulletins de paie certifiés à chaque fin de mois.',
      ],
    ),
    HelpArticle(
      category: 'Comptabilité',
      title: 'Clients à crédit : le suivi comptable des créances',
      description: 'Voir qui vous doit de l\'argent, depuis combien de temps, et comment cela s\'inscrit dans votre comptabilité (compte 411).',
      icon: Icons.history_outlined,
      steps: [
        '1. Chaque vente à crédit est enregistrée au débit du compte 411 - Clients.',
        '2. Suivez les créances échues et les délais de règlement accordés.',
        '3. Les versements partiels ou soldes régularisent automatiquement le compte client.',
      ],
    ),

    // 7. Trésorerie
    HelpArticle(
      category: 'Trésorerie',
      title: 'Comptes de paiement',
      description: 'Caisse espèces, Orange Money, banque : chaque compte suit son propre solde et propose le bon mode de paiement à la caisse.',
      icon: Icons.account_balance_wallet_outlined,
      steps: [
        '1. Créez vos différents comptes de trésorerie (Caisse principale, MTN MoMo, Orange Money, Compte bancaire).',
        '2. Chaque encaissement alimente immédiatement le solde du compte correspondant.',
        '3. Visualisez votre trésorerie globale disponible en temps réel.',
      ],
    ),
    HelpArticle(
      category: 'Trésorerie',
      title: 'Virements de fonds entre comptes',
      description: 'Déplacez de l\'argent d\'un compte vers un autre (ex. : caisse → banque) sans perdre la trace de vos soldes.',
      icon: Icons.swap_horiz,
      steps: [
        '1. Ouvrez "Comptabilité & trésorerie" > "Virement de fonds".',
        '2. Sélectionnez le compte source (ex: Caisse espèces) et le compte destination (ex: Banque).',
        '3. Validez : le mouvement est tracé sans fausser vos revenus ni vos dépenses d\'exploitation.',
      ],
    ),

    // 8. Clients
    HelpArticle(
      category: 'Clients',
      title: 'Vente à crédit et recouvrement',
      description: 'Suivre ce que les clients vous doivent et le récupérer.',
      icon: Icons.credit_card_outlined,
      steps: [
        '1. Lors de l\'encaissement, choisissez "Vente à crédit".',
        '2. Associez la vente à la fiche du client avec sa date d\'échéance promise.',
        '3. Envoyez des rappels polis par SMS ou WhatsApp en un clic.',
        '4. Enregistrez les règlements au fur et à mesure.',
      ],
    ),

    // 9. Réglages & équipe
    HelpArticle(
      category: 'Réglages & équipe',
      title: 'Bien organiser vos catégories',
      description: 'Quelques règles pour des rapports lisibles.',
      icon: Icons.label_outline,
      steps: [
        '1. Créez des catégories claires et homogènes (ex: Outillage, Quincaillerie, Électricité).',
        '2. Évitez les catégories "Fourre-tout" pour obtenir des statistiques de marge précises.',
        '3. Classez chaque nouvel article dans sa catégorie appropriée.',
      ],
    ),
    HelpArticle(
      category: 'Réglages & équipe',
      title: 'Configurer la devise',
      description: 'FCFA, EUR, USD : choisir la devise de votre commerce.',
      icon: Icons.paid_outlined,
      steps: [
        '1. Rendez-vous dans "Entreprise & équipe" > "Préférences".',
        '2. Sélectionnez votre devise de base (F CFA par défaut, EUR ou USD).',
        '3. Tous vos prix, devis et factures s\'adapteront instantanément.',
      ],
    ),
    HelpArticle(
      category: 'Réglages & équipe',
      title: 'Ajouter des caissiers et gérer les rôles',
      description: 'Inviter votre équipe avec les bons droits.',
      icon: Icons.person_add_alt_1_outlined,
      steps: [
        '1. Allez dans "Entreprise & équipe" > "Équipe & utilisateurs".',
        '2. Cliquez sur "+ Ajouter un membre".',
        '3. Attribuez un rôle (Caissier, Gestionnaire de stock, Gérant ou Propriétaire).',
        '4. Définissez les permissions (masquer les prix d\'achat, interdire les remises sans accord).',
      ],
    ),
    HelpArticle(
      category: 'Réglages & équipe',
      title: 'Plans, essai et mise à niveau',
      description: 'Gratuit vs Pro vs Business : ce qui change vraiment.',
      icon: Icons.rocket_launch_outlined,
      steps: [
        '• Gratuit : Gestion de caisse standard, 1 magasin, rapports de base.',
        '• Pro : Multi-utilisateurs, comptabilité SYSCOHADA complète, suivi dettes et créances.',
        '• Business : Multi-boutiques, entrepôts multiples, Studio vidéo IA et support VIP prioritaire.',
      ],
    ),
    HelpArticle(
      category: 'Réglages & équipe',
      title: 'Approuver les demandes de votre équipe',
      description: 'Valider ou refuser les remises, annulations et modifications de prix demandées par vos caissiers.',
      icon: Icons.fact_check_outlined,
      steps: [
        '1. Dans "Entreprise & équipe" > "Approbations".',
        '2. Recevez une notification instantanée dès qu\'un caissier demande une remise exceptionnelle.',
        '3. Validez ou rejetez à distance en direct depuis votre smartphone.',
      ],
    ),
    HelpArticle(
      category: 'Réglages & équipe',
      title: 'Journal d\'activité : qui a fait quoi ?',
      description: 'Retrouvez chaque action enregistrée dans Bricelo Stock — ventes, modifications de stock, connexions — pour contrôler et corriger.',
      icon: Icons.history_outlined,
      steps: [
        '1. Le journal d\'audit consigne toutes les opérations avec date, heure et auteur.',
        '2. Repérez facilement qui a modifié un prix ou supprimé une ligne d\'article.',
        '3. Garantissez une transparence totale au sein de votre commerce.',
      ],
    ),
    HelpArticle(
      category: 'Réglages & équipe',
      title: 'Gérer vos boutiques et entrepôts',
      description: 'Créer plusieurs points de vente ou entrepôts pour suivre le stock par endroit.',
      icon: Icons.store_mall_directory_outlined,
      steps: [
        '1. Allez dans "Entreprise & équipe" > "Points de vente".',
        '2. Ajoutez un nouveau point de vente ou dépôt de stockage.',
        '3. Consultez le stock disponible pour chaque emplacement séparément.',
      ],
    ),
    HelpArticle(
      category: 'Réglages & équipe',
      title: 'Profil de l\'entreprise et fiscalité',
      description: 'Nom, logo, adresse, RCCM, régime fiscal : tout ce qui apparaît sur vos reçus et factures professionnels.',
      icon: Icons.store_outlined,
      steps: [
        '1. Dans "Entreprise & équipe" > "Profil de l\'entreprise".',
        '2. Complétez le Numéro d\'Identifiant Unique (NIU) et le RCCM.',
        '3. Téléversez votre logo pour qu\'il figure sur l\'en-tête de vos tickets et devis.',
      ],
    ),
    HelpArticle(
      category: 'Réglages & équipe',
      title: 'Comprendre les crédits',
      description: 'Deux portefeuilles : crédits vidéo IA (Studio) et crédits publicitaires (Boost TikTok). Ce qu\'ils achètent, ce qui est remboursé, comment payer.',
      icon: Icons.auto_awesome_outlined,
      steps: [
        '• Crédits Studio Vidéo : Utilisés pour générer des vidéos marketing animées de vos articles.',
        '• Crédits Publicitaires : Pour sponsoriser vos catalogues sur Facebook, Instagram et TikTok.',
        '• Recharge instantanée par Mobile Money (Orange Money, MTN MoMo).',
      ],
    ),
    HelpArticle(
      category: 'Réglages & équipe',
      title: 'Repartir à zéro après vos essais',
      description: 'Pendant les 7 premiers jours, le propriétaire peut effacer toutes les données de test (produits, stock, ventes, clients...) et démarrer pour de vrai.',
      icon: Icons.restart_alt_outlined,
      steps: [
        '1. Rendez-vous dans "Entreprise & équipe" > "Réinitialiser les données".',
        '2. Seul le propriétaire peut exécuter cette action avec confirmation de sécurité.',
        '3. Les données de simulation sont purgées pour laisser place à votre inventaire réel.',
      ],
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showArticleDetails(HelpArticle article) {
    final isDark = appState.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollCtrl) {
            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(22),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(article.icon, color: AppTheme.accentGold, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentGold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            article.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : AppTheme.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  article.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Instructions & Bonnes Pratiques',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                ...article.steps.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Compris', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQuickTourModal() {
    final isDark = appState.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.explore_outlined, color: AppTheme.accentGold),
            SizedBox(width: 10),
            Text('Tour rapide de Bricelo Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '1. Accueil : Suivez vos ventes du jour et alertes stock.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 8),
            Text(
              '2. Vente : Encaissez rapidement au comptoir avec reçu instantané.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 8),
            Text(
              '3. Produits : Gérez votre catalogue, prix et stocks.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 8),
            Text(
              '4. Stock : Inventaires, approvisionnements et transferts.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 8),
            Text(
              '5. Plus : Comptabilité, fournisseurs, dépenses et boutique.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('C\'est parti !'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final query = _searchCtrl.text.trim().toLowerCase();

        final filtered = query.isEmpty
            ? _allArticles
            : _allArticles.where((a) {
                return a.title.toLowerCase().contains(query) ||
                    a.description.toLowerCase().contains(query) ||
                    a.category.toLowerCase().contains(query);
              }).toList();

        final categories = [
          'Pour commencer',
          'Ventes & POS',
          'Stock & inventaire',
          'Achats & fournisseurs',
          'Finances',
          'Comptabilité',
          'Trésorerie',
          'Clients',
          'Réglages & équipe',
        ];

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: StockAppBar.navy(
            title: 'Centre d\'aide',
            onBack: () => Navigator.pop(context),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            children: [
              // 1. CHAMP DE RECHERCHE UN SUJET
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un sujet...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                      size: 22,
                    ),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (query.isEmpty) ...[
                // 2. CARTE ASSISTANT BRICELO
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BriceloAssistantScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFB45309), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Posez votre question à l\'Assistant Bricelo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : const Color(0xFF92400E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Réponse immédiate, adaptée à votre boutique.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF92400E),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 3. TOUR RAPIDE DE BRICELO STOCK
                InkWell(
                  onTap: _showQuickTourModal,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.explore_outlined, color: AppTheme.accentGold, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tour rapide de Bricelo Stock',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '2 min : la façon recommandée d\'utiliser l\'app.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 4. TUTORIELS VIDÉO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Color(0xFFDC2626), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tutoriels vidéo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Apprenez Bricelo Stock en vidéo, et dites-nous en commentaire les sujets que vous voulez voir.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ouverture des tutoriels YouTube Bricelo Stock...')),
                                );
                              },
                              child: Row(
                                children: const [
                                  Text(
                                    'Regarder sur YouTube • @bricelostock',
                                    style: TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.open_in_new, size: 14, color: Color(0xFFDC2626)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 5. TOUTES LES RUBRIQUES D'AIDE PAR CATÉGORIE
              if (query.isNotEmpty) ...[
                Text(
                  '${filtered.length} résultat(s) pour "$query"',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 12),
                ...filtered.map((article) => _buildArticleTile(article, isDark)),
              ] else ...[
                ...categories.map((cat) {
                  final catArticles = _allArticles.where((a) => a.category == cat).toList();
                  if (catArticles.isEmpty) return const SizedBox();

                  IconData catIcon;
                  switch (cat) {
                    case 'Pour commencer':
                      catIcon = Icons.rocket_launch_outlined;
                      break;
                    case 'Ventes & POS':
                      catIcon = Icons.shopping_cart_outlined;
                      break;
                    case 'Stock & inventaire':
                      catIcon = Icons.inventory_2_outlined;
                      break;
                    case 'Achats & fournisseurs':
                      catIcon = Icons.local_shipping_outlined;
                      break;
                    case 'Finances':
                      catIcon = Icons.payments_outlined;
                      break;
                    case 'Comptabilité':
                      catIcon = Icons.menu_book_outlined;
                      break;
                    case 'Trésorerie':
                      catIcon = Icons.account_balance_outlined;
                      break;
                    case 'Clients':
                      catIcon = Icons.people_outline;
                      break;
                    case 'Réglages & équipe':
                      catIcon = Icons.settings_outlined;
                      break;
                    default:
                      catIcon = Icons.help_outline;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        child: Row(
                          children: [
                            Icon(catIcon, color: AppTheme.accentGold, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              cat,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : AppTheme.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...catArticles.map((article) => _buildArticleTile(article, isDark)),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ],
            ],
          ),
          bottomNavigationBar: StockBottomBar(
            currentIndex: 4,
            onTap: (_) => Navigator.pop(context),
          ),
        );
      },
    );
  }

  Widget _buildArticleTile(HelpArticle article, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(
          article.icon,
          size: 24,
          color: isDark ? AppTheme.accentGold : const Color(0xFF4B5563),
        ),
        title: Text(
          article.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            article.description,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
              height: 1.3,
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
        onTap: () => _showArticleDetails(article),
      ),
    );
  }
}
