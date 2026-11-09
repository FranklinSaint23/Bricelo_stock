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

      // Vendeur a POS par défaut et n'a pas la gestion du stock ni validation
      appState.userRole = 'Vendeur';
      expect(appState.hasPermission('Point de vente (POS)'), true);
      expect(appState.hasPermission('Gestion du stock & Prix'), false);
      expect(appState.hasPermission('Validation des approbations'), false);
      expect(appState.hasPermission('Comptabilité & Finances'), false);

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
  });
}

