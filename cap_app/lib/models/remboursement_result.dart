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