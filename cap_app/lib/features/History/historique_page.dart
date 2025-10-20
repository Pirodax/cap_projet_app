// lib/historique_page.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

// Modèle de données pour une simulation
class Simulation {
  final String id;
  final String titre;
  final String categorie;
  final double montant;
  final double economieEstimee;
  final DateTime date;
  final IconData icon;
  final Color color;

  Simulation({
    required this.id,
    required this.titre,
    required this.categorie,
    required this.montant,
    required this.economieEstimee,
    required this.date,
    required this.icon,
    required this.color,
  });
}

// Données pour le graphique
class MonthData {
  final String month;
  final double montant;

  MonthData(this.month, this.montant);
}

class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage>
    with TickerProviderStateMixin {
  int _currentIndex = 1;
  late AnimationController _animationController;
  late AnimationController _skeletonController;
  late Animation<double> _animation;
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  String _selectedPeriod = 'Tout'; // Nouveau : période sélectionnée
  String _sortBy = 'date_desc';
  bool _isLoading = true;

  final List<String> _categories = [
    'Tous',
    'Spécialiste',
    'Généraliste',
    'Imagerie',
    'Laboratoire',
    'Dentaire',
  ];

  List<Simulation> _simulations = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _skeletonController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _simulations = [
        Simulation(
          id: '1',
          titre: 'Consultation ORL',
          categorie: 'Spécialiste',
          montant: 50.00,
          economieEstimee: 35.00,
          date: DateTime.now().subtract(const Duration(days: 2)),
          icon: Icons.local_hospital,
          color: Colors.blue,
        ),
        Simulation(
          id: '2',
          titre: 'Médecin généraliste',
          categorie: 'Généraliste',
          montant: 25.00,
          economieEstimee: 17.50,
          date: DateTime.now().subtract(const Duration(days: 5)),
          icon: Icons.medical_services,
          color: Colors.green,
        ),
        Simulation(
          id: '3',
          titre: 'Radiographie thorax',
          categorie: 'Imagerie',
          montant: 80.00,
          economieEstimee: 56.00,
          date: DateTime.now().subtract(const Duration(days: 10)),
          icon: Icons.camera_alt,
          color: Colors.purple,
        ),
        Simulation(
          id: '4',
          titre: 'Analyse sanguine',
          categorie: 'Laboratoire',
          montant: 35.00,
          economieEstimee: 24.50,
          date: DateTime.now().subtract(const Duration(days: 15)),
          icon: Icons.biotech,
          color: Colors.orange,
        ),
        Simulation(
          id: '5',
          titre: 'Consultation dentiste',
          categorie: 'Dentaire',
          montant: 70.00,
          economieEstimee: 21.00,
          date: DateTime.now().subtract(const Duration(days: 20)),
          icon: Icons.health_and_safety,
          color: Colors.teal,
        ),
        Simulation(
          id: '6',
          titre: 'IRM cérébrale',
          categorie: 'Imagerie',
          montant: 150.00,
          economieEstimee: 105.00,
          date: DateTime.now().subtract(const Duration(days: 30)),
          icon: Icons.memory,
          color: Colors.indigo,
        ),
        Simulation(
          id: '7',
          titre: 'Ophtalmologue',
          categorie: 'Spécialiste',
          montant: 45.00,
          economieEstimee: 31.50,
          date: DateTime.now().subtract(const Duration(days: 45)),
          icon: Icons.visibility,
          color: Colors.cyan,
        ),
        Simulation(
          id: '8',
          titre: 'Kinésithérapeute',
          categorie: 'Spécialiste',
          montant: 30.00,
          economieEstimee: 18.00,
          date: DateTime.now().subtract(const Duration(days: 60)),
          icon: Icons.accessibility_new,
          color: Colors.pink,
        ),
      ];
      _isLoading = false;
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _skeletonController.dispose();
    super.dispose();
  }

  double get _totalEconomie {
    final filtered = _getFilteredAndSortedSimulations();
    return filtered.fold(0.0, (sum, item) => sum + item.economieEstimee);
  }

  double get _totalMontant {
    final filtered = _getFilteredAndSortedSimulations();
    return filtered.fold(0.0, (sum, item) => sum + item.montant);
  }

  double get _tauxEconomie {
    if (_totalMontant == 0) return 0;
    return (_totalEconomie / _totalMontant) * 100;
  }

  // Calculer les totaux par catégorie
  Map<String, Map<String, double>> get _categoryTotals {
    final Map<String, Map<String, double>> totals = {};

    for (var sim in _getFilteredAndSortedSimulations()) {
      if (!totals.containsKey(sim.categorie)) {
        totals[sim.categorie] = {
          'montant': 0.0,
          'economie': 0.0,
          'count': 0.0,
        };
      }
      totals[sim.categorie]!['montant'] =
          (totals[sim.categorie]!['montant'] ?? 0) + sim.montant;
      totals[sim.categorie]!['economie'] =
          (totals[sim.categorie]!['economie'] ?? 0) + sim.economieEstimee;
      totals[sim.categorie]!['count'] =
          (totals[sim.categorie]!['count'] ?? 0) + 1;
    }

    return totals;
  }

  List<MonthData> get _chartData {
    final Map<String, double> monthlyData = {};

    for (var sim in _simulations) {
      final monthKey = _getMonthName(sim.date.month).substring(0, 3);
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + sim.economieEstimee;
    }

    return monthlyData.entries
        .map((e) => MonthData(e.key, e.value))
        .toList()
        .reversed
        .take(6)
        .toList()
        .reversed
        .toList();
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return months[month - 1];
  }

  List<Simulation> _getFilteredAndSortedSimulations() {
    var filtered = _simulations.where((simulation) {
      final matchesSearch = _searchQuery.isEmpty ||
          simulation.titre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          simulation.categorie
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'Tous' || simulation.categorie == _selectedCategory;

      // Filtre par période
      final now = DateTime.now();
      bool matchesPeriod = true;

      if (_selectedPeriod == '7 jours') {
        matchesPeriod = now.difference(simulation.date).inDays <= 7;
      } else if (_selectedPeriod == '30 jours') {
        matchesPeriod = now.difference(simulation.date).inDays <= 30;
      } else if (_selectedPeriod == '3 mois') {
        matchesPeriod = now.difference(simulation.date).inDays <= 90;
      }
      // Si 'Tout', matchesPeriod reste true

      return matchesSearch && matchesCategory && matchesPeriod;
    }).toList();

    switch (_sortBy) {
      case 'date_asc':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'date_desc':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'montant_desc':
        filtered.sort((a, b) => b.montant.compareTo(a.montant));
        break;
      case 'montant_asc':
        filtered.sort((a, b) => a.montant.compareTo(b.montant));
        break;
      case 'economie_desc':
        filtered.sort((a, b) => b.economieEstimee.compareTo(a.economieEstimee));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredSimulations = _getFilteredAndSortedSimulations();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Historique des simulations',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.black87),
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date_desc',
                child: Text('Plus récent'),
              ),
              const PopupMenuItem(
                value: 'date_asc',
                child: Text('Plus ancien'),
              ),
              const PopupMenuItem(
                value: 'montant_desc',
                child: Text('Montant élevé'),
              ),
              const PopupMenuItem(
                value: 'montant_asc',
                child: Text('Montant faible'),
              ),
              const PopupMenuItem(
                value: 'economie_desc',
                child: Text('Meilleure économie'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading ? _buildSkeletonLoader() : _buildContent(filteredSimulations),
      ),
    );
  }

  Widget _buildContent(List<Simulation> filteredSimulations) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques rapides
            _buildQuickStats(),
            const SizedBox(height: 20),

            // Barre de recherche (montée en priorité)
            _buildSearchBar(),
            const SizedBox(height: 16),

            // Section Filtres (Catégorie + Période)
            const Text(
              'Filtres',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Filtres par catégorie
            _buildCategoryFilters(),
            const SizedBox(height: 12),

            // Filtres par période
            _buildPeriodFilters(),
            const SizedBox(height: 20),

            // Boutons compacts en 2 colonnes
            Row(
              children: [
                Expanded(child: _buildCompactGraphButton()),
                const SizedBox(width: 12),
                Expanded(child: _buildCompactCategoryButton()),
              ],
            ),
            const SizedBox(height: 24),

            // Header avec nombre de résultats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Simulations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${filteredSimulations.length} résultats',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Liste des simulations
            if (filteredSimulations.isEmpty)
              _buildEmptyState()
            else
              ...List.generate(
                filteredSimulations.length,
                    (index) => TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSimulationCard(filteredSimulations[index]),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Bouton pour ajouter une simulation
            _buildAddSimulationButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total économisé',
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 2000),
              tween: Tween<double>(begin: 0, end: _totalEconomie),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Text(
                  '${value.toStringAsFixed(0)}€',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                );
              },
            ),
            Icons.savings,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Simulations',
            Text(
              '${_simulations.length}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Icons.history,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Économie moy.',
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Text(
                  '${(_tauxEconomie * _animation.value).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                );
              },
            ),
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, Widget value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          value,
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Bouton pour afficher le graphique
  Widget _buildGraphButton() {
    return InkWell(
      onTap: _showGraphModal,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voir le graphique',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Économies sur 6 mois',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  // Bouton pour afficher les totaux par catégorie
  Widget _buildCategoryTotalsButton() {
    final totals = _categoryTotals;
    final categoriesCount = totals.length;

    return InkWell(
      onTap: _showCategoryTotalsModal,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[400]!, Colors.purple[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.pie_chart_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voir par catégorie',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$categoriesCount catégories actives',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  // Modal des totaux par catégorie
  void _showCategoryTotalsModal() {
    final totals = _categoryTotals;
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value['economie']!.compareTo(a.value['economie']!));

    // Couleurs par catégorie
    final categoryColors = {
      'Spécialiste': Colors.blue,
      'Généraliste': Colors.green,
      'Imagerie': Colors.purple,
      'Laboratoire': Colors.orange,
      'Dentaire': Colors.teal,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.pie_chart_rounded,
                      color: Colors.purple[600],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Totaux par catégorie',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Répartition de vos économies',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Résumé global
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${_totalEconomie.toStringAsFixed(0)}€',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total économisé',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey[300],
                    ),
                    Column(
                      children: [
                        Text(
                          '${entries.length}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Catégories',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Détails par catégorie',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Liste des catégories
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final category = entry.key;
                    final economie = entry.value['economie']!;
                    final montant = entry.value['montant']!;
                    final count = entry.value['count']!.toInt();
                    final percentage = (_totalEconomie > 0)
                        ? (economie / _totalEconomie * 100)
                        : 0.0;
                    final color = categoryColors[category] ?? Colors.grey;

                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 500 + (index * 100)),
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: color.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            category,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${economie.toStringAsFixed(2)} €',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Barre de progression
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: TweenAnimationBuilder<double>(
                                      duration: Duration(milliseconds: 800 + (index * 100)),
                                      tween: Tween(begin: 0, end: percentage / 100),
                                      builder: (context, value, child) {
                                        return LinearProgressIndicator(
                                          value: value,
                                          minHeight: 8,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation<Color>(color),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$count simulation${count > 1 ? 's' : ''}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}% du total',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modal du graphique
  void _showGraphModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Graphique des économies',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Économies estimées sur les 6 derniers mois',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildChart()),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    final data = _chartData;
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Pas encore de données',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    final maxValue = data.map((e) => e.montant).reduce(math.max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((monthData) {
                final heightPercent = monthData.montant / maxValue;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${monthData.montant.toStringAsFixed(0)}€',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1000),
                          tween: Tween<double>(begin: 0, end: heightPercent),
                          builder: (context, double value, child) {
                            return Container(
                              height: 150 * value,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          monthData.month,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Rechercher une simulation...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () => setState(() => _searchQuery = ''),
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildPeriodFilters() {
    final periods = ['Tout', '7 jours', '30 jours', '3 mois'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final period = periods[index];
          final isSelected = period == _selectedPeriod;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isSelected ? Colors.orange[700] : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(period),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedPeriod = period);
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.orange[100],
              labelStyle: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.orange[700] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Colors.orange : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }

  // Bouton compact pour le graphique
  Widget _buildCompactGraphButton() {
    return InkWell(
      onTap: _showGraphModal,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[600],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              'Graphique',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bouton compact pour les catégories
  Widget _buildCompactCategoryButton() {
    final totals = _categoryTotals;
    return InkWell(
      onTap: _showCategoryTotalsModal,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple[600],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Catégories',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue[100],
              labelStyle: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.blue[700] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimulationCard(Simulation simulation) {
    return InkWell(
      onTap: () => _showSimulationDetails(simulation),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: simulation.color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: simulation.color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: simulation.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    simulation.icon,
                    color: simulation.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        simulation.titre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        simulation.categorie,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Montant',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${simulation.montant.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Économie estimée',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${simulation.economieEstimee.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(simulation.date),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Bouton pour ajouter une simulation
  Widget _buildAddSimulationButton() {
    return InkWell(
      onTap: _showAddSimulationDialog,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue[300]!, width: 2, style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Colors.blue[600],
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Ajouter une simulation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog pour ajouter une simulation
  void _showAddSimulationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ajouter une simulation'),
        content: const Text(
          'Cette fonctionnalité permettrait d\'ajouter manuellement une simulation.\n\nVous pouvez la connecter à un formulaire ou à votre API.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Ajoutez ici la logique pour ouvrir un formulaire
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Aucune simulation trouvée',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: List.generate(
                3,
                    (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
                    child: _buildSkeletonBox(100),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSkeletonBox(80),
            const SizedBox(height: 24),
            _buildSkeletonBox(50),
            const SizedBox(height: 16),
            ...List.generate(
              5,
                  (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSkeletonBox(140),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBox(double height) {
    return AnimatedBuilder(
      animation: _skeletonController,
      builder: (context, child) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _skeletonController.value - 0.3,
                _skeletonController.value,
                _skeletonController.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Aujourd\'hui';
    if (difference == 1) return 'Hier';
    if (difference < 7) return 'Il y a $difference jours';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSimulationDetails(Simulation simulation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: simulation.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      simulation.icon,
                      color: simulation.color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          simulation.titre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          simulation.categorie,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildDetailRow('Montant total', '${simulation.montant.toStringAsFixed(2)} €'),
              _buildDetailRow('Remboursement prévu', '${simulation.economieEstimee.toStringAsFixed(2)} €'),
              _buildDetailRow(
                'Reste à charge',
                '${(simulation.montant - simulation.economieEstimee).toStringAsFixed(2)} €',
              ),
              _buildDetailRow(
                'Taux de remboursement',
                '${((simulation.economieEstimee / simulation.montant) * 100).toStringAsFixed(0)}%',
              ),
              _buildDetailRow('Date de simulation', _formatDate(simulation.date)),
              _buildDetailRow('Référence', '#${simulation.id.toUpperCase()}'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ceci est une estimation. Les remboursements réels peuvent varier.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: simulation.color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}