import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final appState = AppState.instance;
  bool _isAnnual = false; // Mensuel vs Annuel (-20%)

  void _showPaymentModal({
    required String planName,
    required int monthlyPrice,
    required int annualPrice,
  }) {
    final isYear = _isAnnual;
    final priceToPay = isYear ? annualPrice : monthlyPrice;
    final periodText = isYear ? '1 an' : '1 mois';
    String selectedMethod = 'Orange Money';
    final phoneCtrl = TextEditingController(text: appState.userPhone);
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activer la $planName',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Facturation $periodText',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Récapitulatif du montant
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total à payer :',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF334155)),
                      ),
                      Text(
                        '${_formatCfa(priceToPay)} F CFA',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Moyen de paiement sécurisé',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 10),

                // Sélection de l'opérateur
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildOperatorChip('Orange Money', Icons.phone_android_rounded, const Color(0xFFFF7900), selectedMethod, (val) => setModalState(() => selectedMethod = val)),
                    _buildOperatorChip('MTN MoMo', Icons.network_cell_rounded, const Color(0xFFFFCC00), selectedMethod, (val) => setModalState(() => selectedMethod = val)),
                    _buildOperatorChip('Wave', Icons.waves_rounded, const Color(0xFF1DA1F2), selectedMethod, (val) => setModalState(() => selectedMethod = val)),
                    _buildOperatorChip('Moov Money', Icons.mobile_screen_share_rounded, const Color(0xFF005BA6), selectedMethod, (val) => setModalState(() => selectedMethod = val)),
                    _buildOperatorChip('Carte Bancaire', Icons.credit_card_rounded, AppTheme.primaryNavy, selectedMethod, (val) => setModalState(() => selectedMethod = val)),
                  ],
                ),
                const SizedBox(height: 18),

                if (selectedMethod != 'Carte Bancaire') ...[
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Numéro de compte $selectedMethod *',
                      hintText: 'Ex: +237 689 39 88 07',
                      prefixIcon: const Icon(Icons.dialpad_rounded, size: 20, color: AppTheme.primaryNavy),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Vous recevrez un prompt USSD sur votre téléphone pour valider avec votre code secret.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ] else ...[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Numéro de carte (16 chiffres) *',
                      hintText: '4000 1234 5678 9010',
                      prefixIcon: const Icon(Icons.credit_card_rounded, size: 20, color: AppTheme.primaryNavy),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // Bouton de confirmation
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: isProcessing
                        ? null
                        : () async {
                            setModalState(() => isProcessing = true);
                            await Future.delayed(const Duration(milliseconds: 1200));

                            // Mise à jour de l'abonnement
                            await appState.updateSubscription(
                              plan: planName,
                              billing: isYear ? 'annuel' : 'mensuel',
                              durationMonths: isYear ? 12 : 1,
                            );

                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            if (!mounted) return;

                            _showSuccessDialog(planName, isYear ? '1 an' : '1 mois');
                          },
                    child: isProcessing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                          )
                        : Text(
                            'Payer ${_formatCfa(priceToPay)} F CFA',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorChip(
    String name,
    IconData icon,
    Color brandColor,
    String selectedMethod,
    ValueChanged<String> onSelect,
  ) {
    final isSelected = selectedMethod == name;
    return InkWell(
      onTap: () => onSelect(name),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryNavy : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryNavy : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppTheme.accentGold : brandColor),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String plan, String period) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF059669), size: 44),
            ),
            const SizedBox(height: 18),
            Text(
              'Félicitations !',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryNavy),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre boutique est maintenant passée sur la $plan ($period). Toutes les fonctionnalités avancées sont activées.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF4B5563), height: 1.4),
            ),
            const SizedBox(height: 22),
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
                child: const Text('Continuer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCfa(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  @override
  Widget build(BuildContext context) {
    final currentPlan = appState.subscriptionPlan;
    final isPro = currentPlan.toLowerCase().contains('pro');
    final isEnterprise = currentPlan.toLowerCase().contains('entreprise');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          'Formules & Abonnement',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARTE STATUT ACTUEL
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryNavy, Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_rounded, color: AppTheme.accentGold, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VOTRE FORMULE ACTUELLE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF93C5FD)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              currentPlan,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Actif',
                                style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        if (appState.subscriptionExpiresAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Renouvellement : ${appState.subscriptionExpiresAt!.day}/${appState.subscriptionExpiresAt!.month}/${appState.subscriptionExpiresAt!.year}',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFFE2E8F0)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SÉLECTEUR MENSUEL / ANNUEL
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _isAnnual = false),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: !_isAnnual ? AppTheme.primaryNavy : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Mensuel',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: !_isAnnual ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _isAnnual = true),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isAnnual ? AppTheme.primaryNavy : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Annuel',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isAnnual ? Colors.white : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '-20%',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // PLAN 1 : GRATUIT
            _buildPlanCard(
              title: 'Gratuit',
              badge: 'Découverte',
              price: '0 F CFA',
              period: '/ mois',
              isCurrent: currentPlan == 'Gratuit',
              features: const [
                '1 Boutique & 1 Caisse active',
                'Gestion jusqu\'à 50 produits en stock',
                'Factures & Reçus de caisse standards',
                'Historique des ventes basique',
              ],
              buttonLabel: currentPlan == 'Gratuit' ? 'Formule active' : 'Revenir au Gratuit',
              buttonAction: currentPlan == 'Gratuit'
                  ? null
                  : () async {
                      await appState.updateSubscription(plan: 'Gratuit', billing: 'mensuel');
                      if (mounted) setState(() {});
                    },
            ),
            const SizedBox(height: 16),

            // PLAN 2 : PRO (RECOMMANDÉ)
            _buildPlanCard(
              title: 'Formule Pro',
              badge: 'LE PLUS POPULAIRE',
              badgeColor: AppTheme.accentGold,
              price: _isAnnual ? '19 000 F CFA' : '1 900 F CFA',
              period: _isAnnual ? '/ an (1 580 F CFA/mois)' : '/ mois',
              isCurrent: isPro,
              highlighted: true,
              features: const [
                'Boutiques & Caisses illimitées (plusieurs points de vente)',
                'Produits et ventes illimités (aucun blocage)',
                'Factures & Reçus personnalisés avec le logo de votre boutique',
                'Signature calligraphique automatique sur vos factures',
                'Partage direct des factures et reçus sur WhatsApp aux clients',
                'Suivi précis des crédits / dettes clients et rappels',
                'Suivi des dépenses et dettes fournisseurs',
                'Gestion de l\'équipe (comptes caissiers, magasiniers, gérants)',
                'Alertes automatiques de stock faible et dates de péremption',
                'Calcul des bénéfices nets et bilans de caisse journaliers',
                'Sauvegarde automatique et sécurisée de vos données',
              ],
              buttonLabel: isPro ? 'Formule active' : 'Passer à la Formule Pro',
              buttonAction: isPro
                  ? null
                  : () => _showPaymentModal(
                        planName: 'Formule Pro',
                        monthlyPrice: 1900,
                        annualPrice: 19000,
                      ),
            ),
            const SizedBox(height: 16),

            // PLAN 3 : ENTREPRISE
            _buildPlanCard(
              title: 'Formule Entreprise',
              badge: 'GRANDES BOUTIQUES & RÉSEAUX',
              badgeColor: const Color(0xFF6366F1),
              price: _isAnnual ? '59 000 F CFA' : '5 900 F CFA',
              period: _isAnnual ? '/ an (4 900 F CFA/mois)' : '/ mois',
              isCurrent: isEnterprise,
              features: const [
                'Tout ce qui est inclus dans la Formule Pro',
                'Plusieurs magasins ou dépôts reliés ensemble',
                'Déplacer facilement des articles d\'un magasin à un autre',
                'Données synchronisées en direct sur les téléphones de vos employés',
                'Conseiller intelligent Bricelo pour analyser et booster vos ventes',
                'Téléchargement de vos bilans et rapports sur Excel et PDF',
                'Ligne WhatsApp prioritaire 7j/7 avec un conseiller dédié',
              ],
              buttonLabel: isEnterprise ? 'Formule active' : 'Choisir la Formule Entreprise',
              buttonAction: isEnterprise
                  ? null
                  : () => _showPaymentModal(
                        planName: 'Formule Entreprise',
                        monthlyPrice: 5900,
                        annualPrice: 59000,
                      ),
            ),
            const SizedBox(height: 24),

            // GARANTIE & ASSISTANCE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.security_rounded, color: Color(0xFF059669), size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Paiements sécurisés via Mobile Money & Carte. Vous pouvez changer de formule ou résilier à tout moment sans frais.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String badge,
    Color badgeColor = const Color(0xFFE2E8F0),
    required String price,
    required String period,
    required bool isCurrent,
    bool highlighted = false,
    required List<String> features,
    required String buttonLabel,
    required VoidCallback? buttonAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? AppTheme.accentGold : const Color(0xFFE2E8F0),
          width: highlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: highlighted ? AppTheme.accentGold.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor == const Color(0xFFE2E8F0) ? const Color(0xFF475569) : badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      period,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                ...features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrent
                          ? const Color(0xFFE2E8F0)
                          : (highlighted ? AppTheme.primaryNavy : const Color(0xFF1E293B)),
                      foregroundColor: isCurrent ? const Color(0xFF64748B) : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: buttonAction,
                    child: Text(
                      buttonLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: isCurrent ? const Color(0xFF64748B) : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

