import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/screens/screens.dart';
import 'package:stock_prime/services/app_state.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final appState = AppState.instance;

  bool _isEmailVerified(AppState state) {
    try {
      return state.isEmailVerified;
    } catch (_) {
      try {
        return (state as dynamic).isEmailVerified == true;
      } catch (_) {
        return false;
      }
    }
  }

  String _getSubscriptionPlan(AppState state) {
    try {
      final raw = state.subscriptionPlan.trim();
      return raw.isNotEmpty ? raw : 'Gratuit';
    } catch (_) {
      try {
        return (state as dynamic).subscriptionPlan?.toString() ?? 'Gratuit';
      } catch (_) {
        return 'Gratuit';
      }
    }
  }

  Future<void> _safeUpdateCompanyLogo(String base64String) async {
    try {
      await appState.updateCompanyLogo(base64String);
      return;
    } catch (_) {}

    try {
      await appState.updateCompanyProfile(logoBase64: base64String);
      return;
    } catch (_) {}

    try {
      appState.companyLogo = base64String;
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      appState.notifyListeners();
      await appState.saveSettings();
    } catch (_) {}
  }

  Future<void> _pickShopLogo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = base64Encode(bytes);
        await _safeUpdateCompanyLogo(base64String);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF059669),
              content: Text('Logo de la boutique mis à jour avec succès !'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: const Color(0xFFDC2626), content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: appState.displayUserName);
    final companyCtrl = TextEditingController(text: appState.displayCompanyName);
    final phoneCtrl = TextEditingController(text: appState.userPhone);
    final emailCtrl = TextEditingController(text: appState.userEmail);
    final addressCtrl = TextEditingController(text: appState.companyAddress);

    final isDark = appState.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Modifier mon profil',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : AppTheme.primaryNavy,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? Colors.white70 : const Color(0xFF6B7280)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Nom complet *',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: isDark,
                  fillColor: isDark ? const Color(0xFF162540) : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: companyCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Nom de la boutique / entreprise *',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: isDark,
                  fillColor: isDark ? const Color(0xFF162540) : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: isDark,
                  fillColor: isDark ? const Color(0xFF162540) : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: isDark,
                  fillColor: isDark ? const Color(0xFF162540) : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Adresse de la boutique',
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: isDark,
                  fillColor: isDark ? const Color(0xFF162540) : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                    foregroundColor: isDark ? AppTheme.primaryNavy : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final newEmail = emailCtrl.text.trim();
                    if (newEmail != appState.userEmail) {
                      // Si l'email a changé, réinitialiser la vérification
                      await appState.setEmailVerified(false);
                    }
                    await appState.updateUserProfile(
                      name: nameCtrl.text.trim(),
                      company: companyCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      email: newEmail,
                    );
                    if (addressCtrl.text.trim().isNotEmpty) {
                      await appState.updateCompanyProfile(address: addressCtrl.text.trim());
                    }
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF059669),
                        content: Text('Profil mis à jour avec succès !'),
                      ),
                    );
                  },
                  child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final isDark = appState.isDarkMode;
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool isBusy = false;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Changer le mot de passe'.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppTheme.primaryNavy,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              TextField(
                controller: oldCtrl,
                obscureText: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Ancien mot de passe'.tr,
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                obscureText: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe (min. 6 caract.)'.tr,
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe'.tr,
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isBusy ? null : () => Navigator.pop(ctx),
              child: Text(
                'Annuler'.tr,
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              ),
              onPressed: isBusy
                  ? null
                  : () async {
                      if (newCtrl.text.length < 6) {
                        setDlgState(() => errorMsg = 'Le mot de passe doit comporter au moins 6 caractères.'.tr);
                        return;
                      }
                      if (newCtrl.text != confirmCtrl.text) {
                        setDlgState(() => errorMsg = 'Les mots de passe ne correspondent pas.'.tr);
                        return;
                      }
                      setDlgState(() {
                        isBusy = true;
                        errorMsg = null;
                      });
                      final err = await appState.changeOwnerPassword(
                        oldPassword: oldCtrl.text,
                        newPassword: newCtrl.text,
                      );
                      if (err != null) {
                        setDlgState(() {
                          isBusy = false;
                          errorMsg = err.tr;
                        });
                        return;
                      }
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF059669),
                          content: Text('Mot de passe mis à jour avec succès ! Notification envoyée.'.tr),
                        ),
                      );
                    },
              child: isBusy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Enregistrer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecoveryEmailDialog(BuildContext context) {
    final isDark = appState.isDarkMode;
    final emailCtrl = TextEditingController(
      text: appState.recoveryEmail.isNotEmpty ? appState.recoveryEmail : appState.userEmail,
    );
    bool isBusy = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Email de récupération'.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppTheme.primaryNavy,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cet email sera utilisé pour recevoir les codes de réinitialisation et alertes de sécurité.'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Email de récupération'.tr,
                  labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isBusy ? null : () => Navigator.pop(ctx),
              child: Text(
                'Annuler'.tr,
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              ),
              onPressed: isBusy
                  ? null
                  : () async {
                      final val = emailCtrl.text.trim();
                      if (val.isNotEmpty && !val.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Veuillez entrer une adresse email valide.'.tr)),
                        );
                        return;
                      }
                      setDlgState(() => isBusy = true);
                      await appState.updateRecoveryEmail(val);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF059669),
                          content: Text('Email de récupération enregistré !'.tr),
                        ),
                      );
                    },
              child: isBusy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Enregistrer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final isDark = appState.isDarkMode;
    final pwdCtrl = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Supprimer mon compte'.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cette action est irréversible. Toutes vos données personnelles seront supprimées.'.tr,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: pwdCtrl,
                obscureText: obscure,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280), size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF6B7280),
                      size: 20,
                    ),
                    onPressed: () => setDlgState(() => obscure = !obscure),
                  ),
                  hintText: 'Mot de passe'.tr,
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Annuler'.tr,
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : AppTheme.primaryNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Demande de suppression enregistrée'.tr)),
                );
              },
              child: Text(
                'Supprimer'.tr,
                style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopLogoAvatar({double size = 56}) {
    if (appState.companyLogo.trim().isNotEmpty) {
      try {
        final clean = appState.companyLogo.contains(',')
            ? appState.companyLogo.split(',').last
            : appState.companyLogo;
        return Image.memory(
          base64Decode(clean),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _buildInitialsAvatar(size),
        );
      } catch (_) {
        return _buildInitialsAvatar(size);
      }
    }
    return _buildInitialsAvatar(size);
  }

  Widget _buildInitialsAvatar(double size) {
    return Container(
      color: AppTheme.primaryNavy,
      width: size,
      height: size,
      child: Center(
        child: Text(
          appState.userInitials,
          style: TextStyle(
            color: AppTheme.accentGold,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.isDarkMode;
        final emailDisplay = appState.userEmail.isNotEmpty ? appState.userEmail : 'Non renseigné'.tr;
        final phoneDisplay = appState.userPhone.isNotEmpty ? appState.userPhone : 'Non renseigné'.tr;
        final isOwner = appState.isOwnerAccount;
        final isWebPortal = MediaQuery.of(context).size.width >= 800;
        final storeDisplay = isOwner ? appState.currentStore : appState.assignedStoreForCurrentUser;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkScaffold : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
            elevation: 0,
            centerTitle: true,
            leading: Navigator.canPop(context)
                ? Padding(
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
                  )
                : null,
            title: Text(
              'Mon compte'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. CARTE PROFIL & LOGO DE LA BOUTIQUE
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // LOGO DE LA BOUTIQUE (MODIFIABLE UNIQUEMENT PAR LE PROPRIÉTAIRE)
                          Stack(
                            children: [
                              InkWell(
                                onTap: isOwner ? _pickShopLogo : null,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.accentGold, width: 2),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _buildShopLogoAvatar(size: 60),
                                ),
                              ),
                              if (isOwner)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: _pickShopLogo,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryNavy,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.displayUserName,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  appState.displayCompanyName,
                                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFD1FAE5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        appState.userRole.tr,
                                        style: TextStyle(color: isDark ? const Color(0xFF6EE7B7) : AppTheme.primaryNavy, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (isOwner) ...[
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: _pickShopLogo,
                                        child: Text(
                                          'Changer le logo'.tr,
                                          style: TextStyle(fontSize: 11.5, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. INFORMATIONS PERSONNELLES DYNAMIQUES (Lecture seule pour les comptes invités)
                    Text(
                      'Informations personnelles'.tr,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TÉLÉPHONE'.tr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
                          const SizedBox(height: 4),
                          Text(phoneDisplay, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1F2937), fontWeight: FontWeight.w500)),
                          Divider(height: 24, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6)),

                          Text('EMAIL'.tr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  emailDisplay,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                                ),
                              ),
                              // BADGE ÉTAT DE VÉRIFICATION EMAIL (Uniquement pour le Propriétaire)
                              if (isOwner && _isEmailVerified(appState))
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF86EFAC)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Vérifié'.tr,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                                      ),
                                    ],
                                  ),
                                )
                              else if (isOwner)
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFFECACA)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 13),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Vérifier'.tr,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Divider(height: 24, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6)),

                          Text(
                            (isOwner ? 'BOUTIQUE PRINCIPALE' : 'BOUTIQUE RATTACHÉE').tr,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF)),
                          ),
                          const SizedBox(height: 4),
                          Text(storeDisplay, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1F2937))),

                          if (!isOwner && appState.userAssignedCashDesk != null && appState.userAssignedCashDesk!.trim().isNotEmpty) ...[
                            Divider(height: 24, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6)),
                            Text('CAISSE ATTRIBUÉE'.tr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
                            const SizedBox(height: 4),
                            Text(appState.userAssignedCashDesk!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy)),
                          ],

                          if (isOwner) ...[
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                ),
                                icon: Icon(Icons.edit_outlined, size: 18, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                                label: Text('Modifier le profil'.tr, style: TextStyle(color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                                onPressed: _showEditProfileDialog,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 3. SÉCURITÉ (Uniquement pour le Propriétaire — enlevée pour les comptes invités)
                    if (isOwner) ...[
                      Text(
                        'Sécurité'.tr,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gardez votre compte en sécurité en mettant à jour votre mot de passe régulièrement.'.tr,
                              style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563)),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                ),
                                icon: Icon(Icons.sync_lock_rounded, size: 18, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                                label: Text(
                                  'Changer le mot de passe'.tr,
                                  style: TextStyle(color: isDark ? Colors.white : AppTheme.primaryNavy, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                onPressed: () => _showChangePasswordDialog(context),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                ),
                                icon: Icon(Icons.mark_email_read_outlined, size: 18, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                                label: Text(
                                  'Email de récupération'.tr,
                                  style: TextStyle(color: isDark ? Colors.white : AppTheme.primaryNavy, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                onPressed: () => _showRecoveryEmailDialog(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // 4. ABONNEMENT (Uniquement pour le Propriétaire — enlevé pour les comptes invités)
                    if (isOwner) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Abonnement'.tr,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                          ),
                          if (isWebPortal)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                                );
                              },
                              child: Text(
                                'Voir les formules'.tr,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: isWebPortal
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                                );
                              }
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.workspace_premium_rounded, color: AppTheme.accentGold, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '${'Formule :'.tr} ${_getSubscriptionPlan(appState)}',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Actif'.tr,
                                            style: const TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Date d'expiration affichée UNIQUEMENT sur un abonnement différent de découverte
                                    if (!appState.isDiscoveredPlan) ...[
                                      const SizedBox(height: 3),
                                      Builder(builder: (_) {
                                        final exp = appState.subscriptionExpiresAt ?? DateTime.now().add(const Duration(days: 30));
                                        final expDateStr = '${exp.day.toString().padLeft(2, '0')}/${exp.month.toString().padLeft(2, '0')}/${exp.year}';
                                        final cycleText = appState.subscriptionBilling.toLowerCase() == 'annuel' ? 'Facturation annuelle' : 'Facturation mensuelle';
                                        return Text(
                                          'Expire le : $expDateStr • $cycleText',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        );
                                      }),
                                    ],
                                  ],
                                ),
                              ),
                              if (isWebPortal)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryNavy,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Changer de formule'.tr,
                                    style: const TextStyle(color: AppTheme.accentGold, fontSize: 11.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // 5. SUR LE WEB
                    Text(
                      'Sur le web'.tr,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
                      ),
                      child: InkWell(
                        onTap: () {
                          if (isOwner && isWebPortal) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                            );
                          } else if (!isOwner) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Connectez-vous sur le portail web Bricelo Stock avec votre téléphone et code PIN pour gérer votre caisse ou votre stock ($storeDisplay).'.tr,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Rendez-vous sur le portail web Bricelo Stock pour souscrire ou gérer votre abonnement.'.tr),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.open_in_new_rounded, color: AppTheme.accentGold, size: 20),
                            const SizedBox(width: 14),
                            Text(
                              'Mon compte sur le web'.tr,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 6. ACTIONS ROUGES (DÉCONNEXION & SUPPRESSION POUR LE PROPRIÉTAIRE UNIQUEMENT)
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              await appState.logout();
                              if (!context.mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  const Icon(Icons.logout, size: 20, color: Color(0xFFDC2626)),
                                  const SizedBox(width: 14),
                                  Text('Déconnexion'.tr, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFFDC2626))),
                                ],
                              ),
                            ),
                          ),
                          if (isOwner) ...[
                            Divider(height: 1, indent: 48, color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6)),
                            InkWell(
                              onTap: () => _showDeleteAccountDialog(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_outline, size: 20, color: Color(0xFFDC2626)),
                                    const SizedBox(width: 14),
                                    Text('Supprimer mon compte'.tr, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFFDC2626))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
