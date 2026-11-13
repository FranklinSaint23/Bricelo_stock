import 'package:flutter_test/flutter_test.dart';
import 'package:stock_prime/models/models.dart';
import 'package:stock_prime/services/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TeamMember Model & Credentials', () {
    test('TeamMember correctly stores PIN code and assigned cash desk', () {
      final member = TeamMember(
        id: 'tm_123',
        name: 'Paul Caissier',
        phone: '+237699112233',
        role: 'Caissier',
        storeName: 'Boutique Principale',
        pinCode: '482915',
        assignedCashDesk: 'Caisse Franklin Athletics',
        isActive: true,
      );

      expect(member.pinCode, '482915');
      expect(member.assignedCashDesk, 'Caisse Franklin Athletics');
      expect(member.role, 'Caissier');

      final json = member.toJson();
      final fromJson = TeamMember.fromJson(json);

      expect(fromJson.pinCode, '482915');
      expect(fromJson.assignedCashDesk, 'Caisse Franklin Athletics');
      expect(fromJson.name, 'Paul Caissier');
      expect(fromJson.isActive, true);
    });
  });

  group('CashShift Model & Duration Persistence', () {
    test('CashShift computes elapsed duration accurately', () {
      final opened = DateTime.now().subtract(const Duration(hours: 3, minutes: 25));
      final shift = CashShift(
        id: 'shift_test',
        cashierName: 'Franklin',
        cashDeskName: 'Caisse 1',
        storeName: 'Boutique Centrale',
        openedAt: opened,
        openingCash: 50000,
      );

      expect(shift.duration.inMinutes >= 204, true);
      expect(shift.formattedDuration.contains('h'), true);
      expect(shift.isClosed, false);

      // Clôture du shift
      shift.closedAt = opened.add(const Duration(hours: 8, minutes: 45));
      shift.isClosed = true;

      expect(shift.formattedDuration, '8h 45m');
      expect(shift.formattedDurationHms, '08h 45m 00s');
    });

    test('CashShift formattedDurationHms formats in hours minutes seconds without negative values', () {
      final now = DateTime.now();
      // Cas 1: shift ouvert il y a 2 minutes et 15 secondes
      final shiftRecent = CashShift(
        id: 'shift_${now.subtract(const Duration(minutes: 2, seconds: 15)).millisecondsSinceEpoch}',
        cashierName: 'Caissier',
        cashDeskName: 'Caisse test',
        storeName: 'Boutique',
        openedAt: now.subtract(const Duration(minutes: 2, seconds: 15)),
        openingCash: 0,
      );
      expect(shiftRecent.formattedDurationHms.startsWith('00h 02m'), true);

      // Cas 2: anomalie de fuseau horaire (openedAt dans le futur d'une heure)
      final shiftOffset = CashShift(
        id: 'shift_legacy_future',
        cashierName: 'Caissier',
        cashDeskName: 'Caisse test',
        storeName: 'Boutique',
        openedAt: now.add(const Duration(hours: 1)),
        openingCash: 0,
      );
      expect(shiftOffset.duration.isNegative, false);
      expect(shiftOffset.formattedDurationHms.contains('-'), false);
    });

    test('CashShift payment breakdown serialization', () {
      final shift = CashShift(
        id: 'shift_breakdown',
        cashierName: 'Jean',
        cashDeskName: 'Caisse 1',
        storeName: 'Boutique',
        openedAt: DateTime.now(),
        openingCash: 10000,
        salesCount: 12,
        totalSalesAmount: 185000,
        paymentMethodsBreakdown: {
          'Espèces': 100000,
          'Orange Money': 50000,
          'MTN MoMo': 35000,
        },
      );

      final json = shift.toJson();
      final restored = CashShift.fromJson(json);

      expect(restored.salesCount, 12);
      expect(restored.totalSalesAmount, 185000);
      expect(restored.paymentMethodsBreakdown['Orange Money'], 50000);
      expect(restored.paymentMethodsBreakdown['MTN MoMo'], 35000);
    });
  });

  group('AppState Dynamic Permissions & Approvals Workflow', () {
    final appState = AppState.instance;

    test('hasPermission respects role rules dynamically', () {
      // Propriétaire a tous les droits
      appState.userRole = 'Propriétaire';
      expect(appState.hasPermission('Point de vente (POS)'), true);
      expect(appState.hasPermission('Validation des approbations'), true);
      expect(appState.hasPermission('Suppression de données'), true);

      // Caissier a des droits très restreints
      appState.userRole = 'Caissier';
      expect(appState.hasPermission('Point de vente (POS)'), true);
      expect(appState.hasPermission('Gestion des shifts (Caisse)'), true);
      expect(appState.hasPermission('Gestion du stock & Prix'), false);
      expect(appState.hasPermission('Comptabilité & Finances'), false);
      expect(appState.hasPermission('Validation des approbations'), false);
      expect(appState.hasPermission('Suppression de données'), false);

      // Magasinier gère les stocks et approbations
      appState.userRole = 'Magasinier';
      expect(appState.hasPermission('Point de vente (POS)'), false);
      expect(appState.hasPermission('Gestion du stock & Prix'), true);
      expect(appState.hasPermission('Demandes d\'approvisionnement & Transferts'), true);
      expect(appState.hasPermission('Validation des approbations'), false);

      // Gérant supervise la boutique mais n'a pas la validation finale Propriétaire
      appState.userRole = 'Gérant';
      expect(appState.hasPermission('Point de vente (POS)'), true);
      expect(appState.hasPermission('Gestion du stock & Prix'), true);
      expect(appState.hasPermission('Validation des approbations'), false);
      expect(appState.hasPermission('Suppression de données'), false);

      // Rétablissement du rôle Propriétaire
      appState.userRole = 'Propriétaire';
    });

    test('Pending approvals count badge calculation', () {
      final initialCount = appState.pendingApprovalsCount;

      final req = ApprovalRequest(
        id: 'test_appr_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Approvisionnement',
        type: 'Approvisionnement',
        requesterName: 'Magasinier Test',
        storeName: 'Boutique Principale',
        amount: 45000,
        details: '10 articles requis',
        date: DateTime.now(),
        status: 'pending',
      );

      appState.approvalRequests.insert(0, req);
      expect(appState.pendingApprovalsCount, initialCount + 1);

      // Décision du propriétaire
      req.status = 'approved';
      expect(appState.pendingApprovalsCount, initialCount);

      // Nettoyage
      appState.approvalRequests.remove(req);
    });

    test('Strict password hashing and verification rejects wrong password', () async {
      final h1 = AppState.hashPassword('MonMotDePasse123');
      final h2 = AppState.hashPassword('MonMotDePasse123');
      final hWrong = AppState.hashPassword('MauvaisMotDePasse');

      expect(h1, h2);
      expect(h1 == hWrong, false);

      appState.userPhone = '+237 699 00 11 22';
      appState.ownerPasswordHash = h1;

      final wrongError = await appState.loginUser(
        identifier: '699001122',
        password: 'MauvaisMotDePasse',
      );
      expect(wrongError != null, true);

      final successError = await appState.loginUser(
        identifier: '699001122',
        password: 'MonMotDePasse123',
      );
      expect(successError, null);
    });

    test('Cashier is restricted to assigned store and cannot see all stores', () {
      appState.userRole = 'Caissier';
      expect(appState.isCashierAccount, true);
      expect(appState.isMagasinierAccount, false);
      expect(appState.isGerantAccount, false);

      // Magasinier et Gérant peuvent voir les autres boutiques
      appState.userRole = 'Magasinier';
      expect(appState.isCashierAccount, false);
      expect(appState.isMagasinierAccount, true);

      appState.userRole = 'Gérant';
      expect(appState.isCashierAccount, false);
      expect(appState.isGerantAccount, true);

      // Rétablissement rôle Propriétaire
      appState.userRole = 'Propriétaire';
    });

    test('Product stockForStore isolates stock per store correctly', () {
      final p = Product(
        id: 'p_test',
        name: 'Tissu Jericho',
        category: 'Textile',
        barcode: '123456',
        buyPrice: 1000,
        sellPrice: 1800,
        stock: 20,
        stockByStore: {
          'Franklin Athletics': 20,
        },
      );

      // Dans sa boutique, le stock est de 20
      expect(p.stockForStore('Franklin Athletics'), 20);
      // Dans une autre boutique où le produit n'a pas été alloué, le stock est 0 (pas de fuite de stock)
      expect(p.stockForStore('Autre Boutique'), 0);
    });

    test('Guest account with stock management permission: sales locked to assigned store', () {
      final p = Product(
        id: 'p_multistore',
        name: 'Produit Multi Boutique',
        category: 'Général',
        barcode: '778899',
        buyPrice: 500,
        sellPrice: 1000,
        stock: 50,
        stockByStore: {
          'Boutique A': 10,
          'Boutique B': 40,
        },
      );

      // Simuler un compte invité assigné à Boutique A avec droit de gestion de stock
      appState.userRole = 'Magasinier';
      appState.activeWorkspaceOwnerPhone = '699999999';
      appState.userPhone = '677777777'; // Différent du workspace owner = compte invité
      appState.userAssignedStore = 'Boutique A';

      expect(appState.isOwnerAccount, false);
      expect(appState.hasPermission('Gestion du stock & Prix'), true);
      expect(appState.assignedStoreForCurrentUser, 'Boutique A');

      // Pour la vente, le stock disponible est restreint à sa propre boutique assignée (10 et NON 50 ni 40)
      final sellableStock = appState.getAvailableStockForProduct(p);
      expect(sellableStock, 10);

      // Rétablissement Propriétaire
      appState.userRole = 'Propriétaire';
      appState.activeWorkspaceOwnerPhone = '';
      appState.userPhone = '';
      appState.userAssignedStore = '';
    });
  });
}

