import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';

class PlansScreen extends StatefulWidget {
  final String mutuelleName;
  final Function(String, String) onPlanSelectionComplete;

  const PlansScreen(
      {super.key, required this.mutuelleName, required this.onPlanSelectionComplete});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<String> _allPlans = List.generate(10, (index) => 'Plan ${index + 1}');
  List<String> _filteredPlans = [];

  @override
  void initState() {
    super.initState();
    _filteredPlans = _allPlans;
    _searchController.addListener(_filterPlans);
  }

  void _filterPlans() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPlans = _allPlans.where((plan) {
        return plan.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPlans);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plans pour ${widget.mutuelleName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Search_Bar(
              textController: _searchController,
              hintText: 'Rechercher un plan...',
              onClear: () {
                _searchController.clear();
                _filterPlans();
              },
              focusNode: _searchFocusNode,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _filteredPlans.length,
                itemBuilder: (context, index) {
                  final plan = _filteredPlans[index];
                  return ListTile(
                    title: Text(plan),
                    subtitle: Text('Détails du $plan de la mutuelle ${widget.mutuelleName}'),
                    onTap: () {
                      widget.onPlanSelectionComplete(widget.mutuelleName, plan);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
