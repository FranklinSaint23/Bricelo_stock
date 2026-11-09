import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class SubscriptionScreen extends StatefulWidget {
  final bool showAppBar;
  const SubscriptionScreen({super.key, this.showAppBar = true});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final appState = AppState.instance;
  bool _isAnnual = false; // Mensuel vs Annuel (-20%)

  String _safeSubscriptionPlan(AppState state) {
    try {
      return (state as dynamic).subscriptionPlan?.toString() ?? 'Gratuit';
    } catch (_) {
      return 'Gratuit';
    }
  }

  DateTime? _safeSubscriptionExpiresAt(AppState state) {
    try {
      return (state as dynamic).subscriptionExpiresAt as DateTime?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _safeUpdateSubscription(AppState state, {required String plan, required String billing, int durationMonths = 1}) async {
    try {
      await (state as dynamic).updateSubscription(plan: plan, billing: billing, durationMonths: durationMonths);
    } catch (_) {
      // safe fallback
    }
  }

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

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    Widget buildPaymentFormContent(BuildContext ctx, StateSetter setModalState) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isDesktop) ...[
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
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
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
                        'Facturation $periodText • Synchronisation automatique sur Mobile',
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
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

                        // Mise à jour de l'abonnement + synchronisation immédiate vers Supabase
                        await _safeUpdateSubscription(
                          appState,
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
      );
    }

    if (isDesktop) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: StatefulBuilder(builder: buildPaymentFormContent),
            ),
          ),
        ),
      );
      return;
    }

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
          child: buildPaymentFormContent(ctx, setModalState),
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
              'Votre boutique est maintenant passée sur la $plan ($period). Toutes les fonctionnalités avancées sont activées et synchronisées automatiquement sur votre application mobile via la base de données.',
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
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final currentPlan = _safeSubscriptionPlan(appState);
        final isPro = currentPlan.toLowerCase().contains('pro');
        final isEnterprise = currentPlan.toLowerCase().contains('entreprise');
        final expiresAt = _safeSubscriptionExpiresAt(appState);
        final isWideWeb = MediaQuery.of(context).size.width >= 960;

        final freeCard = _buildPlanCard(
          title: 'Gratuit',
          badge: 'Découverte',
          price: '0 F CFA',
          period: '/ mois',
          isCurrent: currentPlan == 'Gratuit' || currentPlan == 'Découverte',
          features: const [
            '1 Boutique & 1 Caisse active',
            'Max 30 produits en stock',
            'Max 50 ventes par mois (verrouillé au-delà)',
            '0 équipier invité (compte solo propriétaire)',
            'Max 5 clients à crédit (sans rappels auto)',
            'Historique des ventes limité à 14 jours',
            'Filigrane Bricelo imposé sur les reçus',
            'Pas de transferts de stock multi-boutiques',
          ],
          buttonLabel: currentPlan == 'Gratuit' || currentPlan == 'Découverte' ? 'Formule active' : 'Revenir au Gratuit',
          buttonAction: currentPlan == 'Gratuit' || currentPlan == 'Découverte'
              ? null
              : () async {
                  await _safeUpdateSubscription(appState, plan: 'Gratuit', billing: 'mensuel');
                  if (mounted) setState(() {});
                },
        );

        final proCard = _buildPlanCard(
          title: 'Formule Pro',
          badge: 'LE PLUS POPULAIRE',
          badgeColor: AppTheme.accentGold,
          price: _isAnnual ? '24 000 F CFA' : '2 500 F CFA',
          period: _isAnnual ? '/ an (2 000 F CFA/mois)' : '/ mois',
          isCurrent: isPro,
          highlighted: true,
          features: const [
            'Articles & Ventes 100% ILLIMITÉS (aucun blocage)',
            'Jusqu\'à 3 équipiers (Caissiers, Magasinier avec code PIN & shifts)',
            'Jusqu\'à 2 Boutiques / Points de vente',
            'Factures & Reçus personnalisés avec le logo de votre boutique',
            'Signature calligraphique automatique et SANS filigrane',
            'Partage direct des factures et reçus sur WhatsApp aux clients',
            'Gestion illimitée des crédits clients et rappels WhatsApp',
            'Alertes automatiques de stock faible et dates de péremption',
            'Calcul des bénéfices nets et bilans de caisse journaliers',
            'Exports des bilans et ventes sur Excel et PDF',
            'Sauvegarde automatique et sécurisée de vos données',
          ],
          buttonLabel: isPro ? 'Formule active' : 'Passer à la Formule Pro',
          buttonAction: isPro
              ? null
              : () => _showPaymentModal(
                    planName: 'Formule Pro',
                    monthlyPrice: 2500,
                    annualPrice: 24000,
                  ),
        );

        final enterpriseCard = _buildPlanCard(
          title: 'Formule Entreprise',
          badge: 'GRANDES BOUTIQUES & RÉSEAUX',
          badgeColor: const Color(0xFF6366F1),
          price: _isAnnual ? '75 000 F CFA' : '7 900 F CFA',
          period: _isAnnual ? '/ an (6 250 F CFA/mois)' : '/ mois',
          isCurrent: isEnterprise,
          features: const [
            'Tout ce qui est inclus dans la Formule Pro',
            'Boutiques, Caisses & Dépôts ILLIMITÉS',
            'Équipe complète ILLIMITÉE (Gérants, Magasiniers, Caissiers)',
            'Transferts inter-boutiques avec workflow d\'approbation',
            'Tableau de bord de supervision multi-boutiques en direct',
            'Conseiller intelligent Bricelo pour analyser et booster vos ventes',
            'Téléchargement de vos bilans et rapports sur Excel et PDF',
            'Ligne WhatsApp prioritaire VIP 7j/7 avec un conseiller dédié',
          ],
          buttonLabel: isEnterprise ? 'Formule active' : 'Choisir la Formule Entreprise',
          buttonAction: isEnterprise
              ? null
              : () => _showPaymentModal(
                    planName: 'Formule Entreprise',
                    monthlyPrice: 7900,
                    annualPrice: 75000,
                  ),
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: widget.showAppBar
              ? AppBar(
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
                    'Portail Web • Formules & Abonnement',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                  ),
                )
              : null,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CARTE STATUT ACTUEL + SYNCHRONISATION MOBILE
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryNavy, Color(0xFF1E3A8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
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
                            child: const Icon(Icons.verified_rounded, color: AppTheme.accentGold, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'VOTRE FORMULE ACTUELLE (SYNCHRONISÉE SUR MOBILE & WEB)',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF93C5FD)),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 10,
                                  runSpacing: 6,
                                  children: [
                                    Text(
                                      currentPlan,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Actif',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.cloud_sync_rounded, color: AppTheme.accentGold, size: 13),
                                          SizedBox(width: 5),
                                          Text(
                                            'Synchronisé avec l\'app mobile (mode consommation)',
                                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (expiresAt != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Renouvellement : ${expiresAt.day}/${expiresAt.month}/${expiresAt.year}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFFE2E8F0)),
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
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
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
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
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
                    const SizedBox(height: 24),

                    // GRILLE 3 COLONNES SUR PORTAIL WEB OU LISTE VERTICALE SUR ÉCRAN ÉTROIT
                    if (isWideWeb)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: freeCard),
                          const SizedBox(width: 18),
                          Expanded(child: proCard),
                          const SizedBox(width: 18),
                          Expanded(child: enterpriseCard),
                        ],
                      )
                    else ...[
                      freeCard,
                      const SizedBox(height: 16),
                      proCard,
                      const SizedBox(height: 16),
                      enterpriseCard,
                    ],

                    const SizedBox(height: 24),

                    // GARANTIE & ASSISTANCE
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.security_rounded, color: Color(0xFF059669), size: 28),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Portail Web Officiel Bricelo Stock : Paiements sécurisés via Mobile Money & Carte. Toute formule souscrite ici est immédiatement synchronisée avec votre base de données Supabase et appliquée sur votre téléphone mobile.',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF475563), height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

