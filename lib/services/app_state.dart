import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'invoice_print_service.dart';

class AppState extends ChangeNotifier {
  static const String _storageKey = 'bricelo_dynamic_state_v2';

  static final AppState instance = AppState._internal();
  factory AppState() => instance;
  AppState._internal();

  bool _initialized = false;

  // --- Onboarding & Authentification ---
  bool hasSelectedLanguage = false;
  bool isLoggedIn = false;
  String currentLanguage = 'fr'; // 'fr' or 'en'
  bool isDarkMode = false;

  // --- Profil Utilisateur & Entreprise (100% Dynamique, aucun nom prédéfini) ---
  String userName = '';
  String companyName = '';
  String userEmail = '';
  bool isEmailVerified = false;
  String userPhone = '';
  String userRole = 'Propriétaire';

  // --- Abonnement Bricelo SaaS ---
  String subscriptionPlan = 'Gratuit'; // 'Gratuit', 'Pro', 'Entreprise'
  String subscriptionBilling = 'mensuel'; // 'mensuel' or 'annuel'
  String subscriptionStatus = 'Actif';
  DateTime? subscriptionExpiresAt;

  // --- Profil Entreprise & Facturation Dynamique ---
  String companyLogo = '';
  String companyAddress = 'Situé à FOURGEROLE ( Face Tradex avant le Petit Marché)';
  String companyActivity = 'VENTE DE MATELAS, LITS, MOUSSES, MEUBLES ET ACCESSOIRES MENAGERS';
  String taxNumber = 'N° Cont: P049616604139M';
  String rccmNumber = '';

  List<InvoiceHeaderLine> invoiceHeaderLines = [
    InvoiceHeaderLine(id: 'line_1', label: 'Activité', value: 'VENTE DE MATELAS, LITS, MOUSSES, MEUBLES ET ACCESSOIRES MENAGERS'),
    InvoiceHeaderLine(id: 'line_2', label: 'Localisation', value: 'Situé à FOURGEROLE ( Face Tradex avant le Petit Marché)'),
    InvoiceHeaderLine(id: 'line_3', label: 'Téléphone', value: 'Tél: +237 689 39 88 07'),
    InvoiceHeaderLine(id: 'line_4', label: 'N° Contribuable', value: 'N° Cont: P049616604139M'),
  ];

  // Signature personnalisée de la caisse apposée sur les factures
  String invoiceSignatureText = 'Bricelo';
  int invoiceSignatureStyle = 0; // 0: Bouclé classique, 1: Vague moderne, 2: Double paraphe

  // --- Boutique Active & Liste des Boutiques ---
  bool isBossMode = true;
  String currentStore = 'Boutique Principale';
  List<String> availableStores = [];
  List<StoreOutlet> outlets = [];
  List<CashDesk> cashDesks = [];

  double openingCash = 0.0;
  bool isSyncedToBricelo = true;

  // --- Données Centrales 100% Dynamiques ---
  List<CategoryItem> categories = [];
  List<Customer> customers = [];
  List<Supplier> suppliers = [];
  List<Product> products = [];
  List<CartItem> cart = [];
  List<HeldCart> heldCarts = [];
  List<Sale> sales = [];
  List<CustomerDebt> debts = [];
  List<SupplierDebt> supplierDebts = [];
  List<PurchaseOrder> purchaseOrders = [];
  List<Expense> expenses = [];
  List<StockMovement> stockMovements = [];
  List<StockTransfer> stockTransfers = [];
  List<InventorySession> inventorySessions = [];
  List<TeamMember> teamMembers = [];
  List<StockDepreciation> stockDepreciations = [];
  String stockDestockingStrategy = 'FIFO'; // 'FIFO' or 'FEFO'
  int expiryAlertDays = 30;
  List<Quote> quotes = [];

  // --- Getters d'affichage sécurisés ---
  String get language => currentLanguage;
  String get displayUserName => userName.trim().isNotEmpty ? userName.trim() : (currentLanguage == 'en' ? 'Manager' : 'Gérant');
  String get displayCompanyName => companyName.trim().isNotEmpty ? companyName.trim() : (currentLanguage == 'en' ? 'My Store' : 'Ma Boutique');

