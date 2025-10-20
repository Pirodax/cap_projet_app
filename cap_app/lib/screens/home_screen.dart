
import 'dart:ui';

import 'package:flutter/material.dart';
import '../widgets/Search_Bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSearching = false;

  final List<String> _allSearchTerms = [
    'Hospitalisation', 'Dentaire', 'Optique', 'Ostéo', 'Kiné', 'ORL', 'Cardio', 'Psychologie', 'Soins courants'
  ];
  List<String> _filteredSearchTerms = [];

  final List<Map<String, dynamic>> _modules = [
    {'title': 'Hospitalisation', 'icon': Icons.local_hospital, 'color': Colors.deepPurple},
    {'title': 'Dentaire', 'icon': Icons.sentiment_satisfied, 'color': Colors.deepPurple},
    {'title': 'Optique', 'icon': Icons.visibility, 'color': Colors.deepPurple},
    {'title': 'Ostéo', 'icon': Icons.accessibility, 'color': Colors.deepPurple},
    {'title': 'Kiné', 'icon': Icons.directions_run, 'color': Colors.deepPurple},
    {'title': 'ORL', 'icon': Icons.hearing, 'color': Colors.deepPurple},
    {'title': 'Cardio', 'icon': Icons.favorite, 'color': Colors.deepPurple},
    {'title': 'Psychologie', 'icon': Icons.psychology, 'color': Colors.deepPurple},
    {'title': 'Soins courants', 'icon': Icons.healing, 'color': Colors.deepPurple},
  ];

  final List<Map<String, dynamic>> _articles = [
    {'title': 'Nouvelles mesures de remboursement', 'subtitle': 'Découvrez les changements pour 2024...', 'icon': Icons.article},
    {'title': 'Campagne de prévention grippe', 'subtitle': 'Pensez à vous faire vacciner...', 'icon': Icons.campaign},
    {'title': 'Téléconsultation disponible', 'subtitle': 'Consultez un médecin en ligne...', 'icon': Icons.video_call},
    {'title': 'Nouveau centre médical', 'subtitle': 'Ouverture à proximité de vous...', 'icon': Icons.location_on},
    {'title': 'Nouvelles mesures de remboursement', 'subtitle': 'Découvrez les changements pour 2024...', 'icon': Icons.article},
  ];

  @override
  void initState() {
    super.initState();
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

  void _handleSearchChange() {
    setState(() {
      _filteredSearchTerms = _searchController.text.isEmpty
          ? []
          : _allSearchTerms
              .where((term) => term.toLowerCase().contains(_searchController.text.toLowerCase()))
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

  void _selectSearchTerm(String term) {
    _searchController.text = term;
    _focusNode.unfocus();
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
        _buildHorizontalSection('Catégories', _modules),
        _buildHorizontalSection('Récemment consulté', _modules.reversed.toList()),
        _buildNewsSection(),
      ],
    );
  }

  Widget _buildHorizontalSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => _selectSearchTerm(item['title']),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: item['color'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'], size: 40, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        item['title'],
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
  }

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
                    leading: Icon(article['icon']),
                    title: Text(article['title']),
                    subtitle: Text(article['subtitle']),
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
          child: _filteredSearchTerms.isEmpty
              ? Center(
            child: Text(
              _searchController.text.isEmpty ? 'Que recherchez-vous ?' : 'Aucun résultat',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
              : ListView.builder(
            padding: EdgeInsets.only(top: topPadding),
            itemCount: _filteredSearchTerms.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                title: Text(
                  _filteredSearchTerms[index],
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => _selectSearchTerm(_filteredSearchTerms[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}
