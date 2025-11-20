import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // 👈 IMPORT IMPORTANT
// =============================================
// 1️⃣ MODÈLES DE DONNÉES
// =============================================
class Mutuelle {
  final int id;
  final String name;
  Mutuelle({required this.id, required this.name});
}

class Formule {
  final int id;
  final int mutuelleId;
  final String name;
  Formule({required this.id, required this.mutuelleId, required this.name});
}

// ✨ NOUVEAU : Modèle pour le régime d'assurance maladie
class Regime {
  final int id;
  final String name;
  Regime({required this.id, required this.name});
}

// =============================================
// 2️⃣ CLASSE DE SERVICE
// =============================================
class ProfileService {
  final supabase = Supabase.instance.client;

  Future<List<Mutuelle>> getMutuelles() async {
    final response = await supabase.from('mutuelles').select('id, name');
    return (response as List)
        .map((item) => Mutuelle(id: item['id'], name: item['name']))
        .toList();
  }

  Future<List<Formule>> getFormules() async {
    final response = await supabase.from('mutuelle_formules').select('id, mutuelle_id, name');
    return (response as List)
        .map((item) => Formule(id: item['id'], mutuelleId: item['mutuelle_id'], name: item['name']))
        .toList();
  }

  // ✨ NOUVEAU : Récupération des régimes depuis la table 'assurance_maladie_regimes'
  Future<List<Regime>> getRegimes() async {
    try {
      final response = await supabase.from('assurance_maladie_regimes').select('id, name');
      return (response as List)
          .map((item) => Regime(id: item['id'], name: item['name']))
          .toList();
    } catch (e) {
      debugPrint('Erreur récupération régimes: $e');
      return [];
    }
  }
}