  String get userInitials {
    final name = displayUserName;
    final parts = name.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'BS';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // --- INITIALISATION & PERSISTANCE LOCALE + SUPABASE ---
  Future<void> initStorage() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(raw);
        hasSelectedLanguage = data['hasSelectedLanguage'] as bool? ?? false;
        isLoggedIn = data['isLoggedIn'] as bool? ?? false;
        currentLanguage = (data['currentLanguage'] ?? 'fr').toString();
        isDarkMode = data['isDarkMode'] as bool? ?? false;
        userName = (data['userName'] ?? '').toString();
        companyName = (data['companyName'] ?? '').toString();
        userEmail = (data['userEmail'] ?? '').toString();
        isEmailVerified = data['isEmailVerified'] as bool? ?? false;
        userPhone = (data['userPhone'] ?? '').toString();
        userRole = (data['userRole'] ?? 'Propriétaire').toString();
        subscriptionPlan = (data['subscriptionPlan'] ?? 'Gratuit').toString();
        subscriptionBilling = (data['subscriptionBilling'] ?? 'mensuel').toString();
        subscriptionStatus = (data['subscriptionStatus'] ?? 'Actif').toString();
        if (data['subscriptionExpiresAt'] != null) {
          subscriptionExpiresAt = DateTime.tryParse(data['subscriptionExpiresAt'].toString());
        }
        companyLogo = (data['companyLogo'] ?? '').toString();
        companyAddress = (data['companyAddress'] ?? 'Situé à FOURGEROLE ( Face Tradex avant le Petit Marché)').toString();
        companyActivity = (data['companyActivity'] ?? 'VENTE DE MATELAS, LITS, MOUSSES, MEUBLES ET ACCESSOIRES MENAGERS').toString();
        taxNumber = (data['taxNumber'] ?? 'N° Cont: P049616604139M').toString();
        rccmNumber = (data['rccmNumber'] ?? '').toString();

        if (data['invoiceHeaderLines'] != null) {
          final rawLines = data['invoiceHeaderLines'] as List<dynamic>;
          if (rawLines.isNotEmpty) {
            invoiceHeaderLines = rawLines
                .map((e) => InvoiceHeaderLine.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
          }
        }
        invoiceSignatureText = (data['invoiceSignatureText'] ?? 'Bricelo').toString();
        if (invoiceSignatureText.trim().isEmpty) invoiceSignatureText = 'Bricelo';
        invoiceSignatureStyle = (data['invoiceSignatureStyle'] as num?)?.toInt() ?? 0;
        currentStore = (data['currentStore'] ?? (companyName.isNotEmpty ? companyName : 'Boutique Principale')).toString();
        openingCash = (data['openingCash'] as num?)?.toDouble() ?? 0.0;

        availableStores = (data['availableStores'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList();

        outlets = (data['outlets'] as List<dynamic>? ?? [])
            .map((e) => StoreOutlet.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

        cashDesks = (data['cashDesks'] as List<dynamic>? ?? [])
            .map((e) => CashDesk.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

        if (outlets.isEmpty) {
          final defaultName = currentStore.trim().isNotEmpty
              ? currentStore.trim()
              : (companyName.trim().isNotEmpty ? companyName.trim() : 'Boutique Principale');
          currentStore = defaultName;
          outlets = [
            StoreOutlet(
              id: 'outlet_default',
              name: defaultName,
              type: 'Boutique',
              isDefault: true,
              address: '',
              phone: userPhone,
            ),
          ];
          availableStores = [defaultName];
        } else {
          availableStores = outlets.map((o) => o.name).toList();
          if (!availableStores.contains(currentStore)) {
            currentStore = outlets.first.name;
          }
        }

        // Ensure every store has its default Caisse "Caisse [Nom Boutique]"
        for (final c in cashDesks) {
          if (c.name == 'Caisse 1' || c.name.startsWith('Caisse 1')) {
            c.name = 'Caisse ${c.storeName.isNotEmpty ? c.storeName : currentStore}';
          }
        }
        for (final o in outlets) {
          final defaultCaisseName = 'Caisse ${o.name}';
          final hasCaisse = cashDesks.any((c) => c.storeName == o.name);
          if (!hasCaisse) {
            cashDesks.add(CashDesk(
              id: 'caisse_${DateTime.now().millisecondsSinceEpoch}_${o.id}',
              name: defaultCaisseName,
              storeName: o.name,
              isDefault: true,
            ));
          }
        }

        categories = (data['categories'] as List<dynamic>? ?? [])
            .map((e) => CategoryItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        customers = (data['customers'] as List<dynamic>? ?? [])
            .map((e) => Customer.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        suppliers = (data['suppliers'] as List<dynamic>? ?? [])
            .map((e) => Supplier.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        products = (data['products'] as List<dynamic>? ?? [])
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        sales = (data['sales'] as List<dynamic>? ?? [])
            .map((e) => Sale.fromJson(Map<String, dynamic>.from(e as Map)))
            .map((s) {
              if (s.paymentMethod == 'Caisse 1') {
                return Sale(
                  id: s.id,
                  ticketNumber: s.ticketNumber,
                  createdAt: s.createdAt,
                  items: s.items,
                  total: s.total,
                  discountTotal: s.discountTotal,
                  paymentMethod: 'Caisse ${s.storeName}',
                  amountReceived: s.amountReceived,
                  changeReturned: s.changeReturned,
                  customerName: s.customerName,
                  customerPhone: s.customerPhone,
                  cashierName: s.cashierName,
                  storeName: s.storeName,
                );
              }
              return s;
            })
            .toList();
        debts = (data['debts'] as List<dynamic>? ?? [])
            .map((e) => CustomerDebt.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        supplierDebts = (data['supplierDebts'] as List<dynamic>? ?? [])
            .map((e) => SupplierDebt.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        purchaseOrders = (data['purchaseOrders'] as List<dynamic>? ?? [])
            .map((e) => PurchaseOrder.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        expenses = (data['expenses'] as List<dynamic>? ?? [])
            .map((e) => Expense.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        stockMovements = (data['stockMovements'] as List<dynamic>? ?? [])
            .map((e) => StockMovement.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        stockTransfers = (data['stockTransfers'] as List<dynamic>? ?? [])
            .map((e) => StockTransfer.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        inventorySessions = (data['inventorySessions'] as List<dynamic>? ?? [])
            .map((e) => InventorySession.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        teamMembers = (data['teamMembers'] as List<dynamic>? ?? [])
            .map((e) => TeamMember.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        stockDestockingStrategy = (data['stockDestockingStrategy'] ?? 'FIFO').toString();
        expiryAlertDays = (data['expiryAlertDays'] as num?)?.toInt() ?? 30;
        stockDepreciations = (data['stockDepreciations'] as List<dynamic>? ?? [])
            .map((e) => StockDepreciation.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        quotes = (data['quotes'] as List<dynamic>? ?? [])
            .map((e) => Quote.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur chargement local: $e');
    }

    // Synchronisation asynchrone depuis Supabase si connecté
    if (isLoggedIn) {
      syncFromSupabase();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'hasSelectedLanguage': hasSelectedLanguage,
        'isLoggedIn': isLoggedIn,
        'currentLanguage': currentLanguage,
        'isDarkMode': isDarkMode,
        'userName': userName,
        'companyName': companyName,
        'userEmail': userEmail,
        'isEmailVerified': isEmailVerified,
        'userPhone': userPhone,
        'userRole': userRole,
        'subscriptionPlan': subscriptionPlan,
        'subscriptionBilling': subscriptionBilling,
        'subscriptionStatus': subscriptionStatus,
        'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
        'companyLogo': companyLogo,
        'companyAddress': companyAddress,
        'companyActivity': companyActivity,
        'taxNumber': taxNumber,
        'rccmNumber': rccmNumber,
        'invoiceHeaderLines': invoiceHeaderLines.map((e) => e.toJson()).toList(),
        'invoiceSignatureText': invoiceSignatureText,
        'invoiceSignatureStyle': invoiceSignatureStyle,
        'currentStore': currentStore,
        'availableStores': availableStores,
        'outlets': outlets.map((e) => e.toJson()).toList(),
        'cashDesks': cashDesks.map((e) => e.toJson()).toList(),
        'openingCash': openingCash,
        'categories': categories.map((e) => e.toJson()).toList(),
        'customers': customers.map((e) => e.toJson()).toList(),
        'suppliers': suppliers.map((e) => e.toJson()).toList(),
        'products': products.map((e) => e.toJson()).toList(),
        'sales': sales.map((e) => e.toJson()).toList(),
        'debts': debts.map((e) => e.toJson()).toList(),
        'supplierDebts': supplierDebts.map((e) => e.toJson()).toList(),
        'purchaseOrders': purchaseOrders.map((e) => e.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'stockMovements': stockMovements.map((e) => e.toJson()).toList(),
        'stockTransfers': stockTransfers.map((e) => e.toJson()).toList(),
        'inventorySessions': inventorySessions.map((e) => e.toJson()).toList(),
        'teamMembers': teamMembers.map((e) => e.toJson()).toList(),
        'stockDestockingStrategy': stockDestockingStrategy,
        'expiryAlertDays': expiryAlertDays,
        'stockDepreciations': stockDepreciations.map((e) => e.toJson()).toList(),
        'quotes': quotes.map((e) => e.toJson()).toList(),
      };
      await prefs.setString(_storageKey, jsonEncode(payload));
    } catch (e) {
      debugPrint('Erreur sauvegarde locale: $e');
    }
  }

  Future<void> syncFromSupabase() async {
    final sb = _supabase;
    if (sb == null) return;
    try {
      // 1. Catégories
      try {
        final rows = await sb.from('categories').select().order('created_at');
        if (rows.isNotEmpty) {
          final remoteCats = (rows as List).map((r) => CategoryItem.fromJson(Map<String, dynamic>.from(r))).toList();
          for (final rc in remoteCats) {
            if (!categories.any((c) => c.id == rc.id || c.name.toLowerCase() == rc.name.toLowerCase())) {
              categories.add(rc);
            }
          }
        }
      } catch (_) {}

      // 2. Produits
      try {
        final rows = await sb.from('products').select().order('created_at', ascending: false);
        if (rows.isNotEmpty) {
          final remoteProds = (rows as List).map((r) => Product.fromJson(Map<String, dynamic>.from(r))).toList();
          for (final rp in remoteProds) {
            final idx = products.indexWhere((p) => p.id == rp.id);
            if (idx == -1) {
              products.add(rp);
            }
          }
        }
      } catch (_) {}

      // 3. Clients
      try {
        final rows = await sb.from('customers').select().order('created_at', ascending: false);
        if (rows.isNotEmpty) {
          final remoteCusts = (rows as List).map((r) => Customer.fromJson(Map<String, dynamic>.from(r))).toList();
          for (final rc in remoteCusts) {
            if (!customers.any((c) => c.id == rc.id)) {
              customers.add(rc);
            }
          }
        }
      } catch (_) {}

      // 4. Fournisseurs
      try {
        final rows = await sb.from('suppliers').select().order('created_at', ascending: false);
        if (rows.isNotEmpty) {
          final remoteSups = (rows as List).map((r) => Supplier.fromJson(Map<String, dynamic>.from(r))).toList();
          for (final rs in remoteSups) {
            if (!suppliers.any((s) => s.id == rs.id)) {
              suppliers.add(rs);
            }
          }
        }
      } catch (_) {}

      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Info sync Supabase: $e');
    }
  }

  // --- LANGUE & THÈME ---
  void toggleDarkMode(bool val) {
    if (isDarkMode == val) return;
    isDarkMode = val;
    _saveToPrefs();
    notifyListeners();
  }

  void setLanguage(String lang) {
    currentLanguage = lang;
    hasSelectedLanguage = true;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> completeLanguageOnboarding(String lang) async {
    currentLanguage = lang;
    hasSelectedLanguage = true;
    await _saveToPrefs();
    notifyListeners();
  }

  // --- AUTHENTIFICATION & PROFIL UTILISATEUR ---
  Future<void> registerUser({
    required String fullName,
    required String shopName,
    required String phone,
    required String email,
    required String password,
  }) async {
    userName = fullName.trim();
    companyName = shopName.trim().isNotEmpty ? shopName.trim() : 'Boutique ${userName.split(' ').first}';
    userPhone = phone.trim();
    userEmail = email.trim();
    userRole = 'Propriétaire';
    currentStore = companyName;
    if (!availableStores.contains(currentStore)) {
      availableStores.insert(0, currentStore);
    }
    isLoggedIn = true;
    hasSelectedLanguage = true;

    await _saveToPrefs();
    notifyListeners();

    // Enregistrement asynchrone sur Supabase
    final sb = _supabase;
    if (sb != null) {
      () async {
        try {
          if (userEmail.isNotEmpty && password.length >= 6) {
            await sb.auth.signUp(
              email: userEmail,
              password: password,
              data: {
                'full_name': userName,
                'company_name': companyName,
                'phone': userPhone,
              },
            );
          }
        } catch (_) {}
        try {
          await sb.from('stores').upsert({
            'name': currentStore,
            'phone': userPhone,
          }, onConflict: 'name');
        } catch (_) {}
        try {
          await sb.from('user_profiles').upsert({
            'id': userPhone.isNotEmpty ? userPhone : (userEmail.isNotEmpty ? userEmail : 'user_${DateTime.now().millisecondsSinceEpoch}'),
            'full_name': userName,
            'company_name': companyName,
            'email': userEmail,
            'phone': userPhone,
            'language': currentLanguage,
          });
        } catch (_) {}
      }();
    }
  }

  Future<void> loginUser({
    required String identifier,
    required String password,
    String? fallbackName,
    String? fallbackShop,
  }) async {
    final cleanId = identifier.trim();
    final sb = _supabase;

    if (sb != null) {
      // 1. Tentative connexion Supabase Auth si email
      if (cleanId.contains('@') && password.isNotEmpty) {
        try {
          final res = await sb.auth.signInWithPassword(email: cleanId, password: password);
          final meta = res.user?.userMetadata ?? {};
          if (meta['full_name'] != null) userName = meta['full_name'].toString();
          if (meta['company_name'] != null) companyName = meta['company_name'].toString();
          if (meta['phone'] != null) userPhone = meta['phone'].toString();
          userEmail = cleanId;
        } catch (_) {}
      }

      // 2. Recherche dans user_profiles Supabase
      try {
        final rows = await sb
            .from('user_profiles')
            .select()
            .or('phone.eq.$cleanId,email.eq.$cleanId,id.eq.$cleanId')
            .limit(1);
        if ((rows as List).isNotEmpty) {
          final prof = rows.first;
          userName = (prof['full_name'] ?? userName).toString();
          companyName = (prof['company_name'] ?? companyName).toString();
          userEmail = (prof['email'] ?? userEmail).toString();
          userPhone = (prof['phone'] ?? userPhone).toString();
        }
      } catch (_) {}
    }

    // 3. Si profil local ou identifiant saisi
    if (userName.trim().isEmpty) {
      if (fallbackName != null && fallbackName.trim().isNotEmpty) {
        userName = fallbackName.trim();
      } else if (cleanId.contains('@')) {
        final localPart = cleanId.split('@').first.replaceAll(RegExp(r'[._-]'), ' ');
        userName = localPart.isNotEmpty
            ? localPart.split(' ').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ')
            : 'Gérant';
        userEmail = cleanId;
      } else {
        userName = 'Gérant';
        userPhone = cleanId;
      }
    } else {
      if (cleanId.contains('@') && userEmail.isEmpty) userEmail = cleanId;
      if (!cleanId.contains('@') && userPhone.isEmpty) userPhone = cleanId;
    }

    if (companyName.trim().isEmpty) {
      companyName = (fallbackShop != null && fallbackShop.trim().isNotEmpty)
          ? fallbackShop.trim()
          : 'Boutique $displayUserName';
    }

    currentStore = companyName;
    if (!availableStores.contains(currentStore)) {
      availableStores.insert(0, currentStore);
    }

    isLoggedIn = true;
    hasSelectedLanguage = true;
    await _saveToPrefs();
    notifyListeners();

    await syncFromSupabase();
  }

  Future<void> updateUserProfile({
    String? fullName,
    String? name,
    String? shopName,
    String? company,
    String? phone,
    String? email,
  }) async {
    fullName ??= name;
    shopName ??= company;
    if (fullName != null && fullName.trim().isNotEmpty) userName = fullName.trim();
    if (shopName != null && shopName.trim().isNotEmpty) {
      final oldStore = companyName;
      companyName = shopName.trim();
      if (currentStore == oldStore || currentStore == 'Boutique Principale') {
        currentStore = companyName;
      }
      if (!availableStores.contains(companyName)) {
        availableStores.insert(0, companyName);
      }
    }
    if (phone != null) userPhone = phone.trim();
    if (email != null) userEmail = email.trim();

    await _saveToPrefs();
    notifyListeners();

    final sb = _supabase;
    if (sb != null) {
      try {
        await sb.from('user_profiles').upsert({
          'id': userPhone.isNotEmpty ? userPhone : (userEmail.isNotEmpty ? userEmail : 'user_default'),
          'full_name': userName,
          'company_name': companyName,
          'email': userEmail,
          'phone': userPhone,
          'language': currentLanguage,
        });
      } catch (_) {}
    }
  }

  Future<void> logout() async {
    isLoggedIn = false;
    await _saveToPrefs();
    try {
      await _supabase?.auth.signOut();
    } catch (_) {}
    notifyListeners();
  }

  // --- GESTION DE L'ÉQUIPE (100% Dynamique & Réel) ---
  List<TeamMember> get effectiveTeamMembers {
    if (teamMembers.isEmpty) {
      return [
        TeamMember(
          id: 'owner_primary',
          name: displayUserName,
          phone: userPhone.isNotEmpty ? userPhone : 'Non renseigné',
          email: userEmail.isNotEmpty ? userEmail : null,
          role: userRole.isNotEmpty ? userRole : 'Propriétaire',
          storeName: currentStore.isNotEmpty ? currentStore : 'Toutes les boutiques',
        )
      ];
    }
    return teamMembers;
  }

  Future<void> addTeamMember({
    required String name,
    required String phone,
    String? email,
    required String role,
    String storeName = 'Toutes les boutiques',
  }) async {
    if (teamMembers.isEmpty) {
      teamMembers.add(TeamMember(
        id: 'owner_primary',
        name: displayUserName,
        phone: userPhone.isNotEmpty ? userPhone : 'Non renseigné',
        email: userEmail.isNotEmpty ? userEmail : null,
        role: userRole.isNotEmpty ? userRole : 'Propriétaire',
        storeName: currentStore.isNotEmpty ? currentStore : 'Toutes les boutiques',
      ));
    }
    final member = TeamMember(
      id: 'tm_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      phone: phone.trim(),
      email: email?.trim().isNotEmpty == true ? email!.trim() : null,
      role: role,
      storeName: storeName,
    );
    teamMembers.add(member);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> updateTeamMember({
    required String id,
    required String name,
    required String phone,
    String? email,
    required String role,
    required String storeName,
  }) async {
    final idx = teamMembers.indexWhere((m) => m.id == id);
    if (idx != -1) {
      teamMembers[idx].name = name.trim();
      teamMembers[idx].phone = phone.trim();
      teamMembers[idx].email = email?.trim().isNotEmpty == true ? email!.trim() : null;
      teamMembers[idx].role = role;
      teamMembers[idx].storeName = storeName;
      notifyListeners();
      await _saveToPrefs();
    }
  }

  Future<void> removeTeamMember(String id) async {
    teamMembers.removeWhere((m) => m.id == id);
    notifyListeners();
    await _saveToPrefs();
  }

  // --- GESTION DU PROFIL ENTREPRISE & FACTURATION ---
  Future<void> updateCompanyProfile({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? activity,
    String? taxNo,
    String? rccmNo,
    String? logoBase64,
  }) async {
    if (name != null && name.isNotEmpty) companyName = name.trim();
    if (phone != null) userPhone = phone.trim();
    if (email != null) userEmail = email.trim();
    if (address != null) companyAddress = address.trim();
    if (activity != null) companyActivity = activity.trim();
    if (taxNo != null) taxNumber = taxNo.trim();
    if (rccmNo != null) rccmNumber = rccmNo.trim();
    if (logoBase64 != null) companyLogo = logoBase64;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> setEmailVerified(bool verified) async {
    isEmailVerified = verified;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> updateCompanyLogo(String base64) async {
    companyLogo = base64;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> updateSubscription({
    required String plan,
    required String billing,
    int durationMonths = 1,
  }) async {
    subscriptionPlan = plan;
    subscriptionBilling = billing;
    subscriptionStatus = 'Actif';
    subscriptionExpiresAt = plan == 'Gratuit'
        ? null
        : DateTime.now().add(Duration(days: durationMonths * 30));
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> saveInvoiceHeaderLines(List<InvoiceHeaderLine> lines) async {
    invoiceHeaderLines = List.from(lines);
    notifyListeners();
    await _saveToPrefs();
  }

  void resetInvoiceHeaderLinesToDefault() {
    invoiceHeaderLines = [
      InvoiceHeaderLine(id: 'line_1', label: 'Activité', value: companyActivity.isNotEmpty ? companyActivity : 'VENTE DE MATELAS, LITS, MOUSSES, MEUBLES ET ACCESSOIRES MENAGERS'),
      InvoiceHeaderLine(id: 'line_2', label: 'Localisation', value: companyAddress.isNotEmpty ? companyAddress : 'Situé à FOURGEROLE ( Face Tradex avant le Petit Marché)'),
      InvoiceHeaderLine(id: 'line_3', label: 'Téléphone', value: userPhone.isNotEmpty ? 'Tél: $userPhone' : 'Tél: +237 689 39 88 07'),
      InvoiceHeaderLine(id: 'line_4', label: 'N° Contribuable', value: taxNumber.isNotEmpty ? taxNumber : 'N° Cont: P049616604139M'),
    ];
    notifyListeners();
    _saveToPrefs();
  }

  // --- GESTION DE LA SIGNATURE DE CAISSE SUR LES FACTURES ---
  Future<void> updateInvoiceSignature({
    required String text,
    int? style,
  }) async {
    invoiceSignatureText = text.trim().isNotEmpty ? text.trim() : 'Bricelo';
    if (style != null) {
      invoiceSignatureStyle = style;
    }
    notifyListeners();
    await _saveToPrefs();
  }

  void resetInvoiceSignature() {
    invoiceSignatureText = 'Bricelo';
    invoiceSignatureStyle = 0;
    notifyListeners();
    _saveToPrefs();
  }

  String getInvoiceSignatureSvg({String? colorHex}) {
    return InvoiceSignatureHelper.generateSvg(
      text: invoiceSignatureText,
      styleIndex: invoiceSignatureStyle,
      colorHex: colorHex ?? '#1E3A8A',
    );
  }

  String generateNextInvoiceNumber() {
    int maxNum = 0;
    final regex = RegExp(r'(\d+)');
    for (final s in sales) {
      final matches = regex.allMatches(s.ticketNumber);
      if (matches.isNotEmpty) {
        final last = int.tryParse(matches.last.group(0) ?? '') ?? 0;
        if (last > maxNum) maxNum = last;
      }
    }
    if (maxNum == 0) {
      maxNum = sales.isNotEmpty ? sales.length : 650;
    }
    final next = maxNum + 1;
    return next.toString().padLeft(5, '0');
  }

  // --- GESTION DYNAMIQUE DES CATÉGORIES ---
  void addCategory(CategoryItem cat) {
    if (categories.any((c) => c.name.toLowerCase() == cat.name.toLowerCase())) return;
    categories.add(cat);
    _saveToPrefs();
    notifyListeners();

    final sb = _supabase;
    if (sb != null) {
      sb.from('categories').upsert({
        'id': cat.id,
        'name': cat.name,
        'parent_name': cat.parent,
        'tva': cat.tva,
      }).then((_) {}, onError: (_) {});
    }
  }

  void updateCategory(CategoryItem cat) {
    final idx = categories.indexWhere((c) => c.id == cat.id);
    if (idx != -1) {
      categories[idx] = cat;
      _saveToPrefs();
      notifyListeners();
      _supabase?.from('categories').upsert({
        'id': cat.id,
        'name': cat.name,
        'parent_name': cat.parent,
        'tva': cat.tva,
      }).then((_) {}, onError: (_) {});
    }
  }

  void removeCategory(String id) {
    categories.removeWhere((c) => c.id == id);
    _saveToPrefs();
    notifyListeners();
    _supabase?.from('categories').delete().eq('id', id).then((_) {}, onError: (_) {});
  }

  // --- GESTION DYNAMIQUE DES BOUTIQUES ---
  void addStore(String name, {String type = 'Boutique', String address = ''}) {
    final clean = name.trim();
    if (clean.isEmpty) return;
    if (!availableStores.contains(clean)) {
      availableStores.add(clean);
    }
    currentStore = clean;
    _saveToPrefs();
    notifyListeners();

    _supabase?.from('stores').upsert({
      'name': clean,
      'address': address,
      'phone': userPhone,
    }, onConflict: 'name').then((_) {}, onError: (_) {});
  }

  void removeStore(String name) {
    if (availableStores.length <= 1) return;
    availableStores.remove(name);
    if (currentStore == name) {
      currentStore = availableStores.first;
    }
    _saveToPrefs();
    notifyListeners();
  }

  
  // --- GESTION DYNAMIQUE DES BOUTIQUES & CAISSES (100% PERSISTANT) ---
  List<CashDesk> cashDesksForStore(String storeName) {
    return cashDesks.where((c) => c.storeName.trim().toLowerCase() == storeName.trim().toLowerCase()).toList();
  }

  Future<void> addOutlet({
    required String name,
    String type = 'Boutique',
    String address = '',
    String phone = '',
    double discount = 0.0,
    bool isDefault = false,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    if (isDefault) {
      for (final o in outlets) {
        o.isDefault = false;
      }
    }

    final outlet = StoreOutlet(
      id: 'outlet_${DateTime.now().millisecondsSinceEpoch}',
      name: cleanName,
      type: type,
      isDefault: isDefault || outlets.isEmpty,
      address: address.trim(),
      phone: phone.trim(),
      discount: discount,
    );

    outlets.add(outlet);
    if (!availableStores.contains(cleanName)) {
      availableStores.add(cleanName);
    }

    // Création automatique de la caisse par défaut : "Caisse [Nom Boutique]"
    final defaultCaisseName = 'Caisse $cleanName';
    final hasCaisse = cashDesks.any((c) => c.name == defaultCaisseName && c.storeName == cleanName);
    if (!hasCaisse) {
      cashDesks.add(CashDesk(
        id: 'caisse_${DateTime.now().millisecondsSinceEpoch}',
        name: defaultCaisseName,
        storeName: cleanName,
        isDefault: true,
      ));
    }

    if (outlet.isDefault) {
      currentStore = cleanName;
    }

    await _saveToPrefs();
    notifyListeners();

    _supabase?.from('stores').upsert({
      'name': cleanName,
      'address': address,
      'phone': phone.isNotEmpty ? phone : userPhone,
    }, onConflict: 'name').then((_) {}, onError: (_) {});
  }

  Future<void> updateOutlet(
    String id, {
    required String name,
    String type = 'Boutique',
    String address = '',
    String phone = '',
    double discount = 0.0,
    bool isDefault = false,
  }) async {
    final idx = outlets.indexWhere((o) => o.id == id);
    if (idx == -1) return;

    final oldName = outlets[idx].name;
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    if (isDefault) {
      for (final o in outlets) {
        o.isDefault = false;
      }
    }

    outlets[idx].name = cleanName;
    outlets[idx].type = type;
    outlets[idx].address = address.trim();
    outlets[idx].phone = phone.trim();
    outlets[idx].discount = discount;
    if (isDefault) outlets[idx].isDefault = true;

    // Si le nom a changé, mettre à jour availableStores et les caisses rattachées
    if (oldName != cleanName) {
      final aIdx = availableStores.indexOf(oldName);
      if (aIdx != -1) {
        availableStores[aIdx] = cleanName;
      } else if (!availableStores.contains(cleanName)) {
        availableStores.add(cleanName);
      }
      if (currentStore == oldName) {
        currentStore = cleanName;
      }
      for (final c in cashDesks) {
        if (c.storeName == oldName) {
          c.storeName = cleanName;
          if (c.name.startsWith('Caisse $oldName')) {
            c.name = 'Caisse $cleanName';
          }
        }
      }
      for (final p in products) {
        if (p.stockByStore.containsKey(oldName)) {
          final s = p.stockByStore.remove(oldName)!;
          p.stockByStore[cleanName] = s;
        }
      }
    }

    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> deleteOutlet(String id) async {
    if (outlets.length <= 1) return; // Impossible de supprimer la seule boutique
    final idx = outlets.indexWhere((o) => o.id == id);
    if (idx == -1) return;

    final removedName = outlets[idx].name;
    outlets.removeAt(idx);
    availableStores.remove(removedName);
    cashDesks.removeWhere((c) => c.storeName == removedName);

    if (currentStore == removedName) {
      currentStore = outlets.first.name;
    }

    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> addCashDesk({
    required String name,
    required String storeName,
    bool isDefault = false,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty) return;

    if (isDefault) {
      for (final c in cashDesks) {
        if (c.storeName == storeName) c.isDefault = false;
      }
    }

    cashDesks.add(CashDesk(
      id: 'caisse_${DateTime.now().millisecondsSinceEpoch}',
      name: clean,
      storeName: storeName,
      isDefault: isDefault,
    ));

    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateCashDesk(String id, String newName) async {
    final idx = cashDesks.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    final clean = newName.trim();
    if (clean.isEmpty) return;
    cashDesks[idx].name = clean;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> deleteCashDesk(String id) async {
    final idx = cashDesks.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    final desk = cashDesks[idx];
    final count = cashDesks.where((c) => c.storeName == desk.storeName).length;
    if (count <= 1) return; // Garder au moins 1 caisse par boutique
    cashDesks.removeAt(idx);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> setCashDeskInitialBalance(String id, double initialBalance, {String? reason}) async {
    final idx = cashDesks.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    cashDesks[idx].balance = initialBalance;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> adjustCashDeskBalance(String id, double countedBalance, {required String reason}) async {
    final idx = cashDesks.indexWhere((c) => c.id == id);
    if (idx == -1) return;
    cashDesks[idx].balance = countedBalance;
    await _saveToPrefs();
    notifyListeners();
  }

  // --- GESTION DYNAMIQUE DES CLIENTS ---
  void addCustomer(Customer customer) {
    customers.insert(0, customer);
    _saveToPrefs();
    notifyListeners();

    _supabase?.from('customers').upsert({
      'id': customer.id,
      'name': customer.name,
      'phone': customer.phone,
      'email': customer.email,
      'address': customer.address,
    }).then((_) {}, onError: (_) {});
  }

  void updateCustomer(Customer customer) {
    final index = customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      customers[index] = customer;
      _saveToPrefs();
      notifyListeners();

      _supabase?.from('customers').upsert({
        'id': customer.id,
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'address': customer.address,
      }).then((_) {}, onError: (_) {});
    }
  }

  void removeCustomer(String id) {
    customers.removeWhere((c) => c.id == id);
    _saveToPrefs();
    notifyListeners();
    _supabase?.from('customers').delete().eq('id', id).then((_) {}, onError: (_) {});
  }

  // --- GESTION DYNAMIQUE DES FOURNISSEURS ---
  void addSupplier(Supplier supplier) {
    suppliers.insert(0, supplier);
    _saveToPrefs();
    notifyListeners();

    _supabase?.from('suppliers').upsert({
      'id': supplier.id,
      'name': supplier.name,
      'phone': supplier.phone,
      'email': supplier.email,
      'category': supplier.contactName,
      'address': supplier.address,
    }).then((_) {}, onError: (_) {});
  }

  void updateSupplier(Supplier supplier) {
    final index = suppliers.indexWhere((s) => s.id == supplier.id);
    if (index != -1) {
      suppliers[index] = supplier;
      _saveToPrefs();
      notifyListeners();

      _supabase?.from('suppliers').upsert({
        'id': supplier.id,
        'name': supplier.name,
        'phone': supplier.phone,
        'email': supplier.email,
        'category': supplier.contactName,
        'address': supplier.address,
      }).then((_) {}, onError: (_) {});
    }
  }

  void removeSupplier(String id) {
    suppliers.removeWhere((s) => s.id == id);
    _saveToPrefs();
    notifyListeners();
    _supabase?.from('suppliers').delete().eq('id', id).then((_) {}, onError: (_) {});
  }

  void resetAllData() {
    categories.clear();
    customers.clear();
    suppliers.clear();
    products.clear();
    sales.clear();
    debts.clear();
    supplierDebts.clear();
    purchaseOrders.clear();
    expenses.clear();
    stockMovements.clear();
    cart.clear();
    heldCarts.clear();
    _saveToPrefs();
    notifyListeners();
  }

  // --- GETTERS STATISTIQUES ---
  double get cartSubtotal => cart.fold(0.0, (sum, item) => sum + item.subtotal);
  double get cartTotal => cart.fold(0.0, (sum, item) => sum + item.total);
  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);

  int get todaySalesCount => sales.length;
  double get todayRevenue => sales.fold(0.0, (sum, sale) => sum + sale.total);

  double get todayGrossMargin {
    double totalMargin = 0;
    for (var sale in sales) {
      for (var item in sale.items) {
        final p = products.firstWhere(
          (prod) => prod.name == item.productName,
          orElse: () => Product(
            id: '',
            name: item.productName,
            category: '',
            barcode: '',
            buyPrice: item.unitPrice * 0.7,
            sellPrice: item.unitPrice,
            stock: 0,
          ),
        );
        totalMargin += (item.unitPrice - p.buyPrice) * item.quantity;
      }
    }
    return totalMargin;
  }

  double get todayExpensesTotal => expenses.fold(0.0, (sum, exp) => sum + exp.amount);
  double get todayNetProfit => todayGrossMargin - todayExpensesTotal;

  double get totalCustomerDebt => debts.where((d) => !d.isSettled).fold(0.0, (sum, d) => sum + d.remainingDebt);
  double get totalSupplierDebt => supplierDebts.where((d) => !d.isSettled).fold(0.0, (sum, d) => sum + d.remainingDebt);

  double get cashInDrawerExpected {
    final cashSales = sales.where((s) => s.paymentMethod == 'Espèces').fold(0.0, (sum, s) => sum + s.total);
    double debtCash = 0;
    for (var d in debts) {
      for (var p in d.payments) {
        if (p.paymentMethod == 'Espèces') {
          debtCash += p.amount;
        }
      }
    }
    return openingCash + cashSales + debtCash - todayExpensesTotal;
  }

  double get currentCashInDrawer {
    final currentDesk = cashDesks.firstWhereOrNull((c) =>
        c.storeName.trim().toLowerCase() == currentStore.trim().toLowerCase() ||
        c.name.trim().toLowerCase() == 'caisse ${currentStore.trim().toLowerCase()}' ||
        c.name.trim().toLowerCase() == currentStore.trim().toLowerCase());
    if (currentDesk != null) return currentDesk.balance;
    if (cashDesks.isNotEmpty) return cashDesks.first.balance;
    return cashInDrawerExpected;
  }

  List<Product> get lowStockProducts => products.where((p) => p.isLowStock).toList();
  int get lowStockCount => products.where((p) => p.isLowStock).length;
  int get outOfStockCount => products.where((p) => p.isOutOfStock).length;

  int getAvailableStockForProduct(Product product) {
    if (product.productType == 'Service') return 999999;
    if (currentStore == 'Toutes' || currentStore == 'Tous') {
      return product.stock;
    }
    final sStock = product.stockForStore(currentStore);
    return sStock < product.stock ? sStock : product.stock;
  }

  // --- ACTIONS PANIER ---
  bool addToCart(Product product, {bool wholesale = false}) {
    final isPhysical = product.productType != 'Service';
    final maxAvailable = getAvailableStockForProduct(product);

    final index = cart.indexWhere((item) => item.product.id == product.id && item.isWholesale == wholesale);
    if (index >= 0) {
      if (isPhysical && cart[index].quantity >= maxAvailable) {
        return false;
      }
      cart[index].quantity += 1;
    } else {
      if (isPhysical && maxAvailable <= 0) {
        return false;
      }
      cart.add(CartItem(
        product: product,
        quantity: 1,
        unitPrice: wholesale ? product.wholesalePrice : product.sellPrice,
        isWholesale: wholesale,
      ));
    }
    notifyListeners();
    return true;
  }

  void removeFromCart(CartItem item) {
    cart.remove(item);
    notifyListeners();
  }

  bool updateCartQuantity(CartItem item, int delta) {
    final isPhysical = item.product.productType != 'Service';
    final maxAvailable = getAvailableStockForProduct(item.product);
    final newQty = item.quantity + delta;
    if (newQty <= 0) {
      cart.remove(item);
    } else {
      if (isPhysical && delta > 0 && newQty > maxAvailable) {
        return false;
      }
      item.quantity = newQty;
    }
    notifyListeners();
    return true;
  }

  void toggleCartItemGift(CartItem item) {
    item.isGift = !item.isGift;
    if (item.isGift) {
      item.discount = 0.0;
    }
    notifyListeners();
  }

  void toggleCartItemWholesale(CartItem item) {
    item.isWholesale = !item.isWholesale;
    item.unitPrice = item.isWholesale ? item.product.wholesalePrice : item.product.sellPrice;
    notifyListeners();
  }

  void setCartItemDiscount(CartItem item, double discount) {
    final maxAllowed = (item.unitPrice / 2) * item.quantity;
    item.discount = discount.clamp(0.0, maxAllowed);
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  // --- PANIERS EN ATTENTE (Hold Cart) ---
  void holdCurrentCart({String customerName = 'Client en attente'}) {
    if (cart.isEmpty) return;
    heldCarts.add(HeldCart(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'Panier #${heldCarts.length + 1}',
      createdAt: DateTime.now(),
      items: List.from(cart),
      customerName: customerName,
    ));
    cart.clear();
    notifyListeners();
  }

  void resumeHeldCart(HeldCart held) {
    cart = List.from(held.items);
    heldCarts.remove(held);
    notifyListeners();
  }

  void discardHeldCart(HeldCart held) {
    heldCarts.remove(held);
    notifyListeners();
  }

  // --- FINALISATION DE VENTE (POS Checkout) + SYNC SUPABASE ---
  Sale finalizeSale({
    required String paymentMethod,
    required double amountReceived,
    double changeReturned = 0,
    String customerName = 'Client Comptoir',
    String customerPhone = '',
    String? cashierName,
    double? overrideTotal,
    double? globalDiscount,
    DateTime? saleDate,
  }) {
    // Règle stricte : la date de la vente est obligatoirement celle du jour
    final now = DateTime.now();
    final yyyy = now.year.toString();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final nextInvoiceNum = generateNextInvoiceNumber();
    final seqVal = int.tryParse(nextInvoiceNum) ?? 1;
    final seq4 = seqVal.toString().padLeft(4, '0');
    final ticketNumber = 'BS-VTE-$yyyy$mm$dd-$seq4';
    final itemsSummary = cart
        .map((item) => SaleItemSummary(
              productName: item.product.name,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              total: item.total,
              isGift: item.isGift,
              buyPrice: item.product.buyPrice,
            ))
        .toList();

    final effectiveCashier = (cashierName != null && cashierName.trim().isNotEmpty)
        ? cashierName.trim()
        : displayUserName;

    final effectiveTotal = overrideTotal ?? ((cartTotal - (globalDiscount ?? 0.0)).clamp(0.0, double.infinity));
    final effectiveDiscountTotal = cart.fold(0.0, (sum, i) => sum + i.discount) + (globalDiscount ?? 0.0);

    final storeForSale = (currentStore == 'Toutes' || currentStore == 'Tous') ? 'Boutique principale' : currentStore;
    final effectivePayment = (paymentMethod == 'Caisse 1' || paymentMethod.startsWith('Caisse 1') || paymentMethod == 'Caisse')
        ? 'Caisse $storeForSale'
        : paymentMethod;

    final sale = Sale(
      id: 'sale_${now.millisecondsSinceEpoch}',
      ticketNumber: ticketNumber,
      createdAt: now,
      items: itemsSummary,
      total: effectiveTotal,
      discountTotal: effectiveDiscountTotal,
      paymentMethod: effectivePayment,
      amountReceived: amountReceived,
      changeReturned: changeReturned,
      customerName: customerName.trim().isEmpty ? 'Client Comptoir' : customerName.trim(),
      customerPhone: customerPhone,
      cashierName: effectiveCashier,
      storeName: storeForSale,
    );

    final sb = _supabase;

    // Décrémenter le stock des produits par boutique et globalement
    for (var item in cart) {
      final pIdx = products.indexWhere((prod) => prod.id == item.product.id);
      if (pIdx != -1) {
        final p = products[pIdx];
        if (p.productType != 'Service') {
          final curStoreStock = p.stockForStore(storeForSale);
          p.setStockForStore(storeForSale, (curStoreStock - item.quantity).clamp(0, 9999999));
        }

        final sm = StockMovement(
          id: 'sm_${DateTime.now().millisecondsSinceEpoch}_${p.id}',
          productId: p.id,
          productName: p.name,
          type: 'VENTE (-)',
          quantity: item.quantity,
          newStock: p.stock,
          reason: 'Ticket #$ticketNumber',
          date: now,
        );
        stockMovements.insert(0, sm);

        if (sb != null) {
          sb.from('products').update({'stock': p.stock}).eq('id', p.id).then((_) {}, onError: (_) {});
          sb.from('stock_movements').upsert({
            'id': sm.id,
            'product_name': sm.productName,
            'movement_type': sm.type,
            'quantity': sm.quantity,
            'reason': sm.reason,
            'author': effectiveCashier,
          }).then((_) {}, onError: (_) {});
        }
      }
    }

    // Créditer la caisse de la boutique qui a réalisé la vente (hors vente à crédit)
    if (paymentMethod != 'À Crédit') {
      final targetCaisseName = 'Caisse $storeForSale';
      final caisse = cashDesks.firstWhereOrNull((c) =>
          c.storeName.trim().toLowerCase() == storeForSale.trim().toLowerCase() ||
          c.name.trim().toLowerCase() == targetCaisseName.toLowerCase()) ??
          cashDesks.firstOrNull;
      if (caisse != null) {
        caisse.balance += effectiveTotal;
      }
    }

    // Si vente à crédit, enregistrer dans le cahier de dettes
    if (paymentMethod == 'À Crédit') {
      final debt = CustomerDebt(
        id: 'debt_${now.millisecondsSinceEpoch}',
        customerName: customerName.trim().isEmpty ? 'Client Comptoir' : customerName.trim(),
        customerPhone: customerPhone,
        initialDebt: cartTotal,
        paidAmount: amountReceived > 0 ? amountReceived : 0,
        createdAt: now,
        lastPaymentDate: now,
        itemsSummary: itemsSummary.map((i) => '${i.quantity}x ${i.productName}').toList(),
        payments: amountReceived > 0
            ? [
                DebtPayment(
                  id: 'dp_${now.millisecondsSinceEpoch}',
                  amount: amountReceived,
                  date: now,
                  paymentMethod: 'Espèces',
                  note: 'Acompte initial à la vente',
                ),
              ]
            : [],
      );
      debts.insert(0, debt);

      if (sb != null) {
        sb.from('customer_debts').upsert({
          'id': debt.id,
          'customer_name': debt.customerName,
          'phone': debt.customerPhone,
          'total_debt': debt.initialDebt,
          'remaining_amount': debt.remainingDebt,
          'store_name': currentStore,
        }).then((_) {}, onError: (_) {});
      }
    }

    sales.insert(0, sale);
    cart.clear();
    _saveToPrefs();
    notifyListeners();

    // Sauvegarde asynchrone de la vente sur Supabase
    if (sb != null) {
      () async {
        try {
          await sb.from('sales').upsert({
            'id': sale.ticketNumber,
            'sale_date': sale.createdAt.toIso8601String(),
            'total_amount': sale.total,
            'amount_received': sale.amountReceived,
            'change_returned': sale.changeReturned,
            'payment_method': sale.paymentMethod,
            'status': sale.paymentMethod == 'À Crédit' ? 'CREDIT' : 'COMPLETED',
            'customer_name': sale.customerName,
            'cashier_name': sale.cashierName,
            'store_name': sale.storeName,
          });
          for (final it in sale.items) {
            await sb.from('sale_items').insert({
              'sale_id': sale.ticketNumber,
              'product_name': it.productName,
              'quantity': it.quantity,
              'unit_price': it.unitPrice,
            });
          }
        } catch (_) {}
      }();
    }

    return sale;
  }

  void cancelSale(Sale sale) {
    sales.removeWhere((s) => s.id == sale.id || s.ticketNumber == sale.ticketNumber);
    for (final item in sale.items) {
      final pIdx = products.indexWhere((p) => p.name.toLowerCase() == item.productName.toLowerCase());
      if (pIdx != -1) {
        products[pIdx].stock += item.quantity;
        stockMovements.insert(
          0,
          StockMovement(
            id: 'sm_cancel_${DateTime.now().millisecondsSinceEpoch}_${products[pIdx].id}',
            productId: products[pIdx].id,
            productName: products[pIdx].name,
            type: 'RETOUR (+)',
            quantity: item.quantity,
            newStock: products[pIdx].stock,
            reason: 'Annulation vente ${sale.ticketNumber}',
            date: DateTime.now(),
          ),
        );
      }
    }
    if (sale.paymentMethod == 'À Crédit') {
      debts.removeWhere((d) => d.customerName == sale.customerName && d.initialDebt == sale.total);
    }
    _saveToPrefs();
    notifyListeners();
  }

  // --- ACTIONS DETTES CLIENTS ---
  void recordCustomerDebtPayment(String debtId, double amount, String method, {String note = 'Versement'}) {
    final idx = debts.indexWhere((d) => d.id == debtId);
    if (idx == -1) return;
    final debt = debts[idx];
    debt.paidAmount += amount;
    debt.lastPaymentDate = DateTime.now();
    debt.payments.insert(
      0,
      DebtPayment(
        id: 'dp_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        date: DateTime.now(),
        paymentMethod: method,
        note: note,
      ),
    );
    _saveToPrefs();
    notifyListeners();

    _supabase?.from('customer_debts').update({
      'remaining_amount': debt.remainingDebt,
      'last_activity': DateTime.now().toIso8601String(),
    }).eq('id', debt.id).then((_) {}, onError: (_) {});
  }

  void addManualDebt({
    required String customerName,
    required String customerPhone,
    required String customerCity,
    required double amount,
    required String description,
  }) {
    final now = DateTime.now();
    final debt = CustomerDebt(
      id: 'debt_${now.millisecondsSinceEpoch}',
      customerName: customerName,
      customerPhone: customerPhone,
      customerCity: customerCity,
      initialDebt: amount,
      paidAmount: 0,
      createdAt: now,
      lastPaymentDate: now,
      itemsSummary: [description],
    );
    debts.insert(0, debt);
    _saveToPrefs();
    notifyListeners();

    _supabase?.from('customer_debts').upsert({
      'id': debt.id,
      'customer_name': debt.customerName,
      'phone': debt.customerPhone,
      'total_debt': debt.initialDebt,
      'remaining_amount': debt.remainingDebt,
      'store_name': currentStore,
    }).then((_) {}, onError: (_) {});
  }

  void addCustomerDebt(CustomerDebt debt) {
    debts.insert(0, debt);
    _saveToPrefs();
    notifyListeners();
  }

  // --- ACTIONS DETTES FOURNISSEURS ---
  void addSupplierDebt(SupplierDebt debt) {
    supplierDebts.insert(0, debt);
    _saveToPrefs();
    notifyListeners();
  }

  void recordSupplierPayment(
    String debtId,
    double amount, {
    String? paymentMethod,
    DateTime? paymentDate,
    String note = '',
  }) {
    final idx = supplierDebts.indexWhere((d) => d.id == debtId);
    if (idx != -1) {
      supplierDebts[idx].paidAmount += amount;
      final now = paymentDate ?? DateTime.now();
      final yyyy = now.year.toString();
      final mm = now.month.toString().padLeft(2, '0');
      final dd = now.day.toString().padLeft(2, '0');
      final seq = (supplierDebts[idx].payments.length + 1).toString().padLeft(4, '0');
      final ref = 'BS-REG-$yyyy$mm$dd-$seq';
      final pm = (paymentMethod != null && paymentMethod.isNotEmpty)
          ? (paymentMethod.startsWith('Caisse') ? paymentMethod : paymentMethod)
          : 'Caisse $currentStore';

      supplierDebts[idx].payments.insert(
        0,
        DebtPayment(
          id: ref,
          amount: amount,
          date: now,
          paymentMethod: pm,
          note: note.isNotEmpty ? note : 'Règlement facture ${supplierDebts[idx].invoiceRef}',
        ),
      );

      // Déduire immédiatement de la caisse concernée
      final desk = cashDesks.firstWhereOrNull((c) =>
          c.name.trim().toLowerCase() == pm.trim().toLowerCase() ||
          'caisse ${c.storeName.trim().toLowerCase()}' == pm.trim().toLowerCase() ||
          c.storeName.trim().toLowerCase() == currentStore.trim().toLowerCase()) ?? cashDesks.firstOrNull;
      if (desk != null) {
        desk.balance = (desk.balance - amount).clamp(0.0, double.infinity);
      }

      _saveToPrefs();
      notifyListeners();
    }
  }

  // --- ACTIONS BONS D'ACHAT & COMMANDES FOURNISSEUR ---
  void addPurchaseOrder(PurchaseOrder po) {
    purchaseOrders.insert(0, po);
    _saveToPrefs();
    notifyListeners();
  }

  void updatePurchaseOrder(PurchaseOrder po) {
    final idx = purchaseOrders.indexWhere((p) => p.id == po.id);
    if (idx != -1) {
      purchaseOrders[idx] = po;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void deletePurchaseOrder(String id) {
    purchaseOrders.removeWhere((p) => p.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  // --- ACTIONS DÉPENSES ---
  final Map<String, double> lastExpenseAmountByCategory = {};

  double getLastExpenseAmount(String category) {
    if (lastExpenseAmountByCategory.containsKey(category)) {
      return lastExpenseAmountByCategory[category]!;
    }
    final match = expenses.firstWhereOrNull((e) => e.category.toLowerCase() == category.toLowerCase());
    return match?.amount ?? 0.0;
  }

  void addExpense({
    required String category,
    required String description,
    required double amount,
    String? paidBy,
    String? paidFromCaisse,
    String? reference,
    DateTime? createdAt,
  }) {
    final expDate = createdAt ?? DateTime.now();
    final effectiveCaisse = (paidFromCaisse != null && paidFromCaisse.isNotEmpty)
        ? paidFromCaisse
        : 'Caisse $currentStore';

    final exp = Expense(
      id: 'e_${expDate.millisecondsSinceEpoch}',
      category: category,
      description: description,
      amount: amount,
      createdAt: expDate,
      paidBy: paidBy ?? displayUserName,
      paidFromCaisse: effectiveCaisse,
      reference: reference,
    );
    expenses.insert(0, exp);
    lastExpenseAmountByCategory[category] = amount;

    // Déduire de la caisse correspondante
    final caisse = cashDesks.firstWhereOrNull((c) =>
        c.name.toLowerCase() == effectiveCaisse.toLowerCase() ||
        c.storeName.toLowerCase() == currentStore.toLowerCase()) ?? cashDesks.firstOrNull;
    if (caisse != null) {
      caisse.balance -= amount;
    }

    _saveToPrefs();
    notifyListeners();

    _supabase?.from('expenses').upsert({
      'id': exp.id,
      'title': exp.description,
      'category': exp.category,
      'amount': exp.amount,
      'beneficiary': exp.paidBy,
      'paid_from_caisse': exp.paidFromCaisse,
      'reference': exp.reference,
    }).then((_) {}, onError: (_) {});
  }

  // --- ACTIONS GESTION DE PRODUITS & STOCK ---
  void addProduct(Product product) {
    products.insert(0, product);
    if (product.category.trim().isNotEmpty &&
        product.category != 'Non catégorisé' &&
        !categories.any((c) => c.name.toLowerCase() == product.category.toLowerCase())) {
      addCategory(CategoryItem(
        id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
        name: product.category,
      ));
    }

    final sm = StockMovement(
      id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      productName: product.name,
      type: 'AJUSTEMENT',
      quantity: product.stock,
      newStock: product.stock,
      reason: 'Création du produit',
      date: DateTime.now(),
    );
    stockMovements.insert(0, sm);
    _saveToPrefs();
    notifyListeners();

    _supabase?.from('products').upsert({
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'price': product.sellPrice,
      'purchase_price': product.buyPrice,
      'stock': product.stock,
      'min_stock': product.minStockAlert,
      'barcode': product.barcode,
      'unit': product.unit,
      'product_type': product.productType,
      'store_name': currentStore,
    }).then((_) {}, onError: (_) {});
  }

  void updateProduct(Product updated) {
    final idx = products.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      products[idx] = updated;
      _saveToPrefs();
      notifyListeners();

      _supabase?.from('products').upsert({
        'id': updated.id,
        'name': updated.name,
        'category': updated.category,
        'price': updated.sellPrice,
        'purchase_price': updated.buyPrice,
        'stock': updated.stock,
        'min_stock': updated.minStockAlert,
        'barcode': updated.barcode,
        'unit': updated.unit,
        'product_type': updated.productType,
        'store_name': currentStore,
      }).then((_) {}, onError: (_) {});
    }
  }

  void removeProduct(String productId) {
    products.removeWhere((p) => p.id == productId);
    cart.removeWhere((c) => c.product.id == productId);
    _saveToPrefs();
    notifyListeners();

    _supabase?.from('products').delete().eq('id', productId).then((_) {}, onError: (_) {});
  }

  void restockProduct({
    required String productId,
    required int quantity,
    required double buyCost,
    String supplier = '',
    String? storeName,
  }) {
    final idx = products.indexWhere((prod) => prod.id == productId);
    if (idx == -1) return;
    final p = products[idx];
    final targetStore = (storeName != null && storeName.trim().isNotEmpty) ? storeName.trim() : currentStore;
    final currentStoreStock = p.stockForStore(targetStore);
    p.setStockForStore(targetStore, currentStoreStock + quantity);
    if (buyCost > 0) {
      p.buyPrice = buyCost;
    }
    final sm = StockMovement(
      id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
      productId: p.id,
      productName: p.name,
      type: 'RÉASSORT (+)',
      quantity: quantity,
      newStock: p.stockForStore(targetStore),
      reason: supplier.isNotEmpty ? 'Fournisseur: $supplier ($targetStore)' : 'Approvisionnement ($targetStore)',
      date: DateTime.now(),
    );
    stockMovements.insert(0, sm);
    _saveToPrefs();
    notifyListeners();

    _supabase?.from('products').update({
      'stock': p.stock,
      'purchase_price': p.buyPrice,
    }).eq('id', p.id).then((_) {}, onError: (_) {});
  }

  void adjustStock({
    required String productId,
    required int newStock,
    required String reason,
    String? storeName,
  }) {
    final idx = products.indexWhere((prod) => prod.id == productId);
    if (idx == -1) return;
    final p = products[idx];
    final targetStore = (storeName != null && storeName.isNotEmpty && storeName != 'Tous')
        ? storeName
        : currentStore;
    final oldStoreStock = p.stockForStore(targetStore);
    final diff = newStock - oldStoreStock;

    p.setStockForStore(targetStore, newStock);

    final sm = StockMovement(
      id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
      productId: p.id,
      productName: p.name,
      type: diff >= 0 ? 'AJUSTEMENT (+)' : 'AVARIE / PERTE (-)',
      quantity: diff.abs().round(),
      newStock: p.stockForStore(targetStore),
      reason: '$reason ($targetStore)',
      date: DateTime.now(),
    );
    stockMovements.insert(0, sm);
    _saveToPrefs();
    notifyListeners();

    _supabase?.from('products').update({'stock': p.stock}).eq('id', p.id).then((_) {}, onError: (_) {});
  }

  // --- ACTIONS TRANSFERTS DE STOCK INTER-BOUTIQUES ---
  void addStockTransfer(StockTransfer transfer) {
    stockTransfers.insert(0, transfer);

    for (final item in transfer.items) {
      final pIdx = products.indexWhere((p) => p.id == item.productId || p.name.toLowerCase() == item.productName.toLowerCase());
      if (pIdx != -1) {
        final prod = products[pIdx];
        // Déduire de la source
        final curSource = prod.stockForStore(transfer.sourceStore);
        prod.setStockForStore(transfer.sourceStore, (curSource - item.quantity).clamp(0, 9999999));

        // Ajouter à la destination
        final curDest = prod.stockForStore(transfer.destinationStore);
        prod.setStockForStore(transfer.destinationStore, curDest + item.quantity);

        // Mouvement de stock
        final sm = StockMovement(
          id: 'sm_${DateTime.now().millisecondsSinceEpoch}_${prod.id}',
          productId: prod.id,
          productName: prod.name,
          type: 'TRANSFERT',
          quantity: item.quantity,
          newStock: prod.stock,
          reason: '${transfer.reference} : ${transfer.sourceStore} -> ${transfer.destinationStore}',
          date: transfer.date,
        );
        stockMovements.insert(0, sm);
      }
    }

    _saveToPrefs();
    notifyListeners();
  }

  // --- ACTIONS INVENTAIRE PHYSIQUE ---
  void saveInventorySession(InventorySession session) {
    inventorySessions.insert(0, session);

    // Ajuster le stock de chaque produit selon le comptage réel
    for (final item in session.items) {
      final pIdx = products.indexWhere((p) => p.id == item.productId || p.name.toLowerCase() == item.productName.toLowerCase());
      if (pIdx != -1) {
        final prod = products[pIdx];
        if (item.difference != 0) {
          prod.setStockForStore(session.storeName, item.countedStock);

          final sm = StockMovement(
            id: 'sm_${DateTime.now().millisecondsSinceEpoch}_${prod.id}',
            productId: prod.id,
            productName: prod.name,
            type: item.difference > 0 ? 'INVENTAIRE (+)' : 'INVENTAIRE (-)',
            quantity: item.difference.abs(),
            newStock: prod.stockForStore(session.storeName),
            reason: '${session.reference} (${session.storeName}) ${item.discrepancyReason.isNotEmpty ? "- ${item.discrepancyReason}" : ""}',
            date: session.completedAt,
          );
          stockMovements.insert(0, sm);
        }
      }
    }

    _saveToPrefs();
    notifyListeners();
  }

  // --- GESTION DE LA DÉPRÉCIATION DE STOCK & PÉREMPTION ---
  void setStockDestockingStrategy(String strategy) {
    stockDestockingStrategy = strategy;
    _saveToPrefs();
    notifyListeners();
  }

  void setExpiryAlertDays(int days) {
    expiryAlertDays = days;
    _saveToPrefs();
    notifyListeners();
  }

  void updateProductExpiry(String productId, DateTime? expiryDate, {String? lotNumber}) {
    final idx = products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      products[idx].expiryDate = expiryDate;
      if (lotNumber != null) {
        products[idx].lotNumber = lotNumber;
      }
      _saveToPrefs();
      notifyListeners();
    }
  }

  void recordStockDepreciation({
    required String productId,
    required int quantity,
    required String reason,
    String notes = '',
    String? storeName,
  }) {
    final idx = products.indexWhere((prod) => prod.id == productId);
    if (idx == -1) return;
    final p = products[idx];
    final targetStore = (storeName != null && storeName.isNotEmpty && storeName != 'Tous')
        ? storeName
        : currentStore;
    final oldStoreStock = p.stockForStore(targetStore);
    final newStock = (oldStoreStock - quantity).clamp(0, 9999999);
    p.setStockForStore(targetStore, newStock);

    final unitCost = p.buyPrice > 0 ? p.buyPrice : (p.sellPrice * 0.7);
    final totalLoss = unitCost * quantity;

    final dep = StockDepreciation(
      id: 'dep_${DateTime.now().millisecondsSinceEpoch}',
      productId: p.id,
      productName: p.name,
      quantity: quantity,
      unitCost: unitCost,
      totalLoss: totalLoss,
      reason: reason,
      notes: notes,
      storeName: targetStore,
      date: DateTime.now(),
    );
    stockDepreciations.insert(0, dep);

    final sm = StockMovement(
      id: 'sm_${DateTime.now().millisecondsSinceEpoch}_${p.id}',
      productId: p.id,
      productName: p.name,
      type: 'DÉPRÉCIATION (-)',
      quantity: quantity,
      newStock: p.stockForStore(targetStore),
      reason: 'Dépréciation: $reason ($targetStore)${notes.isNotEmpty ? " - $notes" : ""}',
      date: DateTime.now(),
    );
    stockMovements.insert(0, sm);

    _saveToPrefs();
    notifyListeners();

    _supabase?.from('products').update({'stock': p.stock}).eq('id', p.id).then((_) {}, onError: (_) {});
  }

  // --- GESTION DES DEVIS PRO-FORMA ---
  void addQuote(Quote quote) {
    quotes.insert(0, quote);
    _saveToPrefs();
    notifyListeners();
  }

  void deleteQuote(String quoteId) {
    quotes.removeWhere((q) => q.id == quoteId);
    _saveToPrefs();
    notifyListeners();
  }

  // --- PARAMÈTRES & BOUTIQUE ---
  void switchStore(String store) {
    currentStore = store;
    _saveToPrefs();
    notifyListeners();
  }

  void setCurrentStore(String store) => switchStore(store);

  void toggleBossMode() {
    isBossMode = !isBossMode;
    notifyListeners();
  }
}
