import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // États de chargement
  bool _isLoading = true;
  bool _profilComplet = false;
  String? _errorMessage;

  // Données du soin
  Map<String, dynamic>? _soinData;
  Map<String, dynamic>? _remboursementSecu;
  Map<String, dynamic>? _remboursementMutuelle;

  // Valeurs pour le calcul
  double _prixFacture = 0;
  double _brss = 0;
  double _tauxSecu = 0;
  bool _estConventionne = true;

  // Résultats calculés
  double _remboursementSecuMontant = 0;
  double _remboursementMutuelleMontant = 0;
  double _totalRembourse = 0;
  double _resteACharge = 0;
  double _montantDepassement = 0;

  @override
  void initState() {
    super.initState();
    _checkProfilAndLoadData();
  }

  @override
  void dispose() {
    _prixController.dispose();
    super.dispose();
  }

  Future<void> _checkProfilAndLoadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 1. Récupérer l'utilisateur connecté
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // 2. Vérifier le profil utilisateur
      final userInfoResponse = await _supabase
          .from('user_infos')
          .select('mutuelle_id, mutuelle_formule_id, regime_assurance_maladie_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (userInfoResponse == null ||
          userInfoResponse['mutuelle_formule_id'] == null) {
        setState(() {
          _profilComplet = false;
          _isLoading = false;
        });
        return;
      }

      final int formuleId = userInfoResponse['mutuelle_formule_id'];
      // Récupérer le regimeId s'il existe, sinon utiliser 8 par défaut
      final int regimeId = userInfoResponse['regime_assurance_maladie_id'] ?? 8;

      // 3. Charger les données du soin
      final soinResponse = await _supabase
          .from('soins')
          .select('*')
          .eq('id', widget.soinId)
          .single();

      // 4. Charger le remboursement Sécu
      // Utiliser le regime_id du profil utilisateur
      final secuResponse = await _supabase
          .from('assurance_maladie_remboursements')
          .select('*')
          .eq('soins_id', widget.soinId)
          .eq('regimes_id', regimeId)  // Utiliser le regimeId du profil
          .maybeSingle();

      // 5. Charger le remboursement Mutuelle
      final mutuelleResponse = await _supabase
          .from('mutuelle_remboursements')
          .select('*')
          .eq('soins_id', widget.soinId)
          .eq('formule_id', formuleId)
          .maybeSingle();

      // DEBUG: Afficher les valeurs pour diagnostic
      print('=== DEBUG REMBOURSEMENTS ===');
      print('Soin ID: ${widget.soinId}');
      print('Regime ID: $regimeId');
      print('Formule ID: $formuleId');
      print('Sécu Response: $secuResponse');
      print('Mutuelle Response: $mutuelleResponse');
      print('===========================');

      // Vérifier les données et donner un message d'erreur précis
      if (secuResponse == null) {
        throw Exception(
            'Remboursement Sécurité sociale introuvable\n\n'
                'Soin ID: ${widget.soinId}\n'
                'Régime ID: $regimeId\n\n'
                'Vérifiez que ce remboursement existe dans:\n'
                'assurance_maladie_remboursements\n'
                'avec soins_id=${widget.soinId} ET regimes_id=$regimeId'
        );
      }

      if (mutuelleResponse == null) {
        throw Exception(
            'Remboursement Mutuelle introuvable\n\n'
                'Soin ID: ${widget.soinId}\n'
                'Formule ID: $formuleId\n\n'
                'Vérifiez que ce remboursement existe dans:\n'
                'mutuelle_remboursements\n'
                'avec soins_id=${widget.soinId} ET formule_id=$formuleId'
        );
      }

      setState(() {
        _soinData = soinResponse;
        _remboursementSecu = secuResponse;  // Maintenant on est sûr que c'est pas null
        _remboursementMutuelle = mutuelleResponse;  // Maintenant on est sûr que c'est pas null
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
    if (_soinData == null || _remboursementSecu == null || _remboursementMutuelle == null) {
      return;
    }

    // Détecter si conventionné ou non
    _estConventionne = _prixFacture <= _brss;
    _montantDepassement = _estConventionne ? 0 : _prixFacture - _brss;

    // 1. Calcul remboursement Sécu (toujours sur BRSS)
    _remboursementSecuMontant = _brss * (_tauxSecu / 100);

    // 2. Calcul remboursement Mutuelle selon le type
    final String typeMutuelle = _remboursementMutuelle!['type'] ?? 'pourcentage';

    switch (typeMutuelle) {
      case 'pourcentage':
        final double tauxMutuelle = _estConventionne
            ? (_remboursementMutuelle!['taux_mutuelle_conventionne'] as num?)?.toDouble() ?? 0
            : (_remboursementMutuelle!['taux_mutuelle_non_conventionne'] as num?)?.toDouble() ?? 0;
        _remboursementMutuelleMontant = _brss * (tauxMutuelle / 100);
        break;

      case 'forfait':
        final double forfait = _estConventionne
            ? (_remboursementMutuelle!['forfait_conventionne'] as num?)?.toDouble() ?? 0
            : (_remboursementMutuelle!['forfait_non_conventionne'] as num?)?.toDouble() ?? 0;
        _remboursementMutuelleMontant = forfait;
        break;

      case 'forfait_annuel':
        final double tauxMutuelle = _estConventionne
            ? (_remboursementMutuelle!['taux_mutuelle_conventionne'] as num?)?.toDouble() ?? 0
            : (_remboursementMutuelle!['taux_mutuelle_non_conventionne'] as num?)?.toDouble() ?? 0;
        final double forfait = _estConventionne
            ? (_remboursementMutuelle!['forfait_conventionne'] as num?)?.toDouble() ?? 0
            : (_remboursementMutuelle!['forfait_non_conventionne'] as num?)?.toDouble() ?? 0;
        _remboursementMutuelleMontant = (_brss * (tauxMutuelle / 100)) + forfait;
        break;
    }

    // 3. Calculs finaux
    _totalRembourse = _remboursementSecuMontant + _remboursementMutuelleMontant;
    _resteACharge = _prixFacture - _totalRembourse;
    if (_resteACharge < 0) _resteACharge = 0;

    setState(() {});
  }

  void _onPrixChanged(String value) {
    final double? newPrix = double.tryParse(value.replaceAll(',', '.'));
    if (newPrix != null && newPrix >= 0) {
      setState(() {
        _prixFacture = newPrix;
      });
      _calculerRemboursements();
    }
  }

  Color _getCouleurRAC() {
    if (_resteACharge == 0) return Colors.green;
    if (_resteACharge < _prixFacture * 0.20) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Détails du soin',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF1A1A1A),
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Détails du soin',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF1A1A1A),
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_profilComplet) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Détails du soin',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF1A1A1A),
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        ),
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
                  child: const Icon(
                    Icons.account_circle_outlined,
                    size: 80,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Profil incomplet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Veuillez compléter votre profil pour voir vos remboursements personnalisés',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Compléter mon profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Interface complète avec simulation
    final String soinName = _soinData!['name'] ?? 'Soin';
    final String soinIcon = _soinData!['icon'] ?? '💊';
    final String soinDetail = _soinData!['detail'] ?? '';
    final String typeBrss = _soinData!['type_brss'] ?? 'fixe';
    final String typeMutuelle = _remboursementMutuelle!['type'] ?? 'pourcentage';
    final int? nbrMax = _remboursementMutuelle!['nbr_max'];
    final String detailMutuelle = _remboursementMutuelle!['detail'] ?? '';

    final double pourcentagePriseEnCharge = _prixFacture > 0
        ? (_totalRembourse / _prixFacture) * 100
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Détails du soin',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF1A1A1A),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec icône et nom
            Row(
              children: [
                Text(
                  soinIcon,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    soinName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Card informations de base
            _buildInfoCard(
              'Informations du soin',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Base de remboursement (BRSS)', '${_brss.toStringAsFixed(2)}€'),
                  _buildInfoRow('Type de tarif', typeBrss == 'fixe' ? 'Tarif fixe' : 'Tarif moyen'),
                  _buildInfoRow('Taux Sécurité sociale', '${_tauxSecu.toStringAsFixed(0)}%'),
                  if (soinDetail.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      soinDetail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card saisie du prix
            _buildInfoCard(
              'Simulation de remboursement',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prix de référence (Secteur 1)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_brss.toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _prixController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    onChanged: _onPrixChanged,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Prix facturé par le praticien',
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                      suffixText: '€',
                      suffixStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Indicateur type de praticien
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _estConventionne
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _estConventionne ? Icons.check_circle : Icons.warning,
                          color: _estConventionne
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _estConventionne
                                ? 'Praticien conventionné (Secteur 1 ou OPTAM)'
                                : 'Praticien non conventionné (dépassements)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _estConventionne
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_montantDepassement > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dépassement: ${_montantDepassement.toStringAsFixed(2)}€\nLe remboursement est calculé sur la BRSS (${_brss.toStringAsFixed(2)}€)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFEF4444),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card résultats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Résultats',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${pourcentagePriseEnCharge.toStringAsFixed(0)}% remboursé',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildResultRow(
                    'Prix facturé',
                    '${_prixFacture.toStringAsFixed(2)}€',
                    false,
                  ),
                  const SizedBox(height: 16),
                  _buildResultRow(
                    'Sécurité sociale (${_tauxSecu.toStringAsFixed(0)}%)',
                    '${_remboursementSecuMontant.toStringAsFixed(2)}€',
                    false,
                  ),
                  const SizedBox(height: 16),
                  _buildResultRow(
                    _buildMutuelleLabel(),
                    '${_remboursementMutuelleMontant.toStringAsFixed(2)}€',
                    false,
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24, thickness: 1),
                  const SizedBox(height: 20),
                  _buildResultRow(
                    'TOTAL REMBOURSÉ',
                    '${_totalRembourse.toStringAsFixed(2)}€',
                    true,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getCouleurRAC().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getCouleurRAC().withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _resteACharge == 0
                                  ? Icons.check_circle
                                  : Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'RESTE À CHARGE',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_resteACharge.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_resteACharge == 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.celebration, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ce soin est entièrement pris en charge !',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Informations complémentaires
            if (nbrMax != null || detailMutuelle.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                'Informations complémentaires',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (nbrMax != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 20, color: Color(0xFF4F46E5)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Limite: $nbrMax acte(s) par an',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (detailMutuelle.isNotEmpty) const SizedBox(height: 12),
                    ],
                    if (detailMutuelle.isNotEmpty)
                      Text(
                        detailMutuelle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, Widget content) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          content,
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 20 : 16,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _buildMutuelleLabel() {
    final String type = _remboursementMutuelle!['type'] ?? 'pourcentage';

    if (type == 'forfait') {
      return 'Mutuelle (forfait)';
    } else if (type == 'forfait_annuel') {
      return 'Mutuelle (% + forfait)';
    } else {
      final double taux = _estConventionne
          ? (_remboursementMutuelle!['taux_mutuelle_conventionne'] as num?)?.toDouble() ?? 0
          : (_remboursementMutuelle!['taux_mutuelle_non_conventionne'] as num?)?.toDouble() ?? 0;
      return 'Mutuelle (${taux.toStringAsFixed(0)}%)';
    }
  }
}