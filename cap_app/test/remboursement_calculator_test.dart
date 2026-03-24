import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/features/simulator/models/remboursement_info.dart';
import 'package:loodo_app/features/simulator/models/remboursement_result.dart';
import 'package:loodo_app/features/simulator/calculators/remboursement_calculator.dart';

void main() {
  group('RemboursementCalculator.calculer', () {
    test('conventionné pourcentage — mutuelle 100% BR complète la sécu', () {
      final info = RemboursementInfo(
        prixFacture: 25.0,
        brss: 25.0,
        tauxSecu: 70.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 100.0,
        tauxMutuelleNonConventionne: 50.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isTrue);
      expect(result.montantDepassement, 0.0);
      // Sécu: 25 * 0.70 - 1€ = 16.50
      expect(result.remboursementSecu, 16.50);
      expect(result.participationForfaitaire, 1.0);
      // Mutuelle: total autorisé = 25 * 1.00 = 25.0, complément = 25.0 - 16.50 = 8.50
      expect(result.totalAutoriseMutuelle, 25.0);
      expect(result.remboursementMutuelle, 8.50);
      // Total: 16.50 + 8.50 = 25.0
      expect(result.totalRembourse, 25.0);
      // RAC: 25 - 25 = 0
      expect(result.resteACharge, 0.0);
    });

    test('conventionné pourcentage — taux mutuelle < taux sécu → mutuelle à 0', () {
      // Cas où le total autorisé mutuelle (30% BR) est inférieur à ce que la sécu rembourse déjà
      final info = RemboursementInfo(
        prixFacture: 25.0,
        brss: 25.0,
        tauxSecu: 70.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 30.0,
        tauxMutuelleNonConventionne: 10.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isTrue);
      // Sécu: 25 * 0.70 - 1€ = 16.50
      expect(result.remboursementSecu, 16.50);
      // Mutuelle: 25 * 0.30 = 7.50 - 16.50 = -9.0 → clampé à 0
      expect(result.remboursementMutuelle, 0.0);
      // Total: 16.50 + 0 = 16.50
      expect(result.totalRembourse, 16.50);
      // RAC: 25 - 16.50 = 8.50
      expect(result.resteACharge, 8.50);
    });

    test('non-conventionné pourcentage — prix > BRSS (dépassement)', () {
      final info = RemboursementInfo(
        prixFacture: 50.0,
        brss: 25.0,
        tauxSecu: 70.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 100.0,
        tauxMutuelleNonConventionne: 150.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isFalse);
      expect(result.montantDepassement, 25.0);
      // Sécu: 25 * 0.70 - 1€ = 16.50
      expect(result.remboursementSecu, 16.50);
      // Mutuelle non-conv: total = 25 * 1.50 = 37.50, complément = 37.50 - 16.50 = 21.0
      expect(result.remboursementMutuelle, 21.0);
      // Total: 16.50 + 21.0 = 37.50
      expect(result.totalRembourse, 37.50);
      // RAC: 50 - 37.50 = 12.50
      expect(result.resteACharge, 12.50);
    });

    test('forfait conventionné — plafonné au reste après sécu', () {
      final info = RemboursementInfo(
        prixFacture: 30.0,
        brss: 30.0,
        tauxSecu: 60.0,
        typeMutuelle: 'forfait',
        forfaitConventionne: 15.0,
        forfaitNonConventionne: 5.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isTrue);
      // Sécu: 30 * 0.60 - 1€ = 17.0
      expect(result.remboursementSecu, 17.0);
      // Mutuelle: forfait 15€, mais max = 30 - 17 = 13.0 → plafonné à 13.0
      expect(result.remboursementMutuelle, 13.0);
      // Total: 17 + 13 = 30.0
      expect(result.totalRembourse, 30.0);
      // RAC: 30 - 30 = 0
      expect(result.resteACharge, 0.0);
    });

    test('forfait non-conventionné — forfait sous le plafond', () {
      final info = RemboursementInfo(
        prixFacture: 50.0,
        brss: 30.0,
        tauxSecu: 60.0,
        typeMutuelle: 'forfait',
        forfaitConventionne: 15.0,
        forfaitNonConventionne: 5.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isFalse);
      // Sécu: 30 * 0.60 - 1€ = 17.0
      expect(result.remboursementSecu, 17.0);
      // Mutuelle: forfait non-conv = 5.0, max = 50 - 17 = 33 → pas plafonné
      expect(result.remboursementMutuelle, 5.0);
      expect(result.montantDepassement, 20.0);
      // RAC: 50 - 22 = 28.0
      expect(result.resteACharge, 28.0);
    });

    test('forfait_annuel — combine % + forfait, plafonné au prix', () {
      final info = RemboursementInfo(
        prixFacture: 100.0,
        brss: 100.0,
        tauxSecu: 70.0,
        typeMutuelle: 'forfait_annuel',
        tauxMutuelleConventionne: 20.0,
        forfaitConventionne: 50.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isTrue);
      // Sécu: 100 * 0.70 - 1€ = 69.0
      expect(result.remboursementSecu, 69.0);
      // Mutuelle brut: (100 * 0.20) + 50 = 70.0, max = 100 - 69 = 31.0 → plafonné
      expect(result.remboursementMutuelle, 31.0);
      // Total: 69 + 31 = 100.0
      expect(result.totalRembourse, 100.0);
      // RAC: 100 - 100 = 0
      expect(result.resteACharge, 0.0);
    });

    test('participation forfaitaire 1€ pour majeur', () {
      final info = RemboursementInfo(
        prixFacture: 25.0,
        brss: 25.0,
        tauxSecu: 70.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 0.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.participationForfaitaire, 1.0);
      // Sécu: 25 * 0.70 - 1€ = 16.50
      expect(result.remboursementSecu, 16.50);
    });

    test('pas de participation forfaitaire pour mineur', () {
      final info = RemboursementInfo(
        prixFacture: 25.0,
        brss: 25.0,
        tauxSecu: 70.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 0.0,
        isMajeur: false,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.participationForfaitaire, 0.0);
      // Sécu: 25 * 0.70 = 17.50 (pas de déduction)
      expect(result.remboursementSecu, 17.50);
    });

    test('prix à 0 — tout à 0', () {
      final info = RemboursementInfo(
        prixFacture: 0.0,
        brss: 25.0,
        tauxSecu: 70.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 30.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isTrue);
      expect(result.resteACharge, 0.0);
    });

    test('remboursement Sécu clampé à 0 si négatif (faible BRSS)', () {
      final info = RemboursementInfo(
        prixFacture: 1.0,
        brss: 1.0,
        tauxSecu: 50.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 0.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      // Sécu: 1 * 0.50 - 1€ = -0.50 → clampé à 0
      expect(result.remboursementSecu, 0.0);
    });

    test('type mutuelle inconnu — mutuelle à 0 par défaut', () {
      final info = RemboursementInfo(
        prixFacture: 25.0,
        brss: 25.0,
        tauxSecu: 70.0,
        typeMutuelle: 'type_inconnu',
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.remboursementMutuelle, 0.0);
    });

    test('prix exactement égal au BRSS — conventionné (limite)', () {
      final info = RemboursementInfo(
        prixFacture: 25.0,
        brss: 25.0,
        tauxSecu: 70.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 100.0,
        tauxMutuelleNonConventionne: 50.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isTrue);
      expect(result.montantDepassement, 0.0);
    });

    test('prix 1 centime au-dessus du BRSS — non-conventionné', () {
      final info = RemboursementInfo(
        prixFacture: 25.01,
        brss: 25.0,
        tauxSecu: 70.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 100.0,
        tauxMutuelleNonConventionne: 50.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isFalse);
      expect(result.montantDepassement, closeTo(0.01, 0.001));
    });

    test('taux sécu à 100% — remboursement maximum', () {
      final info = RemboursementInfo(
        prixFacture: 25.0,
        brss: 25.0,
        tauxSecu: 100.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 0.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      // Sécu: 25 * 1.00 - 1€ = 24.0
      expect(result.remboursementSecu, 24.0);
    });

    test('taux sécu à 0% — mutuelle prend le relais', () {
      final info = RemboursementInfo(
        prixFacture: 25.0,
        brss: 25.0,
        tauxSecu: 0.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 100.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      // Sécu: 25 * 0 - 1€ = -1 → clampé à 0
      expect(result.remboursementSecu, 0.0);
      // Mutuelle: total = 25 * 1.00 = 25, complément = 25 - 0 = 25.0
      expect(result.remboursementMutuelle, 25.0);
    });

    test('null taux mutuelle — traité comme 0', () {
      final info = RemboursementInfo(
        prixFacture: 25.0,
        brss: 25.0,
        tauxSecu: 70.0,
        typeMutuelle: 'pourcentage',
        // tauxMutuelleConventionne is null
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.remboursementMutuelle, 0.0);
    });

    test('forfait_annuel non-conventionné — utilise taux + forfait non-conv', () {
      final info = RemboursementInfo(
        prixFacture: 150.0,
        brss: 100.0,
        tauxSecu: 70.0,
        typeMutuelle: 'forfait_annuel',
        tauxMutuelleConventionne: 20.0,
        tauxMutuelleNonConventionne: 10.0,
        forfaitConventionne: 50.0,
        forfaitNonConventionne: 20.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isFalse);
      // Sécu: 100 * 0.70 - 1€ = 69.0
      expect(result.remboursementSecu, 69.0);
      // Mutuelle: (100 * 0.10) + 20 = 30.0, max = 150 - 69 = 81 → pas plafonné
      expect(result.remboursementMutuelle, 30.0);
      // RAC: 150 - 99 = 51.0
      expect(result.resteACharge, 51.0);
    });

    test('très grand montant — dépassement avec mutuelle 100% non-conv', () {
      final info = RemboursementInfo(
        prixFacture: 10000.0,
        brss: 5000.0,
        tauxSecu: 70.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 100.0,
        tauxMutuelleNonConventionne: 100.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isFalse);
      expect(result.montantDepassement, 5000.0);
      // Sécu: 5000 * 0.70 - 1 = 3499.0
      expect(result.remboursementSecu, 3499.0);
      // Mutuelle: total = 5000 * 1.00 = 5000, complément = 5000 - 3499 = 1501
      expect(result.remboursementMutuelle, 1501.0);
      // Total: 3499 + 1501 = 5000
      expect(result.totalRembourse, 5000.0);
      // RAC: 10000 - 5000 = 5000 (le dépassement reste à charge)
      expect(result.resteACharge, 5000.0);
    });
  });

  group('RemboursementCalculator.getLabelMutuelle', () {
    test('forfait → label forfait', () {
      final label = RemboursementCalculator.getLabelMutuelle(
        typeMutuelle: 'forfait',
        estConventionne: true,
      );
      expect(label, 'Mutuelle (forfait)');
    });

    test('forfait_annuel → label % + forfait', () {
      final label = RemboursementCalculator.getLabelMutuelle(
        typeMutuelle: 'forfait_annuel',
        estConventionne: true,
      );
      expect(label, 'Mutuelle (% + forfait)');
    });

    test('pourcentage conventionné → affiche taux conv', () {
      final label = RemboursementCalculator.getLabelMutuelle(
        typeMutuelle: 'pourcentage',
        estConventionne: true,
        tauxConventionne: 100.0,
        tauxNonConventionne: 150.0,
      );
      expect(label, 'Mutuelle (100%)');
    });

    test('pourcentage non-conventionné → affiche taux non-conv', () {
      final label = RemboursementCalculator.getLabelMutuelle(
        typeMutuelle: 'pourcentage',
        estConventionne: false,
        tauxConventionne: 100.0,
        tauxNonConventionne: 150.0,
      );
      expect(label, 'Mutuelle (150%)');
    });
  });

  group('RemboursementCalculator.getCouleurRAC', () {
    test('RAC = 0 → green', () {
      expect(RemboursementCalculator.getCouleurRAC(0, 100), 'green');
    });

    test('RAC < 20% du prix → orange', () {
      expect(RemboursementCalculator.getCouleurRAC(15, 100), 'orange');
    });

    test('RAC >= 20% du prix → red', () {
      expect(RemboursementCalculator.getCouleurRAC(25, 100), 'red');
    });
  });

  group('RemboursementResult.pourcentagePriseEnCharge', () {
    test('RAC = 0 → 100%', () {
      final result = RemboursementResult(
        remboursementSecu: 20,
        totalAutoriseMutuelle: 0,
        remboursementMutuelle: 10,
        participationForfaitaire: 1,
        totalRembourse: 30,
        resteACharge: 0,
        montantDepassement: 0,
        estConventionne: true,
      );
      expect(result.pourcentagePriseEnCharge, 100.0);
    });

    test('prise en charge partielle', () {
      final result = RemboursementResult(
        remboursementSecu: 16.5,
        totalAutoriseMutuelle: 25.0,
        remboursementMutuelle: 8.5,
        participationForfaitaire: 1,
        totalRembourse: 25,
        resteACharge: 0,
        montantDepassement: 0,
        estConventionne: true,
      );
      // 25 / (0 + 25) * 100 = 100%
      expect(result.pourcentagePriseEnCharge, 100.0);
    });
  });
}