import 'dart:ui';
import 'dart:math';

import '../services/category_service.dart';
import 'package:flutter/material.dart';
import '../widgets/Search_Bar.dart';
import 'category_details_screen.dart';

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

  void _handleSearchChange() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = query.isEmpty
          ? []
          : _allCategories
          .where((category) {
        // ✅ CORRIGÉ: Utiliser 'name' au lieu de 'nom'
        final categoryName = (category['name'] as String? ?? '').toLowerCase();
        return categoryName.contains(query);
      })
          .toList();
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

  // Fonction pour générer une couleur aléatoire pour les catégories
  Color _getRandomColor() {
    final List<Color> presetColors = [
      Colors.blue.shade300, Colors.green.shade300, Colors.orange.shade300,
      Colors.purple.shade300, Colors.red.shade300, Colors.teal.shade300,
    ];
    return presetColors[Random().nextInt(presetColors.length)];
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
                        color: _getRandomColor(), // Utilise une couleur aléatoire prédéfinie
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
    return GestureDetector(
      onTap: _focusNode.unfocus,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: _filteredCategories.isEmpty
              ? Center(
            child: Text(
              _searchController.text.isEmpty ? 'Que recherchez-vous ?' : 'Aucun résultat',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
              : ListView.builder(
            padding: EdgeInsets.only(top: topPadding),
            itemCount: _filteredCategories.length,
            itemBuilder: (context, index) {
              final category = _filteredCategories[index];
              // ✅ CORRIGÉ: Utiliser 'name' et 'icon'
              final categoryName = category['name'] as String? ?? 'Sans nom';
              final categoryIcon = category['icon'] as String? ?? '❓';

              return ListTile(
                // ✅ CORRIGÉ: Afficher l'emoji dans un Text
                leading: Text(categoryIcon, style: const TextStyle(fontSize: 24)),
                title: Text(
                  categoryName,
                  style: const TextStyle(color: Colors.white),
                ),
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
            },
          ),
        ),
      ),
    );
  }
}
