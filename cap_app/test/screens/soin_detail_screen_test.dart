import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Widget simplifié pour les tests
class SoinDetailScreenTest extends StatefulWidget {
  final int soinId;
  final String soinName;
  final double brss;
  final String detail;

  const SoinDetailScreenTest({
    super.key,
    required this.soinId,
    required this.soinName,
    required this.brss,
    required this.detail,
  });

  @override
  State<SoinDetailScreenTest> createState() => _SoinDetailScreenTestState();
}

class _SoinDetailScreenTestState extends State<SoinDetailScreenTest> {
  final prixController = TextEditingController();
  bool calcul = false;
  double? totalRembourse;
  double? resteACharge;

  @override
  void dispose() {
    prixController.dispose();
    super.dispose();
  }

  void calculer() {
    double? prix = double.tryParse(prixController.text.replaceAll(',', '.'));
    if (prix == null || prix <= 0) return;

    setState(() => calcul = true);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          totalRembourse = widget.brss - 1.0;
          resteACharge = prix! - widget.brss + 1.0;
          calcul = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Simulation")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.soinName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text("Base BRSS: ${widget.brss.toStringAsFixed(2)} €"),
              if (widget.detail.isNotEmpty) Text(widget.detail),

              const SizedBox(height: 20),
              TextFormField(
                controller: prixController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Montant en €",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: calcul ? null : calculer,
                child: Text(calcul ? "Calcul en cours..." : "Lancer la simulation"),
              ),

              const SizedBox(height: 20),
              if (totalRembourse != null) ...[
                Text("Total remboursé: ${totalRembourse!.toStringAsFixed(2)} €"),
                Text("Reste à charge: ${resteACharge!.toStringAsFixed(2)} €"),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('SoinDetailScreen', () {
    testWidgets('affiche le nom du soin', (tester) async {
      await tester.pumpWidget(const SoinDetailScreenTest(
        soinId: 71,
        soinName: 'Consultation généraliste',
        brss: 30.0,
        detail: '',
      ));

      expect(find.text('Consultation généraliste'), findsOneWidget);
    });

    testWidgets('affiche la base BRSS', (tester) async {
      await tester.pumpWidget(const SoinDetailScreenTest(
        soinId: 71,
        soinName: 'Consultation',
        brss: 30.0,
        detail: '',
      ));

      expect(find.text('Base BRSS: 30.00 €'), findsOneWidget);
    });

    testWidgets('affiche le détail si présent', (tester) async {
      await tester.pumpWidget(const SoinDetailScreenTest(
        soinId: 71,
        soinName: 'Consultation',
        brss: 30.0,
        detail: 'Secteur 1',
      ));

      expect(find.text('Secteur 1'), findsOneWidget);
    });

    testWidgets('peut entrer un prix', (tester) async {
      await tester.pumpWidget(const SoinDetailScreenTest(
        soinId: 71,
        soinName: 'Consultation',
        brss: 30.0,
        detail: '',
      ));

      await tester.enterText(find.byType(TextFormField), '35.50');
      expect(find.text('35.50'), findsOneWidget);
    });

    testWidgets('calcul affiche le résultat', (tester) async {
      await tester.pumpWidget(const SoinDetailScreenTest(
        soinId: 71,
        soinName: 'Consultation',
        brss: 30.0,
        detail: '',
      ));

      await tester.enterText(find.byType(TextFormField), '30');
      await tester.tap(find.text('Lancer la simulation'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Total remboursé'), findsOneWidget);
      expect(find.textContaining('Reste à charge'), findsOneWidget);
    });
  });
}