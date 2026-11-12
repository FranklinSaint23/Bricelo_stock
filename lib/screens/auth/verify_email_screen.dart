import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String? initialEmail;
  final bool autoSend;
  final VoidCallback? onVerified;

  const VerifyEmailScreen({
    super.key,
    this.initialEmail,
    this.autoSend = false,
    this.onVerified,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final appState = AppState.instance;

  late final TextEditingController _emailController;
  final TextEditingController _codeController = TextEditingController();

  bool _isSending = false;
  bool _isValidating = false;
  bool _codeSent = false;
  int _resendCountdown = 0;
  Timer? _timer;
  String? _errorMessage;

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

  Future<void> _setEmailVerifiedSafe(AppState state, bool verified) async {
    try {
      await state.setEmailVerified(verified);
      return;
    } catch (_) {}
    try {
      state.isEmailVerified = verified;
      await state.saveSettings();
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    final defaultEmail = widget.initialEmail?.trim().isNotEmpty == true
        ? widget.initialEmail!.trim()
        : (appState.userEmail.isNotEmpty ? appState.userEmail : '');
    _emailController = TextEditingController(text: defaultEmail);

    if (widget.autoSend && defaultEmail.isNotEmpty && defaultEmail.contains('@')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendVerificationCode();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendCountdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
        setState(() => _resendCountdown = 0);
      }
    });
  }

  String _formatErrorMessage(dynamic err, bool isEn) {
    final msg = err.toString().toLowerCase();
    if (msg.contains('token has expired') || msg.contains('expired')) {
      return isEn
          ? 'The verification code has expired. Please request a new one.'
          : 'Le code a expiré. Veuillez en redemander un nouveau.';
    }
    if (msg.contains('invalid') || msg.contains('incorrect') || msg.contains('otp_expired')) {
      return isEn
          ? 'Incorrect or expired code. Please check your inbox and try again.'
          : 'Code incorrect ou expiré. Veuillez vérifier votre boîte mail et réessayer.';
    }
    if (msg.contains('rate limit') || msg.contains('over_email_send_rate_limit')) {
      return isEn
          ? 'Email rate limit reached. Please wait a few moments before requesting a new code.'
          : 'Limite d\'envois atteinte. Veuillez patienter un instant avant de renvoyer un code.';
    }
    if (msg.contains('socket') || msg.contains('network') || msg.contains('connection')) {
      return isEn
          ? 'Network connection issue. Please check your internet connection.'
          : 'Problème de connexion réseau. Veuillez vérifier votre accès internet.';
    }
    return isEn
        ? 'Verification error. Please check the code and try again.'
        : 'Erreur de vérification. Veuillez vérifier le code et réessayer.';
  }

  /// Envoi réel du code OTP via Supabase Auth
  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();
    final isEn = appState.currentLanguage == 'en';

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEn
                ? 'Please enter a valid email address.'
                : 'Veuillez entrer une adresse email valide.',
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      final sb = Supabase.instance.client;

      // 1. Tenter le renvoi de confirmation d'inscription (type: signup)
      try {
        await sb.auth.resend(
          type: OtpType.signup,
          email: email,
        );
      } catch (eSignup) {
        // 2. Si le compte existe déjà ou nécessite un OTP par email (type: email)
        try {
          await sb.auth.signInWithOtp(
            email: email,
            shouldCreateUser: false,
          );
        } catch (_) {
          // 3. Si aucun compte auth n'existe encore pour cet email, en créer un
          await sb.auth.signInWithOtp(
            email: email,
            shouldCreateUser: true,
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _isSending = false;
        _codeSent = true;
      });

      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          backgroundColor: AppTheme.primaryNavy,
          content: Row(
            children: [
              const Icon(Icons.mark_email_read_rounded, color: AppTheme.accentGold, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEn
                      ? 'Verification code sent to $email. Please check your inbox.'
                      : 'Code de vérification envoyé à $email. Consultez votre boîte mail.',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _errorMessage = _formatErrorMessage(err, isEn);
      });
    }
  }

  /// Validation réelle du code OTP à 6 chiffres via Supabase Auth
  Future<void> _validateCode() async {
    final enteredCode = _codeController.text.trim();
    final isEn = appState.currentLanguage == 'en';

    if (enteredCode.length != 6) {
      setState(() => _errorMessage = isEn
          ? 'Please enter all 6 digits of the code.'
          : 'Veuillez saisir les 6 chiffres du code reçu.');
      return;
    }

    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    final verifiedEmail = _emailController.text.trim();
    final sb = Supabase.instance.client;

    try {
      AuthResponse? response;

      // 1. Tenter la vérification avec OtpType.signup
      try {
        response = await sb.auth.verifyOTP(
          email: verifiedEmail,
          token: enteredCode,
          type: OtpType.signup,
        );
      } catch (e1) {
        // 2. Si non applicable, tenter avec OtpType.email
        try {
          response = await sb.auth.verifyOTP(
            email: verifiedEmail,
            token: enteredCode,
            type: OtpType.email,
          );
        } catch (e2) {
          // 3. Tenter avec OtpType.magiclink
          response = await sb.auth.verifyOTP(
            email: verifiedEmail,
            token: enteredCode,
            type: OtpType.magiclink,
          );
        }
      }

      if (response.session != null || response.user != null) {
        // Email vérifié avec succès sur Supabase
        await _setEmailVerifiedSafe(appState, true);

        if (verifiedEmail != appState.userEmail) {
          await appState.updateUserProfile(email: verifiedEmail);
        }

        // Synchronisation du statut dans la table user_profiles
        if (appState.userPhone.isNotEmpty) {
          await appState.enqueueOrSendSupabase(
            table: 'user_profiles',
            action: 'update',
            matchCol: 'phone',
            matchVal: appState.userPhone,
            payload: {
              'email': verifiedEmail,
              'is_email_verified': true,
              'email_verified_at': DateTime.now().toIso8601String(),
            },
          );
        }

        widget.onVerified?.call();

        if (!mounted) return;
        setState(() => _isValidating = false);

        final isDark = appState.isDarkMode;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 40),
                ),
                const SizedBox(height: 18),
                Text(
                  isEn ? 'Email verified!' : 'Email vérifié !',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDark ? Colors.white : AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isEn
                      ? 'Your address $verifiedEmail is securely verified and linked to your store.'
                      : 'Votre adresse $verifiedEmail est confirmée et associée de façon sécurisée à votre boutique.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      foregroundColor: isDark ? const Color(0xFF0D1B2E) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: Text(
                      isEn ? 'Done' : 'Parfait',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        if (!mounted) return;
        setState(() {
          _isValidating = false;
          _errorMessage = isEn
              ? 'Verification failed. Please check the code.'
              : 'Échec de vérification. Veuillez vérifier le code.';
        });
      }
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _isValidating = false;
        _errorMessage = _formatErrorMessage(err, isEn);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadyVerified = _isEmailVerified(appState);
    final isDark = appState.isDarkMode;
    final isEn = appState.currentLanguage == 'en';

    final bgColor = isDark ? AppTheme.darkScaffold : const Color(0xFFF8FAFC);
    final cardColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E3352) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : AppTheme.primaryNavy;
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.primaryNavy,
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
          isEn ? 'Email Verification' : 'Vérification de l\'email',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Si déjà vérifié
            if (isAlreadyVerified) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 36),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isEn ? 'Your email is verified' : 'Votre email est vérifié',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      appState.userEmail.isNotEmpty
                          ? appState.userEmail
                          : (isEn ? 'Verified address' : 'Adresse confirmée'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isEn
                          ? 'Your account is securely verified and your alerts will be sent properly.'
                          : 'Votre compte est entièrement sécurisé et vos alertes sont transmises.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: subtextColor),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      ),
                      label: Text(
                        isEn ? 'Change email address' : 'Changer d\'adresse email',
                        style: TextStyle(
                          color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _setEmailVerifiedSafe(appState, false);
                          _codeSent = false;
                          _codeController.clear();
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Titre et sous-titre
              Text(
                isEn ? 'Confirm your email address' : 'Confirmez votre adresse email',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isEn
                    ? '6-digit code validation protects your sales data, receipts, and invoices.'
                    : 'La validation par code à 6 chiffres protège vos données de vente, reçus et factures.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: subtextColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Carte de saisie email
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Email address to verify' : 'Adresse e-mail à vérifier',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtextColor),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_codeSent,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'exemple@entreprise.com',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                          size: 20,
                        ),
                        suffixIcon: _codeSent
                            ? IconButton(
                                tooltip: isEn ? 'Edit email' : 'Modifier l\'email',
                                icon: Icon(Icons.edit, size: 18, color: subtextColor),
                                onPressed: () {
                                  setState(() {
                                    _codeSent = false;
                                    _codeController.clear();
                                    _errorMessage = null;
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (!_codeSent) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                            foregroundColor: isDark ? const Color(0xFF0D1B2E) : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: _isSending ? null : _sendVerificationCode,
                          child: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                )
                              : Text(
                                  isEn ? 'Send verification code' : 'Envoyer le code de vérification',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                ),
                        ),
                      ),
                    ],

                    if (_codeSent) ...[
                      Divider(height: 28, color: borderColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEn ? 'Email code (6 digits):' : 'Code reçu par email (6 chiffres) :',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          if (_resendCountdown > 0)
                            Text(
                              '$_resendCountdown s',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtextColor),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _codeController,
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
                          fillColor: isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF8FAFC),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                            foregroundColor: isDark ? const Color(0xFF0D1B2E) : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: _isValidating ? null : _validateCode,
                          child: _isValidating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                )
                              : Text(
                                  isEn ? 'Confirm and verify email' : 'Confirmer et valider l\'email',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: _resendCountdown == 0 && !_isSending ? _sendVerificationCode : null,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: Text(
                            _resendCountdown == 0
                                ? (isEn ? 'Resend new code' : 'Renvoyer un nouveau code')
                                : (isEn
                                    ? 'Resend in $_resendCountdown s'
                                    : 'Renvoyer dans $_resendCountdown s'),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: _resendCountdown == 0
                                  ? (isDark ? AppTheme.accentGold : AppTheme.primaryNavy)
                                  : subtextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Conseil sécurité
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: isDark ? AppTheme.accentGold : AppTheme.primaryNavy,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEn
                            ? 'Tip: Verifying your email allows secure password recovery and weekly activity reports.'
                            : 'Astuce : En vérifiant votre email, vous pourrez réinitialiser votre mot de passe en toute sécurité et recevoir vos rapports hebdomadaires.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
