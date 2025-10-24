import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PageSimu extends StatefulWidget {
  const PageSimu({super.key});

  @override
  State<PageSimu> createState() => _PageSimuState();
}

class _PageSimuState extends State<PageSimu> with SingleTickerProviderStateMixin {
  String? selectedSoin;
  String? mutuelleName;
  String? planName;
  String? estEtudiant;
  int? age;
  String? departement;
  double estimation = 0.0;

  late AnimationController _controller;
  bool _isDarkMode = false; // 🔹 état manuel du thème

  final List<String> soins = [
    'Consultation généraliste',
    'Consultation spécialiste',
    'Hospitalisation',
    'Soins dentaires',
    'Optique (lunettes, lentilles)',
    'Médicaments sur ordonnance',
  ];

  final List<String> mutuelles = ['MGEN', 'Alan', 'Axa', 'Mutualia'];
  final List<String> plans = ['Essentiel', 'Standard', 'Confort', 'Premium'];

  final Map<String, int> tauxBRSS = {
    'MGEN': 200,
    'Alan': 150,
    'Axa': 300,
    'Mutualia': 100,
  };

  final Map<String, Map<String, List<Map<String, dynamic>>>> offresParSoin = {
    'MGEN': {
      'Soins dentaires': [
        {
          'title': 'Détartrage gratuit',
          'description': 'Une séance annuelle gratuite pour les adhérents.',
          'eligibility': {'minAge': 18, 'maxAge': 60},
        },
        {
          'title': 'Couronne remboursée à 100%',
          'description': 'Remboursement complet pour les seniors de 65 ans et +.',
          'eligibility': {'minAge': 65},
        },
      ],
      'Optique (lunettes, lentilles)': [
        {
          'title': 'Pack étudiant - 2e paire offerte',
          'description': 'Offre spéciale pour les étudiants de moins de 26 ans.',
          'eligibility': {'isEtudiant': true, 'maxAge': 26},
        },
        {
          'title': 'Monture gratuite en réseau partenaire',
          'description': 'Disponible pour les plans Premium dans toute la France.',
          'eligibility': {'plan': 'Premium'},
        },
      ],
    },
    'Alan': {
      'Consultation généraliste': [
        {
          'title': 'Téléconsultation gratuite 24h/24',
          'description': 'Disponible pour tous les adhérents, sans condition.',
          'eligibility': {},
        },
      ],
      'Hospitalisation': [
        {
          'title': 'Chambre individuelle offerte',
          'description': 'Réservée aux adhérents Premium âgés de plus de 30 ans.',
          'eligibility': {'plan': 'Premium', 'minAge': 30},
        },
      ],
    },
    'Axa': {
      'Soins dentaires': [
        {
          'title': 'Implant remboursé à 80%',
          'description': 'Offre pour les assurés Premium de plus de 40 ans.',
          'eligibility': {'plan': 'Premium', 'minAge': 40},
        },
        {
          'title': 'Consultation dentaire enfant gratuite',
          'description': 'Valable pour les moins de 18 ans dans le département 75.',
          'eligibility': {'maxAge': 18, 'departement': '75'},
        },
      ],
    },
    'Mutualia': {
      'Optique (lunettes, lentilles)': [
        {
          'title': 'Remise régionale',
          'description':
          '10 % de réduction sur les verres pour les assurés d’Île-de-France.',
          'eligibility': {'departement': '75'},
        },
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  void calculerSimulation() {
    if (selectedSoin == null || mutuelleName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez choisir un soin et une mutuelle."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    double base = 100.0;
    double taux = (tauxBRSS[mutuelleName!] ?? 100) / 100;
    double rem = base * taux;

    if (planName != null && planName!.toLowerCase().contains('premium')) rem *= 1.1;
    if (estEtudiant == 'Oui') rem += 5;
    if ((age ?? 0) > 65) rem += 10;

    setState(() {
      estimation = rem;
    });

    _controller.forward(from: 0);
  }

  bool estEligible(Map<String, dynamic> criteria) {
    if (criteria.isEmpty) return true;
    if (criteria['isEtudiant'] == true && estEtudiant != 'Oui') return false;
    if (criteria['plan'] != null &&
        planName != null &&
        planName != criteria['plan']) return false;
    if (criteria['departement'] != null &&
        departement != criteria['departement']) return false;
    if (criteria['minAge'] != null && (age ?? 0) < criteria['minAge']) return false;
    if (criteria['maxAge'] != null && (age ?? 200) > criteria['maxAge']) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = _isDarkMode;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        centerTitle: true,
        title: Text(
          "Simulation de droits santé",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          // 🔹 Switch pour changer manuellement le mode
          Row(
            children: [
              Icon(isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? Colors.tealAccent[400] : Colors.blueAccent),
              Switch(
                value: _isDarkMode,
                activeColor: Colors.tealAccent[400],
                inactiveThumbColor: Colors.blueAccent,
                onChanged: (value) {
                  setState(() => _isDarkMode = value);
                },
              ),
            ],
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSectionCard(
                icon: Icons.healing_outlined,
                title: "1. Choisissez un soin",
                child: DropdownButtonFormField<String>(
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration(isDark, hint: "Type de soin"),
                  value: selectedSoin,
                  items: soins.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => selectedSoin = val),
                ),
              ),
              if (selectedSoin != null)
                _buildSectionCard(
                  icon: Icons.local_hospital_outlined,
                  title: "2. Sélectionnez votre mutuelle",
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        dropdownColor: cardColor,
                        style: TextStyle(color: textColor),
                        decoration: _inputDecoration(isDark, hint: "Mutuelle"),
                        value: mutuelleName,
                        items: mutuelles
                            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (val) => setState(() => mutuelleName = val),
                      ),
                      const SizedBox(height: 18),
                      if (mutuelleName != null) _buildTauxBRSSBar(mutuelleName!, isDark),
                      const SizedBox(height: 18),
                      if (mutuelleName != null)
                        _buildFilteredOffers(mutuelleName!, selectedSoin!, isDark),
                    ],
                  ),
                ),
              _buildSectionCard(
                icon: Icons.person_outline,
                title: "3. Informations personnelles",
                child: _buildInputCard(isDark),
              ),
              _buildSectionCard(
                icon: Icons.euro_symbol,
                title: "4. Résultat de simulation",
                child: _buildResultCard(isDark),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: calculerSimulation,
                icon: const Icon(Icons.calculate_rounded),
                label: const Text("Lancer la simulation"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.tealAccent[400] : Colors.blueAccent,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- SOUS-COMPOSANTS VISUELS ----------

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final bool isDark = _isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Icon(icon,
                color: isDark ? Colors.tealAccent[400] : Colors.blueAccent,
                size: 24),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
        const SizedBox(height: 15),
        child,
      ]),
    );
  }

  Widget _buildTauxBRSSBar(String mutuelle, bool isDark) {
    int taux = tauxBRSS[mutuelle] ?? 100;
    double normalized = taux / 300;
    Color barColor = taux >= 250
        ? Colors.greenAccent
        : taux >= 150
        ? Colors.lightBlueAccent
        : Colors.orangeAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Taux de remboursement BRSS : $taux%",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 14,
          percent: normalized.clamp(0.0, 1.0),
          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
          progressColor: barColor,
          animation: true,
          barRadius: const Radius.circular(12),
        ),
      ],
    );
  }

  Widget _buildFilteredOffers(String mutuelle, String soin, bool isDark) {
    final offres = offresParSoin[mutuelle]?[soin] ?? [];
    if (offres.isEmpty) {
      return Text("Aucune offre spéciale pour ce soin.",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54));
    }
    return Column(
      children: offres.map((offer) {
        bool eligible = estEligible(offer['eligibility']);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: eligible
                ? (isDark ? Colors.teal.withOpacity(0.2) : Colors.green[50])
                : (isDark ? Colors.grey[850] : Colors.grey[100]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                eligible ? Icons.check_circle : Icons.info_outline,
                color: eligible
                    ? (isDark ? Colors.tealAccent : Colors.green)
                    : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer['title'],
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                              isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 4),
                      Text(offer['description'],
                          style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.black54)),
                      if (eligible)
                        Text("✅ Éligible à cette offre",
                            style: TextStyle(
                                color: isDark
                                    ? Colors.tealAccent
                                    : Colors.green,
                                fontWeight: FontWeight.w500)),
                    ]),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInputCard(bool isDark) {
    return Column(children: [
      DropdownButtonFormField<String>(
        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        value: planName,
        hint: const Text("Plan"),
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: _inputDecoration(isDark),
        items: plans.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (val) => setState(() => planName = val),
      ),
      const SizedBox(height: 15),
      DropdownButtonFormField<String>(
        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        value: estEtudiant,
        hint: const Text("Étudiant ?"),
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: _inputDecoration(isDark),
        items: ['Oui', 'Non']
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: (val) => setState(() => estEtudiant = val),
      ),
      const SizedBox(height: 15),
      TextFormField(
        decoration: _inputDecoration(isDark, label: "Âge"),
        keyboardType: TextInputType.number,
        onChanged: (val) => age = int.tryParse(val),
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      const SizedBox(height: 15),
      TextFormField(
        decoration: _inputDecoration(isDark, label: "Département"),
        onChanged: (val) => departement = val,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
    ]);
  }

  Widget _buildResultCard(bool isDark) {
    return FadeTransition(
      opacity: _controller.drive(CurveTween(curve: Curves.easeInOut)),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.tealAccent.withOpacity(0.5), Colors.cyanAccent.withOpacity(0.4)]
                : [const Color(0xFF8FD3F4), const Color(0xFF84FAB0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.euro, color: Colors.white, size: 30),
            const SizedBox(width: 16),
            Text(
              estimation == 0 ? "—" : "${estimation.toStringAsFixed(2)} €",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, {String? label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
    );
  }
}