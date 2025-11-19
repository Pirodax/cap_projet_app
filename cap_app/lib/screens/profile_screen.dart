import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// =============================================
// MODÈLES DE DONNÉES (inchangés)
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

// =============================================
//  CLASSE DE SERVICE (inchangée)
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
}

// =============================================
//  ÉCRAN DU PROFIL
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

  // ↔️ CHANGÉ: Plus besoin de Future ici, on les utilise directement dans les FutureBuilders.
  List<Mutuelle> _allMutuelles = [];
  List<Formule> _allFormules = [];
  List<Formule> _filteredFormules = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // On charge tout en parallèle pour plus d'efficacité
      final results = await Future.wait([
        _profileService.getMutuelles(),
        _profileService.getFormules(),
        _loadUserProfileData(), // Charge les données spécifiques à l'utilisateur
      ]);

      // On assigne les résultats aux variables d'état
      _allMutuelles = results[0] as List<Mutuelle>;
      _allFormules = results[1] as List<Formule>;
      final userData = results[2] as Map<String, dynamic>?;

      if (userData != null) {
        _usernameController.text = userData['username'] ?? '';
        _selectedMutuelleId = userData['mutuelle_id'];
        _selectedFormuleId = userData['mutuelle_formule_id'];
        if (userData['date_of_birth'] != null) {
          _birthDate = DateTime.tryParse(userData['date_of_birth']);
        }

        if (_selectedMutuelleId != null) {
          // La mise à jour du filtre ne doit pas être dans un setState ici
          _filteredFormules = _allFormules.where((f) => f.mutuelleId == _selectedMutuelleId).toList();
        }
      }
    } catch (e) {
      debugPrint('Erreur chargement des données initiales: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement des données: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<Map<String, dynamic>?> _loadUserProfileData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    return await supabase
        .from('user_infos')
        .select('username, date_of_birth, mutuelle_id, mutuelle_formule_id')
        .eq('user_id', user.id)
        .maybeSingle();
  }

  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = {
      'user_id': user.id,
      'username': _usernameController.text.trim(),
      'date_of_birth': _birthDate?.toIso8601String(),
      'mutuelle_id': _selectedMutuelleId,
      'mutuelle_formule_id': _selectedFormuleId,
    };

    try {
      await supabase.from('user_infos').upsert(data, onConflict: 'user_id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour ✅')),
        );
      }
    } catch (e) {
      debugPrint('Erreur maj profil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
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
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon profil', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [IconButton(icon: const Icon(Icons.save_rounded), onPressed: _saveProfile)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ... Avatar et autres widgets
            CircleAvatar(
              radius: 45,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child:
              const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nom d’utilisateur',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date de naissance'),
              subtitle: Text(_birthDate != null
                  ? DateFormat('dd MMM yyyy').format(_birthDate!)
                  : 'Non renseignée'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: _selectBirthDate,
              ),
            ),
            const Divider(height: 30),

            // === MENU DÉROULANT DES MUTUELLES ===
            DropdownButtonFormField<int>(
              value: _selectedMutuelleId,
              hint: const Text('Choisir une mutuelle'),
              items: _allMutuelles.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMutuelleId = value);
                  _updateFilteredFormules(value);
                }
              },
              decoration: InputDecoration(
                labelText: 'Mutuelle',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            // === MENU DÉROULANT DES FORMULES ===
            DropdownButtonFormField<int>(
              value: _selectedFormuleId,
              hint: const Text('Choisir une formule'),
              items: _filteredFormules.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
              onChanged: _selectedMutuelleId == null ? null : (value) => setState(() => _selectedFormuleId = value),
              decoration: InputDecoration(
                labelText: 'Formule',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: _selectedMutuelleId == null,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: const Text('Enregistrer les modifications', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
