import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  late TextEditingController _usernameController;
  DateTime? _birthDate;
  String? _selectedMutuelle;
  String? _selectedFormule;
  String? _selectedRegime;

  final List<String> mutuelles = ['Alan', 'MGEN', 'Axa', 'Mutualia'];
  final List<String> formules = ['Standard', 'Premium', 'Jeune'];
  final List<String> regimes = ['Régime général', 'Étudiant', 'MSA', 'RSI'];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('user_infos')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (data != null) {
        setState(() {
          _usernameController.text = data['username'] ?? '';
          _selectedMutuelle = data['mituelle_id'];
          _selectedFormule = data['mituelle_formule_id'];
          _selectedRegime = data['regime_assurance_maladie_id'];
          if (data['date_of_birth'] != null) {
            _birthDate = DateTime.tryParse(data['date_of_birth']);
          }
        });
      } else {
        // si aucun profil n’existe encore → le créer automatiquement
        await supabase.from('user_infos').insert({
          'user_id': user.id,
          'username': user.email ?? 'Utilisateur',
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement profil: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = {
      'username': _usernameController.text.trim(),
      'date_of_birth': _birthDate != null
          ? DateFormat('yyyy-MM-dd').format(_birthDate!)
          : null,
      'mituelle_id': _selectedMutuelle,
      'mituelle_formule_id': _selectedFormule,
      'regime_assurance_maladie_id': _selectedRegime,
    };

    try {
      await supabase
          .from('user_infos')
          .update(data)
          .eq('user_id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour ✅')),
        );
      }
    } catch (e) {
      debugPrint('Erreur maj profil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour ❌')),
        );
      }
    }
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
    final cs = Theme.of(context).colorScheme;
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('Mon profil',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _saveProfile,
            tooltip: 'Enregistrer les modifications',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: cs.primaryContainer,
              child:
              const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text('Bonjour 👋', style: GoogleFonts.poppins(fontSize: 18)),
            const SizedBox(height: 6),
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
            DropdownButtonFormField<String>(
              value: _selectedMutuelle,
              hint: const Text('Mutuelle'),
              items: mutuelles
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedMutuelle = v),
              decoration: InputDecoration(
                labelText: 'Mutuelle',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedFormule,
              hint: const Text('Formule'),
              items: formules
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedFormule = v),
              decoration: InputDecoration(
                labelText: 'Formule',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedRegime,
              hint: const Text('Régime d’assurance maladie'),
              items: regimes
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRegime = v),
              decoration: InputDecoration(
                labelText: 'Régime d’assurance maladie',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: cs.primary,
                ),
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: const Text(
                  'Enregistrer les modifications',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
