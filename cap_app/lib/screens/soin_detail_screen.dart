// soin_detail_screen.dart
// Version tout-en-un avec models et calculator intégrés

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/simulation_history_service.dart';

// ============================================
// MODELS
// ============================================

/// Modèle contenant toutes les informations nécessaires pour calculer un remboursement
class RemboursementInfo {
  final double brss;
  final double tauxSecu;
  final String typeMutuelle;
  final double? tauxMutuelleConventionne;
  final double? tauxMutuelleNonConventionne;
  final double? forfaitConventionne;
  final double? forfaitNonConventionne;
  final bool isMajeur;
  final double prixFacture;

  RemboursementInfo({
    required this.brss,
    required this.tauxSecu,
    required this.typeMutuelle,
    this.tauxMutuelleConventionne,
    this.tauxMutuelleNonConventionne,
    this.forfaitConventionne,
    this.forfaitNonConventionne,
    required this.isMajeur,
    required this.prixFacture,
  });
}

/// Résultat d'un calcul de remboursement
class RemboursementResult {
  final double remboursementSecu;
  final double totalAutoriseMutuelle;
  final double remboursementMutuelle;
  final double participationForfaitaire;
  final double totalRembourse;
  final double resteACharge;
  final double montantDepassement;
  final bool estConventionne;

  RemboursementResult({
    required this.remboursementSecu,
    required this.totalAutoriseMutuelle,
    required this.remboursementMutuelle,
    required this.participationForfaitaire,
    required this.totalRembourse,
    required this.resteACharge,
    required this.montantDepassement,
    required this.estConventionne,
  });

  double get pourcentagePriseEnCharge {
    if (resteACharge == 0) return 100.0;
    return (totalRembourse / (resteACharge + totalRembourse)) * 100;
  }
}

// ============================================
// CALCULATOR
// ============================================

class RemboursementCalculator {
  static RemboursementResult calculer(RemboursementInfo info) {
    // 1. Déterminer si le praticien est conventionné
    final bool estConventionne = info.prixFacture <= info.brss;
    final double montantDepassement = info.prixFacture > info.brss ? info.prixFacture - info.brss : 0;

    double totalAutoriseMutuelle = 0;

    if (info.typeMutuelle == 'pourcentage') {
      final double taux = estConventionne
          ? (info.tauxMutuelleConventionne ?? 0)
          : (info.tauxMutuelleNonConventionne ?? 0);

      totalAutoriseMutuelle = info.brss * (taux / 100);
    }

    // 2. Calculer le remboursement Sécurité sociale
    double remboursementSecu = info.brss * (info.tauxSecu / 100);

    // 3. Calculer la participation forfaitaire (1€ si majeur)
    final double participationForfaitaire = info.isMajeur ? 1.00 : 0.00;

    // 4. Déduire la participation forfaitaire du remboursement Sécu
    remboursementSecu = remboursementSecu - participationForfaitaire;
    if (remboursementSecu < 0) remboursementSecu = 0;

    // 5. Calculer le remboursement Mutuelle selon le type
    double remboursementMutuelle = _calculerRemboursementMutuelle(
      info: info,
      estConventionne: estConventionne,
    );

    // Cas mutuelle en pourcentage : le taux représente le TOTAL autorisé
    if (info.typeMutuelle == 'pourcentage') {
      remboursementMutuelle = remboursementMutuelle - remboursementSecu;
      if (remboursementMutuelle < 0) remboursementMutuelle = 0;
    }

    final double maxRemboursable = info.prixFacture - remboursementSecu;

    if (remboursementMutuelle > maxRemboursable) {
      remboursementMutuelle = maxRemboursable < 0 ? 0 : maxRemboursable;
    }

    // 6. Calculer le total remboursé et le reste à charge
    final double totalRembourse = remboursementSecu + remboursementMutuelle;
    double resteACharge = info.prixFacture - totalRembourse;
    if (resteACharge < 0) resteACharge = 0;

    return RemboursementResult(
      remboursementSecu: remboursementSecu,
      totalAutoriseMutuelle: totalAutoriseMutuelle,
      remboursementMutuelle: remboursementMutuelle,
      participationForfaitaire: participationForfaitaire,
      totalRembourse: totalRembourse,
      resteACharge: resteACharge,
      montantDepassement: montantDepassement,
      estConventionne: estConventionne,
    );
  }

