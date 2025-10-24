import 'package:flutter/material.dart';

class SuggestionScreen extends StatefulWidget {
  const SuggestionScreen({super.key});

  @override
  State<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen>
    with SingleTickerProviderStateMixin {
  String? selectedSoin;
  String? selectedMutuelle;
  String? selectedPlan;
  bool isEtudiant = false;
  double age = 30;
  String departement = '';
  bool sortByBrss = false; // bouton "Comparer" : tri BRSS décroissant

  late final AnimationController _controller;

  // Filtres
  final List<String> soins = const [
    'Consultation généraliste',
    'Consultation spécialiste',
    'Hospitalisation',
    'Soins dentaires',
    'Optique (lunettes, lentilles)',
    'Prévention & bien-être',
    'Médicaments sur ordonnance',
  ];
  final List<String> mutuelles = const ['MGEN', 'Alan', 'Axa', 'Mutualia'];
  final List<String> plans = const ['Essentiel', 'Standard', 'Confort', 'Premium'];

  // BRSS simulé par mutuelle
  final Map<String, int> tauxBRSS = const {
    'MGEN': 200,
    'Alan': 150,
    'Axa': 300,
    'Mutualia': 120,
  };

  // Offres d’exemple
  final Map<String, Map<String, List<Map<String, dynamic>>>> offres = {
    'MGEN': {
      'Optique (lunettes, lentilles)': [
        {
          'title': 'Paniers 100% Santé (optique)',
          'description': 'Reste à charge zéro sur verres et montures éligibles selon votre contrat.',
          'eligibility': {},
          'source': 'MGEN',
        },
      ],
      'Soins dentaires': [
        {
          'title': 'Couronnes et prothèses 100% Santé',
          'description': 'Certaines prothèses totalement remboursées selon la formule.',
          'eligibility': {'minAge': 18},
          'source': 'MGEN',
        },
      ],
    },
    'Alan': {
      'Consultation généraliste': [
        {
          'title': 'Téléconsultation illimitée',
          'description': 'Consultations à distance incluses pour tous les adhérents.',
          'eligibility': {},
          'source': 'Alan',
        },
      ],
      'Hospitalisation': [
        {
          'title': 'Chambre individuelle (selon plan)',
          'description': 'Prise en charge de la chambre particulière pour le plan Premium.',
          'eligibility': {'plan': 'Premium'},
          'source': 'Alan',
        },
      ],
    },
    'Axa': {
      'Soins dentaires': [
        {
          'title': 'Implants / Prothèses renforcés',
          'description': 'Prise en charge jusqu’à 80% selon la formule souscrite.',
          'eligibility': {'plan': 'Premium'},
          'source': 'Axa',
        },
      ],
      'Optique (lunettes, lentilles)': [
        {
          'title': 'Réseau Itélis partenaires',
          'description': 'Réductions sur montures et verres via le réseau Itélis.',
          'eligibility': {},
          'source': 'Axa',
        },
      ],
    },
    'Mutualia': {
      'Optique (lunettes, lentilles)': [
        {
          'title': 'Réseau Carte Blanche',
          'description': 'Conditions avantageuses pour les assurés d’Île-de-France.',
          'eligibility': {'departement': '75'},
          'source': 'Mutualia',
        },
      ],
    },
  };

  // Palette premium “clinique/luxe”
  Color get _primary => const Color(0xFF0D47A1); // bleu profond
  Color get _accent => const Color(0xFF00B8D9);  // bleu glacé
  Color get _silver => const Color(0xFFE9EEF5);  // argent clair
  Color get _ink => const Color(0xFF0E1A2B);     // encre douce

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 450))
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------- Helpers sûrs ----------
  Map<String, dynamic> _toStringKeyMap(dynamic raw) {
    if (raw == null) return <String, dynamic>{};
    if (raw is Map) return Map<String, dynamic>.from(raw as Map);
    return <String, dynamic>{};
  }

  bool _isEligible(Map<String, dynamic> criteria) {
    if (criteria.isEmpty) return true;
    final minAge = criteria['minAge'];
    final maxAge = criteria['maxAge'];
    final needStudent = criteria['isEtudiant'];
    final needPlan = criteria['plan'];
    final needDept = criteria['departement'];

    if (minAge is num && age < minAge) return false;
    if (maxAge is num && age > maxAge) return false;
    if (needStudent == true && !isEtudiant) return false;
    if (needPlan is String && (selectedPlan ?? '') != needPlan) return false;
    if (needDept is String && (departement) != needDept) return false;
    return true;
  }

  double _calculateEstimate(String mutuelle, String soin) {
    final taux = (tauxBRSS[mutuelle] ?? 100) / 100.0;
    double result = 100.0 * taux;
    if (isEtudiant) result += 5.0;
    if ((selectedPlan ?? '').toLowerCase().contains('premium')) result *= 1.08;
    if (age >= 65) result += 10.0;
    return result;
  }

  List<Map<String, dynamic>> offresFor(String mutuelle, String soin) {
    final mutMap = offres[mutuelle];
    if (mutMap == null) return const [];
    final list = mutMap[soin] ?? const [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  int _countSuggestions() {
    if (selectedSoin == null) return 0;
    final muts = selectedMutuelle != null ? [selectedMutuelle!] : mutuelles;
    int total = 0;
    for (final m in muts) {
      total += offresFor(m, selectedSoin!).length;
    }
    return total;
  }

  // Regroupe toutes les suggestions selon filtres, avec score
  List<_SuggestionEntry> _gatherEntries() {
    final List<_SuggestionEntry> entries = [];
    if (selectedSoin == null) return entries;
    final muts = selectedMutuelle != null ? [selectedMutuelle!] : mutuelles;

    for (final m in muts) {
      for (final offer in offresFor(m, selectedSoin!)) {
        final elig = _isEligible(_toStringKeyMap(offer['eligibility']));
        final brss = tauxBRSS[m] ?? 100;
        final estimate = _calculateEstimate(m, selectedSoin!);
        final score = (elig ? 50 : 0) + brss; // simple scoring : éligibilité prime + BRSS
        entries.add(_SuggestionEntry(
          mutuelle: m,
          soin: selectedSoin!,
          offer: offer,
          eligible: elig,
          brss: brss,
          estimate: estimate,
          score: score.toDouble(),
        ));
      }
    }

    if (sortByBrss) {
      entries.sort((a, b) => b.brss.compareTo(a.brss));
    } else {
      // tri par score (relevance) puis BRSS
      entries.sort((a, b) {
        final c = b.score.compareTo(a.score);
        if (c != 0) return c;
        return b.brss.compareTo(a.brss);
      });
    }
    return entries;
  }

  // Trouve la meilleure recommandation
  _SuggestionEntry? _bestEntry() {
    final all = _gatherEntries();
    if (all.isEmpty) return null;
    return all.first;
  }

  // Icônes Material par type de soin
  IconData _iconForSoin(String soin) {
    switch (soin) {
      case 'Consultation généraliste':
        return Icons.medical_services_rounded;
      case 'Consultation spécialiste':
        return Icons.person_search;
      case 'Hospitalisation':
        return Icons.local_hospital_rounded;
      case 'Soins dentaires':
        return Icons.medical_information_rounded;
      case 'Optique (lunettes, lentilles)':
        return Icons.visibility_rounded;
      case 'Prévention & bien-être':
        return Icons.health_and_safety_rounded;
      case 'Médicaments sur ordonnance':
        return Icons.local_pharmacy;
      default:
        return Icons.health_and_safety_rounded;
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final best = _bestEntry();

    return Scaffold(
      backgroundColor: _silver,
      appBar: AppBar(
        title: const Text("Suggestions personnalisées"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => sortByBrss = !sortByBrss),
            icon: Icon(
              sortByBrss ? Icons.bar_chart_rounded : Icons.auto_awesome_rounded,
              color: _primary,
              size: 20,
            ),
            label: Text(
              sortByBrss ? "Trier BRSS" : "Pertinence",
              style: TextStyle(color: _primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _HeaderPremium(
            title: "Découvrez vos avantages",
            subtitle: "Filtrez, comparez et trouvez le meilleur niveau de prise en charge.",
            primary: _primary,
            accent: _accent,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  // Carte de filtres
                  _FiltersCard(
                    ink: _ink,
                    silver: _silver,
                    onReset: _resetFilters,
                    child: Column(
                      children: [
                        _LabeledField(
                          label: "Type de soin",
                          child: DropdownButtonFormField<String>(
                            value: selectedSoin,
                            hint: const Text("Sélectionnez un soin"),
                            items: soins
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) => setState(() => selectedSoin = v),
                            decoration: _inputDecoration(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _LabeledField(
                                label: "Mutuelle",
                                child: DropdownButtonFormField<String>(
                                  value: selectedMutuelle,
                                  hint: const Text("Toutes"),
                                  items: [null, ...mutuelles]
                                      .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m ?? 'Toutes'),
                                  ))
                                      .toList(),
                                  onChanged: (v) => setState(() => selectedMutuelle = v),
                                  decoration: _inputDecoration(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _LabeledField(
                                label: "Plan",
                                child: DropdownButtonFormField<String>(
                                  value: selectedPlan,
                                  hint: const Text("Tous"),
                                  items: [null, ...plans]
                                      .map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p ?? 'Tous'),
                                  ))
                                      .toList(),
                                  onChanged: (v) => setState(() => selectedPlan = v),
                                  decoration: _inputDecoration(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _LabeledField(
                                label: "Âge : ${age.round()}",
                                child: Slider(
                                  value: age,
                                  min: 0,
                                  max: 100,
                                  divisions: 100,
                                  onChanged: (v) => setState(() => age = v),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _LabeledField(
                                label: "Étudiant",
                                child: Row(
                                  children: [
                                    Switch(
                                      value: isEtudiant,
                                      activeColor: _primary,
                                      onChanged: (v) => setState(() => isEtudiant = v),
                                    ),
                                    Text(isEtudiant ? "Oui" : "Non"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _LabeledField(
                          label: "Département",
                          child: TextFormField(
                            initialValue: departement,
                            decoration: _inputDecoration(hint: 'Ex : 75 (Paris)'),
                            onChanged: (v) => setState(() => departement = v.trim()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Résumé intelligent (reco)
                  if (best != null)
                    _BestCard(
                      entry: best,
                      ink: _ink,
                      primary: _primary,
                      accent: _accent,
                      icon: _iconForSoin(best.soin),
                    )
                  else
                    _EmptyState(
                      title: "Aucune suggestion pour l’instant",
                      subtitle: "Sélectionnez un type de soin et ajustez vos filtres.",
                    ),

                  const SizedBox(height: 12),

                  // Entête "Résultats"
                  if (selectedSoin != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.recommend_rounded, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          "Résultats",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                        const Spacer(),
                        _Pill(
                          text: "${_countSuggestions()} suggestion(s)",
                          bg: Colors.white,
                          fg: Colors.black54,
                          border: Border.all(color: Colors.black12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Liste suggestions
                  ..._gatherEntries().map(
                        (e) => _OfferCard(
                      entry: e,
                      primary: _primary,
                      accent: _accent,
                      ink: _ink,
                      icon: _iconForSoin(e.soin),
                      onTap: () {
                        // Placeholder action (ouvrir détail, etc.)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("« ${e.offer['title']} » — ${e.mutuelle}"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedSoin = null;
      selectedMutuelle = null;
      selectedPlan = null;
      isEtudiant = false;
      age = 30;
      departement = '';
      sortByBrss = false;
    });
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE6ECF5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _primary, width: 1.2),
      ),
    );
  }
}

// --------- Modèles simples ---------
class _SuggestionEntry {
  final String mutuelle;
  final String soin;
  final Map<String, dynamic> offer;
  final bool eligible;
  final int brss;
  final double estimate;
  final double score;

  _SuggestionEntry({
    required this.mutuelle,
    required this.soin,
    required this.offer,
    required this.eligible,
    required this.brss,
    required this.estimate,
    required this.score,
  });
}

// --------- Widgets décoratifs premium ---------
class _HeaderPremium extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color primary;
  final Color accent;

  const _HeaderPremium({
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 38, bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, Color.lerp(primary, accent, 0.35)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 12)),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.verified_user_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ]),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white.withOpacity(0.92), fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onReset;
  final Color ink;
  final Color silver;

  const _FiltersCard({
    required this.child,
    required this.onReset,
    required this.ink,
    required this.silver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6ECF5)),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: ink.withOpacity(0.8)),
              const SizedBox(width: 8),
              Text(
                "Filtres",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Réinitialiser"),
                style: TextButton.styleFrom(
                  foregroundColor: ink.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6, top: 2),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0E1A2B),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final Border? border;

  const _Pill({required this.text, required this.bg, required this.fg, this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: border,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6ECF5)),
      ),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFEEF3FA),
            child: Icon(Icons.info_outline_rounded, color: Color(0xFF0D47A1)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Aucune suggestion pour l’instant.\nSélectionnez un type de soin et ajustez vos filtres.",
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class _BestCard extends StatelessWidget {
  final _SuggestionEntry entry;
  final Color ink;
  final Color primary;
  final Color accent;
  final IconData icon;

  const _BestCard({
    required this.entry,
    required this.ink,
    required this.primary,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = (entry.brss / 300).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFF9FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8)),
        ],
        border: Border.all(color: const Color(0xFFE6ECF5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB300)),
              const SizedBox(width: 8),
              Text("Notre recommandation",
                  style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
              const Spacer(),
              _Pill(text: entry.mutuelle, bg: primary.withOpacity(0.08), fg: primary),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accent.withOpacity(0.12),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    (entry.offer['title'] ?? '') as String,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (entry.offer['description'] ?? '') as String,
                    style: TextStyle(color: ink.withOpacity(0.75)),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.shield_rounded, size: 18, color: primary),
              const SizedBox(width: 6),
              Text("BRSS : ${entry.brss}%",
                  style: TextStyle(fontWeight: FontWeight.w700, color: ink)),
              const Spacer(),
              _Pill(
                text: entry.eligible ? "Éligible" : "Non éligible",
                bg: entry.eligible ? const Color(0xFFE9F8EF) : const Color(0xFFFFF3E6),
                fg: entry.eligible ? const Color(0xFF1E8449) : const Color(0xFFAF601A),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 12,
              backgroundColor: const Color(0xFFE8F0FA),
              color: entry.brss >= 250
                  ? const Color(0xFF2ECC71)
                  : (entry.brss >= 150
                  ? const Color(0xFF5DADE2)
                  : const Color(0xFFF39C12)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.euro, size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                "Estimation : ${entry.estimate.toStringAsFixed(0)} €",
                style: TextStyle(fontWeight: FontWeight.w800, color: ink),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

class _OfferCard extends StatefulWidget {
  final _SuggestionEntry entry;
  final Color primary;
  final Color accent;
  final Color ink;
  final IconData icon;
  final VoidCallback? onTap;

  const _OfferCard({
    required this.entry,
    required this.primary,
    required this.accent,
    required this.ink,
    required this.icon,
    this.onTap,
  });

  @override
  State<_OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<_OfferCard> {
  double _elev = 8;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final normalized = (e.brss / 300).clamp(0.0, 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _elev = 14),
      onExit: (_) => setState(() => _elev = 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0x12000000),
              blurRadius: _elev,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF9FBFF)],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE6ECF5), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: widget.accent.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: widget.accent.withOpacity(0.25)),
                        ),
                        child: Icon(widget.icon, color: widget.accent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          (e.offer['title'] ?? '') as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: widget.ink,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Pill(
                        text: e.mutuelle,
                        bg: widget.primary.withOpacity(0.08),
                        fg: widget.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (e.offer['description'] ?? '') as String,
                    style: TextStyle(color: widget.ink.withOpacity(0.75), height: 1.35),
                  ),
                  const SizedBox(height: 16),
                  // BRSS + barre
                  Row(
                    children: [
                      Icon(Icons.shield_rounded, size: 18, color: widget.primary),
                      const SizedBox(width: 6),
                      Text(
                        "BRSS : ${e.brss}%",
                        style: TextStyle(color: widget.ink, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: normalized,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFE8F0FA),
                      color: e.brss >= 250
                          ? const Color(0xFF2ECC71)
                          : (e.brss >= 150
                          ? const Color(0xFF5DADE2)
                          : const Color(0xFFF39C12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Pill(
                        text: e.eligible ? "Éligible" : "Non éligible",
                        bg: e.eligible ? const Color(0xFFE9F8EF) : const Color(0xFFFFF3E6),
                        fg: e.eligible ? const Color(0xFF1E8449) : const Color(0xFFAF601A),
                      ),
                      Text(
                        e.eligible ? "Estimation : ${e.estimate.toStringAsFixed(0)} €" : "—",
                        style: TextStyle(fontWeight: FontWeight.w800, color: widget.ink),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}