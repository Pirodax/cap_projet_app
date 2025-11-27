import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../services/remboursement_service.dart';
import '../models/remboursement_result.dart';
import '../core/supabase/supabase_init.dart';

class SoinDetailScreen extends StatefulWidget {
  final int soinId;
  final String soinName;
  final double brss;
  final String detail;

  const SoinDetailScreen({
    super.key,
    required this.soinId,
    required this.soinName,
    required this.brss,
    required this.detail,
  });

  @override
  State<SoinDetailScreen> createState() => _SoinDetailScreenState();
}

class _SoinDetailScreenState extends State<SoinDetailScreen>
    with SingleTickerProviderStateMixin {
  final service = RemboursementService();
  final prixController = TextEditingController();

  late AnimationController _controller;
  bool calcul = false;
  RemboursementResult? resultat;

  // Infos perso
  String? estEtudiant;
  int? age;
  String? departement;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    prixController.dispose();
    super.dispose();
  }

  void calculer() async {
    if (prixController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un prix.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    double? prix = double.tryParse(prixController.text.replaceAll(',', '.'));
    if (prix == null || prix <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le prix saisi est invalide.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur non connecté.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => calcul = true);

    RemboursementResult result = await service.calculerRemboursement(
      userId: userId,
      soinId: widget.soinId,
      prixReel: prix,
    );

    setState(() {
      resultat = result;
      calcul = false;
    });

    if (result.success) {
      _controller.forward(from: 0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Erreur de calcul'),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Simulation",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Section 1 : Soin sélectionné
            _buildSectionCard(
              icon: Icons.healing_outlined,
              title: "1. Soin sélectionné",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.soinName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildBRSSBar(widget.brss),
                  if (widget.detail.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildInfoBanner(widget.detail),
                  ],
                  // Debug info
                  const SizedBox(height: 8),
                  Text(
                    "ID du soin: ${widget.soinId}",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            // Section 2 : Prix facturé
            _buildSectionCard(
              icon: Icons.euro_symbol,
              title: "2. Prix facturé",
              child: TextFormField(
                controller: prixController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.black87),
                decoration: _inputDecoration(
                  label: "Montant en €",
                  hint: "Ex: ${widget.brss.toStringAsFixed(2)}",
                ),
              ),
            ),

            // Section 3 : Informations personnelles
            _buildSectionCard(
              icon: Icons.person_outline,
              title: "3. Informations personnelles",
              child: _buildInputCard(),
            ),

            // Section 4 : Résultat
            _buildSectionCard(
              icon: Icons.calculate_rounded,
              title: "4. Résultat de simulation",
              child: _buildResultSection(),
            ),

            const SizedBox(height: 15),

            // Bouton calculer
            ElevatedButton.icon(
              onPressed: calcul ? null : calculer,
              icon: calcul
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.calculate_rounded),
              label: Text(calcul ? "Calcul en cours..." : "Lancer la simulation"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildBRSSBar(double brss) {
    double normalized = (brss / 500).clamp(0.0, 1.0);
    Color barColor = brss >= 100
        ? Colors.greenAccent
        : brss >= 50
        ? Colors.lightBlueAccent
        : Colors.orangeAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Base de remboursement (BRSS) : ${brss.toStringAsFixed(2)} €",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 14,
          percent: normalized,
          backgroundColor: Colors.grey[200],
          progressColor: barColor,
          animation: true,
          barRadius: const Radius.circular(12),
        ),
      ],
    );
  }

  Widget _buildInfoBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade400, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          value: estEtudiant,
          hint: const Text("Êtes-vous étudiant ?"),
          style: const TextStyle(color: Colors.black),
          decoration: _inputDecoration(),
          items: ['Oui', 'Non']
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (val) => setState(() => estEtudiant = val),
        ),
        const SizedBox(height: 15),
        TextFormField(
          decoration: _inputDecoration(label: "Âge"),
          keyboardType: TextInputType.number,
          onChanged: (val) => age = int.tryParse(val),
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 15),
        TextFormField(
          decoration: _inputDecoration(label: "Département"),
          onChanged: (val) => departement = val,
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    // État initial - en attente
    if (resultat == null) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.pending_outlined, color: Colors.grey, size: 30),
            const SizedBox(width: 16),
            Text(
              "—",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Erreur - on affiche seulement le SnackBar, pas dans la card
    if (!resultat!.success) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.pending_outlined, color: Colors.grey, size: 30),
            SizedBox(width: 16),
            Text(
              "—",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Succès
    final details = resultat!.details!;

    return FadeTransition(
      opacity: _controller.drive(CurveTween(curve: Curves.easeInOut)),
      child: Column(
        children: [
          // Card gradient résumé
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8FD3F4), Color(0xFF84FAB0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.euro, color: Colors.white, size: 30),
                    Text(
                      "${details.totalRembourse.toStringAsFixed(2)} €",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total remboursé",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      "Reste: ${details.resteACharge.toStringAsFixed(2)} €",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Détails
          _buildDetailRow("Prix facturé", "${details.prixReel.toStringAsFixed(2)} €"),
          _buildDetailRow("Base BRSS", "${details.baseRemboursement.toStringAsFixed(2)} €"),

          const SizedBox(height: 10),
          _buildSubtitle("Sécurité sociale"),
          _buildDetailRow("Taux", "${details.tauxSecu.toStringAsFixed(0)} %", indent: true),
          _buildDetailRow("Remb. brut", "${details.rembSecuBrut.toStringAsFixed(2)} €", indent: true),
          if (details.participationForfaitaire > 0)
            _buildDetailRow(
              "Part. forfaitaire",
              "-${details.participationForfaitaire.toStringAsFixed(2)} €",
              indent: true,
              color: Colors.orange,
            ),
          _buildDetailRow(
            "Remb. net Sécu",
            "${details.rembSecuNet.toStringAsFixed(2)} €",
            indent: true,
            bold: true,
          ),

          const SizedBox(height: 10),
          _buildSubtitle("Mutuelle"),
          _buildDetailRow("Taux", "${details.tauxMutuelle.toStringAsFixed(0)} %", indent: true),
          _buildDetailRow(
            "Remboursement",
            "${details.rembMutuelle.toStringAsFixed(2)} €",
            indent: true,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label,
      String value, {
        bool indent = false,
        bool bold = false,
        Color? color,
      }) {
    return Padding(
      padding: EdgeInsets.only(left: indent ? 16 : 0, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color ?? Colors.grey.shade700,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: color ?? Colors.black87,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.black54),
      hintStyle: TextStyle(color: Colors.grey.shade400),
    );
  }
}