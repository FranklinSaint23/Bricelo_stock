import 'package:stock_prime/services/app_state.dart';

class AppTranslations {
  static String get currentLanguage => AppState.instance.currentLanguage;

  static String get formattedCurrentDate {
    final now = DateTime.now();
    final isEn = currentLanguage == 'en';
    
    final daysFr = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final daysEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    final monthsFr = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    final monthsEn = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    final dayName = isEn ? daysEn[now.weekday - 1] : daysFr[now.weekday - 1];
    final monthName = isEn ? monthsEn[now.month - 1] : monthsFr[now.month - 1];
    
    if (isEn) {
      return '$dayName, $monthName ${now.day}';
    } else {
      return '$dayName ${now.day} $monthName';
    }
  }

  static const Map<String, String> _en = {
  "Accueil": "Home",
  "Vente": "Sales",
  "Produits": "Products",
  "Stock": "Inventory",
  "Plus": "More",
  "BRICELO STOCK": "BRICELO STOCK",
  "Bricelo Stock": "Bricelo Stock",
  "Gestion & Commerce": "Inventory & Commerce",
  "Connecté à Bricélo.cm": "Connected to Bricelo.cm",
  "Gérez votre stock et vos ventes": "Manage your stock and sales",
  "Mardi 27 octobre": "Tuesday, October 27",
  "Samedi 31 octobre": "Saturday, October 31",
  "Bonjour, Franklin": "Hello, Franklin",
  "Aujourd'hui": "Today",
  "ventes": "sales",
  "vente": "sale",
  "Encaissé": "Collected",
  "À recouvrer": "To Recover",
  "Ajoutez vos premiers produits pour commencer": "Add your first products to get started",
  "Configuration rapide": "Quick Setup",
  "Ajouter un produit": "Add a Product",
  "Ventes du jour": "Today's Sales",
  "Total Dettes Clients": "Customer Debts Total",
  "Nombre de ventes": "Total Transactions",
  "Bénéfice": "Profit",
  "Bénéfice estimé": "Estimated Profit",
  "Accès rapide": "Quick Access",
  "Boutique": "Store",
  "Boutiques & Entrepots": "Stores & Warehouses",
  "Boutique principale": "Main Store",
  "Boutique principale (Akwa)": "Main Store (Akwa)",
  "Point de vente": "Point of Sale",
  "Rechercher un produit...": "Search a product...",
  "Scanner code-barres activé": "Barcode scanner activated",
  "Catalogue rafraîchi": "Catalog refreshed",
  "Rien à vendre pour l’instant": "Nothing to sell for now",
  "Rien à vendre pour l'instant": "Nothing to sell for now",
  "Ajoutez un produit et son stock pour démarrer vos ventes.": "Add a product and its stock to start selling.",
  "Ajouter mon premier produit": "Add my first product",
  "Payer": "Pay",
  "Encaissement Rapide": "Quick Checkout",
  "Espèces (Cash)": "Cash",
  "Avec calcul automatique de monnaie à rendre": "With automatic change calculation",
  "Espèces": "Cash",
  "Vente enregistrée en espèces !": "Sale recorded in cash!",
  "Orange Money Cameroun": "Orange Money Cameroon",
  "Orange Money": "Orange Money",
  "Vente enregistrée Orange Money !": "Sale recorded via Orange Money!",
  "MTN Mobile Money": "MTN Mobile Money",
  "MTN MoMo": "MTN MoMo",
  "Vente enregistrée MTN MoMo !": "Sale recorded via MTN MoMo!",
  "Panier": "Cart",
  "Panier vide": "Empty Cart",
  "Paniers en attente": "Held Carts",
  "Mettre en attente": "Hold Cart",
  "Reprendre": "Resume",
  "Abandonner": "Discard",
  "Articles": "Items",
  "Total à payer": "Total to Pay",
  "Montant reçu": "Amount Received",
  "Monnaie à rendre": "Change Due",
  "Tous": "All",
  "Services": "Services",
  "Packs": "Packs",
  "Catalogue actualisé !": "Catalog updated!",
  "Rechercher un produit": "Search a product",
  "Aucun produit pour l'instant.": "No products for now.",
  "Ajoutez votre premier produit !": "Add your first product!",
  "Importer une liste (Excel / CSV)": "Import a list (Excel / CSV)",
  "Importer des produits": "Import Products",
  "Stock :": "Stock:",
  "Nouveau Produit": "New Product",
  "Modifier le produit": "Edit Product",
  "Détails du produit": "Product Details",
  "Nom du produit": "Product Name",
  "Prix de vente": "Selling Price",
  "Prix d'achat": "Purchase Price",
  "Catégorie": "Category",
  "Catégories": "Categories",
  "Code-barres": "Barcode",
  "Enregistrer le produit": "Save Product",
  "VALEUR DU STOCK": "STOCK VALUE",
  "Coût": "Cost",
  "Marge": "Margin",
  "articles": "items",
  "bas": "low",
  "rupture": "out of stock",
  "Inventaire": "Inventory",
  "Aucun stock pour cette boutique": "No stock for this store",
  "Le stock arrive de vos fournisseurs. Créez une commande pour en recevoir.": "Stock arrives from suppliers. Create an order to receive stock.",
  "Approvisionner": "Supply / Restock",
  "Ajuster le stock": "Adjust Stock",
  "Transférer entre boutiques": "Transfer Between Stores",
  "Enregistrer une perte": "Record a Loss",
  "Module d'ajustement de stock ouvert !": "Stock adjustment module opened!",
  "Module de transfert inter-boutiques ouvert !": "Inter-store transfer module opened!",
  "Ajustement": "Adjustment",
  "Transfert": "Transfer",
  "Pertes & Avaries": "Losses & Damages",
  "Fournisseurs": "Suppliers",
  "Fournisseur": "Supplier",
  "Commandes d'achat": "Purchase Orders",
  "Historique du stock": "Stock History",
  "Assistant Bricelo": "Bricelo Assistant",
  "Bricelo": "Bricelo",
  "Salut, je suis Bricelo": "Hi, I'm Bricelo",
  "Posez une question à Bricelo...": "Ask Bricelo a question...",
  "Le copilote intelligent de votre boutique Bricelo. Posez une question sur vos ventes, votre stock ou vos dettes.": "Your store's smart copilot. Ask me about your sales, inventory or debts.",
  "Combien j'ai vendu aujourd'hui ?": "How much did I sell today?",
  "Comment enregistrer une vente à crédit ?": "How to record a credit sale?",
  "Quel est mon stock bas ?": "Which items are low on stock?",
  "Termine la configuration de ma boutique": "Complete my store setup",
  "Posez vos questions à Bricelo, votre assistant intelligent": "Ask your questions to Bricelo, your smart assistant",
  "Rechercher dans le menu": "Search in menu",
  "Mon compte": "My Account",
  "Franklin Athletics": "Franklin Athletics",
  "Propriétaire": "Owner",
  "Proprietaire": "Owner",
  "Formule Gratuit": "Free Plan",
  "Changer de boutique": "Switch Store",
  "Boutiques & Dépôts": "Stores & Warehouses",
  "Dépôts & Magasins": "Warehouses & Stores",
  "Équipe & Caissiers": "Team & Cashiers",
  "Profil d'entreprise": "Company Profile",
  "Langue de l'application": "App Language",
  "Langue": "Language",
  "Français": "French",
  "Anglais": "English",
  "Paramètres": "Settings",
  "Préférences": "Preferences",
  "Sécurité": "Security",
  "Se déconnecter": "Log Out",
  "Déconnexion": "Log Out",
  "À propos de Bricelo": "About Bricelo",
  "Support & Contact WhatsApp": "Support & WhatsApp Contact",
  "Donnez votre avis": "Give Feedback",
  "Version": "Version",
  "Annonces & Mises à jour": "Announcements & Updates",
  "Dettes Clients": "Customer Debts",
  "Dettes Fournisseurs": "Supplier Debts",
  "Rapports & Statistiques": "Reports & Analytics",
  "Comptabilité": "Accounting",
  "Dépenses": "Expenses",
  "Achats": "Purchases",
  "Créer une dépense": "Create an Expense",
  "Loyer": "Rent",
  "Frais de livraison": "Delivery Fees",
  "Électricité / Eau": "Electricity / Water",
  "Transport": "Transportation",
  "Salaire": "Salary",
  "Autre": "Other",
  "Montant": "Amount",
  "Enregistrer": "Save",
  "Annuler": "Cancel",
  "Fermer": "Close",
  "Confirmer": "Confirm",
  "SUIVI": "TRACKING",
  "ADMINISTRATION": "ADMINISTRATION",
  "Historique": "History",
  "Taux de change": "Exchange Rate",
  "Caisses": "Cash Desks",
  "Statistiques": "Analytics",
  "Discussion": "Chat",
  "Objectifs": "Goals",
  "Actionnaires": "Shareholders",
  "Sites": "Outlets",
  "Unités de stock": "Stock Units",
  "Entrées de stock": "Stock Entries",
  "Réappro.": "Reorder",
  "Comptes": "Accounts",
  "Transferts": "Transfers",
  "Ajustements": "Adjustments",
  "Dettes": "Debts",
  "Pertes": "Losses",
  "Thème sombre": "Dark Mode",
  "Êtes-vous sûr de vouloir vous déconnecter ?": "Are you sure you want to log out?",
  "Déconnexion réussie": "Successfully logged out",
  "SUIVI & FINANCES": "TRACKING & FINANCE",
  "GESTION DU STOCK": "INVENTORY MANAGEMENT",
  "ADMINISTRATION & COMMERCE": "ADMINISTRATION & COMMERCE",
  "Entrées stock": "Stock In",
  "Unités": "Units",
  "Clients": "Customers",
  "Devis": "Quotes",
  "Boutiques": "Stores",
  "Équipe": "Team",
  "Paiements": "Payments",
  "Nouvelle vente": "New Sale",
  "Tableau de bord": "Dashboard",
  "Point de vente (Caisse)": "Point of Sale (Cashier)",
  "Gestion des Produits": "Product Management",
  "Gestion du Stock": "Inventory Management",
  "Menu & Paramètres": "Menu & Settings",
  "COMMERCE": "COMMERCE",
  "INVENTAIRE": "INVENTORY",
  "GESTION": "MANAGEMENT",
  "Copilote IA connecté": "Connected AI Copilot",
  "Akwa, Douala": "Akwa, Douala",
  "Rechercher par nom ou code-barres...": "Search by name or barcode...",
  "Rechercher un article par nom ou code-barres...": "Search an item by name or barcode...",
  "Scanner": "Scan",
  "Caisse / Ticket": "Cash Register / Ticket",
  "Caisse rapide & encaissement": "Quick checkout & collection",
  "Vider": "Clear",
  "Panier en cours": "Current Cart",
  "Cliquez sur un produit à gauche pour l'ajouter à la caisse.": "Click a product on the left to add it to the cash desk.",
  "Sous-total": "Subtotal",
  "Remise": "Discount",
  "TOTAL": "TOTAL",
  "articles au total": "total items",
  "Articles au total": "Total items",
  "PRODUIT": "PRODUCT",
  "CODE-BARRES": "BARCODE",
  "PRIX DE VENTE": "SELLING PRICE",
  "STOCK": "STOCK",
  "STATUT": "STATUS",
  "En stock": "In stock",
  "Stock bas": "Low stock",
  "Rupture": "Out of stock",
  "Modifier": "Edit",
  "Détails": "Details",
  "VALEUR DU STOCK (VENTE)": "STOCK VALUE (SALES)",
  "COÛT D'ACHAT": "PURCHASE COST",
  "MARGE BRUTE": "GROSS MARGIN",
  "Transférer": "Transfer",
  "Réassort": "Restock",
  "Détail des mouvements & Niveaux de Stock": "Movement Details & Stock Levels",
  "articles référencés": "registered products",
  "Aucun stock enregistré pour l'instant": "No stock recorded for now",
  "Le stock arrive de vos fournisseurs. Créez une commande ou ajoutez un produit.": "Stock arrives from suppliers. Create an order or add a product.",
  "Approvisionner le stock": "Restock Inventory",
  "Voici le point d'activité en temps réel de votre boutique Bricelo.": "Here is the real-time activity report for your Bricelo store.",
  "Chiffre du jour": "Today's Revenue",
  "Espèces & Mobile Money": "Cash & Mobile Money",
  "À recouvrer (Dettes)": "To Recover (Debts)",
  "Voir les clients endettés >": "View indebted customers >",
  "Articles en stock": "Items in stock",
  "Stock optimal": "Optimal stock",
  "Actions Rapides": "Quick Actions",
  "Point de vente (POS)": "Point of Sale (POS)",
  "Nouveau produit au catalogue": "New product in catalog",
  "Réception de marchandises": "Goods receipt",
  "Dépenses & Charges": "Expenses & Overhead",
  "Loyer, livraisons, salaires...": "Rent, deliveries, salaries...",
  "Ventes Récentes": "Recent Sales",
  "Aucune vente enregistrée aujourd'hui": "No sales recorded today",
  "Ouvrez le point de vente pour enregistrer vos premiers encaissements.": "Open the point of sale to record your first payments.",
  "Client Comptant": "Cash Customer",
  "Copilote IA de votre commerce": "AI Copilot for your business",
  "Posez une question sur vos ventes, votre stock ou la configuration de votre boutique.": "Ask a question about your sales, stock, or store setup.",
  "Poser une question à Bricelo": "Ask Bricelo a Question",
  "Alertes de Stock": "Stock Alerts",
  "Tous vos stocks sont à niveau optimal": "All your stock is at optimal level",
  "articles ont un stock faible (< 5 unités)": "items have low stock (< 5 units)",
  "articles en rupture de stock": "items out of stock"
};

  static String translate(String text) {
    if (currentLanguage == 'fr') return text;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;

    // 1. Recherche directe exacte
    final direct = _en[trimmed];
    if (direct != null) {
      if (text.startsWith(' ') && text.endsWith(' ')) return ' $direct ';
      if (text.startsWith(' ')) return ' $direct';
      if (text.endsWith(' ')) return '$direct ';
      return direct;
    }

    // 2. Recherche insensible à la casse
    final lowerTrimmed = trimmed.toLowerCase();
    for (final entry in _en.entries) {
      if (entry.key.toLowerCase() == lowerTrimmed) {
        return entry.value;
      }
    }

    // 3. Gestion de ponctuation en fin de chaîne (: ! ?)
    if (trimmed.endsWith(':') || trimmed.endsWith('*') || trimmed.endsWith('!')) {
      final lastChar = trimmed[trimmed.length - 1];
      final core = trimmed.substring(0, trimmed.length - 1).trim();
      final coreTr = _en[core];
      if (coreTr != null) {
        return '$coreTr $lastChar';
      }
    }

    return text;
  }
}

extension StringTranslateExtension on String {
  String get tr => AppTranslations.translate(this);
}

String tr(String key) => AppTranslations.translate(key);
