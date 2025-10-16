import '../widgets/search_bar.dart';
import 'package:flutter/material.dart';

class PlansScreen extends StatefulWidget {
  final String mutuelleName;

  const PlansScreen({super.key, required this.mutuelleName});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
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
              onClear: () => _searchController.clear(),
              focusNode: _searchFocusNode,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: 10, // Example plan count
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Plan ${index + 1}'),
                    subtitle: Text('Détails du plan ${index + 1} de la mutuelle ${widget.mutuelleName}'),
                    onTap: () {
                      // Handle plan selection
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
