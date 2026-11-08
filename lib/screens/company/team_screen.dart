import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final appState = AppState.instance;

  void _showInviteDialog(BuildContext context) {
    final prenomCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String role = 'Caissier';
    String assignedStore = appState.availableStores.isNotEmpty
        ? appState.availableStores.first
        : (appState.currentStore.isNotEmpty ? appState.currentStore : 'Toutes les boutiques');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Inviter un membre',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF111827)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PRÉNOM *
                TextField(
                  controller: prenomCtrl,
                  decoration: InputDecoration(
                    labelText: 'Prénom *',
                    hintText: 'Ex: Jean',
                    labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                // NOM *
                TextField(
                  controller: nomCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nom *',
                    hintText: 'Ex: Dupont',
                    labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                // TÉLÉPHONE *
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Téléphone *',
                    hintText: 'Ex: 699 00 00 00',
                    labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                // EMAIL (Optionnel)
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email (optionnel)',
                    hintText: 'Ex: equipier@entreprise.com',
                    labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                // RÔLE * (Propriétaire / Gérant / Caissier / Magasinier / Vendeur)
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: InputDecoration(
                    labelText: 'Rôle *',
                    labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Propriétaire', child: Text('Propriétaire')),
                    DropdownMenuItem(value: 'Gérant', child: Text('Gérant')),
                    DropdownMenuItem(value: 'Caissier', child: Text('Caissier')),
                    DropdownMenuItem(value: 'Magasinier', child: Text('Magasinier')),
                    DropdownMenuItem(value: 'Vendeur', child: Text('Vendeur')),
                  ],
                  onChanged: (v) {
                    setDlgState(() {
                      role = v ?? 'Caissier';
                      if (role == 'Propriétaire') {
                        assignedStore = 'Toutes les boutiques';
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Si Propriétaire alors il gère tout : le champ Boutique assignée n'a pas sa place
                if (role == 'Propriétaire') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.all_inclusive_rounded, color: Color(0xFF92400E), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Le Propriétaire gère l\'ensemble des boutiques et stocks.',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // BOUTIQUE ASSIGNÉE (pour les autres rôles)
                  DropdownButtonFormField<String>(
                    initialValue: assignedStore,
                    decoration: InputDecoration(
                      labelText: 'Boutique assignée',
                      labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'Toutes les boutiques', child: Text('Toutes les boutiques')),
                      ...appState.availableStores.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                    ],
                    onChanged: (v) => setDlgState(() => assignedStore = v ?? 'Toutes les boutiques'),
                  ),
                ],
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Annuler', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                        foregroundColor: AppTheme.primaryNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final prenom = prenomCtrl.text.trim();
                        final nom = nomCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();
                        if (prenom.isEmpty || nom.isEmpty || phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Veuillez remplir le prénom, le nom et le téléphone.'), backgroundColor: Color(0xFFDC2626)),
                          );
                          return;
                        }

                        final fullName = '$prenom $nom';
                        appState.addTeamMember(
                          name: fullName,
                          phone: phone,
                          email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                          role: role,
                          storeName: role == 'Propriétaire' ? 'Toutes les boutiques' : assignedStore,
                        );

                        Navigator.pop(ctx);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF059669),
                            content: Text('$fullName ajouté(e) avec succès avec le rôle $role.'),
                          ),
                        );
                      },
                      child: const Text('Inviter', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMemberDialog(BuildContext context, TeamMember member) {
    final isOwner = member.role.toLowerCase().contains('propriétaire') || member.id == 'owner_primary';
    final nameParts = member.name.split(' ');
    final prenomCtrl = TextEditingController(text: nameParts.first);
    final nomCtrl = TextEditingController(text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    final phoneCtrl = TextEditingController(text: member.phone);
    final emailCtrl = TextEditingController(text: member.email ?? '');
    String role = member.role;
    String assignedStore = member.storeName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Modifier le membre',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF111827)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: prenomCtrl,
                  decoration: InputDecoration(
                    labelText: 'Prénom *',
                    labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nomCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nom *',
                    labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Téléphone *',
                    labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                // RÔLE
                if (isOwner) ...[
                  // Rôle verrouillé pour le Propriétaire (Non modifiable)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rôle (Non modifiable)',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Propriétaire',
                              style: TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Icon(Icons.lock_rounded, size: 18, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ] else ...[
                  DropdownButtonFormField<String>(
                    initialValue: ['Gérant', 'Caissier', 'Magasinier', 'Vendeur'].contains(role) ? role : 'Caissier',
                    decoration: InputDecoration(
                      labelText: 'Rôle *',
                      labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Gérant', child: Text('Gérant')),
                      DropdownMenuItem(value: 'Caissier', child: Text('Caissier')),
                      DropdownMenuItem(value: 'Magasinier', child: Text('Magasinier')),
                      DropdownMenuItem(value: 'Vendeur', child: Text('Vendeur')),
                    ],
                    onChanged: (v) {
                      setDlgState(() {
                        role = v ?? 'Caissier';
                        if (role == 'Propriétaire') {
                          assignedStore = 'Toutes les boutiques';
                        }
                      });
                    },
                  ),
                ],
                const SizedBox(height: 12),

                // Si Propriétaire alors il gère tout : le champ Boutique assignée n'a pas sa place
                if (role == 'Propriétaire') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.all_inclusive_rounded, color: Color(0xFF92400E), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Le Propriétaire gère l\'ensemble des boutiques et stocks.',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // BOUTIQUE ASSIGNÉE (pour les autres rôles)
                  DropdownButtonFormField<String>(
                    initialValue: assignedStore.isNotEmpty ? assignedStore : 'Toutes les boutiques',
                    decoration: InputDecoration(
                      labelText: 'Boutique assignée',
                      labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'Toutes les boutiques', child: Text('Toutes les boutiques')),
                      ...appState.availableStores.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                    ],
                    onChanged: (v) => setDlgState(() => assignedStore = v ?? 'Toutes les boutiques'),
                  ),
                ],
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Annuler', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNavy,
                        foregroundColor: AppTheme.accentGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final prenom = prenomCtrl.text.trim();
                        final nom = nomCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();
                        if (prenom.isEmpty || phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Veuillez remplir le prénom et le téléphone.'), backgroundColor: Color(0xFFDC2626)),
                          );
                          return;
                        }

                        final fullName = nom.isNotEmpty ? '$prenom $nom' : prenom;
                        appState.updateTeamMember(
                          id: member.id,
                          name: fullName,
                          phone: phone,
                          email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                          role: isOwner ? 'Propriétaire' : role,
                          storeName: (isOwner || role == 'Propriétaire') ? 'Toutes les boutiques' : assignedStore,
                        );

                        Navigator.pop(ctx);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF059669),
                            content: Text('Membre mis à jour avec succès.'),
                          ),
                        );
                      },
                      child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberDetailModal(BuildContext context, TeamMember member) {
    final isDark = appState.isDarkMode;
    final isOwner = member.role.toLowerCase().contains('proprio') ||
        member.role.toLowerCase().contains('propriétaire') ||
        member.id == 'owner_primary';

    // Calcul des ventes enregistrées par ce membre
    final memberSales = appState.sales.where((s) {
      final cName = s.cashierName.trim().toLowerCase();
      final mName = member.name.trim().toLowerCase();
      return cName == mName || (mName.isNotEmpty && cName.contains(mName.split(' ').first));
    }).toList();
    final totalRevenue = memberSales.fold(0.0, (sum, s) => sum + s.total);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entête membre
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            member.name.isNotEmpty
                                ? member.name.split(' ').take(2).map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase()
                                : 'TM',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accentGold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                member.role,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Carte d'informations
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Téléphone', member.phone),
                      const Divider(height: 14, color: Color(0xFFE2E8F0)),
                      _buildDetailRow('Email', member.email?.isNotEmpty == true ? member.email! : 'Non renseigné'),
                      if (!isOwner) ...[
                        const Divider(height: 14, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Boutique assignée', member.storeName),
                      ],
                      const Divider(height: 14, color: Color(0xFFE2E8F0)),
                      _buildDetailRow('Performance ventes', '${memberSales.length} transaction(s) • ${AppTheme.formatFCFA(totalRevenue)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Boutons d'actions
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryNavy),
                          label: const Text('Modifier', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showEditMemberDialog(context, member);
                          },
                        ),
                      ),
                    ),
                    if (!isOwner) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFEE2E2),
                              foregroundColor: const Color(0xFFDC2626),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                            label: const Text('Supprimer', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _confirmDeleteMember(context, member);
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _confirmDeleteMember(BuildContext context, TeamMember member) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Supprimer ce membre ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text('Voulez-vous vraiment retirer ${member.name} de l\'équipe ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dlgCtx);
              appState.removeTeamMember(member.id);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${member.name} a été retiré(e) de l\'équipe.')),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        final members = appState.effectiveTeamMembers;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryNavy,
            elevation: 0,
            centerTitle: true,
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8),
                  Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Plus', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            leadingWidth: 70,
            title: const Text(
              'Equipe',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.groups_rounded, size: 40, color: AppTheme.accentGold),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Aucun membre dans l\'équipe',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Cliquez sur "Inviter" pour ajouter vos gérants, caissiers et magasiniers.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: members.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final m = members[idx];
                    return InkWell(
                      onTap: () => _showMemberDetailModal(context, m),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m.phone,
                                    style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                                  ),
                                  if (m.email != null && m.email!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      m.email!,
                                      style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      m.role,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Chevron droit interactif
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: AppTheme.accentGold, size: 24),
                              onPressed: () => _showMemberDetailModal(context, m),
                              tooltip: 'Détails du membre',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          // Bouton Inviter Gold
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.accentGold,
            foregroundColor: AppTheme.primaryNavy,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primaryNavy, size: 20),
            label: const Text(
              'Inviter',
              style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w900, fontSize: 14),
            ),
            onPressed: () => _showInviteDialog(context),
          ),
        );
      },
    );
  }
}
