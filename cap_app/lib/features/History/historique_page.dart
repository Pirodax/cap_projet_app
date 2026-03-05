import 'package:flutter/material.dart';
import '../../models/simulation_history.dart';
import '../../services/simulation_history_service.dart';
import '../../widgets/search_bar.dart';

// Map category name to a color for display
Color _colorForCategory(String? categorieName) {
  switch (categorieName?.toLowerCase()) {
    case 'consultations et visites':
    case 'généraliste':
      return Colors.green;
    case 'spécialistes':
    case 'spécialiste':
      return Colors.blue;
    case 'imagerie médicale':
    case 'imagerie':
      return Colors.purple;
    case 'analyses et biologie':
    case 'laboratoire':
      return Colors.orange;
    case 'dentaire':
    case 'soins dentaires':
      return Colors.teal;
    case 'optique':
      return Colors.cyan;
    case 'hospitalisation':
      return Colors.red;
    case 'pharmacie':
      return Colors.indigo;
    case 'audioprothèses':
      return Colors.pink;
    default:
      return Colors.blueGrey;
  }
}

class HistoriquePage extends StatefulWidget {
  final bool isActive;

  const HistoriquePage({super.key, this.isActive = false});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage>
    with TickerProviderStateMixin {
  final SimulationHistoryService _historyService = SimulationHistoryService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late AnimationController _animationController;
  late AnimationController _skeletonController;
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  String _selectedPeriod = 'Tout';
  String _sortBy = 'date_desc';
  bool _isLoading = true;

  List<SimulationHistory> _simulations = [];

  // Dynamic categories built from loaded data
  List<String> get _categories {
    final cats = _simulations
        .map((s) => s.categorieName ?? 'Autre')
        .toSet()
        .toList()
      ..sort();
    return ['Tous', ...cats];
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _skeletonController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });

    _loadData();
  }

  @override
  void didUpdateWidget(covariant HistoriquePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final simulations = await _historyService.getSimulations();
      setState(() {
        _simulations = simulations;
        _isLoading = false;
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSimulation(SimulationHistory simulation) async {
    await _historyService.deleteSimulation(simulation.id);
    setState(() {
      _simulations.removeWhere((s) => s.id == simulation.id);
    });
  }

  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content:
            const Text('Supprimer cette simulation de l\'historique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDelete(SimulationHistory simulation) async {
    final confirmed = await _confirmDelete();
    if (confirmed == true) {
      _deleteSimulation(simulation);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _skeletonController.dispose();
    super.dispose();
  }

  double get _totalRembourse {
    final filtered = _getFilteredAndSortedSimulations();
    return filtered.fold(0.0, (sum, item) => sum + item.totalRembourse);
  }

  // Category totals for the modal
  Map<String, Map<String, double>> get _categoryTotals {
    final Map<String, Map<String, double>> totals = {};

    for (var sim in _getFilteredAndSortedSimulations()) {
      final cat = sim.categorieName ?? 'Autre';
      if (!totals.containsKey(cat)) {
        totals[cat] = {
          'montant': 0.0,
          'rembourse': 0.0,
          'count': 0.0,
        };
      }
      totals[cat]!['montant'] =
          (totals[cat]!['montant'] ?? 0) + sim.prixFacture;
      totals[cat]!['rembourse'] =
          (totals[cat]!['rembourse'] ?? 0) + sim.totalRembourse;
      totals[cat]!['count'] = (totals[cat]!['count'] ?? 0) + 1;
    }

    return totals;
  }

  List<SimulationHistory> _getFilteredAndSortedSimulations() {
    var filtered = _simulations.where((simulation) {
      final matchesSearch = _searchQuery.isEmpty ||
          simulation.soinName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (simulation.categorieName ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final cat = simulation.categorieName ?? 'Autre';
      final matchesCategory =
          _selectedCategory == 'Tous' || cat == _selectedCategory;

      // Period filter
      final now = DateTime.now();
      bool matchesPeriod = true;

      if (_selectedPeriod == '7 jours') {
        matchesPeriod = now.difference(simulation.createdAt).inDays <= 7;
      } else if (_selectedPeriod == '30 jours') {
        matchesPeriod = now.difference(simulation.createdAt).inDays <= 30;
      } else if (_selectedPeriod == '3 mois') {
        matchesPeriod = now.difference(simulation.createdAt).inDays <= 90;
      }

      return matchesSearch && matchesCategory && matchesPeriod;
    }).toList();

    switch (_sortBy) {
      case 'date_asc':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'date_desc':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'montant_desc':
        filtered.sort((a, b) => b.prixFacture.compareTo(a.prixFacture));
        break;
      case 'montant_asc':
        filtered.sort((a, b) => a.prixFacture.compareTo(b.prixFacture));
        break;
      case 'economie_desc':
        filtered
            .sort((a, b) => b.totalRembourse.compareTo(a.totalRembourse));
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
                child: Text('Meilleur remboursement'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? _buildSkeletonLoader()
            : _buildContent(filteredSimulations),
      ),
    );
  }

  Widget _buildContent(List<SimulationHistory> filteredSimulations) {
    if (_simulations.isEmpty) {
      return _buildEmptyHistoryState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            _buildSearchBar(),
            const SizedBox(height: 16),

            // Filters section
            const Text(
              'Filtres',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Category filters
            _buildCategoryFilters(),
            const SizedBox(height: 12),

            // Period filters
            _buildPeriodFilters(),
            const SizedBox(height: 20),

            // Category totals button
            _buildCategoryButton(),
            const SizedBox(height: 24),

            // Results header
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

            // Simulation list
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
                    child: Dismissible(
                      key: Key('sim_${filteredSimulations[index].id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      confirmDismiss: (direction) => _confirmDelete(),
                      onDismissed: (_) {
                        _deleteSimulation(filteredSimulations[index]);
                      },
                      child: _buildSimulationCard(
                          filteredSimulations[index]),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Full-width category totals button
  Widget _buildCategoryButton() {
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
            colors: [Colors.teal.shade400, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withValues(alpha: 0.3),
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
                color: Colors.white.withValues(alpha: 0.2),
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

  // Category totals modal
  void _showCategoryTotalsModal() {
    final totals = _categoryTotals;
    final entries = totals.entries.toList()
      ..sort(
          (a, b) => b.value['rembourse']!.compareTo(a.value['rembourse']!));

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
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.pie_chart_rounded,
                      color: Colors.teal,
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
                          'Répartition de vos remboursements',
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

              // Global summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${_totalRembourse.toStringAsFixed(0)}€',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total remboursé',
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
                            color: Colors.teal.shade700,
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

              // Category list
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final category = entry.key;
                    final rembourse = entry.value['rembourse']!;
                    final count = entry.value['count']!.toInt();
                    final percentage = (_totalRembourse > 0)
                        ? (rembourse / _totalRembourse * 100)
                        : 0.0;
                    final color = _colorForCategory(category);

                    return TweenAnimationBuilder<double>(
                      duration:
                          Duration(milliseconds: 500 + (index * 100)),
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                        '${rembourse.toStringAsFixed(2)} €',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Progress bar
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(4),
                                    child: TweenAnimationBuilder<double>(
                                      duration: Duration(
                                          milliseconds:
                                              800 + (index * 100)),
                                      tween: Tween(
                                          begin: 0,
                                          end: percentage / 100),
                                      builder: (context, value, child) {
                                        return LinearProgressIndicator(
                                          value: value,
                                          minHeight: 8,
                                          backgroundColor:
                                              Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<
                                                  Color>(color),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                    backgroundColor: Colors.teal,
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

  Widget _buildSearchBar() {
    return Search_Bar(
      textController: _searchController,
      hintText: 'Rechercher une simulation...',
      focusNode: _searchFocusNode,
      onClear: () => _searchController.clear(),
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
                    color: isSelected
                        ? Colors.teal
                        : Colors.grey[600],
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
              selectedColor: Colors.teal.shade50,
              labelStyle: TextStyle(
                fontSize: 13,
                color:
                    isSelected ? Colors.teal : Colors.grey[700],
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Colors.teal : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final cats = _categories;

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final category = cats[index];
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
              selectedColor: Colors.teal.shade50,
              labelStyle: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.teal : Colors.grey[700],
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Colors.teal : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimulationCard(SimulationHistory simulation) {
    final color = _colorForCategory(simulation.categorieName);

    return InkWell(
      onTap: () => _showSimulationDetails(simulation),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
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
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: simulation.soinIcon != null
                      ? Text(
                          simulation.soinIcon!,
                          style: const TextStyle(fontSize: 24),
                        )
                      : Icon(Icons.medical_services,
                          color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        simulation.soinName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        simulation.categorieName ?? 'Autre',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                  onPressed: () => _confirmAndDelete(simulation),
                  tooltip: 'Supprimer',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
                const SizedBox(width: 4),
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
                      'Prix facturé',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${simulation.prixFacture.toStringAsFixed(2)} €',
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
                      'Remboursé',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${simulation.totalRembourse.toStringAsFixed(2)} €',
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
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(simulation.createdAt),
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

  // Empty state when no simulations exist at all
  Widget _buildEmptyHistoryState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 24),
              Text(
                'Aucune simulation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Vos simulations de remboursement\napparaîtront ici automatiquement.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Consultez un soin pour lancer une simulation.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty state for filter results
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

  void _showSimulationDetails(SimulationHistory simulation) {
    final color = _colorForCategory(simulation.categorieName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
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
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: simulation.soinIcon != null
                          ? Text(
                              simulation.soinIcon!,
                              style: const TextStyle(fontSize: 32),
                            )
                          : Icon(Icons.medical_services,
                              color: color, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            simulation.soinName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            simulation.categorieName ?? 'Autre',
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
                const SizedBox(height: 24),

                // Coverage percentage bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Prise en charge',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${simulation.pourcentagePriseEnCharge.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value:
                              simulation.pourcentagePriseEnCharge / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green[600]!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Detailed breakdown
                const Text(
                  'Détail du remboursement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                _buildDetailRow('Prix facturé',
                    '${simulation.prixFacture.toStringAsFixed(2)} €'),
                _buildDetailRow(
                    'Base de remboursement (BRSS)',
                    '${simulation.brss.toStringAsFixed(2)} €'),
                _buildDetailRow('Taux Sécurité sociale',
                    '${simulation.tauxSecu.toStringAsFixed(0)}%'),
                _buildDetailRow(
                  'Remboursement Sécu',
                  '${simulation.remboursementSecu.toStringAsFixed(2)} €',
                  valueColor: Colors.green[700],
                ),
                _buildDetailRow(
                  'Remboursement Mutuelle',
                  '${simulation.remboursementMutuelle.toStringAsFixed(2)} €',
                  valueColor: Colors.green[700],
                ),
                if (simulation.participationForfaitaire > 0)
                  _buildDetailRow(
                    'Participation forfaitaire',
                    '-${simulation.participationForfaitaire.toStringAsFixed(2)} €',
                    valueColor: Colors.orange[700],
                  ),
                if (simulation.montantDepassement > 0)
                  _buildDetailRow(
                    'Dépassement d\'honoraires',
                    '${simulation.montantDepassement.toStringAsFixed(2)} €',
                    valueColor: Colors.orange[700],
                  ),
                _buildDetailRow(
                  'Conventionné',
                  simulation.estConventionne ? 'Oui' : 'Non',
                ),

                const SizedBox(height: 8),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 8),

                _buildDetailRow(
                  'Total remboursé',
                  '${simulation.totalRembourse.toStringAsFixed(2)} €',
                  valueColor: Colors.green[700],
                  isBold: true,
                ),
                _buildDetailRow(
                  'Reste à charge',
                  '${simulation.resteACharge.toStringAsFixed(2)} €',
                  valueColor: Colors.red[700],
                  isBold: true,
                ),
                _buildDetailRow(
                    'Date de simulation',
                    _formatDate(simulation.createdAt)),
                _buildDetailRow(
                    'Référence', '#${simulation.id}'),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.teal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ceci est une estimation. Les remboursements réels peuvent varier.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.teal,
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
                      backgroundColor: color,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
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
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