  static double _calculerRemboursementMutuelle({
    required RemboursementInfo info,
    required bool estConventionne,
  }) {
    switch (info.typeMutuelle) {
      case 'pourcentage':
        final double taux = estConventionne
            ? (info.tauxMutuelleConventionne ?? 0)
            : (info.tauxMutuelleNonConventionne ?? 0);
        return info.brss * (taux / 100);

      case 'forfait':
        final double forfait = estConventionne
            ? (info.forfaitConventionne ?? 0)
            : (info.forfaitNonConventionne ?? 0);
        return forfait;

      case 'forfait_annuel':
        final double taux = estConventionne
            ? (info.tauxMutuelleConventionne ?? 0)
            : (info.tauxMutuelleNonConventionne ?? 0);
        final double forfait = estConventionne
            ? (info.forfaitConventionne ?? 0)
            : (info.forfaitNonConventionne ?? 0);
        return (info.brss * (taux / 100)) + forfait;

      default:
        return 0;
    }
  }

  static String getLabelMutuelle({
    required String typeMutuelle,
    required bool estConventionne,
    double? tauxConventionne,
    double? tauxNonConventionne,
  }) {
    if (typeMutuelle == 'forfait') {
      return 'Mutuelle (forfait)';
    } else if (typeMutuelle == 'forfait_annuel') {
      return 'Mutuelle (% + forfait)';
    } else {
      final double taux = estConventionne
          ? (tauxConventionne ?? 0)
          : (tauxNonConventionne ?? 0);
      return 'Mutuelle (${taux.toStringAsFixed(0)}%)';
    }
  }
}

// ============================================
// SCREEN
// ============================================

class SoinDetailScreen extends StatefulWidget {
  final int soinId;

  const SoinDetailScreen({
    super.key,
    required this.soinId,
  });

  @override
  State<SoinDetailScreen> createState() => _SoinDetailScreenState();
}

