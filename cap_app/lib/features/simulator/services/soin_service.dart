import 'package:supabase_flutter/supabase_flutter.dart';

/// Service pour charger les données d'un soin depuis Supabase
class SoinService {
  final SupabaseClient _client;

  SoinService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  /// Vérifie et charge le profil utilisateur
  /// Retourne null si profil incomplet, sinon les données
  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecté');

    final response = await _client
        .from('user_infos')
        .select('mutuelle_formule_id, regime_assurance_maladie_id, date_of_birth')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null || response['mutuelle_formule_id'] == null) {
      return null;
    }

    return response;
  }

  /// Charge les données du soin
  Future<Map<String, dynamic>> getSoin(int soinId) async {
    return await _client
        .from('soins')
        .select('*, categories_soins(name)')
        .eq('id', soinId)
        .single();
  }

  /// Charge les données de remboursement Sécu
  Future<Map<String, dynamic>?> getRemboursementSecu(int soinId, int regimeId) async {
    return await _client
        .from('assurance_maladie_remboursements')
        .select('*')
        .eq('soins_id', soinId)
        .eq('regimes_id', regimeId)
        .maybeSingle();
  }

  /// Charge les données de remboursement Mutuelle
  Future<Map<String, dynamic>?> getRemboursementMutuelle(int soinId, int formuleId) async {
    return await _client
        .from('mutuelle_remboursements')
        .select('*')
        .eq('soins_id', soinId)
        .eq('formule_id', formuleId)
        .maybeSingle();
  }

  /// Calcule si l'utilisateur est majeur
  bool calculerIsMajeur(String? dateOfBirthStr) {
    if (dateOfBirthStr == null) return true;

    try {
      final dateOfBirth = DateTime.parse(dateOfBirthStr);
      final today = DateTime.now();
      int age = today.year - dateOfBirth.year;

      if (today.month < dateOfBirth.month ||
          (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
        age--;
      }

      return age >= 18;
    } catch (_) {
      return true;
    }
  }

  /// Extrait le nom de la catégorie depuis la réponse du soin
  String? extractCategorieName(Map<String, dynamic> soinData) {
    final categoriesData = soinData['categories_soins'];
    if (categoriesData != null && categoriesData is Map) {
      return categoriesData['name'] as String?;
    }
    return null;
  }
}