import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/features/Home/models/remboursement_info.dart';
import 'package:loodo_app/features/Home/services/remboursement_calculator.dart';

void main() {
  group('RemboursementCalculator.calculer', () {
    test('conventionné pourcentage — prix <= BRSS', () {
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
      expect(result.montantDepassement, 0.0);
      // Sécu: 25 * 0.70 - 1€ = 16.50
      expect(result.remboursementSecu, 16.50);
      expect(result.participationForfaitaire, 1.0);
      // Mutuelle: 25 * 0.30 = 7.50
      expect(result.remboursementMutuelle, 7.50);
      // Total: 16.50 + 7.50 = 24.0
      expect(result.totalRembourse, 24.0);
      // RAC: 25 - 24 = 1.0
      expect(result.resteACharge, 1.0);
    });

    test('non-conventionné pourcentage — prix > BRSS (dépassement)', () {
      final info = RemboursementInfo(
        prixFacture: 50.0,
        brss: 25.0,
        tauxSecu: 70.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 30.0,
        tauxMutuelleNonConventionne: 10.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isFalse);
      expect(result.montantDepassement, 25.0);
      // Sécu: 25 * 0.70 - 1€ = 16.50
      expect(result.remboursementSecu, 16.50);
      // Mutuelle non-conv: 25 * 0.10 = 2.50
      expect(result.remboursementMutuelle, 2.50);
      // Total: 16.50 + 2.50 = 19.0
      expect(result.totalRembourse, 19.0);
      // RAC: 50 - 19 = 31.0
      expect(result.resteACharge, 31.0);
    });

    test('forfait conventionné', () {
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
      // Mutuelle: forfait conv = 15.0
      expect(result.remboursementMutuelle, 15.0);
      expect(result.totalRembourse, 32.0);
      // RAC: 30 - 32 = -2 → clampé à 0
      expect(result.resteACharge, 0.0);
    });

    test('forfait non-conventionné', () {
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
      // Mutuelle: forfait non-conv = 5.0
      expect(result.remboursementMutuelle, 5.0);
      expect(result.montantDepassement, 20.0);
    });

    test('forfait_annuel — combine pourcentage + forfait', () {
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
      // Mutuelle: (100 * 0.20) + 50 = 70.0
      expect(result.remboursementMutuelle, 70.0);
      expect(result.totalRembourse, 139.0);
      // RAC: 100 - 139 = -39 → clampé à 0
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
      // RAC: 0 - total → clampé à 0
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
        tauxMutuelleConventionne: 30.0,
        tauxMutuelleNonConventionne: 10.0,
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
        tauxMutuelleConventionne: 30.0,
        tauxMutuelleNonConventionne: 10.0,
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

    test('taux sécu à 0% — aucun remboursement sécu', () {
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
      // Mutuelle: 25 * 1.00 = 25.0
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
      // Mutuelle: (100 * 0.10) + 20 = 30.0
      expect(result.remboursementMutuelle, 30.0);
    });

    test('très grand montant — calcul correct', () {
      final info = RemboursementInfo(
        prixFacture: 10000.0,
        brss: 5000.0,
        tauxSecu: 70.0,
        typeMutuelle: 'pourcentage',
        tauxMutuelleConventionne: 30.0,
        tauxMutuelleNonConventionne: 10.0,
        isMajeur: true,
      );

      final result = RemboursementCalculator.calculer(info);

      expect(result.estConventionne, isFalse);
      expect(result.montantDepassement, 5000.0);
      // Sécu: 5000 * 0.70 - 1 = 3499.0
      expect(result.remboursementSecu, 3499.0);
      // Mutuelle non-conv: 5000 * 0.10 = 500.0
      expect(result.remboursementMutuelle, 500.0);
      expect(result.resteACharge, 6001.0);
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
        tauxConventionne: 30.0,
        tauxNonConventionne: 10.0,
      );
      expect(label, 'Mutuelle (30%)');
    });

    test('pourcentage non-conventionné → affiche taux non-conv', () {
      final label = RemboursementCalculator.getLabelMutuelle(
        typeMutuelle: 'pourcentage',
        estConventionne: false,
        tauxConventionne: 30.0,
        tauxNonConventionne: 10.0,
      );
      expect(label, 'Mutuelle (10%)');
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
        remboursementMutuelle: 7.5,
        participationForfaitaire: 1,
        totalRembourse: 24,
        resteACharge: 1,
        montantDepassement: 0,
        estConventionne: true,
      );
      // 24 / (1 + 24) * 100 = 96%
      expect(result.pourcentagePriseEnCharge, 96.0);
    });
  });
}
