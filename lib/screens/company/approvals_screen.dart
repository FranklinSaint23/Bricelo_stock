import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  final appState = AppState.instance;
  int _selectedTab = 0; // 0: En attente, 1: Approuvées, 2: Rejetées

  final List<String> _tabs = ['En attente', 'Approuvées', 'Rejetées'];

  void _showNewRequestDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final requesterCtrl = TextEditingController(text: appState.teamMembers.isNotEmpty ? appState.teamMembers.first.name : 'Caissier');
    final detailsCtrl = TextEditingController();
    String selectedType = 'Approvisionnement';
    final types = ['Approvisionnement', 'Transfert de stock', 'Remise', 'Dépense', 'Dépréciation', 'Crédit', 'Annulation'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDlgState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text('Nouvelle demande d\'approbation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Type de demande',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) {
                        if (val != null) setDlgState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Objet / Titre *',
                        hintText: 'Ex: Remise exceptionnelle 10%',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Montant concerné (FCFA)',
                        hintText: '0',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: requesterCtrl,
                      decoration: InputDecoration(
                        labelText: 'Demandeur',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailsCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Justification / Détails',
                        hintText: 'Expliquez la raison de la demande...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) return;
                    final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                    final req = ApprovalRequest(
                      id: 'appr_${DateTime.now().millisecondsSinceEpoch}',
                      title: title,
                      type: selectedType,
                      requesterName: requesterCtrl.text.trim().isNotEmpty ? requesterCtrl.text.trim() : 'Employé',
                      storeName: appState.currentStore,
                      amount: amt,
                      details: detailsCtrl.text.trim(),
                      date: DateTime.now(),
                      status: 'pending',
                    );
                    await appState.createApprovalRequest(req);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Demande d\'approbation créée'),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  child: const Text('Soumettre', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDecisionDialog(ApprovalRequest req, bool isApprove) {
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isApprove ? const Color(0xFF059669) : const Color(0xFFDC2626),
            ),
            const SizedBox(width: 8),
            Text(
              isApprove ? 'Approuver la demande' : 'Rejeter la demande',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demande: "${req.title}" (${AppTheme.formatFCFA(req.amount)})',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: isApprove ? 'Note / Instruction (optionnel)' : 'Motif du rejet (optionnel)',
                hintText: isApprove ? 'Ex: Validé exceptionnellement' : 'Ex: Remise trop élevée',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? const Color(0xFF059669) : const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final note = noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null;
              if (isApprove) {
                await appState.approveApprovalRequest(req.id, note: note);
              } else {
                await appState.rejectApprovalRequest(req.id, note: note);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isApprove ? 'Demande approuvée' : 'Demande rejetée'),
                    backgroundColor: isApprove ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                );
              }
            },
            child: Text(isApprove ? 'Approuver' : 'Rejeter', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _badgeColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'approvisionnement':
        return const Color(0xFF0D9488);
      case 'transfert de stock':
        return const Color(0xFF0284C7);
      case 'remise':
        return const Color(0xFFD97706);
      case 'dépense':
        return const Color(0xFFDC2626);
      case 'dépréciation':
        return const Color(0xFF7C3AED);
      case 'crédit':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF4B5563);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final allReqs = appState.approvalRequests;
        final pendingReqs = allReqs.where((r) => r.status == 'pending').toList();
        final approvedReqs = allReqs.where((r) => r.status == 'approved').toList();
        final rejectedReqs = allReqs.where((r) => r.status == 'rejected').toList();

        List<ApprovalRequest> currentList;
        if (_selectedTab == 0) {
          currentList = pendingReqs;
        } else if (_selectedTab == 1) {
          currentList = approvedReqs;
        } else {
          currentList = rejectedReqs;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
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
              'Approbations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                tooltip: 'Créer une demande',
                onPressed: _showNewRequestDialog,
              ),
            ],
          ),
          body: Column(
            children: [
              // BARRE D'ONGLETS SEGMENTEE (Screenshot 5 corrigé)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: Row(
                    children: List.generate(_tabs.length, (idx) {
                      final isSelected = _selectedTab == idx;
                      int count = 0;
                      if (idx == 0) count = pendingReqs.length;
                      if (idx == 1) count = approvedReqs.length;
                      if (idx == 2) count = rejectedReqs.length;

                      return Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedTab = idx),
                          borderRadius: BorderRadius.horizontal(
                            left: idx == 0 ? const Radius.circular(22) : Radius.zero,
                            right: idx == _tabs.length - 1 ? const Radius.circular(22) : Radius.zero,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFEF3C7) : Colors.transparent,
                              borderRadius: BorderRadius.horizontal(
                                left: idx == 0 ? const Radius.circular(22) : Radius.zero,
                                right: idx == _tabs.length - 1 ? const Radius.circular(22) : Radius.zero,
                              ),
                              border: Border(
                                right: idx < _tabs.length - 1 ? const BorderSide(color: Color(0xFFE5E7EB)) : BorderSide.none,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _tabs[idx],
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                  if (count > 0) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppTheme.primaryNavy : const Color(0xFFE5E7EB),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$count',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : const Color(0xFF4B5563),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // LISTE DES DEMANDES OU ETAT VIDE
              Expanded(
                child: currentList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.move_to_inbox_outlined,
                              size: 56,
                              color: Color(0xFFD1D5DB),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedTab == 0
                                  ? 'Aucune demande en attente.'
                                  : _selectedTab == 1
                                      ? 'Aucune demande approuvée.'
                                      : 'Aucune demande rejetée.',
                              style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _showNewRequestDialog,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Créer une demande'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryNavy,
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: currentList.length,
                        itemBuilder: (ctx, idx) {
                          final req = currentList[idx];
                          final badgeCol = _badgeColorForType(req.type);
                          final dateStr = '${req.date.day.toString().padLeft(2, "0")}/${req.date.month.toString().padLeft(2, "0")}/${req.date.year} à ${req.date.hour.toString().padLeft(2, "0")}:${req.date.minute.toString().padLeft(2, "0")}';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: badgeCol.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        req.type,
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeCol),
                                      ),
                                    ),
                                    Text(
                                      dateStr,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  req.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111827)),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 14, color: Color(0xFF6B7280)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${req.requesterName} · ${req.storeName}',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                    ),
                                    const Spacer(),
                                    if (req.amount > 0)
                                      Text(
                                        AppTheme.formatFCFA(req.amount),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
                                      ),
                                  ],
                                ),
                                if (req.details.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFF3F4F6)),
                                    ),
                                    child: Text(
                                      req.details,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.35),
                                    ),
                                  ),
                                ],
                                if (req.decisionNote != null && req.decisionNote!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.comment_outlined, size: 14, color: Color(0xFF6B7280)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Note: ${req.decisionNote}',
                                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF4B5563)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (req.status == 'pending') ...[
                                  const SizedBox(height: 14),
                                  if (appState.hasPermission('Validation des approbations')) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFFDC2626),
                                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                            ),
                                            onPressed: () => _showDecisionDialog(req, false),
                                            child: const Text('Rejeter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF059669),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                            ),
                                            onPressed: () => _showDecisionDialog(req, true),
                                            child: Text(
                                              req.type == 'Approvisionnement' ? 'Valider & Payer' : 'Approuver',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.hourglass_top_rounded, color: Color(0xFF92400E), size: 16),
                                          SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'En attente de validation par le propriétaire',
                                              style: TextStyle(color: Color(0xFF92400E), fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.primaryNavy,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Demande'),
            onPressed: _showNewRequestDialog,
          ),
        );
      },
    );
  }
}
