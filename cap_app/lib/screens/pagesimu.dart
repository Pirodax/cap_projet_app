import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/remboursement_service.dart';
import '../models/remboursement_result.dart';
import '../core/supabase/supabase_init.dart';

class PageSimu extends StatefulWidget {
  const PageSimu({super.key});

  @override
  State<PageSimu> createState() => _PageSimuState();
}

class _PageSimuState extends State<PageSimu> {
  final service = RemboursementService();
  final prixController = TextEditingController();

  List<Map<String, dynamic>> soins = [];
  int? soinSelectionne;
  bool chargement = true;
  bool calcul = false;
  RemboursementResult? resultat;

  @override
  void initState() {
    super.initState();
    chargerSoins();
  }

  void chargerSoins() async {
    var listeSoins = await service.getSoins();
    setState(() {
      soins = listeSoins;
      chargement = false;
    });
  }

  void calculer() async {
    if (soinSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un soin.')),
      );
      return;
    }

    if (prixController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un prix.')),
      );
      return;
    }

    double? prix = double.tryParse(prixController.text);
    if (prix == null || prix <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le prix saisi est invalide.')),
      );
      return;
    }

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur non connecté. Veuillez vous reconnecter.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => calcul = true);

    RemboursementResult result = await service.calculerRemboursement(
      userId: userId,
      soinId: soinSelectionne!,
      prixReel: prix,
    );

    setState(() {
      resultat = result;
      calcul = false;
    });

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Une erreur de calcul est survenue'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (chargement) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Simulation",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Récapitulatif de la simulation",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 25),

              _buildCard(
                icon: Icons.person,
                title: "Votre situation civile",
                subtitle: "Homme / Femme\nÂge & Mutuelle Santé",
              ),

              _buildSoinCard(),

              _buildPrixCard(),

              const SizedBox(height: 40),

              Center(
                child: ElevatedButton(
                  onPressed: calcul ? null : calculer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  child: calcul
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    "CALCULER",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              if (resultat != null && resultat!.success) ...[
                const SizedBox(height: 30),
                _buildResultCard(resultat!.details!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = Colors.deepPurpleAccent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildSoinCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.favorite_rounded,
                      color: Colors.pinkAccent, size: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  "Soin souhaité",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: soinSelectionne,
              hint: Text('Sélectionnez un soin'),
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: soins.map((soin) {
                return DropdownMenuItem<int>(
                  value: soin['id'],
                  child: Text(
                    soin['name'],
                    style: GoogleFonts.poppins(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => soinSelectionne = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrixCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigoAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.euro_rounded,
                      color: Colors.indigoAccent, size: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  "Prix (€)",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: prixController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ex: 30.00',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(RemboursementDetails details) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
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
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Text(
                "Résultat de la simulation",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Divider(height: 24),

          _ligne('Soin', details.soinName, gras: true),
          _ligne('Prix payé', '${details.prixReel.toStringAsFixed(2)} €'),
          _ligne('Base remb.', '${details.baseRemboursement.toStringAsFixed(2)} €'),

          const SizedBox(height: 16),
          Text(
            'Sécurité sociale',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _ligne('Taux', '${details.tauxSecu.toStringAsFixed(0)} %', indent: true),
          _ligne('Remb. brut', '${details.rembSecuBrut.toStringAsFixed(2)} €', indent: true),
          if (details.participationForfaitaire > 0)
            _ligne('Part. forfaitaire', '-${details.participationForfaitaire.toStringAsFixed(2)} €',
                indent: true, couleur: Colors.orange),
          _ligne('Remb. net', '${details.rembSecuNet.toStringAsFixed(2)} €',
              indent: true, gras: true),

          const SizedBox(height: 16),
          Text(
            'Mutuelle',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _ligne('Taux', '${details.tauxMutuelle.toStringAsFixed(0)} %', indent: true),
          _ligne('Remboursement', '${details.rembMutuelle.toStringAsFixed(2)} €',
              indent: true, gras: true),

          Divider(height: 24),

          _ligne('TOTAL REMBOURSÉ', '${details.totalRembourse.toStringAsFixed(2)} €',
              gras: true, couleur: Colors.green, taille: 16),
          _ligne('RESTE À CHARGE', '${details.resteACharge.toStringAsFixed(2)} €',
              gras: true, couleur: Colors.red, taille: 18),
        ],
      ),
    );
  }

  Widget _ligne(String label, String valeur, {
    bool indent = false,
    bool gras = false,
    Color? couleur,
    double? taille,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, left: indent ? 16 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: taille ?? 13,
                fontWeight: gras ? FontWeight.bold : FontWeight.normal,
                color: couleur ?? Colors.grey[700],
              ),
            ),
          ),
          Text(
            valeur,
            style: GoogleFonts.poppins(
              fontSize: taille ?? 13,
              fontWeight: gras ? FontWeight.bold : FontWeight.w600,
              color: couleur ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    prixController.dispose();
    super.dispose();
  }
}