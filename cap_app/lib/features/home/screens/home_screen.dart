import 'dart:ui';

import '../services/category_service.dart';
import 'package:flutter/material.dart';
import '../../../widgets/Search_Bar.dart';
import 'category_details_screen.dart';
import '../../simulator/screens/soin_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSearching = false;

  final CategoryService _categoryService = CategoryService();
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  List<Map<String, dynamic>> _allCategories = [];
  List<Map<String, dynamic>> _filteredCategories = [];
  List<Map<String, dynamic>> _filteredSoins = [];

  // Données locales pour les articles, conservées telles quelles.
  final List<Map<String, dynamic>> _articles = [
    {'title': 'Nouvelles mesures de remboursement', 'subtitle': 'Découvrez les changements pour 2024...', 'icon': Icons.article},
    {'title': 'Campagne de prévention grippe', 'subtitle': 'Pensez à vous faire vacciner...', 'icon': Icons.campaign},
    // ... reste des articles
  ];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getCategories();
    _focusNode.addListener(_handleFocusChange);
    _searchController.addListener(_handleSearchChange);
  }

  // Le reste des méthodes initState, dispose, etc. reste inchangé...

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _isSearching) {
      setState(() {
        _isSearching = _focusNode.hasFocus;
      });
    }
  }

  void _handleSearchChange() async {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredCategories = [];
        _filteredSoins = [];
      });
      return;
    }

    // Recherche catégories localement
    final filteredCats = _allCategories
        .where((category) {
          final categoryName = (category['name'] as String? ?? '').toLowerCase();
          return categoryName.contains(query);
        })
        .toList();

    // Recherche soins depuis Supabase
    final soins = await _categoryService.searchSoins(query);

    setState(() {
      _filteredCategories = filteredCats;
      _filteredSoins = soins;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChange);
    _focusNode.removeListener(_handleFocusChange);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() => _searchController.clear();

  // Liste de couleurs fixes pour les catégories
  static const List<Color> _categoryColors = [
    Color(0xFFFFA726), // Orange
    Color(0xFFAB47BC), // Violet
    Color(0xFF42A5F5), // Bleu
    Color(0xFF66BB6A), // Vert
    Color(0xFF7E57C2), // Violet foncé
    Color(0xFFFFCA28), // Jaune
    Color(0xFF26C6DA), // Cyan
    Color(0xFFEF5350), // Rouge
    Color(0xFF8BC34A), // Vert clair
  ];

  // Fonction pour obtenir une couleur fixe basée sur l'index
  Color _getCategoryColor(int index) {
    return _categoryColors[index % _categoryColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = kToolbarHeight + MediaQuery.of(context).padding.top + 20;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Search_Bar(
          textController: _searchController,
          hintText: 'Rechercher...',
          focusNode: _focusNode,
          onClear: _clearSearch,
        ),
      ),
      body: Stack(
        children: [
          _buildMainContent(topPadding),
          if (_isSearching) _buildSearchOverlay(topPadding),
        ],
      ),
    );
  }

  Widget _buildMainContent(double topPadding) {
    // ... Le contenu principal (Titre, etc.) reste identique
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(height: topPadding),
        Center(
          child: Text(
            'CAP PROJET',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 55,
                fontFamily: 'serif'
            ),
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            'Ma mutuelle, mes avantages !',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
                fontSize: 15,
                fontFamily: 'serif'
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildCategoriesSection(),
        _buildNewsSection(),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucune catégorie trouvée.'));
        }
        _allCategories = snapshot.data!;

        // La section horizontale est maintenant construite avec les données de la DB
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Catégories',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _allCategories.length,
                itemBuilder: (context, index) {
                  final item = _allCategories[index];
                  // ✅ CORRIGÉ: Utiliser 'name' pour le titre et 'icon' pour l'emoji
                  final title = item['name'] as String? ?? 'Sans nom';
                  final iconString = item['icon'] as String? ?? '❓';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryDetailsScreen(
                            categoryId: item['id'] as int,
                            categoryName: title,
                            categoryIcon: iconString,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(index),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ✅ CORRIGÉ: Utiliser un Widget Text pour afficher l'emoji
                          Text(
                            iconString,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // La méthode _buildNewsSection() reste inchangée
  Widget _buildNewsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actualités',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _articles.length,
            itemBuilder: (context, index) {
              final article = _articles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: Icon(article['icon'] as IconData),
                    title: Text(article['title'] as String),
                    subtitle: Text(article['subtitle'] as String),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay(double topPadding) {
    final hasResults = _filteredCategories.isNotEmpty || _filteredSoins.isNotEmpty;

    return GestureDetector(
      onTap: _focusNode.unfocus,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: !hasResults
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty ? 'Que recherchez-vous ?' : 'Aucun résultat',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.only(top: topPadding),
                  children: [
                    // Section Catégories
                    if (_filteredCategories.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Catégories',
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ..._filteredCategories.map((category) {
                        final categoryName = category['name'] as String? ?? 'Sans nom';
                        final categoryIcon = category['icon'] as String? ?? '❓';

                        return ListTile(
                          leading: Text(categoryIcon, style: const TextStyle(fontSize: 24)),
                          title: Text(categoryName, style: const TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryDetailsScreen(
                                  categoryId: category['id'] as int,
                                  categoryName: categoryName,
                                  categoryIcon: categoryIcon,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                    // Section Soins
                    if (_filteredSoins.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Soins',
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ..._filteredSoins.map((soin) {
                        final soinName = soin['name'] as String? ?? 'Sans nom';
                        final categoryData = soin['categories_soins'] as Map<String, dynamic>?;
                        final categoryName = categoryData?['name'] as String? ?? '';
                        final categoryIcon = categoryData?['icon'] as String? ?? '💊';

                        return ListTile(
                          leading: Text(categoryIcon, style: const TextStyle(fontSize: 24)),
                          title: Text(soinName, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(categoryName, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SoinDetailScreen(
                                  soinId: soin['id'] as int,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
