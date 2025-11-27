import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

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

class Regime {
  final int id;
  final String name;
  Regime({required this.id, required this.name});
}

// =============================================
// 2️⃣ CLASSE DE SERVICE (LOGIQUE CENTRALISÉE)
// =============================================
class ProfileService {
  final SupabaseClient supabase;
  ProfileService(this.supabase);

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

  Future<List<Regime>> getRegimes() async {
    final response = await supabase.from('assurance_maladie_regimes').select('id, name');
    return (response as List)
        .map((item) => Regime(id: item['id'], name: item['name']))
        .toList();
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    return await supabase
        .from('user_infos')
        .select('username, date_of_birth, mutuelle_id, mutuelle_formule_id, regime_assurance_maladie_id')
        .eq('user_id', user.id)
        .maybeSingle();
  }

  Future<void> saveUserProfile(Map<String, dynamic> data) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }
    final dataWithUser = {...data, 'user_id': user.id};
    await supabase.from('user_infos').upsert(dataWithUser, onConflict: 'user_id');
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

// =============================================
// 3️⃣ ÉCRAN DU PROFIL (UI)
// =============================================
class ProfileScreen extends StatefulWidget {
  final SupabaseClient? supabaseClient;
  final ProfileService? profileService;

  const ProfileScreen({super.key, this.supabaseClient, this.profileService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileService _profileService;

  late TextEditingController _usernameController;
  DateTime? _birthDate;

  int? _selectedMutuelleId;
  int? _selectedFormuleId;
  int? _selectedRegimeId;

  List<Mutuelle> _allMutuelles = [];
  List<Formule> _allFormules = [];
  List<Formule> _filteredFormules = [];
  List<Regime> _allRegimes = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final supabase = widget.supabaseClient ?? Supabase.instance.client;
    _profileService = widget.profileService ?? ProfileService(supabase);
    _usernameController = TextEditingController();

    initializeDateFormatting('fr_FR', null).then((_) {
      if (mounted) {
        _loadInitialData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        _profileService.getMutuelles(),
        _profileService.getFormules(),
        _profileService.getRegimes(),
        _profileService.getUserProfile(), // Appel au service
      ]);

      _allMutuelles = results[0] as List<Mutuelle>;
      _allFormules = results[1] as List<Formule>;
      _allRegimes = results[2] as List<Regime>;
      final userData = results[3] as Map<String, dynamic>?;

      if (userData != null) {
        _usernameController.text = userData['username'] ?? '';
        _selectedMutuelleId = userData['mutuelle_id'];
        _selectedFormuleId = userData['mutuelle_formule_id'];
        _selectedRegimeId = userData['regime_assurance_maladie_id'];

        if (userData['date_of_birth'] != null) {
          _birthDate = DateTime.tryParse(userData['date_of_birth']);
        }

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

  Future<void> _saveProfile() async {
    final data = {
      'username': _usernameController.text.trim(),
      'date_of_birth': _birthDate?.toIso8601String(),
      'mutuelle_id': _selectedMutuelleId,
      'mutuelle_formule_id': _selectedFormuleId,
      'regime_assurance_maladie_id': _selectedRegimeId,
    };

    try {
      await _profileService.saveUserProfile(data); // Appel au service
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

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
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

  Future<void> _signOut() async {
    try {
      await _profileService.signOut(); // Appel au service
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Mon Profil', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            Center(
              child: Container(
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
            ),
            const SizedBox(height: 30),
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
                  TextField(
                    controller: _usernameController,
                    decoration: _buildInputDecoration('Nom d’utilisateur', Icons.person_outline),
                  ),
                  const SizedBox(height: 20),
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
                  DropdownButtonFormField<int>(
                    value: _selectedRegimeId,
                    hint: const Text('Choisir un régime'),
                    items: _allRegimes.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
                    onChanged: (value) => setState(() => _selectedRegimeId = value),
                    decoration: _buildInputDecoration('Régime d’assurance maladie', Icons.local_hospital_outlined),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 20),
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
            Center(
              child: TextButton.icon(
                onPressed: _signOut,
                icon: Icon(Icons.logout, color: Colors.red.shade400),
                label: Text(
                  'Se déconnecter',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade400,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.red.shade100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text(
                'Enregistrer les modifications',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
