import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/auth/login_screen.dart';

class SuperAdminPortalShell extends StatefulWidget {
  const SuperAdminPortalShell({super.key});

  @override
  State<SuperAdminPortalShell> createState() => _SuperAdminPortalShellState();
}

class _SuperAdminPortalShellState extends State<SuperAdminPortalShell> {
  final appState = AppState.instance;
  int _selectedNavIndex = 0; // 0: Monitoring, 1: Abonnements, 2: Boutiques & Comptes

  bool _isLoading = true;
  int _latencyMs = -1;
  bool _isTestingLatency = false;
  String _searchQuery = '';
  String _selectedPlanFilter = 'TOUS'; // 'TOUS', 'Découverte', 'Pro', 'Entreprise'

  List<Map<String, dynamic>> _profiles = [];
  Map<String, int> _systemCounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      appState.fetchSuperAdminAllProfiles(),
      appState.checkSupabaseLatencyMs(),
      appState.fetchSupabaseSystemCounts(),
    ]);

    if (mounted) {
      setState(() {
        _profiles = results[0] as List<Map<String, dynamic>>;
        _latencyMs = results[1] as int;
        _systemCounts = results[2] as Map<String, int>;
        _isLoading = false;
      });
    }
  }

  Future<void> _testLatency() async {
    setState(() => _isTestingLatency = true);
    final ms = await appState.checkSupabaseLatencyMs();
    if (mounted) {
      setState(() {
        _latencyMs = ms;
        _isTestingLatency = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ms >= 0
                ? 'Latence Supabase : ${ms}ms (Connexion ${ms < 120 ? "Optimale" : "Moyenne"})'
                : 'Erreur de ping vers Supabase (Hors-ligne ou serveur indisponible)',
          ),
          backgroundColor: ms >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion Super Admin'),
        content: const Text('Voulez-vous fermer la console d\'administration ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await appState.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  List<Map<String, dynamic>> get _filteredProfiles {
    return _profiles.where((p) {
      final compName = (p['company_name'] ?? '').toString().toLowerCase();
      final fullName = (p['full_name'] ?? '').toString().toLowerCase();
      final phone = (p['phone'] ?? '').toString().toLowerCase();
      final email = (p['email'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase().trim();

      if (q.isNotEmpty) {
        final matches = compName.contains(q) || fullName.contains(q) || phone.contains(q) || email.contains(q);
        if (!matches) return false;
      }

      final plan = (p['subscription_plan'] ?? 'Gratuit').toString();
      final isDecouverte = plan == 'Gratuit' || plan.toLowerCase().contains('découverte') || plan.toLowerCase().contains('decouverte');
      final isPro = plan.toLowerCase().contains('pro');
      final isEnt = plan.toLowerCase().contains('entreprise') || plan.toLowerCase().contains('enterprise');

      if (_selectedPlanFilter == 'Découverte' && !isDecouverte) return false;
      if (_selectedPlanFilter == 'Pro' && !isPro) return false;
      if (_selectedPlanFilter == 'Entreprise' && !isEnt) return false;

      return true;
    }).toList();
  }

  int get _countDecouverte => _profiles.where((p) {
        final plan = (p['subscription_plan'] ?? 'Gratuit').toString().toLowerCase();
        return plan == 'gratuit' || plan.contains('découverte') || plan.contains('decouverte');
      }).length;

  int get _countPro => _profiles.where((p) {
        final plan = (p['subscription_plan'] ?? '').toString().toLowerCase();
        return plan.contains('pro');
      }).length;

  int get _countEntreprise => _profiles.where((p) {
        final plan = (p['subscription_plan'] ?? '').toString().toLowerCase();
        return plan.contains('entreprise') || plan.contains('enterprise');
      }).length;

  int get _calculatedMrr => (_countPro * 2500) + (_countEntreprise * 7900);

  // Dialogue d'activation manuelle d'abonnement
  void _showManualActivationDialog(Map<String, dynamic> profile) {
    final profileId = (profile['id'] ?? '').toString();
    final companyName = (profile['company_name'] ?? 'Boutique').toString();
    final ownerName = (profile['full_name'] ?? '').toString();
    final phone = (profile['phone'] ?? '').toString();

    String selectedPlan = 'Pro';
    String selectedBilling = 'mensuel';
    int durationMonths = 1;
    String selectedPaymentMethod = 'Orange Money';
    final notesCtrl = TextEditingController(text: 'Règlement validé par Super Admin');
    bool isSubmitting = false;

    final isDark = appState.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: AppTheme.accentGold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Activer un abonnement', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    Text(
                      '$companyName ($ownerName)',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Formule à activer *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setDlgState(() => selectedPlan = 'Pro'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: selectedPlan == 'Pro'
                                  ? (isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFEF3C7))
                                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedPlan == 'Pro' ? AppTheme.accentGold : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Text('Formule Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                SizedBox(height: 2),
                                Text('2 500 F CFA / mois', style: TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => setDlgState(() => selectedPlan = 'Entreprise'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: selectedPlan == 'Entreprise'
                                  ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFD1FAE5))
                                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedPlan == 'Entreprise' ? const Color(0xFF10B981) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Text('Entreprise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                SizedBox(height: 2),
                                Text('7 900 F CFA / mois', style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  const Text('Durée de l\'abonnement *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    initialValue: durationMonths,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 Mois (Facturation mensuelle)')),
                      DropdownMenuItem(value: 3, child: Text('3 Mois (Trimestriel)')),
                      DropdownMenuItem(value: 6, child: Text('6 Mois (Semestriel)')),
                      DropdownMenuItem(value: 12, child: Text('1 An (12 Mois • Facturation annuelle)')),
                      DropdownMenuItem(value: 24, child: Text('2 Ans (24 Mois • Offre spéciale)')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setDlgState(() {
                          durationMonths = v;
                          selectedBilling = v >= 12 ? 'annuel' : 'mensuel';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  const Text('Mode de règlement reçu *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPaymentMethod,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Orange Money', child: Text('Orange Money CM')),
                      DropdownMenuItem(value: 'MTN Mobile Money', child: Text('MTN Mobile Money (MoMo)')),
                      DropdownMenuItem(value: 'Wave', child: Text('Wave')),
                      DropdownMenuItem(value: 'Espèces (Cash)', child: Text('Espèces en main propre (Cash)')),
                      DropdownMenuItem(value: 'Virement Bancaire', child: Text('Virement Bancaire direct')),
                      DropdownMenuItem(value: 'Offert / Partenariat', child: Text('Abonnement Offert (Partenariat)')),
                    ],
                    onChanged: (v) => setDlgState(() => selectedPaymentMethod = v ?? 'Orange Money'),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(
                      labelText: 'Notes / Référence du reçu',
                      hintText: 'Ex: Reçu MoMo ID #TX924823 validé le ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Builder(builder: (_) {
                    final monthlyPrice = selectedPlan == 'Pro' ? 2500 : 7900;
                    final totalPrice = durationMonths >= 12
                        ? (selectedPlan == 'Pro' ? 24000 * (durationMonths ~/ 12) : 75000 * (durationMonths ~/ 12))
                        : (monthlyPrice * durationMonths);
                    final expDate = DateTime.now().add(Duration(days: durationMonths * 30));
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TOTAL À ENCAISSER', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                              Text(
                                '${NumberFormat('#,###', 'fr_FR').format(totalPrice)} F CFA',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.accentGold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('EXPIRATION PRÉVUE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                              Text(
                                DateFormat('dd/MM/yyyy').format(expDate),
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: AppTheme.primaryNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              icon: isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryNavy))
                  : const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(isSubmitting ? 'Activation...' : 'Activer immédiatement', style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDlgState(() => isSubmitting = true);
                      final success = await appState.superAdminUpdateSubscription(
                        profileId: profileId,
                        plan: selectedPlan,
                        billing: selectedBilling,
                        durationMonths: durationMonths,
                        phone: phone,
                        companyName: companyName,
                        notes: '${notesCtrl.text.trim()} • Moyen: $selectedPaymentMethod • Tél: $phone',
                        status: 'Actif',
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      await _loadData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: success ? const Color(0xFF059669) : const Color(0xFFD97706),
                            content: Text(success
                                ? 'Abonnement $selectedPlan activé avec succès dans le Cloud pour $companyName !'
                                : 'Abonnement $selectedPlan mis à jour en local pour $companyName (vérifiez la connexion Supabase).'),
                          ),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelSubscriptionDialog(Map<String, dynamic> profile) {
    final profileId = (profile['id'] ?? '').toString();
    final companyName = (profile['company_name'] ?? 'Boutique').toString();
    final phone = (profile['phone'] ?? '').toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Résilier l\'abonnement'),
        content: Text(
          'Voulez-vous vraiment rétrograder "$companyName" à la formule Découverte (Gratuit) ? Les quotas stricts (25 produits max, 50 ventes/mois max) seront réappliqués.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await appState.superAdminCancelSubscription(
                profileId: profileId,
                phone: phone,
                companyName: companyName,
              );
              await _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFFDC2626),
                    content: Text('Abonnement de $companyName rétrogradé en Découverte (Gratuit).'),
                  ),
                );
              }
            },
            child: const Text('Résilier', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final isDark = appState.isDarkMode;
    final bg = isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC);
    final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      body: Row(
        children: [
          // 1. SIDEBAR DÉDIÉE SUPER ADMINISTRATEUR (ISOLÉE DU SYSTÈME MAGASIN)
          if (isDesktop)
            Container(
              width: 270,
              decoration: const BoxDecoration(
                color: Color(0xFF080F1D),
                border: Border(right: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Column(
                children: [
                  // En-tête Bricelo Cloud Administration
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primaryNavy, size: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BRICELO STOCK',
                                style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w900, fontSize: 14.5, letterSpacing: 1.1),
                              ),
                              SizedBox(height: 2),
                              Text('Super Admin Console', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge Statut Super Admin
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131F33),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1E3A5F)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: AppTheme.accentGold, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            appState.displayUserName.isNotEmpty ? appState.displayUserName : 'Super Admin',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('ROOT', style: TextStyle(color: Color(0xFF34D399), fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF1E293B), height: 20),

                  // Navigation Tabs
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      children: [
                        _buildNavTile(0, Icons.speed_rounded, 'Monitoring & Performances', 'Latence Supabase & Santé'),
                        _buildNavTile(1, Icons.workspace_premium_rounded, 'Gestion des Abonnements', 'Formules, MRR & Validations'),
                        _buildNavTile(2, Icons.storefront_rounded, 'Comptes & Boutiques', 'Répertoire des Entreprises'),
                      ],
                    ),
                  ),

                  // Latence & Synchro en bas de sidebar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111D30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _latencyMs >= 0 ? (_latencyMs < 150 ? const Color(0xFF10B981) : const Color(0xFFF59E0B)) : const Color(0xFFEF4444),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _latencyMs >= 0 ? '$_latencyMs ms' : 'Ping...',
                                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _isTestingLatency ? null : _testLatency,
                              child: const Icon(Icons.refresh_rounded, color: AppTheme.accentGold, size: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.cloud_done_rounded, color: Color(0xFF34D399), size: 13),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${appState.pendingSyncQueue.length} op. en attente',
                                style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bouton Déconnexion
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                    child: SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          foregroundColor: const Color(0xFFDC2626),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text('Déconnexion Super Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                        onPressed: _logout,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 2. CONTENU PRINCIPAL DE LA CONSOLE SUPER ADMIN
          Expanded(
            child: Scaffold(
              backgroundColor: bg,
              appBar: AppBar(
                backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF091320),
                elevation: 0,
                title: Text(
                  _selectedNavIndex == 0
                      ? 'Monitoring Cloud & Performances'
                      : (_selectedNavIndex == 1 ? 'Gestion des Abonnements SaaS' : 'Comptes & Boutiques Inscrits'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.sync_rounded, color: AppTheme.accentGold),
                    tooltip: 'Actualiser les données',
                    onPressed: _loadData,
                  ),
                  if (!isDesktop)
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
                      tooltip: 'Déconnexion',
                      onPressed: _logout,
                    ),
                ],
              ),
              bottomNavigationBar: !isDesktop
                  ? BottomNavigationBar(
                      currentIndex: _selectedNavIndex,
                      selectedItemColor: AppTheme.accentGold,
                      unselectedItemColor: const Color(0xFF64748B),
                      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
                      onTap: (idx) => setState(() => _selectedNavIndex = idx),
                      items: const [
                        BottomNavigationBarItem(icon: Icon(Icons.speed_rounded), label: 'Monitoring'),
                        BottomNavigationBarItem(icon: Icon(Icons.workspace_premium_rounded), label: 'Abonnements'),
                        BottomNavigationBarItem(icon: Icon(Icons.storefront_rounded), label: 'Comptes'),
                      ],
                    )
                  : null,
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
                  : Column(
                      children: [
                        // KPIS Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                SizedBox(width: 170, child: _buildKpiCard('Entreprises', '${_profiles.length}', Icons.business_rounded, const Color(0xFF3B82F6), cardBg, cardBorder, isDark)),
                                const SizedBox(width: 8),
                                SizedBox(width: 170, child: _buildKpiCard('Découverte (25 prod)', '$_countDecouverte', Icons.lock_open_rounded, const Color(0xFF64748B), cardBg, cardBorder, isDark, subtitle: '25 prod / 50 ventes')),
                                const SizedBox(width: 8),
                                SizedBox(width: 170, child: _buildKpiCard('Formule Pro', '$_countPro', Icons.star_rounded, AppTheme.accentGold, cardBg, cardBorder, isDark, subtitle: '2 500 F CFA / mois')),
                                const SizedBox(width: 8),
                                SizedBox(width: 170, child: _buildKpiCard('Entreprise', '$_countEntreprise', Icons.verified_rounded, const Color(0xFF10B981), cardBg, cardBorder, isDark, subtitle: '7 900 F CFA / mois')),
                                const SizedBox(width: 8),
                                SizedBox(width: 190, child: _buildKpiCard('MRR Estimé', '${NumberFormat('#,###', 'fr_FR').format(_calculatedMrr)} F', Icons.payments_rounded, const Color(0xFF8B5CF6), cardBg, cardBorder, isDark, subtitle: 'Revenu mensuel récurrent')),
                              ],
                            ),
                          ),
                        ),

                        // Vue active
                        Expanded(
                          child: _selectedNavIndex == 0
                              ? _buildMonitoringView(cardBg, cardBorder, isDark)
                              : (_selectedNavIndex == 1
                                  ? _buildSubscriptionsView(cardBg, cardBorder, isDark)
                                  : _buildAccountsView(cardBg, cardBorder, isDark)),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(int index, IconData icon, String title, String subtitle) {
    final isSel = _selectedNavIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedNavIndex = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.accentGold.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSel ? Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSel ? AppTheme.accentGold : Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSel ? AppTheme.accentGold : Colors.white,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String val, IconData icon, Color color, Color cardBg, Color cardBorder, bool isDark, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          ],
        ],
      ),
    );
  }

  // Vue 0: Monitoring & Performance Cloud
  Widget _buildMonitoringView(Color cardBg, Color cardBorder, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SANTÉ ET LATENCE RÉSEAU (SUPABASE POSTGRESQL)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF131F33),
                        foregroundColor: AppTheme.accentGold,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      icon: const Icon(Icons.speed_rounded, size: 16),
                      label: Text(_isTestingLatency ? 'Mesure...' : 'Tester le ping Supabase'),
                      onPressed: _isTestingLatency ? null : _testLatency,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      _latencyMs >= 0 ? '$_latencyMs ms' : 'Injoignable',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: _latencyMs >= 0 ? (_latencyMs < 150 ? const Color(0xFF10B981) : const Color(0xFFF59E0B)) : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _latencyMs >= 0 && _latencyMs < 150
                            ? 'Excellente vitesse de connexion. Toutes les transactions POS et synchronisations de stocks s\'exécutent de façon quasi-instantanée.'
                            : 'Connexion opérationnelle.',
                        style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('VOLUMÉTRIE DE LA BASE DE DONNÉES CLOUD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildDbRow('Entreprises & Profils', '${_systemCounts['profiles'] ?? _profiles.length}', Icons.account_circle_outlined)),
                    Expanded(child: _buildDbRow('Articles & Produits', '${_systemCounts['products'] ?? appState.products.length}', Icons.inventory_2_outlined)),
                    Expanded(child: _buildDbRow('Ventes Enregistrées', '${_systemCounts['sales'] ?? appState.sales.length}', Icons.point_of_sale_outlined)),
                    Expanded(child: _buildDbRow('Équipiers & Rôles', '${_systemCounts['team'] ?? appState.teamMembers.length}', Icons.group_outlined)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cardBorder),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cloud_done_rounded, color: Color(0xFF10B981)),
              title: const Text('File d\'attente synchronisation hors-ligne (Outbox)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              subtitle: Text('${appState.pendingSyncQueue.length} opérations en attente de synchronisation cloud'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white),
                onPressed: () async {
                  await appState.flushPendingSyncQueue();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File d\'attente vidée et synchronisée avec Supabase !')),
                    );
                  }
                },
                child: const Text('Forcer la synchro'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDbRow(String table, String count, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.accentGold),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            Text(table, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
      ],
    );
  }

  // Vue 1: Gestion des Abonnements
  Widget _buildSubscriptionsView(Color cardBg, Color cardBorder, bool isDark) {
    final filtered = _filteredProfiles;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher une entreprise, gérant, téléphone WhatsApp, email...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 10),
              Wrap(
                spacing: 6,
                children: ['TOUS', 'Découverte', 'Pro', 'Entreprise'].map((plan) {
                  final isSel = _selectedPlanFilter == plan;
                  return ChoiceChip(
                    label: Text(plan, style: TextStyle(fontSize: 11.5, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                    selected: isSel,
                    selectedColor: AppTheme.accentGold.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedPlanFilter = plan),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('Aucun compte trouvé correspondant aux critères.', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B))),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, idx) {
                      final p = filtered[idx];
                      final compName = (p['company_name'] ?? 'Boutique').toString();
                      final ownerName = (p['full_name'] ?? 'Propriétaire').toString();
                      final phone = (p['phone'] ?? '').toString();
                      final email = (p['email'] ?? '').toString();
                      final plan = (p['subscription_plan'] ?? 'Gratuit').toString();
                      final billing = (p['subscription_billing'] ?? 'mensuel').toString();
                      final status = (p['subscription_status'] ?? 'Actif').toString();
                      final rawExpires = p['subscription_expires_at']?.toString();
                      DateTime? expiresAt;
                      if (rawExpires != null && rawExpires.isNotEmpty) {
                        try {
                          expiresAt = DateTime.parse(rawExpires);
                        } catch (_) {}
                      }

                      final isPro = plan.toLowerCase().contains('pro');
                      final isEnt = plan.toLowerCase().contains('entreprise') || plan.toLowerCase().contains('enterprise');
                      final isDecouverte = !isPro && !isEnt;

                      final planColor = isEnt ? const Color(0xFF10B981) : (isPro ? AppTheme.accentGold : const Color(0xFF64748B));
                      final planLabel = isEnt ? 'Formule Entreprise' : (isPro ? 'Formule Pro' : 'Découverte (Gratuit)');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(color: planColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                              child: Icon(
                                isEnt ? Icons.workspace_premium_rounded : (isPro ? Icons.star_rounded : Icons.storefront_rounded),
                                color: planColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        compName,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: planColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: planColor.withValues(alpha: 0.5)),
                                        ),
                                        child: Text(planLabel, style: TextStyle(color: planColor, fontSize: 10.5, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('$ownerName · Tél: $phone ${email.isNotEmpty ? "· $email" : ""}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                                  if (isDecouverte) ...[
                                    const SizedBox(height: 3),
                                    const Text('Quotas Découverte : 25 produits max · 50 ventes / mois max · 0 équipier', style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
                                  ],
                                ],
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: status == 'Actif' ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                                      const SizedBox(width: 6),
                                      Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: status == 'Actif' ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                                      const SizedBox(width: 6),
                                      Text('($billing)', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  if (expiresAt != null && !isDecouverte)
                                    Text('Expire le : ${DateFormat('dd/MM/yyyy').format(expiresAt)}', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)))
                                  else if (isDecouverte)
                                    const Text('Sans expiration (Gratuit)', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentGold,
                                    foregroundColor: AppTheme.primaryNavy,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.edit_calendar_rounded, size: 15),
                                  label: Text(isDecouverte ? 'Activer Pro/Entreprise' : 'Modifier', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                  onPressed: () => _showManualActivationDialog(p),
                                ),
                                if (!isDecouverte) ...[
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFDC2626)),
                                      foregroundColor: const Color(0xFFDC2626),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _showCancelSubscriptionDialog(p),
                                    child: const Text('Résilier', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Vue 2: Comptes & Boutiques
  Widget _buildAccountsView(Color cardBg, Color cardBorder, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: _profiles.length,
        itemBuilder: (ctx, idx) {
          final p = _profiles[idx];
          final compName = (p['company_name'] ?? 'Boutique').toString();
          final ownerName = (p['full_name'] ?? 'Propriétaire').toString();
          final phone = (p['phone'] ?? '').toString();
          final email = (p['email'] ?? '').toString();
          final role = (p['role'] ?? 'Propriétaire').toString();
          final stores = (p['available_stores'] is List) ? (p['available_stores'] as List).map((e) => e.toString()).toList() : [compName];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, color: AppTheme.accentGold, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(compName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('$ownerName · Rôle: $role · Tél: $phone ${email.isNotEmpty ? "· $email" : ""}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: stores.map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF1E3A5F).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                          child: Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accentGold)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
