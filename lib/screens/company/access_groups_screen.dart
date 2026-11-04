import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';

class AccessGroupsScreen extends StatefulWidget {
  const AccessGroupsScreen({super.key});

  @override
  State<AccessGroupsScreen> createState() => _AccessGroupsScreenState();
}

class _AccessGroupsScreenState extends State<AccessGroupsScreen> {
  final appState = AppState.instance;

  final List<Map<String, dynamic>> _roles = [
    {
      'role': 'Propriétaire (Gérant)',
      'description': 'Accès complet et illimité à toute l\'application',
      'usersCount': 1,
      'isDefault': true,
      'permissions': {
        'Point de vente (POS)': true,
        'Gestion du stock & Prix': true,
        'Comptabilité & Finances': true,
        'Suppression de données': true,
        'Gestion des collaborateurs': true,
      },
    },
    {
      'role': 'Responsable de magasin',
      'description': 'Gestion des stocks, ventes et validation des transferts',
      'usersCount': 1,
      'isDefault': false,
      'permissions': {
        'Point de vente (POS)': true,
        'Gestion du stock & Prix': true,
        'Comptabilité & Finances': false,
        'Suppression de données': false,
        'Gestion des collaborateurs': true,
      },
    },
    {
      'role': 'Caissier / Vendeur',
      'description': 'Encaissement des ventes, devis et consultation des stocks',
      'usersCount': 2,
      'isDefault': false,
      'permissions': {
        'Point de vente (POS)': true,
        'Gestion du stock & Prix': false,
        'Comptabilité & Finances': false,
        'Suppression de données': false,
        'Gestion des collaborateurs': false,
      },
    },
  ];

  void _showAddRoleDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = appState.isDarkMode;
        final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Nouveau groupe d\'accès'.tr, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Nom du rôle *'.tr,
                  hintText: 'Ex: Chef de rayon, Stagiaire',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Description'.tr,
                  hintText: 'Responsabilités du groupe',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler'.tr, style: const TextStyle(color: Color(0xFF6B7280))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _roles.add({
                      'role': name,
                      'description': descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : 'Groupe personnalisé',
                      'usersCount': 0,
                      'isDefault': false,
                      'permissions': {
                        'Point de vente (POS)': true,
                        'Gestion du stock & Prix': false,
                        'Comptabilité & Finances': false,
                        'Suppression de données': false,
                        'Gestion des collaborateurs': false,
                      },
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Groupe "$name" créé avec succès !'.tr)),
                  );
                }
              },
              child: Text('Créer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.isDarkMode;
    final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    return Scaffold(
      backgroundColor: pageBg,
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
        title: Text(
          'Groupes d\'accès'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Définissez les autorisations et droits d\'accès de chaque groupe pour sécuriser vos opérations de caisse et de gestion.'.tr,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          for (final role in _roles) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: AppTheme.accentGold, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            role['role'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy.withValues(alpha: isDark ? 0.4 : 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${role['usersCount']} utilisateur(s)'.tr,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentGold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    role['description'] as String,
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: cardBorder),
                  const SizedBox(height: 10),

                  // PERMISSIONS LIST
                  ...(role['permissions'] as Map<String, bool>).entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            entry.value ? Icons.check_circle_rounded : Icons.cancel_outlined,
                            size: 16,
                            color: entry.value ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 13,
                                color: entry.value ? textColor : const Color(0xFF94A3B8),
                                fontWeight: entry.value ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (role['role'] != 'Propriétaire (Gérant)')
                            Switch.adaptive(
                              value: entry.value,
                              activeColor: AppTheme.accentGold,
                              activeTrackColor: AppTheme.primaryNavy,
                              onChanged: (val) {
                                setState(() {
                                  (role['permissions'] as Map<String, bool>)[entry.key] = val;
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _showAddRoleDialog,
              icon: const Icon(Icons.add_rounded, color: AppTheme.primaryNavy),
              label: Text(
                'Créer un nouveau groupe d\'accès'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

