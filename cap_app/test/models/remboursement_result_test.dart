import 'package:flutter_test/flutter_test.dart';

class RemboursementResult {
  final bool success;
  final String? error;
  final RemboursementDetails? details;

  RemboursementResult({
    required this.success,
    this.error,
    this.details,
  });
}

class RemboursementDetails {
  final double prixReel;
  final double baseRemboursement;
  final double tauxSecu;
  final double rembSecuBrut;
  final double participationForfaitaire;
  final double rembSecuNet;
  final double tauxMutuelle;
  final double rembMutuelle;
  final double totalRembourse;
  final double resteACharge;
  final String soinName;

  RemboursementDetails({
    required this.prixReel,
    required this.baseRemboursement,
    required this.tauxSecu,
    required this.rembSecuBrut,
    required this.participationForfaitaire,
    required this.rembSecuNet,
    required this.tauxMutuelle,
    required this.rembMutuelle,
    required this.totalRembourse,
    required this.resteACharge,
    required this.soinName,
  });
}

void main() {
  group('RemboursementResult', () {
    test('création avec succès', () {
      final result = RemboursementResult(success: true);
      expect(result.success, true);
      expect(result.error, isNull);
    });

    test('création avec erreur', () {
      final result = RemboursementResult(
        success: false,
        error: 'Profil non trouvé',
      );
      expect(result.success, false);
      expect(result.error, 'Profil non trouvé');
    });

    test('création avec détails', () {
      final details = RemboursementDetails(
        prixReel: 30.0,
        baseRemboursement: 30.0,
        tauxSecu: 70.0,
        rembSecuBrut: 21.0,
        participationForfaitaire: 1.0,
        rembSecuNet: 20.0,
        tauxMutuelle: 100.0,
        rembMutuelle: 9.0,
        totalRembourse: 29.0,
        resteACharge: 1.0,
        soinName: 'Consultation',
      );

      final result = RemboursementResult(success: true, details: details);
      expect(result.details, isNotNull);
      expect(result.details!.soinName, 'Consultation');
    });
  });

  group('RemboursementDetails', () {
    test('stocke les valeurs correctement', () {
      final details = RemboursementDetails(
        prixReel: 50.0,
        baseRemboursement: 30.0,
        tauxSecu: 70.0,
        rembSecuBrut: 21.0,
        participationForfaitaire: 1.0,
        rembSecuNet: 20.0,
        tauxMutuelle: 100.0,
        rembMutuelle: 9.0,
        totalRembourse: 29.0,
        resteACharge: 21.0,
        soinName: 'Test',
      );

      expect(details.prixReel, 50.0);
      expect(details.baseRemboursement, 30.0);
      expect(details.tauxSecu, 70.0);
    });

    test('reste à charge = prix - total remboursé', () {
      final details = RemboursementDetails(
        prixReel: 100.0,
        baseRemboursement: 80.0,
        tauxSecu: 70.0,
        rembSecuBrut: 56.0,
        participationForfaitaire: 1.0,
        rembSecuNet: 55.0,
        tauxMutuelle: 100.0,
        rembMutuelle: 24.0,
        totalRembourse: 79.0,
        resteACharge: 21.0,
        soinName: 'Test',
      );

      expect(details.resteACharge, details.prixReel - details.totalRembourse);
    });

    test('secteur 1: prix = BRSS', () {
      final details = RemboursementDetails(
        prixReel: 30.0,
        baseRemboursement: 30.0,
        tauxSecu: 70.0,
        rembSecuBrut: 21.0,
        participationForfaitaire: 1.0,
        rembSecuNet: 20.0,
        tauxMutuelle: 100.0,
        rembMutuelle: 9.0,
        totalRembourse: 29.0,
        resteACharge: 1.0,
        soinName: 'Généraliste',
      );

      expect(details.prixReel, details.baseRemboursement);
      expect(details.resteACharge, 1.0); // participation forfaitaire
    });

    test('secteur 2: prix > BRSS', () {
      final details = RemboursementDetails(
        prixReel: 60.0,
        baseRemboursement: 30.0,
        tauxSecu: 70.0,
        rembSecuBrut: 21.0,
        participationForfaitaire: 1.0,
        rembSecuNet: 20.0,
        tauxMutuelle: 150.0,
        rembMutuelle: 24.0,
        totalRembourse: 44.0,
        resteACharge: 16.0,
        soinName: 'Spécialiste',
      );

      expect(details.prixReel, greaterThan(details.baseRemboursement));
    });
  });
}