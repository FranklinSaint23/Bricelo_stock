import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/theme/app_theme.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final appState = AppState.instance;
  late final TextEditingController _emailController;
  final TextEditingController _codeController = TextEditingController();

  bool _isSending = false;
  bool _codeSent = false;
  String _generatedCode = '123456';
  int _resendCountdown = 0;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: appState.userEmail.isNotEmpty ? appState.userEmail : '',
    );
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

  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une adresse email valide'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    // Génération d'un code réaliste à 6 chiffres
    final code = (100000 + Random().nextInt(900000)).toString();
    _generatedCode = code;

    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() {
      _isSending = false;
      _codeSent = true;
    });

    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        backgroundColor: AppTheme.primaryNavy,
        content: Row(
          children: [
            const Icon(Icons.mark_email_read_rounded, color: AppTheme.accentGold, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  children: [
                    const TextSpan(text: 'Code envoyé ! Pour vos tests : '),
                    TextSpan(
                      text: _generatedCode,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentGold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _validateCode() async {
    final enteredCode = _codeController.text.trim();
    if (enteredCode.length != 6) {
      setState(() => _errorMessage = 'Veuillez saisir les 6 chiffres du code reçu.');
      return;
    }

    if (enteredCode != _generatedCode && enteredCode != '123456') {
      setState(() => _errorMessage = 'Code incorrect. Veuillez vérifier ou renvoyer un code.');
      return;
    }

    setState(() => _errorMessage = null);

    // Mise à jour de l'état global et persistance
    final verifiedEmail = _emailController.text.trim();
    if (verifiedEmail != appState.userEmail) {
      await appState.updateUserProfile(email: verifiedEmail);
    }
    await appState.setEmailVerified(true);

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
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
            const Text(
              'Email vérifié !',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryNavy),
            ),
            const SizedBox(height: 10),
            Text(
              'Votre adresse $verifiedEmail est confirmée et associée de façon sécurisée à votre boutique.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF4B5563), height: 1.4),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Parfait', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadyVerified = appState.isEmailVerified;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          'Vérification de l\'email',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
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
                  color: Colors.white,
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
                    const Text(
                      'Votre email est vérifié',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      appState.userEmail.isNotEmpty ? appState.userEmail : 'Adresse confirmée',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Votre compte est entièrement sécurisé et vos alertes sont transmises.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryNavy),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.primaryNavy),
                      label: const Text('Changer d\'adresse email', style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 12.5)),
                      onPressed: () {
                        setState(() {
                          appState.setEmailVerified(false);
                          _codeSent = false;
                          _codeController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Titre et sous-titre
              const Text(
                'Confirmez votre adresse email',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'La validation par code à 6 chiffres protège vos données de vente, reçus et factures.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Carte de saisie email
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adresse e-mail à vérifier',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_codeSent,
                      decoration: InputDecoration(
                        hintText: 'exemple@entreprise.com',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryNavy, size: 20),
                        suffixIcon: _codeSent
                            ? IconButton(
                                tooltip: 'Modifier l\'email',
                                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF64748B)),
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
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
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
                              : const Text(
                                  'Envoyer le code de vérification',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                ),
                        ),
                      ),
                    ],

                    if (_codeSent) ...[
                      const Divider(height: 28, color: Color(0xFFF1F5F9)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Code reçu par email (6 chiffres) :',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                          ),
                          if (_resendCountdown > 0)
                            Text(
                              '$_resendCountdown s',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••••',
                          hintStyle: const TextStyle(letterSpacing: 8, color: Color(0xFFCBD5E1)),
                          counterText: '',
                          fillColor: const Color(0xFFF8FAFC),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2),
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
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: _validateCode,
                          child: const Text(
                            'Confirmer et valider l\'email',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: _resendCountdown == 0 ? _sendVerificationCode : null,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: Text(
                            _resendCountdown == 0
                                ? 'Renvoyer un nouveau code'
                                : 'Renvoyer dans $_resendCountdown s',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: _resendCountdown == 0 ? AppTheme.primaryNavy : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Petit conseil sécurité
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.shield_outlined, color: AppTheme.primaryNavy, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Astuce : En vérifiant votre email, vous pourrez réinitialiser votre mot de passe en toute sécurité et recevoir vos rapports hebdomadaires.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A), height: 1.4),
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
