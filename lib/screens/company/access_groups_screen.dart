import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/services/translations.dart';

class AccessGroupsScreen extends StatefulWidget {
  const AccessGroupsScreen({super.key});

  @override
  State<AccessGroupsScreen> createState() => _AccessGroupsScreenState();
}

class _AccessGroupsScreenState extends State<AccessGroupsScreen> {
  final appState = AppState.instance;

  int _countUsersForRole(String roleName) {
    final r = roleName.toLowerCase().trim();
    if (r.contains('propriétaire') || r.contains('owner') || r.contains('gérant')) {
      final matches = appState.teamMembers.where((m) {
        final mr = m.role.toLowerCase();
        return mr.contains('propriétaire') || mr.contains('owner') || mr.contains('gérant') || mr.contains('admin');
      }).length;
      return matches > 0 ? matches : 1; // Le propriétaire connecté au minimum
    }
    return appState.teamMembers.where((m) => m.role.toLowerCase().trim() == r).length;
  }

  bool _isOwnerRole(String roleName) {
    final r = roleName.toLowerCase();
    return r.contains('propriétaire') || r.contains('owner') || r.contains('gérant');
  }

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
                  labelText: 'Nom du groupe / rôle *'.tr,
                  hintText: 'Ex: Chef de rayon, Magasinier',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Description'.tr,
                  hintText: 'Responsabilités et attributions du groupe',
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
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  final newRole = {
                    'role': name,
                    'description': descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : 'Groupe d\'accès personnalisé',
                    'isDefault': false,
                    'permissions': {
                      'Point de vente (POS)': true,
                      'Gestion du stock & Prix': false,
                      'Comptabilité & Finances': false,
                      'Suppression de données': false,
                      'Gestion des collaborateurs': false,
                    },
                  };
                  final updated = List<Map<String, dynamic>>.from(appState.accessGroups)..add(newRole);
                  await appState.saveAccessGroups(updated);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Groupe "$name" créé avec succès !'.tr),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  }
                }
              },
              child: Text('Créer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _deleteRole(int index, String roleName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Supprimer le groupe "$roleName" ?'),
        content: const Text('Les utilisateurs associés perdront les droits de ce groupe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () async {
              Navigator.pop(ctx);
              final updated = List<Map<String, dynamic>>.from(appState.accessGroups)..removeAt(index);
              await appState.saveAccessGroups(updated);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Groupe "$roleName" supprimé')),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
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
        final pageBg = isDark ? const Color(0xFF09121E) : const Color(0xFFF9FAFB);
        final cardBg = isDark ? const Color(0xFF132238) : Colors.white;
        final cardBorder = isDark ? const Color(0xFF1E3352) : const Color(0xFFE5E7EB);
        final textColor = isDark ? Colors.white : const Color(0xFF111827);

        final roles = appState.accessGroups;

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

              for (int i = 0; i < roles.length; i++) ...[
                Builder(builder: (_) {
                  final role = roles[i];
                  final roleName = (role['role'] ?? '').toString();
                  final isOwner = _isOwnerRole(roleName);
                  final isDefault = role['isDefault'] as bool? ?? false;
                  final permissions = Map<String, dynamic>.from(role['permissions'] as Map? ?? {});
                  final usersCount = _countUsersForRole(roleName);

                  return Container(
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
                                Icon(
                                  isOwner ? Icons.workspace_premium : Icons.shield_outlined,
                                  color: AppTheme.accentGold,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  roleName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryNavy.withValues(alpha: isDark ? 0.4 : 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$usersCount ${usersCount > 1 ? "utilisateurs" : "utilisateur"}'.tr,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentGold),
                                  ),
                                ),
                                if (!isDefault && !isOwner) ...[
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                                    onPressed: () => _deleteRole(i, roleName),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (role['description'] ?? '').toString(),
                          style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                        ),
                        if (isOwner) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_outline, size: 12, color: Color(0xFF92400E)),
                                SizedBox(width: 4),
                                Text(
                                  'Droits d\'accès totaux et inaltérables',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Divider(height: 1, color: cardBorder),
                        const SizedBox(height: 10),

                        // PERMISSIONS LIST
                        ...permissions.entries.map((entry) {
                          final isGranted = isOwner ? true : (entry.value as bool? ?? false);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  isGranted ? Icons.check_circle_rounded : Icons.cancel_outlined,
                                  size: 16,
                                  color: isGranted ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isGranted ? textColor : const Color(0xFF94A3B8),
                                      fontWeight: isGranted ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (!isOwner)
                                  Switch.adaptive(
                                    value: isGranted,
                                    activeColor: AppTheme.accentGold,
                                    activeTrackColor: AppTheme.primaryNavy,
                                    onChanged: (val) async {
                                      final updated = List<Map<String, dynamic>>.from(appState.accessGroups);
                                      final pMap = Map<String, dynamic>.from(updated[i]['permissions'] as Map? ?? {});
                                      pMap[entry.key] = val;
                                      updated[i]['permissions'] = pMap;
                                      await appState.saveAccessGroups(updated);
                                    },
                                  )
                                else
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(Icons.lock_outline, size: 16, color: Color(0xFF94A3B8)),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
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
      },
    );
  }
}
