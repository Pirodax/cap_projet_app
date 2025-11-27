import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

// Service mock simplifié
class RemboursementServiceMock {
  double getTauxDefautParCategorie(int categorieId) {
    switch (categorieId) {
      case 1: return 70.0;
      case 2: return 80.0;
      case 3: return 60.0;
      case 6: return 100.0;
      case 9: return 65.0;
      default: return 70.0;
    }
  }

  double calculerRembSecuBrut(double brss, double tauxSecu) {
    return brss * (tauxSecu / 100);
  }

  double calculerParticipationForfaitaire(int categorieId, double tauxSecu) {
    if (categorieId == 1 && tauxSecu > 0) return 1.0;
    return 0.0;
  }

  double calculerRembSecuNet(double rembSecuBrut, double participationForfaitaire) {
    return max(0.0, rembSecuBrut - participationForfaitaire);
  }

  bool estConventionne(double prixReel, double brss) {
    return prixReel <= brss;
  }

  double calculerResteACharge(double prixReel, double totalRembourse) {
    return max(0.0, prixReel - totalRembourse);
  }
}

void main() {
  late RemboursementServiceMock service;

  setUp(() {
    service = RemboursementServiceMock();
  });

  group('Taux par catégorie', () {
    test('soins courants 70%', () {
      expect(service.getTauxDefautParCategorie(1), 70.0);
    });

    test('hospitalisation 80%', () {
      expect(service.getTauxDefautParCategorie(2), 80.0);
    });

    test('maternité 100%', () {
      expect(service.getTauxDefautParCategorie(6), 100.0);
    });
  });

  group('Calcul remboursement sécu', () {
    test('consultation 30€ à 70%', () {
      expect(service.calculerRembSecuBrut(30.0, 70.0), 21.0);
    });

    test('hospitalisation 1000€ à 80%', () {
      expect(service.calculerRembSecuBrut(1000.0, 80.0), 800.0);
    });
  });

  group('Participation forfaitaire', () {
    test('soins courants = 1€', () {
      expect(service.calculerParticipationForfaitaire(1, 70.0), 1.0);
    });

    test('hospitalisation = 0€', () {
      expect(service.calculerParticipationForfaitaire(2, 80.0), 0.0);
    });
  });

  group('Remboursement net', () {
    test('21€ brut - 1€ participation = 20€', () {
      expect(service.calculerRembSecuNet(21.0, 1.0), 20.0);
    });

    test('ne peut pas être négatif', () {
      expect(service.calculerRembSecuNet(0.5, 1.0), 0.0);
    });
  });

  group('Conventionné ou non', () {
    test('prix = BRSS => conventionné', () {
      expect(service.estConventionne(30.0, 30.0), true);
    });

    test('prix > BRSS => non conventionné', () {
      expect(service.estConventionne(50.0, 30.0), false);
    });
  });

  group('Reste à charge', () {
    test('50€ - 40€ remboursé = 10€', () {
      expect(service.calculerResteACharge(50.0, 40.0), 10.0);
    });

    test('minimum 0€', () {
      expect(service.calculerResteACharge(30.0, 35.0), 0.0);
    });
  });

  group('Scénario complet', () {
    test('consultation généraliste secteur 1', () {
      const brss = 30.0;
      const prixReel = 30.0;

      final rembSecuBrut = service.calculerRembSecuBrut(brss, 70.0);
      final participation = service.calculerParticipationForfaitaire(1, 70.0);
      final rembSecuNet = service.calculerRembSecuNet(rembSecuBrut, participation);
      final rembMutuelle = brss - rembSecuBrut; // 100% BRSS
      final totalRembourse = rembSecuNet + rembMutuelle;
      final resteACharge = service.calculerResteACharge(prixReel, totalRembourse);

      expect(rembSecuBrut, 21.0);
      expect(participation, 1.0);
      expect(rembSecuNet, 20.0);
      expect(rembMutuelle, 9.0);
      expect(totalRembourse, 29.0);
      expect(resteACharge, 1.0);
    });
  });
}