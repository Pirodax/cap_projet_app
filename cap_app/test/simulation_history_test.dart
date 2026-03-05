import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/models/simulation_history.dart';

void main() {
  group('SimulationHistory.fromJson', () {
    test('parse all fields correctly', () {
      final json = {
        'id': 1,
        'soin_name': 'Consultation généraliste',
        'soin_icon': '🩺',
        'categorie_name': 'Consultations',
        'prix_facture': 25.0,
        'brss': 25.0,
        'taux_secu': 70.0,
        'remboursement_secu': 16.5,
        'remboursement_mutuelle': 7.5,
        'participation_forfaitaire': 1.0,
        'total_autorise_mutuelle': 25.0,
        'total_rembourse': 24.0,
        'reste_a_charge': 1.0,
        'montant_depassement': 0.0,
        'est_conventionne': true,
        'created_at': '2025-12-01T10:30:00Z',
      };

      final sim = SimulationHistory.fromJson(json);

      expect(sim.id, 1);
      expect(sim.soinName, 'Consultation généraliste');
      expect(sim.soinIcon, '🩺');
      expect(sim.categorieName, 'Consultations');
      expect(sim.prixFacture, 25.0);
      expect(sim.brss, 25.0);
      expect(sim.tauxSecu, 70.0);
      expect(sim.remboursementSecu, 16.5);
      expect(sim.remboursementMutuelle, 7.5);
      expect(sim.participationForfaitaire, 1.0);
      expect(sim.totalAutoriseMutuelle, 25.0);
      expect(sim.totalRembourse, 24.0);
      expect(sim.resteACharge, 1.0);
      expect(sim.montantDepassement, 0.0);
      expect(sim.estConventionne, isTrue);
      expect(sim.createdAt, DateTime.parse('2025-12-01T10:30:00Z'));
    });

    test('handles nullable fields (soinIcon, categorieName)', () {
      final json = {
        'id': 2,
        'soin_name': 'Détartrage',
        'soin_icon': null,
        'categorie_name': null,
        'prix_facture': 50,
        'brss': 30,
        'taux_secu': 70,
        'remboursement_secu': 20,
        'remboursement_mutuelle': 10,
        'participation_forfaitaire': 1,
        'total_autorise_mutuelle': 30,
        'total_rembourse': 30,
        'reste_a_charge': 20,
        'montant_depassement': 20,
        'est_conventionne': false,
        'created_at': '2025-11-15T08:00:00Z',
      };

      final sim = SimulationHistory.fromJson(json);

      expect(sim.soinIcon, isNull);
      expect(sim.categorieName, isNull);
      expect(sim.estConventionne, isFalse);
    });

    test('handles int values cast to double via num.toDouble()', () {
      final json = {
        'id': 3,
        'soin_name': 'Radio',
        'soin_icon': null,
        'categorie_name': null,
        'prix_facture': 100,
        'brss': 80,
        'taux_secu': 60,
        'remboursement_secu': 47,
        'remboursement_mutuelle': 24,
        'participation_forfaitaire': 1,
        'total_autorise_mutuelle': 80,
        'total_rembourse': 71,
        'reste_a_charge': 29,
        'montant_depassement': 20,
        'est_conventionne': false,
        'created_at': '2025-10-01T12:00:00Z',
      };

      final sim = SimulationHistory.fromJson(json);

      // int values should be converted to double without error
      expect(sim.prixFacture, 100.0);
      expect(sim.brss, 80.0);
      expect(sim.resteACharge, 29.0);
    });
  });

  group('SimulationHistory.pourcentagePriseEnCharge', () {
    test('100% when reste a charge = 0', () {
      final sim = SimulationHistory(
        id: 1,
        soinName: 'Test',
        prixFacture: 25,
        brss: 25,
        tauxSecu: 70,
        remboursementSecu: 16.5,
        remboursementMutuelle: 8.5,
        participationForfaitaire: 1,
        totalAutoriseMutuelle: 25,
        totalRembourse: 25,
        resteACharge: 0,
        montantDepassement: 0,
        estConventionne: true,
        createdAt: DateTime.now(),
      );

      expect(sim.pourcentagePriseEnCharge, 100.0);
    });

    test('partial coverage calculation', () {
      final sim = SimulationHistory(
        id: 2,
        soinName: 'Test',
        prixFacture: 50,
        brss: 25,
        tauxSecu: 70,
        remboursementSecu: 16.5,
        remboursementMutuelle: 2.5,
        participationForfaitaire: 1,
        totalAutoriseMutuelle: 25,
        totalRembourse: 19,
        resteACharge: 31,
        montantDepassement: 25,
        estConventionne: false,
        createdAt: DateTime.now(),
      );

      // 19 / (31 + 19) * 100 = 38%
      expect(sim.pourcentagePriseEnCharge, 38.0);
    });
  });
}
