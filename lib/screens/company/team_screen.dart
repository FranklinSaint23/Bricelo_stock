import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
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

  Future<void> _shareCredentialsOnWhatsApp(TeamMember member, String pin) async {
    final store = member.storeName.isNotEmpty ? member.storeName : appState.currentStore;
    final deskInfo = (member.role.toLowerCase() == 'caissier' && member.assignedCashDesk != null && member.assignedCashDesk!.isNotEmpty)
        ? '\n💰 *Caisse attribuée :* ${member.assignedCashDesk}'
        : '';
    final message = '''🏪 *Invitation Bricelo Stock - ${appState.displayCompanyName}*

Bonjour *${member.name}*,
Vous avez été invité(e) à rejoindre l'équipe de *${appState.displayCompanyName}* en tant que *${member.role}*.

🔑 *Vos identifiants de connexion :*
📱 *Identifiant (Tél) :* ${member.phone}
🔒 *Code PIN secret :* $pin
🏬 *Boutique :* $store$deskInfo

👉 Ouvrez l'application *Bricelo Stock*, connectez-vous avec votre numéro et ce code PIN pour commencer votre service.''';

    final cleanPhone = member.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uriPhone = cleanPhone.startsWith('+') ? cleanPhone.substring(1) : cleanPhone;
    final waUrl = Uri.parse('https://wa.me/$uriPhone?text=${Uri.encodeComponent(message)}');
    final directWaUrl = Uri.parse('whatsapp://send?phone=$uriPhone&text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(directWaUrl)) {
        await launchUrl(directWaUrl);
      } else if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        await Share.share(message, subject: 'Identifiants Bricelo Stock');
      }
    } catch (_) {
      await Share.share(message, subject: 'Identifiants Bricelo Stock');
    }
  }

  void _showCredentialsDialog(BuildContext context, TeamMember member, String pin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF25D366), size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              'Membre invité avec succès !',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Transmettez les identifiants générés au collaborateur pour qu\'il puisse se connecter à son compte.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildCredentialRow('Nom :', member.name),
                  const SizedBox(height: 6),
                  _buildCredentialRow('Rôle :', member.role, isBadge: true),
                  const SizedBox(height: 6),
                  _buildCredentialRow('Téléphone (Login) :', member.phone),
                  const SizedBox(height: 6),
                  if (member.role.toLowerCase() == 'caissier' && member.assignedCashDesk != null) ...[
                    _buildCredentialRow('Caisse attribuée :', member.assignedCashDesk!),
                    const SizedBox(height: 6),
                  ],
                  _buildCredentialRow('Boutique :', member.storeName),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Code PIN de connexion :',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.accentGold),
                        ),
                        child: Text(
                          pin,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // BOUTON WHATSAPP PROÉMINENT
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.share, size: 20),
                label: const Text(
                  'Partager sur WhatsApp',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _shareCredentialsOnWhatsApp(member, pin),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF334155),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copier', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: 'Identifiant Bricelo Stock : ${member.phone} | Code PIN : $pin | Rôle : ${member.role}',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Identifiants copiés dans le presse-papier !'),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Fermer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCredentialRow(String label, String value, {bool isBadge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
        const SizedBox(width: 8),
        isBadge
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                ),
              )
            : Flexible(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
      ],
    );
  }

  void _showInviteDialog(BuildContext context) {
    final prenomCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String role = 'Caissier';
    String assignedStore = appState.availableStores.isNotEmpty
        ? appState.availableStores.first
        : (appState.currentStore.isNotEmpty ? appState.currentStore : 'Toutes les boutiques');
    String selectedCashDesk = appState.cashDesks.isNotEmpty ? appState.cashDesks.first.name : 'Caisse Principale';
    final generatedPin = (100000 + Random().nextInt(900000)).toString();
    final pinCtrl = TextEditingController(text: generatedPin);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Inviter un rôle / collaborateur',
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
                    labelText: 'Téléphone (Identifiant WhatsApp) *',
                    hintText: 'Ex: +237 699 00 00 00',
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

                // RÔLE * (Uniquement Caissier, Magasinier, Gérant, Propriétaire)
                DropdownButtonFormField<String>(
                  initialValue: role,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Rôle *',
                    labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Caissier',
                      child: Text('Caissier (POS, encaissement, reçu)', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'Magasinier',
                      child: Text('Magasinier (Stock, réappro à valider)', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'Gérant',
                      child: Text('Gérant (Supervision sous validation)', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'Propriétaire',
                      child: Text('Propriétaire (Tous droits & validations)', overflow: TextOverflow.ellipsis),
                    ),
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

                // Si Caissier -> Sélection obligatoire de la caisse à lui attribuer
                if (role == 'Caissier') ...[
                  DropdownButtonFormField<String>(
                    value: selectedCashDesk,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Caisse attribuée au caissier *',
                      labelStyle: const TextStyle(color: Color(0xFF0284C7), fontSize: 13, fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF0284C7)),
                      ),
                      prefixIcon: const Icon(Icons.point_of_sale_rounded, color: Color(0xFF0284C7)),
                    ),
                    items: appState.cashDesks.isNotEmpty
                        ? appState.cashDesks
                            .map((d) => DropdownMenuItem(
                                  value: d.name,
                                  child: Text(d.name, overflow: TextOverflow.ellipsis),
                                ))
                            .toList()
                        : const [
                            DropdownMenuItem(value: 'Caisse Principale', child: Text('Caisse Principale', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'Caisse 1', child: Text('Caisse 1', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'Caisse 2', child: Text('Caisse 2', overflow: TextOverflow.ellipsis)),
                          ],
                    onChanged: (v) => setDlgState(() => selectedCashDesk = v ?? 'Caisse Principale'),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Le caissier ne pourra ouvrir et fermer que cette caisse attribuée.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                ],

                // Si Magasinier -> Indication approbation requise
                if (role == 'Magasinier') ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.security_rounded, color: Color(0xFF92400E), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Le magasinier peut demander des réapprovisionnements et transferts. Toute action sera soumise à votre validation dans "Approbations".',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Si Propriétaire alors il gère tout
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
                            'Le Propriétaire gère l\'ensemble des boutiques, valide les approbations et effectue les paiements fournisseurs.',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  // BOUTIQUE ASSIGNÉE (pour les autres rôles)
                  DropdownButtonFormField<String>(
                    initialValue: assignedStore,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Boutique assignée',
                      labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'Toutes les boutiques',
                        child: Text('Toutes les boutiques', overflow: TextOverflow.ellipsis),
                      ),
                      ...appState.availableStores.map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (v) => setDlgState(() => assignedStore = v ?? 'Toutes les boutiques'),
                  ),
                  const SizedBox(height: 12),
                ],

                // CODE PIN GÉNÉRÉ
                TextField(
                  controller: pinCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Code PIN secret (Généré) *',
                    hintText: '6 chiffres',
                    helperText: 'Code de connexion qui sera envoyé au collaborateur',
                    labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.password_rounded, color: AppTheme.accentGold),
                  ),
                ),
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
                      onPressed: () async {
                        final prenom = prenomCtrl.text.trim();
                        final nom = nomCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();
                        final pin = pinCtrl.text.trim();
                        if (prenom.isEmpty || nom.isEmpty || phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Veuillez renseigner le prénom, le nom et le téléphone.'), backgroundColor: Color(0xFFDC2626)),
                          );
                          return;
                        }

                        final fullName = '$prenom $nom';
                        final desk = role == 'Caissier' ? selectedCashDesk : null;

                        await appState.addTeamMember(
                          name: fullName,
                          phone: phone,
                          email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                          role: role,
                          storeName: role == 'Propriétaire' ? 'Toutes les boutiques' : assignedStore,
                          pinCode: pin.isNotEmpty ? pin : generatedPin,
                          assignedCashDesk: desk,
                        );

                        Navigator.pop(ctx);
                        setState(() {});

                        final createdMember = appState.teamMembers.last;
                        if (mounted) {
                          _showCredentialsDialog(context, createdMember, pin.isNotEmpty ? pin : generatedPin);
                        }
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
                    initialValue: ['Gérant', 'Caissier', 'Magasinier'].contains(role) ? role : 'Caissier',
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Rôle *',
                      labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Gérant', child: Text('Gérant', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Caissier', child: Text('Caissier', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Magasinier', child: Text('Magasinier', overflow: TextOverflow.ellipsis)),
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
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Boutique assignée',
                      labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'Toutes les boutiques',
                        child: Text('Toutes les boutiques', overflow: TextOverflow.ellipsis),
                      ),
                      ...appState.availableStores.map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, overflow: TextOverflow.ellipsis),
                        ),
                      ),
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
                      _buildDetailRow('Téléphone (Identifiant)', member.phone, isDark: isDark),
                      if (member.pinCode.isNotEmpty) ...[
                        Divider(height: 14, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        _buildDetailRow('Code PIN secret', member.pinCode, isDark: isDark),
                      ],
                      Divider(height: 14, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      _buildDetailRow('Email', member.email?.isNotEmpty == true ? member.email! : 'Non renseigné', isDark: isDark),
                      if (member.role.toLowerCase() == 'caissier' && member.assignedCashDesk != null) ...[
                        Divider(height: 14, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        _buildDetailRow('Caisse attribuée', member.assignedCashDesk!, isDark: isDark),
                      ],
                      if (!isOwner) ...[
                        Divider(height: 14, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        _buildDetailRow('Boutique assignée', member.storeName, isDark: isDark),
                      ],
                      Divider(height: 14, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      _buildDetailRow('Performance ventes', '${memberSales.length} transaction(s) • ${AppTheme.formatFCFA(totalRevenue)}', isDark: isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Partager sur WhatsApp
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.share, size: 18),
                    label: Text('Partager identifiants sur WhatsApp'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _shareCredentialsOnWhatsApp(member, member.pinCode.isNotEmpty ? member.pinCode : '------');
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Boutons d'actions
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: Icon(Icons.edit_outlined, size: 18, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                          label: Text('Modifier'.tr, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy)),
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
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFEE2E2),
                              foregroundColor: const Color(0xFFDC2626),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                            label: Text('Supprimer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildDetailRow(String label, String value, {bool isDark = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.tr, style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value.tr,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _confirmDeleteMember(BuildContext context, TeamMember member) {
    final isDark = AppTheme.isDark(context);
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Supprimer ce membre ?'.tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        content: Text(
          'Voulez-vous vraiment retirer ${member.name} de l\'équipe ? Ses accès, identifiants et permissions seront définitivement révoqués en base de données.'.tr,
          style: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: Text('Annuler'.tr, style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dlgCtx);
              await appState.removeTeamMember(member.id);
              if (mounted) setState(() {});
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${member.name} a été retiré(e) de l\'équipe et ses identifiants supprimés.'.tr)),
                );
              }
            },
            child: Text('Supprimer'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
            elevation: 0,
            centerTitle: true,
            leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text('Plus'.tr, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            leadingWidth: 70,
            title: Text(
              'Equipe'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
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
                      Text(
                        'Aucun membre dans l\'équipe'.tr,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cliquez sur "Inviter" pour ajouter vos gérants, caissiers et magasiniers.'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
                          border: Border.all(color: isDark ? const Color(0xFF1E3052) : const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
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
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF2E2211) : const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          m.role.tr,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFD97706),
                                          ),
                                        ),
                                      ),
                                      if (m.role.toLowerCase() == 'caissier' && m.assignedCashDesk != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF102847) : const Color(0xFFE0F2FE),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '💰 ${m.assignedCashDesk}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppTheme.accentGold : const Color(0xFF0369A1),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Chevron droit interactif
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: AppTheme.accentGold, size: 24),
                              onPressed: () => _showMemberDetailModal(context, m),
                              tooltip: 'Détails du membre'.tr,
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
            label: Text(
              'Inviter'.tr,
              style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w900, fontSize: 14),
            ),
            onPressed: () => _showInviteDialog(context),
          ),
        );
      },
    );
  }
}
