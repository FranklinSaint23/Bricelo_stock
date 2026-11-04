import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/widgets/widgets.dart';

class OnlineShopScreen extends StatefulWidget {
  const OnlineShopScreen({super.key});

  @override
  State<OnlineShopScreen> createState() => _OnlineShopScreenState();
}

class _OnlineShopScreenState extends State<OnlineShopScreen> {
  final appState = AppState.instance;

  late String _shopSlug;

  @override
  void initState() {
    super.initState();
    final raw = appState.displayCompanyName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    _shopSlug = raw.isNotEmpty ? raw : 'ma-boutique';
  }
  bool _isShopActive = false;
  bool _acceptOrders = false;
  bool _proposeDelivery = false;
  String _deliveryPolicy = 'Non renseigné';
  String _welcomeMessage = 'Non renseigné';
  String _city = 'Non renseigné';

  void _editSlugDialog() {
    final ctrl = TextEditingController(text: _shopSlug);
    final isDark = appState.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'Adresse de la boutique',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.primaryNavy,
          ),
        ),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            prefixText: 'bricelo.app/s/',
            hintText: 'mon-magasin',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final val = ctrl.text.trim();
              if (val.isNotEmpty) {
                setState(() => _shopSlug = val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _editFieldDialog(String title, String currentValue, ValueChanged<String> onSaved) {
    final ctrl = TextEditingController(text: currentValue == 'Non renseigné' ? '' : currentValue);
    final isDark = appState.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.primaryNavy,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Saisissez votre $title',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final val = ctrl.text.trim();
              onSaved(val.isEmpty ? 'Non renseigné' : val);
              Navigator.pop(ctx);
            },
            child: const Text('Valider'),
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
        final publishedCount = appState.products.length;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: StockAppBar.navy(
            title: 'Boutique en ligne',
            onBack: () => Navigator.pop(context),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // 1. NOTIFICATION : Boutique non publiée (Image 1)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 22,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Votre boutique n\'est pas encore publiée',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Publiez vos produits (photo requise), activez la boutique puis publiez-la.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. CARTE VISIBILITÉ (Image 1)
              _buildSectionCard(
                isDark: isDark,
                title: 'Visibilité',
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      'Adresse de la boutique',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'bricelo.app/s/$_shopSlug',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    trailing: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentGold,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _editSlugDialog,
                      child: const Text('Modifier', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  _buildDivider(isDark),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      'Boutique activée',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Visible publiquement dès la publication, y compris sur Google et dans l\'annuaire Bricelo.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                          height: 1.3,
                        ),
                      ),
                    ),
                    value: _isShopActive,
                    activeTrackColor: AppTheme.primaryNavy,
                    activeThumbColor: AppTheme.accentGold,
                    onChanged: (val) => setState(() => _isShopActive = val),
                  ),
                  _buildDivider(isDark),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      'Accepter les commandes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Sans paiement en ligne',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    value: _acceptOrders,
                    activeTrackColor: AppTheme.primaryNavy,
                    activeThumbColor: AppTheme.accentGold,
                    onChanged: (val) => setState(() => _acceptOrders = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. CARTE LIVRAISON (Image 1)
              _buildSectionCard(
                isDark: isDark,
                title: 'Livraison',
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      'Proposer la livraison',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    value: _proposeDelivery,
                    activeTrackColor: AppTheme.primaryNavy,
                    activeThumbColor: AppTheme.accentGold,
                    onChanged: (val) => setState(() => _proposeDelivery = val),
                  ),
                  _buildDivider(isDark),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      'Politique de livraison',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    subtitle: Text(
                      _deliveryPolicy,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                    onTap: () {
                      _editFieldDialog('Politique de livraison', _deliveryPolicy, (val) {
                        setState(() => _deliveryPolicy = val);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. CARTE PRÉSENTATION (Image 1 & 2)
              _buildSectionCard(
                isDark: isDark,
                title: 'Présentation',
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      'Phrase d\'accueil',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    subtitle: Text(
                      _welcomeMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                    onTap: () {
                      _editFieldDialog('Phrase d\'accueil', _welcomeMessage, (val) {
                        setState(() => _welcomeMessage = val);
                      });
                    },
                  ),
                  _buildDivider(isDark),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      'Ville',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    subtitle: Text(
                      _city,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                    onTap: () {
                      _editFieldDialog('Ville', _city, (val) {
                        setState(() => _city = val);
                      });
                    },
                  ),
                  _buildDivider(isDark),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      'Produits publiés',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    subtitle: Text(
                      '$publishedCount produit(s) sur la boutique',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gestion des $publishedCount produits de la boutique')),
                      );
                    },
                  ),
                  _buildDivider(isDark),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      'Statistiques boutique',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Statistiques de visite et commandes en ligne')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Note sous la carte Présentation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Les prix et le stock affichés sont ceux de ${appState.currentStore}.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. CARTE RÉFÉRENCEMENT GOOGLE & APERÇU (Image 2 & 3)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Score
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Référencement Google',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '0/100',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Google Snippet Box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'bricelo.app/s/$_shopSlug',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppTheme.accentGold : const Color(0xFF047857),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${appState.displayCompanyName} — Boutique en ligne au Cameroun',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${appState.displayCompanyName} : $publishedCount produit(s). Commandez en ligne, livraison ou retrait en boutique.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Checklist items avec icône warning (Image 2 & 3)
                    _buildSeoItem(isDark, 'Ajoutez une phrase d\'accroche'),
                    _buildDivider(isDark),
                    _buildSeoItem(isDark, 'Indiquez la ville de votre boutique'),
                    _buildDivider(isDark),
                    _buildSeoItem(isDark, 'Ajoutez votre logo'),
                    _buildDivider(isDark),
                    _buildSeoItem(isDark, '0 produits sans description détaillée (50 caractères min.)'),
                    _buildDivider(isDark),
                    _buildSeoItem(isDark, '0 produits avec moins de 2 photos'),
                    _buildDivider(isDark),
                    _buildSeoItem(isDark, '0 produits sans catégorie'),
                    _buildDivider(isDark),
                    _buildSeoItem(isDark, '0 produits portent le même nom'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. BOUTON PUBLIER LA BOUTIQUE (Image 3)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  icon: const Icon(Icons.rocket_launch_outlined, color: AppTheme.accentGold, size: 20),
                  label: const Text(
                    'Publier la boutique',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.primaryNavy,
                        content: Row(
                          children: const [
                            Icon(Icons.info_outline, color: AppTheme.accentGold, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Boutique enregistrée. Assurez-vous d\'avoir des produits avec photos avant publication publique.',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Avertissement sous le bouton (Image 3)
              const Center(
                child: Text(
                  'Publiez au moins un produit avant de mettre la boutique en ligne.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFFD97706), fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),

              // Disclaimer légal
              Center(
                child: Text(
                  'Votre boutique publiée est visible sur Google et dans l\'annuaire Bricelo. Conditions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF4B5563),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSeoItem(bool isDark, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: const Icon(Icons.error_outline, color: Color(0xFFEA580C), size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1F2937),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Configuration SEO : $title')),
        );
      },
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
    );
  }
}
