import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 0 = Propriétaire existant (Connexion), 1 = Nouveau (Créer boutique), 2 = Compte Invité (Équipier)
  int _authMode = 0;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  // Contrôleurs Connexion & Inscription
  final _fullNameCtrl = TextEditingController();
  final _shopNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tous les champs restent strictement vides à l'ouverture de l'écran de connexion
    _authMode = 0;
  }

  void _clearAllFields() {
    _fullNameCtrl.clear();
    _shopNameCtrl.clear();
    _phoneCtrl.clear();
    _emailCtrl.clear();
    _passwordCtrl.clear();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _shopNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final state = AppState.instance;
    final isEn = state.currentLanguage == 'en';

    if (_authMode == 1) {
      final name = _fullNameCtrl.text.trim();
      final shop = _shopNameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final pwd = _passwordCtrl.text.trim();

      if (name.isEmpty || shop.isEmpty || phone.isEmpty || pwd.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            content: Text(
              isEn
                  ? 'Please enter your name, store name, phone number and password.'
                  : 'Veuillez renseigner votre nom, le nom de votre boutique, votre téléphone et un mot de passe.',
            ),
          ),
        );
        return;
      }

      if (pwd.length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            content: Text(
              isEn
                  ? 'Password must contain at least 4 characters.'
                  : 'Le mot de passe doit contenir au moins 4 caractères.',
            ),
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      await state.registerUser(
        fullName: name,
        shopName: shop,
        phone: phone,
        email: email,
        password: pwd,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (state.isSuperAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SuperAdminPortalShell()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } else if (_authMode == 2) {
      // CONNEXION COMPTE INVITÉ / ÉQUIPIER (Caissier, Magasinier, Gérant, Vendeur...)
      final identifier = _phoneCtrl.text.trim();
      final pin = _passwordCtrl.text.trim();

      if (identifier.isEmpty || pin.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            content: Text(
              isEn
                  ? 'Please enter your phone number and the 6-digit PIN sent by the owner.'
                  : 'Veuillez entrer votre numéro de téléphone et le code PIN reçu du propriétaire.',
            ),
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      final matchedMember = await state.loginInvitedMember(
        identifier: identifier,
        pinCode: pin,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (matchedMember == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            content: Text(
              isEn
                  ? 'Invalid credentials. Check your phone number and PIN code with the store owner.'
                  : 'Identifiants incorrects. Vérifiez votre numéro et le code PIN transmis par le propriétaire.',
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF059669),
          content: Text(
            'Bienvenue ${matchedMember.name} — Connecté en tant que ${matchedMember.role}',
          ),
        ),
      );

      if (state.isSuperAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SuperAdminPortalShell()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } else {
      final phone = _phoneCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final pwd = _passwordCtrl.text.trim();

      if (phone.isEmpty || pwd.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            content: Text(
              isEn
                  ? 'Please enter your phone number and your password.'
                  : 'Veuillez entrer votre numéro de téléphone (obligatoire) et votre mot de passe.',
            ),
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      final errorMsg = await state.loginUser(
        identifier: phone,
        email: email,
        password: pwd,
        fallbackName: _fullNameCtrl.text.trim(),
        fallbackShop: _shopNameCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (errorMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            content: Text(errorMsg),
          ),
        );
        return;
      }

      if (state.isSuperAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SuperAdminPortalShell()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    }
  }

  void _showForgotPasswordModal() {
    final state = AppState.instance;
    final isEn = state.currentLanguage == 'en';
    final isDark = state.isDarkMode;

    final idCtrl = TextEditingController(
      text: _emailCtrl.text.isNotEmpty
          ? _emailCtrl.text
          : (_phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : ''),
    );
    final otpCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    final confirmPwdCtrl = TextEditingController();

    int step = 1; // 1: Email/Identifiant, 2: Code OTP, 3: Nouveau mot de passe
    String resolvedEmail = '';
    bool isBusy = false;
    String? stepError;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
          final borderCol = isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0);
          final textCol = isDark ? Colors.white : AppTheme.primaryNavy;
          final subtextCol = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

          return Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(modalCtx).viewInsets.bottom + 24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: borderCol),
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
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEn ? 'Reset Password' : 'Réinitialiser le mot de passe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textCol,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: subtextCol, size: 20),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step == 1
                        ? (isEn
                            ? 'Enter your phone number or recovery email to receive a 6-digit reset code.'
                            : 'Entrez votre numéro de téléphone ou votre email de récupération pour recevoir un code à 6 chiffres.')
                        : step == 2
                            ? (isEn
                                ? 'A 6-digit code has been sent to $resolvedEmail. Please enter it below.'
                                : 'Un code à 6 chiffres a été envoyé à $resolvedEmail. Saisissez-le ci-dessous.')
                            : (isEn
                                ? 'Choose a new password (min. 6 characters) for your account.'
                                : 'Choisissez votre nouveau mot de passe (min. 6 caractères).'),
                    style: TextStyle(fontSize: 13, color: subtextCol, height: 1.4),
                  ),
                  const SizedBox(height: 18),

                  if (stepError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              stepError!,
                              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // STEP 1: Saisie Email ou Téléphone
                  if (step == 1) ...[
                    TextField(
                      controller: idCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: isEn ? 'Phone number or Email' : 'Numéro de téléphone ou Email',
                        labelStyle: TextStyle(color: subtextCol, fontSize: 13),
                        prefixIcon: Icon(Icons.account_circle_outlined, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                          foregroundColor: isDark ? const Color(0xFF0D1B2E) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isBusy
                            ? null
                            : () async {
                                final input = idCtrl.text.trim();
                                if (input.isEmpty) {
                                  setModalState(() => stepError = isEn ? 'Please enter your email or phone.' : 'Veuillez saisir votre email ou téléphone.');
                                  return;
                                }

                                setModalState(() {
                                  isBusy = true;
                                  stepError = null;
                                });

                                String target = '';
                                if (input.contains('@')) {
                                  target = input.toLowerCase();
                                } else {
                                  final found = await state.findRecoveryEmailForIdentifier(input);
                                  if (found != null && found.isNotEmpty) {
                                    target = found;
                                  } else {
                                    setModalState(() {
                                      isBusy = false;
                                      stepError = isEn
                                          ? 'No recovery email found for this phone number. Please enter your email address directly.'
                                          : 'Aucun email de récupération trouvé pour ce numéro. Veuillez entrer directement votre adresse email.';
                                    });
                                    return;
                                  }
                                }

                                final err = await state.sendPasswordResetCode(target);
                                setModalState(() {
                                  isBusy = false;
                                  if (err != null) {
                                    stepError = err;
                                  } else {
                                    resolvedEmail = target;
                                    step = 2;
                                  }
                                });
                              },
                        child: isBusy
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(isEn ? 'Send 6-digit Code' : 'Envoyer le code à 6 chiffres', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],

                  // STEP 2: Saisie du Code OTP
                  if (step == 2) ...[
                    TextField(
                      controller: otpCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        letterSpacing: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      ),
                      decoration: InputDecoration(
                        hintText: '••••••',
                        hintStyle: const TextStyle(letterSpacing: 8, color: Color(0xFFCBD5E1)),
                        counterText: '',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                          foregroundColor: isDark ? const Color(0xFF0D1B2E) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isBusy
                            ? null
                            : () async {
                                final code = otpCtrl.text.trim();
                                if (code.length != 6) {
                                  setModalState(() => stepError = isEn ? 'Please enter the 6-digit code.' : 'Veuillez saisir les 6 chiffres du code.');
                                  return;
                                }

                                setModalState(() {
                                  isBusy = true;
                                  stepError = null;
                                });

                                try {
                                  final sb = Supabase.instance.client;
                                  final authResp = await sb.auth.verifyOTP(
                                    email: resolvedEmail,
                                    token: code,
                                    type: OtpType.recovery,
                                  );

                                  if (authResp.session != null || authResp.user != null) {
                                    setModalState(() {
                                      isBusy = false;
                                      step = 3;
                                    });
                                  } else {
                                    setModalState(() {
                                      isBusy = false;
                                      stepError = isEn ? 'Invalid or expired code.' : 'Code invalide ou expiré.';
                                    });
                                  }
                                } catch (e) {
                                  setModalState(() {
                                    isBusy = false;
                                    stepError = isEn ? 'Invalid code. Please retry.' : 'Code incorrect ou expiré. Veuillez réessayer.';
                                  });
                                }
                              },
                        child: isBusy
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(isEn ? 'Verify Code' : 'Valider le code', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: Text(isEn ? 'Resend code' : 'Renvoyer un nouveau code', style: TextStyle(color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, fontSize: 12.5)),
                        onPressed: isBusy
                            ? null
                            : () async {
                                setModalState(() => isBusy = true);
                                await state.sendPasswordResetCode(resolvedEmail);
                                setModalState(() {
                                  isBusy = false;
                                  stepError = null;
                                });
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF059669),
                                    content: Text(isEn ? 'New code sent to $resolvedEmail.' : 'Nouveau code envoyé à $resolvedEmail.'),
                                  ),
                                );
                              },
                      ),
                    ),
                  ],

                  // STEP 3: Saisie du Nouveau Mot de Passe
                  if (step == 3) ...[
                    TextField(
                      controller: newPwdCtrl,
                      obscureText: obscureNew,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: isEn ? 'New password (min. 6 chars) *' : 'Nouveau mot de passe (min. 6 caract.) *',
                        labelStyle: TextStyle(color: subtextCol, fontSize: 13),
                        prefixIcon: Icon(Icons.lock_outline, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, color: subtextCol, size: 20),
                          onPressed: () => setModalState(() => obscureNew = !obscureNew),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPwdCtrl,
                      obscureText: obscureConfirm,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: isEn ? 'Confirm password *' : 'Confirmer le mot de passe *',
                        labelStyle: TextStyle(color: subtextCol, fontSize: 13),
                        prefixIcon: Icon(Icons.lock_reset_outlined, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, color: subtextCol, size: 20),
                          onPressed: () => setModalState(() => obscureConfirm = !obscureConfirm),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF162540) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                          foregroundColor: isDark ? const Color(0xFF0D1B2E) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isBusy
                            ? null
                            : () async {
                                final newPwd = newPwdCtrl.text.trim();
                                final confirmPwd = confirmPwdCtrl.text.trim();

                                if (newPwd.length < 6) {
                                  setModalState(() => stepError = isEn ? 'Password must be at least 6 characters.' : 'Le mot de passe doit comporter au moins 6 caractères.');
                                  return;
                                }
                                if (newPwd != confirmPwd) {
                                  setModalState(() => stepError = isEn ? 'Passwords do not match.' : 'Les mots de passe ne correspondent pas.');
                                  return;
                                }

                                setModalState(() {
                                  isBusy = true;
                                  stepError = null;
                                });

                                try {
                                  final sb = Supabase.instance.client;
                                  // 1. Mise à jour dans Supabase Auth (déclenche notification 'Password changed')
                                  await sb.auth.updateUser(UserAttributes(password: newPwd));

                                  // 2. Mise à jour hash local et sync table user_profiles
                                  final newHash = AppState.hashPassword(newPwd);
                                  state.ownerPasswordHash = newHash;
                                  await state.saveSettings();

                                  if (resolvedEmail.isNotEmpty) {
                                    await state.enqueueOrSendSupabase(
                                      table: 'user_profiles',
                                      action: 'update',
                                      matchCol: 'email',
                                      matchVal: resolvedEmail,
                                      payload: {
                                        'password_hash': newHash,
                                        'updated_at': DateTime.now().toIso8601String(),
                                      },
                                    );
                                  }

                                  Navigator.pop(modalCtx);
                                  _passwordCtrl.text = newPwd;

                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFF059669),
                                      content: Text(
                                        isEn
                                            ? 'Password reset successfully! Security confirmation email sent.'
                                            : 'Mot de passe réinitialisé avec succès ! Un email de sécurité vous a été envoyé.',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  setModalState(() {
                                    isBusy = false;
                                    stepError = 'Erreur: $e';
                                  });
                                }
                              },
                        child: isBusy
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(isEn ? 'Save New Password' : 'Enregistrer le nouveau mot de passe', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = AppState().isDarkMode;
        final isEn = appState.currentLanguage == 'en';
        final pageBg = isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC);
        final cardBg = isDark ? AppTheme.darkSurface : Colors.white;
        final cardBorder = isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0);
        final textPrimary = isDark ? Colors.white : AppTheme.primaryNavy;
        final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

        return Scaffold(
          backgroundColor: pageBg,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // 1. TOP BAR : CHANGEMENT DE LANGUE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LanguageOnboardingScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(isEn ? '🇬🇧 EN' : '🇫🇷 FR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy)),
                              const SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down, size: 16, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
              const SizedBox(height: 18),

              // 2. EN-TÊTE LOGO & BIENVENUE
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Center(
                          child: Text(
                            'B⁺',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bricelo Stock',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEn
                          ? 'Point of Sale, Inventory & Accounting'
                          : 'Point de vente, gestion de stock & trésorerie',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. QUESTION DE PROFIL : PROPRIÉTAIRE, NOUVEAU OU COMPTE INVITÉ (ÉQUIPIER)
              Text(
                isEn
                    ? 'How would you like to continue?'
                    : 'Quel est votre profil sur la plateforme ?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildProfileTypeCard(
                      isSelected: _authMode == 0,
                      icon: Icons.login_rounded,
                      title: isEn ? 'Owner' : 'Propriétaire',
                      subtitle: isEn ? 'My store account' : 'Déjà utilisateur',
                      isDark: isDark,
                      onTap: () => setState(() {
                        _authMode = 0;
                        _clearAllFields();
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildProfileTypeCard(
                      isSelected: _authMode == 1,
                      icon: Icons.storefront_rounded,
                      title: isEn ? 'New Store' : 'Nouveau',
                      subtitle: isEn ? 'Create store' : 'Créer boutique',
                      isDark: isDark,
                      onTap: () => setState(() {
                        _authMode = 1;
                        _clearAllFields();
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildProfileTypeCard(
                      isSelected: _authMode == 2,
                      icon: Icons.badge_rounded,
                      title: isEn ? 'Invited Staff' : 'Compte Invité',
                      subtitle: isEn ? 'Cashier, Staff...' : 'Équipier / Rôle',
                      isDark: isDark,
                      onTap: () => setState(() {
                        _authMode = 2;
                        _clearAllFields();
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. CARTE FORMULAIRE DYNAMIQUE
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _authMode == 2 ? AppTheme.accentGold : cardBorder,
                    width: _authMode == 2 ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_authMode == 2) ...[
                          Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.verified_user_rounded, color: AppTheme.primaryNavy, size: 18),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            _authMode == 1
                                ? (isEn ? 'Create your store account' : 'Créer votre compte & boutique')
                                : _authMode == 2
                                    ? (isEn ? 'Invited Team Member Login' : 'Connexion Compte Invité (Équipier)')
                                    : (isEn ? 'Sign in to your account' : 'Connexion Espace Propriétaire'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _authMode == 1
                          ? (isEn
                              ? 'Configure your workspace in seconds.'
                              : 'Configurez votre boutique en quelques secondes.')
                          : _authMode == 2
                              ? (isEn
                                  ? 'Enter the phone number and 6-digit PIN sent by the store owner on WhatsApp.'
                                  : 'Entrez votre numéro de téléphone et le code PIN reçus sur WhatsApp de votre propriétaire.')
                              : (isEn
                                  ? 'Enter your credentials to access your data.'
                                  : 'Entrez vos identifiants pour retrouver votre boutique.'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),

                    if (_authMode == 1) ...[
                      _buildInput(
                        controller: _fullNameCtrl,
                        icon: Icons.badge_outlined,
                        label: isEn ? 'Your full name *' : 'Votre nom complet *',
                        hint: isEn ? 'Ex: Jean-Pierre Kamga' : 'Ex: Jean-Pierre Kamga',
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 14),
                      _buildInput(
                        controller: _shopNameCtrl,
                        icon: Icons.store_mall_directory_outlined,
                        label: isEn ? 'Store / Company name *' : 'Nom de votre boutique / entreprise *',
                        hint: isEn ? 'Ex: Quincaillerie Kamga' : 'Ex: Quincaillerie Kamga',
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 14),
                      _buildInput(
                        controller: _phoneCtrl,
                        icon: Icons.phone_android_rounded,
                        label: isEn ? 'Phone number *' : 'Numéro de téléphone *',
                        hint: 'Ex: 699 00 11 22',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      _buildInput(
                        controller: _emailCtrl,
                        icon: Icons.alternate_email_rounded,
                        label: isEn ? 'Email address (optional)' : 'Adresse email (optionnel)',
                        hint: 'contact@maboutique.cm',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                    ] else if (_authMode == 2) ...[
                      _buildInput(
                        controller: _phoneCtrl,
                        icon: Icons.phone_android_rounded,
                        label: isEn ? 'Invited Phone Number *' : 'Numéro de téléphone (Identifiant) *',
                        hint: 'Ex: +237 699 00 11 22',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                    ] else ...[
                      _buildInput(
                        controller: _phoneCtrl,
                        icon: Icons.phone_android_rounded,
                        label: isEn ? 'Phone number *' : 'Numéro de téléphone *',
                        hint: isEn ? 'Enter your phone number' : 'Ex: +237 699 00 11 22',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      _buildInput(
                        controller: _emailCtrl,
                        icon: Icons.alternate_email_rounded,
                        label: isEn ? 'Email address (optional)' : 'Adresse email (optionnel)',
                        hint: 'contact@maboutique.cm',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Mot de passe ou Code PIN
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      keyboardType: _authMode == 2 ? TextInputType.number : TextInputType.text,
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          _authMode == 2 ? Icons.pin_outlined : Icons.lock_outline_rounded,
                          color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        labelText: _authMode == 2
                            ? (isEn ? '6-digit PIN Code *' : 'Code PIN secret (6 chiffres) *')
                            : (isEn ? 'Password *' : 'Mot de passe *'),
                        hintText: _authMode == 2 ? 'Ex: 482915' : null,
                        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13),
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), fontSize: 13),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),

                    if (_authMode == 0) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordModal,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            isEn ? 'Forgot password?' : 'Mot de passe oublié ?',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (_authMode == 2) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? const Color(0xFF047857) : const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.shield_outlined, color: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Votre interface s\'adaptera automatiquement à votre rôle (Caissier, Magasinier, Gérant...) et aux permissions accordées par le propriétaire.',
                                style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF166534), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // BOUTON VALIDER
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _authMode == 1
                                          ? (isEn ? 'Create my store & Start' : 'Créer ma boutique & Démarrer')
                                          : _authMode == 2
                                              ? (isEn ? 'Sign In as Team Member' : 'Se connecter à mon espace équipier')
                                              : (isEn ? 'Sign In' : 'Se connecter'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: AppTheme.accentGold, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTypeCard({
    required bool isSelected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryNavy
              : (isDark ? AppTheme.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentGold
                : (isDark ? const Color(0xFF1E3052) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentGold : AppTheme.primaryNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: isSelected ? Colors.white : (isDark ? Colors.white : AppTheme.primaryNavy),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                color: isSelected ? Colors.white70 : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final isDark = AppState().isDarkMode;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, size: 20),
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13),
        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), fontSize: 13),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
