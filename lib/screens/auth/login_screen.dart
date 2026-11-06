import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/services/app_state.dart';
import 'package:stock_prime/screens/screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // true = Nouvel utilisateur (Inscription), false = Utilisateur déjà existant (Connexion)
  bool _isNewUser = false;
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
    final state = AppState.instance;
    // Si aucun profil n'a jamais été créé sur l'appareil, pré-sélectionner "Nouveau sur la plateforme"
    if (state.userName.isEmpty && state.companyName.isEmpty) {
      _isNewUser = true;
    } else {
      _isNewUser = false;
      _phoneCtrl.text = state.userPhone.isNotEmpty ? state.userPhone : state.userEmail;
      _fullNameCtrl.text = state.userName;
      _shopNameCtrl.text = state.companyName;
    }
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

    if (_isNewUser) {
      final name = _fullNameCtrl.text.trim();
      final shop = _shopNameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final pwd = _passwordCtrl.text.trim();

      if (name.isEmpty || shop.isEmpty || phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            content: Text(
              isEn
                  ? 'Please enter your name, store name and phone number.'
                  : 'Veuillez renseigner votre nom, le nom de votre boutique et votre téléphone.',
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      final identifier = _phoneCtrl.text.trim();
      final pwd = _passwordCtrl.text.trim();

      if (identifier.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            content: Text(
              isEn
                  ? 'Please enter your phone number or email.'
                  : 'Veuillez entrer votre numéro de téléphone ou email.',
            ),
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      await state.loginUser(
        identifier: identifier,
        password: pwd,
        fallbackName: _fullNameCtrl.text.trim(),
        fallbackShop: _shopNameCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final isEn = appState.currentLanguage == 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP BAR : CHANGEMENT DE LANGUE & STATUT CLOUD SUPABASE
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(isEn ? '🇬🇧 EN' : '🇫🇷 FR', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryNavy)),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.primaryNavy),
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
                    const Text(
                      'Bricelo Stock',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEn
                          ? 'Point of Sale, Inventory & Accounting'
                          : 'Point de vente, gestion de stock & trésorerie',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. QUESTION DE PROFIL : NOUVEAU OU DÉJÀ EXISTANT SUR LA PLATEFORME
              Text(
                isEn
                    ? 'How would you like to continue?'
                    : 'Quel est votre profil sur la plateforme ?',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildProfileTypeCard(
                      isSelected: !_isNewUser,
                      icon: Icons.login_rounded,
                      title: isEn ? 'Existing User' : 'Déjà utilisateur',
                      subtitle: isEn ? 'Log in to my store' : 'Me connecter à mon compte',
                      onTap: () => setState(() => _isNewUser = false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProfileTypeCard(
                      isSelected: _isNewUser,
                      icon: Icons.storefront_rounded,
                      title: isEn ? 'New User' : 'Nouveau',
                      subtitle: isEn ? 'Create my store' : 'Créer ma boutique',
                      onTap: () => setState(() => _isNewUser = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. CARTE FORMULAIRE DYNAMIQUE
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    Text(
                      _isNewUser
                          ? (isEn ? 'Create your store account' : 'Créer votre compte & boutique')
                          : (isEn ? 'Sign in to your account' : 'Connexion à votre espace'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isNewUser
                          ? (isEn
                              ? 'Configure your workspace in seconds.'
                              : 'Configurez votre boutique en quelques secondes.')
                          : (isEn
                              ? 'Enter your credentials to access your data.'
                              : 'Entrez vos identifiants pour retrouver votre boutique.'),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 18),

                    if (_isNewUser) ...[
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
                    ] else ...[
                      _buildInput(
                        controller: _phoneCtrl,
                        icon: Icons.person_outline_rounded,
                        label: isEn ? 'Phone number or Email *' : 'Téléphone ou Email *',
                        hint: isEn ? 'Enter phone or email' : 'Votre numéro ou adresse email',
                      ),
                      const SizedBox(height: 14),
                      if (appState.userName.isEmpty) ...[
                        _buildInput(
                          controller: _fullNameCtrl,
                          icon: Icons.badge_outlined,
                          label: isEn ? 'Your name (if new device)' : 'Votre nom d\'affichage',
                          hint: isEn ? 'Ex: Jean Kamga' : 'Ex: Jean Kamga',
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 14),
                      ],
                    ],

                    // Mot de passe
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryNavy, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: const Color(0xFF64748B),
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        labelText: isEn ? 'Password *' : 'Mot de passe *',
                        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 22),

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
                                      _isNewUser
                                          ? (isEn ? 'Create my store & Start' : 'Créer ma boutique & Démarrer')
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
    );
  }

  Widget _buildProfileTypeCard({
    required bool isSelected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : const Color(0xFFE2E8F0),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentGold : AppTheme.primaryNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: isSelected ? Colors.white : AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white70 : const Color(0xFF64748B),
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
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppTheme.primaryNavy, size: 20),
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