class _SoinDetailScreenState extends State<SoinDetailScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _prixController = TextEditingController();

  bool _isLoading = true;
  bool _profilComplet = false;
  String? _errorMessage;

  Map<String, dynamic>? _soinData;
  Map<String, dynamic>? _remboursementSecu;
  Map<String, dynamic>? _remboursementMutuelle;

  double _prixFacture = 0;
  double _brss = 0;
  double _tauxSecu = 0;
  bool _isMajeur = false;
  String? _categorieName;
  bool _userHasSimulated = false;

  RemboursementResult? _result;

  @override
  void initState() {
    super.initState();
    _checkProfilAndLoadData();
  }

  @override
  void dispose() {
    _saveToHistory();
    _prixController.dispose();
    super.dispose();
  }

  void _saveToHistory() {
    if (_result == null || !_profilComplet || _soinData == null || !_userHasSimulated) return;

    SimulationHistoryService().saveSimulation(
      soinId: widget.soinId,
      soinName: _soinData!['name'] ?? 'Soin',
      soinIcon: _soinData!['icon'],
      categorieName: _categorieName,
      prixFacture: _prixFacture,
      brss: _brss,
      tauxSecu: _tauxSecu,
      remboursementSecu: _result!.remboursementSecu,
      remboursementMutuelle: _result!.remboursementMutuelle,
      participationForfaitaire: _result!.participationForfaitaire,
      totalAutoriseMutuelle: _result!.totalAutoriseMutuelle,
      totalRembourse: _result!.totalRembourse,
      resteACharge: _result!.resteACharge,
      montantDepassement: _result!.montantDepassement,
      estConventionne: _result!.estConventionne,
    );
  }

  Future<void> _checkProfilAndLoadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final userInfoResponse = await _supabase
          .from('user_infos')
          .select('mutuelle_formule_id, regime_assurance_maladie_id, date_of_birth')
          .eq('user_id', userId)
          .maybeSingle();

      if (userInfoResponse == null || userInfoResponse['mutuelle_formule_id'] == null) {
        setState(() {
          _profilComplet = false;
          _isLoading = false;
        });
        return;
      }

      final int formuleId = userInfoResponse['mutuelle_formule_id'];
      final int regimeId = userInfoResponse['regime_assurance_maladie_id'] ?? 8;

      if (userInfoResponse['date_of_birth'] != null) {
        final dateOfBirth = DateTime.parse(userInfoResponse['date_of_birth']);
        final today = DateTime.now();
        int age = today.year - dateOfBirth.year;
        if (today.month < dateOfBirth.month ||
            (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
          age--;
        }
        _isMajeur = age >= 18;
      }

      final soinResponse = await _supabase.from('soins').select('*, categories_soins(name)').eq('id', widget.soinId).single();
      final secuResponse = await _supabase.from('assurance_maladie_remboursements').select('*').eq('soins_id', widget.soinId).eq('regimes_id', regimeId).maybeSingle();
      final mutuelleResponse = await _supabase.from('mutuelle_remboursements').select('*').eq('soins_id', widget.soinId).eq('formule_id', formuleId).maybeSingle();

      if (secuResponse == null) {
        throw Exception('Remboursement Sécurité sociale introuvable\n\nSoin ID: ${widget.soinId}\nRégime ID: $regimeId');
      }

      if (mutuelleResponse == null) {
        throw Exception('Remboursement Mutuelle introuvable\n\nSoin ID: ${widget.soinId}\nFormule ID: $formuleId');
      }

      // Extract category name from joined data
      final categoriesData = soinResponse['categories_soins'];
      if (categoriesData != null && categoriesData is Map) {
        _categorieName = categoriesData['name'] as String?;
      }

      setState(() {
        _soinData = soinResponse;
        _remboursementSecu = secuResponse;
        _remboursementMutuelle = mutuelleResponse;
        _brss = (soinResponse['brss'] as num?)?.toDouble() ?? 0;
        _tauxSecu = (secuResponse['taux_assurance_maladie'] as num?)?.toDouble() ?? 0;
        _prixFacture = _brss;
        _prixController.text = _brss.toStringAsFixed(2);
        _profilComplet = true;
        _isLoading = false;
      });

      _calculerRemboursements();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _calculerRemboursements() {
    if (_soinData == null || _remboursementSecu == null || _remboursementMutuelle == null) return;

    final info = RemboursementInfo(
      brss: _brss,
      tauxSecu: _tauxSecu,
      typeMutuelle: _remboursementMutuelle!['type'] ?? 'pourcentage',
      tauxMutuelleConventionne: (_remboursementMutuelle!['taux_mutuelle_conventionne'] as num?)?.toDouble(),
      tauxMutuelleNonConventionne: (_remboursementMutuelle!['taux_mutuelle_non_conventionne'] as num?)?.toDouble(),
      forfaitConventionne: (_remboursementMutuelle!['forfait_conventionne'] as num?)?.toDouble(),
      forfaitNonConventionne: (_remboursementMutuelle!['forfait_non_conventionne'] as num?)?.toDouble(),
      isMajeur: _isMajeur,
      prixFacture: _prixFacture,
    );

    setState(() {
      _result = RemboursementCalculator.calculer(info);
    });
  }

  void _onPrixChanged(String value) {
    final double? newPrix = double.tryParse(value.replaceAll(',', '.'));
    if (newPrix != null && newPrix >= 0) {
      setState(() {
        _prixFacture = newPrix;
        _userHasSimulated = true;
      });
      _calculerRemboursements();
    }
  }

  Color _getCouleurRAC() {
    if (_result == null) return Colors.grey;
    if (_result!.resteACharge == 0) return Colors.green;
    if (_result!.resteACharge < _prixFacture * 0.20) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen();
    if (_errorMessage != null) return _buildErrorScreen();
    if (!_profilComplet) return _buildProfilIncompletScreen();
    return _buildDetailScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Erreur', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilIncompletScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.account_circle_outlined, size: 80, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(height: 24),
              const Text('Profil incomplet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 12),
              const Text(
                'Veuillez compléter votre profil pour voir vos remboursements personnalisés',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280), height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Compléter mon profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailScreen() {
    if (_result == null) return const SizedBox();

    final String soinName = _soinData!['name'] ?? 'Soin';
    final String soinIcon = _soinData!['icon'] ?? '💊';
    final String soinDetail = _soinData!['detail'] ?? '';
    final String typeBrss = _soinData!['type_brss'] ?? 'fixe';
    final int? nbrMax = _remboursementMutuelle!['nbr_max'];
    final String detailMutuelle = _remboursementMutuelle!['detail'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(soinIcon, soinName),
            const SizedBox(height: 24),
            _buildInfoCard(soinDetail, typeBrss),
            const SizedBox(height: 16),
            _buildSimulationCard(),
            const SizedBox(height: 16),
            _buildResultsCard(),
            if (nbrMax != null || detailMutuelle.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoComplementairesCard(nbrMax, detailMutuelle),
            ],
            const SizedBox(height: 32),
            _buildExpandableFAQ(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Détails du soin', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF1A1A1A))),
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
    );
  }

  Widget _buildHeader(String icon, String name) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 40)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A), height: 1.3, letterSpacing: -0.5)),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String detail, String typeBrss) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informations du soin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 16),
          _buildInfoRow('Base de remboursement (BRSS)', '${_brss.toStringAsFixed(2)}€'),
          _buildInfoRow('Type de tarif', typeBrss == 'fixe' ? 'Tarif fixe' : 'Tarif moyen'),
          _buildInfoRow('Taux Sécurité sociale', '${_tauxSecu.toStringAsFixed(0)}%'),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(detail, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _buildSimulationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Simulation de remboursement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 16),
          const Text('Prix de référence (Secteur 1)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          Text('${_brss.toStringAsFixed(2)}€', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
          const SizedBox(height: 24),
          TextField(
            controller: _prixController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            onChanged: _onPrixChanged,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              labelText: 'Prix facturé par le praticien',
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
              suffixText: '€',
              suffixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildPraticienIndicator(),
          if (_result!.montantDepassement > 0) ...[
            const SizedBox(height: 12),
            _buildDepassementWarning(),
          ],
        ],
      ),
    );
  }

  Widget _buildPraticienIndicator() {
    if (_result == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _result!.estConventionne ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _result!.estConventionne ? Icons.check_circle : Icons.warning,
            color: _result!.estConventionne ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _result!.estConventionne ? 'Praticien conventionné (Secteur 1 ou OPTAM)' : 'Praticien non conventionné (dépassements)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _result!.estConventionne ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepassementWarning() {
    if (_result == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Dépassement: ${_result!.montantDepassement.toStringAsFixed(2)}€\nLe remboursement est calculé sur la BRSS (${_brss.toStringAsFixed(2)}€)',
              style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    if (_result == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Résultats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('${_result!.pourcentagePriseEnCharge.toStringAsFixed(0)}% remboursé', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildResultRow('Prix facturé', '${_prixFacture.toStringAsFixed(2)}€', false),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, thickness: 2),
          _buildResultRow('Sécurité sociale (${_tauxSecu.toStringAsFixed(0)}%)', '${_result!.remboursementSecu.toStringAsFixed(2)}€', false),
          if (_result!.participationForfaitaire > 0) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('- Participation forfaitaire', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white70)),
                  Text('-${_result!.participationForfaitaire.toStringAsFixed(2)}€', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white70)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildResultRow(_getLabelMutuelle(), '${_result!.remboursementMutuelle.toStringAsFixed(2)}€', false),
          const Divider(color: Colors.white24, thickness: 2),
          const SizedBox(height: 20),
          _buildResultRow('Total Remboursable', '${_result!.totalAutoriseMutuelle.toStringAsFixed(2)}€', false,),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              'Calculé sur la BRSS (${_brss.toStringAsFixed(2)}€ × ${_getTauxMutuelle().toStringAsFixed(0)}%)',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildResultRow('TOTAL REMBOURSÉ', '${_result!.totalRembourse.toStringAsFixed(2)}€', true),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCouleurRAC().withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getCouleurRAC().withOpacity(0.5), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_result!.resteACharge == 0 ? Icons.check_circle : Icons.account_balance_wallet, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text('RESTE À CHARGE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
                  ],
                ),
                Text('${_result!.resteACharge.toStringAsFixed(2)}€', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
          if (_result!.resteACharge == 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.celebration, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Ce soin est entièrement pris en charge !', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoComplementairesCard(int? nbrMax, String detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informations complémentaires', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 16),
          if (nbrMax != null) ...[
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: Color(0xFF4F46E5)),
                const SizedBox(width: 8),
                Expanded(child: Text('Limite: $nbrMax acte(s) par an', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)))),
              ],
            ),
            if (detail.isNotEmpty) const SizedBox(height: 12),
          ],
          if (detail.isNotEmpty) Text(detail, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildExpandableFAQ() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.all(20),
          leading: const Icon(Icons.help_outline, color: Color(0xFF4F46E5), size: 24),
          title: const Text('Comment est calculé votre remboursement ?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Formule de calcul', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 12),
                      const Text(
                        'Reste à charge = Prix facturé - Remboursement Sécu - Remboursement Mutuelle',
                        style: TextStyle(fontSize: 13, color: Color(0xFF4F46E5), fontWeight: FontWeight.w600, height: 1.5),
                      ),
                      const SizedBox(height: 8),
                      const Text('Avec :', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                      const SizedBox(height: 4),
                      Text(
                        '• Remboursement Sécu = (BRSS × Taux Sécu / 100)${_isMajeur ? ' - 1€' : ''}\n• Remboursement Mutuelle = (BRSS × Taux Mutuelle / 100) − Remboursement Sécu',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Définitions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 12),
                _buildDefinitionItem('📋', 'BRSS', 'Base de Remboursement de la Sécurité Sociale', 'C\'est le tarif de référence fixé par la Sécurité sociale. Les remboursements sont TOUJOURS calculés sur cette base, même si le prix facturé est supérieur.'),
                const SizedBox(height: 12),
                _buildDefinitionItem('🏥', 'Taux Sécu', 'Taux de remboursement de la Sécurité sociale', 'Pourcentage de la BRSS remboursé par la Sécurité sociale. Varie selon le type de soin (60%, 70%, 100%).'),
                const SizedBox(height: 12),
                _buildDefinitionItem('🛡️', 'Taux Mutuelle', 'Taux de remboursement de votre mutuelle', 'Pourcentage de la BRSS remboursé par votre mutuelle. Varie selon votre formule et le type de praticien (conventionné ou non).'),
                const SizedBox(height: 12),
                _buildDefinitionItem('⚕️', 'Praticien conventionné', 'Secteur 1 ou Secteur 2 OPTAM', 'Praticien qui applique les tarifs de la Sécurité sociale ou pratique des dépassements d\'honoraires maîtrisés. Meilleur remboursement.'),
                const SizedBox(height: 12),
                _buildDefinitionItem('💰', 'Dépassement d\'honoraires', 'Prix facturé > BRSS', 'Lorsque le praticien facture plus que le tarif conventionné. Le remboursement reste calculé sur la BRSS, le surplus est à votre charge.'),
                const SizedBox(height: 12),
                _buildDefinitionItem('⚠️', 'Participation forfaitaire', '1€ déduit par consultation (si majeur)', 'La Sécurité sociale déduit 1€ par consultation ou acte médical pour les personnes majeures (≥18 ans). Cette déduction est automatiquement prise en compte dans le calcul.'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.2))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Color(0xFF4F46E5), size: 20),
                          const SizedBox(width: 8),
                          const Text('Exemple pratique', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Consultation spécialiste à 60€ (majeur)\n'
                            '• BRSS : 31,50€\n'
                            '• Taux Sécu : 70%\n'
                            '• Taux Mutuelle : 110%\n\n'
                            'Calcul :\n'
                            '• Sécu brut : 31,50€ × 70% = 22,05€\n'
                            '• Participation : -1€\n'
                            '• Sécu net : 21,05€\n\n'
                            '• Total autorisé (mutuelle 110%) : 34,65€\n'
                            '• Mutuelle : 34,65€ − 21,05€ = 13,60€\n\n'
                            '• Total remboursé : 34,65€\n'
                            '• Reste à charge : 60€ − 34,65€ = 25,35€'
                        ,
                        style: TextStyle(fontSize: 12, color: Color(0xFF4F46E5), height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionItem(String emoji, String term, String subtitle, String definition) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(child: Text(term, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)))),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
                const SizedBox(height: 4),
                Text(definition, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, color: Colors.white)),
        Text(value, style: TextStyle(fontSize: isBold ? 20 : 16, fontWeight: isBold ? FontWeight.w700 : FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  String _getLabelMutuelle() {
    if (_result == null || _remboursementMutuelle == null) return 'Mutuelle';

    return RemboursementCalculator.getLabelMutuelle(
      typeMutuelle: _remboursementMutuelle!['type'] ?? 'pourcentage',
      estConventionne: _result!.estConventionne,
      tauxConventionne: (_remboursementMutuelle!['taux_mutuelle_conventionne'] as num?)?.toDouble(),
      tauxNonConventionne: (_remboursementMutuelle!['taux_mutuelle_non_conventionne'] as num?)?.toDouble(),
    );
  }

  double _getTauxMutuelle() {
    if (_result == null || _remboursementMutuelle == null) return 0;

    final bool estConventionne = _result!.estConventionne;

    return estConventionne
        ? ((_remboursementMutuelle!['taux_mutuelle_conventionne'] as num?)?.toDouble() ?? 0)
        : ((_remboursementMutuelle!['taux_mutuelle_non_conventionne'] as num?)?.toDouble() ?? 0);
  }
}