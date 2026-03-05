import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/category_service.dart';
import '../widgets/search_bar.dart';
import 'category_details_screen.dart';
import 'soin_detail_screen.dart';

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

  // Données locales pour les articles
  final List<Map<String, dynamic>> _articles = [
    {'title': 'Nouvelles mesures de remboursement', 'subtitle': 'Découvrez les changements pour 2024...', 'icon': Icons.article},
    {'title': 'Campagne de prévention grippe', 'subtitle': 'Pensez à vous faire vacciner...', 'icon': Icons.campaign},
    {'title': 'Téléconsultation disponible', 'subtitle': 'Consultez un médecin en ligne...', 'icon': Icons.video_call},
    {'title': 'Nouveau centre médical', 'subtitle': 'Ouverture à proximité de vous...', 'icon': Icons.location_on},
  ];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getCategories();
    _focusNode.addListener(_handleFocusChange);
    _searchController.addListener(_handleSearchChange);
  }

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

  // Liste de couleurs pastel pour les catégories, en accord avec le style Mutuelio
  static const List<Color> _categoryColors = [
    Color(0xFF80CBC4), // Teal clair
    Color(0xFF90CAF9), // Bleu clair
    Color(0xFFCE93D8), // Violet clair
    Color(0xFFFFCC80), // Orange clair
    Color(0xFFA5D6A7), // Vert clair
    Color(0xFFB39DDB), // Indigo clair
    Color(0xFFFFF59D), // Jaune clair
    Color(0xFFEF9A9A), // Rouge clair
  ];

  Color _getCategoryColor(int index) {
    return _categoryColors[index % _categoryColors.length];
  }

  @override
  Widget build(BuildContext context) {
    // Calcul du padding top pour éviter que le contenu ne soit caché par l'app bar fixe
    final topPadding = kToolbarHeight + MediaQuery.of(context).padding.top + 20;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Fond gris clair comme ProfileScreen
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        // On garde la SearchBar dans l'AppBar pour qu'elle reste fixe
        title: Search_Bar(
          textController: _searchController,
          hintText: 'Rechercher un soin, une catégorie...',
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
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(height: topPadding + 10), // Espace sous la barre de recherche

        // En-tête Mutuelio
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(
                'Mutuelio',
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Ma santé, mes remboursements simplifiés',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.blueGrey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),

        // Section Catégories
        _buildCategoriesSection(),

        const SizedBox(height: 25),

        // Section Actualités
        _buildNewsSection(),
        
        const SizedBox(height: 40), // Marge en bas de liste
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: Colors.teal),
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        
        _allCategories = snapshot.data ?? [];
        if (_allCategories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Text(
                'Explorer par catégorie',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ),
            SizedBox(
              height: 150, // Hauteur ajustée pour les cartes
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _allCategories.length,
                itemBuilder: (context, index) {
                  final item = _allCategories[index];
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
                      width: 130,
                      margin: const EdgeInsets.only(right: 15, bottom: 10, top: 5), // Marge pour l'ombre
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(index).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              iconString,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.blueGrey.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
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

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Text(
            'Actualités santé',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _articles.length,
          itemBuilder: (context, index) {
            final article = _articles[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(article['icon'] as IconData, color: Colors.teal),
                ),
                title: Text(
                  article['title'] as String,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    article['subtitle'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey.shade300),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchOverlay(double topPadding) {
    final hasResults = _filteredCategories.isNotEmpty || _filteredSoins.isNotEmpty;

    return GestureDetector(
      onTap: _focusNode.unfocus,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: const Color(0xFFF5F7FA).withOpacity(0.95), // Fond opaque pour masquer le contenu derrière
          child: !hasResults
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.teal.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty 
                            ? 'Recherchez un soin ou une catégorie' 
                            : 'Aucun résultat trouvé',
                        style: GoogleFonts.poppins(
                          color: Colors.blueGrey, 
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: EdgeInsets.only(top: topPadding + 20, left: 20, right: 20, bottom: 20),
                  children: [
                    if (_filteredCategories.isNotEmpty) ...[
                      Text(
                        'CATÉGORIES',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._filteredCategories.map((category) {
                        final categoryName = category['name'] as String? ?? 'Sans nom';
                        final categoryIcon = category['icon'] as String? ?? '❓';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              )
                            ]
                          ),
                          child: ListTile(
                            leading: Text(categoryIcon, style: const TextStyle(fontSize: 24)),
                            title: Text(
                              categoryName, 
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800)
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                    ],
                    if (_filteredSoins.isNotEmpty) ...[
                      Text(
                        'SOINS',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._filteredSoins.map((soin) {
                        final soinName = soin['name'] as String? ?? 'Sans nom';
                        final categoryData = soin['categories_soins'] as Map<String, dynamic>?;
                        final categoryName = categoryData?['name'] as String? ?? '';
                        final categoryIcon = categoryData?['icon'] as String? ?? '💊';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              )
                            ]
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Text(categoryIcon, style: const TextStyle(fontSize: 20)),
                            ),
                            title: Text(
                              soinName,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.blueGrey.shade800)
                            ),
                            subtitle: Text(
                              categoryName, 
                              style: GoogleFonts.poppins(color: Colors.blueGrey.shade400, fontSize: 12)
                            ),
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
                          ),
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