// =============================================
// 3️⃣ ÉCRAN DU PROFIL (UI MODERNE)
// =============================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final _profileService = ProfileService();

  late TextEditingController _usernameController;
  DateTime? _birthDate;

  int? _selectedMutuelleId;
  int? _selectedFormuleId;
  int? _selectedRegimeId; // ✨ NOUVEAU

  List<Mutuelle> _allMutuelles = [];
  List<Formule> _allFormules = [];
  List<Formule> _filteredFormules = [];
  List<Regime> _allRegimes = []; // ✨ NOUVEAU

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();

    initializeDateFormatting('fr_FR', null).then((_) {
      if (mounted) {
        _loadInitialData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    try {
      // Chargement parallèle de toutes les données
      final results = await Future.wait([
        _profileService.getMutuelles(), // index 0
        _profileService.getFormules(),  // index 1
        _profileService.getRegimes(),   // index 2 (✨ NOUVEAU)
        _loadUserProfileData(),         // index 3
      ]);

      _allMutuelles = results[0] as List<Mutuelle>;
      _allFormules = results[1] as List<Formule>;
      _allRegimes = results[2] as List<Regime>; // ✨ NOUVEAU
      final userData = results[3] as Map<String, dynamic>?;

      if (userData != null) {
        _usernameController.text = userData['username'] ?? '';
        _selectedMutuelleId = userData['mutuelle_id'];
        _selectedFormuleId = userData['mutuelle_formule_id'];
        _selectedRegimeId = userData['regime_assurance_maladie_id']; // ✨ NOUVEAU

        if (userData['date_of_birth'] != null) {
          _birthDate = DateTime.tryParse(userData['date_of_birth']);
        }

        // Appliquer le filtre initial pour les formules
        if (_selectedMutuelleId != null) {
          _filteredFormules = _allFormules.where((f) => f.mutuelleId == _selectedMutuelleId).toList();
        }
      }
    } catch (e) {
      debugPrint('Erreur chargement des données initiales: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Map<String, dynamic>?> _loadUserProfileData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // ✨ NOUVEAU : On récupère aussi le regime_assurance_maladie_id
    return await supabase
        .from('user_infos')
        .select('username, date_of_birth, mutuelle_id, mutuelle_formule_id, regime_assurance_maladie_id')
        .eq('user_id', user.id)
        .maybeSingle();
  }

  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = {
      'user_id': user.id,
      'username': _usernameController.text.trim(),
      'date_of_birth': _birthDate?.toIso8601String(), // ✨ Date sauvegardée
      'mutuelle_id': _selectedMutuelleId,
      'mutuelle_formule_id': _selectedFormuleId,
      'regime_assurance_maladie_id': _selectedRegimeId, // ✨ Régime sauvegardé
    };

    try {
      await supabase.from('user_infos').upsert(data, onConflict: 'user_id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil mis à jour avec succès'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur maj profil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _updateFilteredFormules(int mutuelleId) {
    setState(() {
      _filteredFormules = _allFormules.where((formule) => formule.mutuelleId == mutuelleId).toList();
      if (_selectedFormuleId != null && !_filteredFormules.any((f) => f.id == _selectedFormuleId)) {
        _selectedFormuleId = null;
      }
    });
  }

  void _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = _birthDate ?? DateTime(now.year - 25);

    // Design moderne pour le date picker
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal, // Couleur santé
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  // 🎨 DESIGN: Méthode utilitaire pour le style des champs
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.teal)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Fond gris très clair/moderne
      appBar: AppBar(
        title: Text('Mon Profil', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Section Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.teal.shade100,
                    child: Icon(Icons.person, size: 55, color: Colors.teal.shade700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 2. Carte Formulaire
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Informations Personnelles", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 20),

                  // Champ Username
                  TextField(
                    controller: _usernameController,
                    decoration: _buildInputDecoration('Nom d’utilisateur', Icons.person_outline),
                  ),
                  const SizedBox(height: 20),

                  // Champ Date de Naissance (Custom tap)
                  GestureDetector(
                    onTap: _selectBirthDate,
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: _buildInputDecoration(
                            'Date de naissance',
                            Icons.cake_outlined
                        ).copyWith(
                          hintText: _birthDate != null ? DateFormat('dd/MM/yyyy').format(_birthDate!) : 'JJ/MM/AAAA',
                        ),
                        controller: TextEditingController(
                          text: _birthDate != null ? DateFormat('dd MMMM yyyy', 'fr_FR').format(_birthDate!) : '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 3. Carte Santé
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Couverture Santé", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 20),

                  // ✨ NOUVEAU : Dropdown Régime Assurance Maladie
                  DropdownButtonFormField<int>(
                    value: _selectedRegimeId,
                    hint: const Text('Choisir un régime'),
                    items: _allRegimes.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
                    onChanged: (value) => setState(() => _selectedRegimeId = value),
                    decoration: _buildInputDecoration('Régime d’assurance maladie', Icons.local_hospital_outlined),
                    isExpanded: true, // Empêche le débordement de texte
                  ),
                  const SizedBox(height: 20),

                  // Dropdown Mutuelle
                  DropdownButtonFormField<int>(
                    value: _selectedMutuelleId,
                    hint: const Text('Ma mutuelle'),
                    items: _allMutuelles.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedMutuelleId = value);
                        _updateFilteredFormules(value);
                      }
                    },
                    decoration: _buildInputDecoration('Mutuelle', Icons.health_and_safety_outlined),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown Formule
                  DropdownButtonFormField<int>(
                    value: _selectedFormuleId,
                    hint: const Text('Ma formule'),
                    items: _filteredFormules.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
                    onChanged: _selectedMutuelleId == null ? null : (value) => setState(() => _selectedFormuleId = value),
                    decoration: _buildInputDecoration('Formule', Icons.description_outlined).copyWith(
                      filled: _selectedMutuelleId == null,
                      fillColor: _selectedMutuelleId == null ? Colors.grey.shade100 : Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 4. Bouton d'action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                  shadowColor: Colors.teal.withOpacity(0.4),
                ),
                child: Text(
                  'Enregistrer les modifications',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
