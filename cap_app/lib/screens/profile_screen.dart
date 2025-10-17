import 'plans_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String? mutuelleName;
  final String? planName;
  final Function(String, String)? onPlanSelectionComplete;
  final VoidCallback? onClearPlanSelection;
  final String? estEtudiant;
  final Function(String)? onSetEtudiantStatus;
  final VoidCallback? onClearEtudiantStatus;

  const ProfileScreen(
      {super.key,
      this.mutuelleName,
      this.planName,
      this.onPlanSelectionComplete,
      this.onClearPlanSelection,
      this.estEtudiant,
      this.onSetEtudiantStatus,
      this.onClearEtudiantStatus});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _mutuelle;

  @override
  void initState() {
    super.initState();
    _mutuelle = widget.mutuelleName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Profil'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.indigo),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),
            const Text(
              'Votre couverture santé:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (widget.planName != null && widget.mutuelleName != null)
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mutuelle: ${widget.mutuelleName}'),
                      const SizedBox(height: 10),
                      Text('Plan: ${widget.planName}'),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: widget.onClearPlanSelection,
                  )
                ],
              )
            else
              DropdownButtonFormField<String>(
                value: _mutuelle,
                hint: const Text('Mutuelle'),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlansScreen(
                          mutuelleName: newValue,
                          onPlanSelectionComplete: widget.onPlanSelectionComplete!,
                        ),
                      ),
                    );
                  }
                },
                items: <String>['MGEN', 'Alan', 'Axa', 'Mutualia']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Carte vitale:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text('(si non afficher les démarches et conditions)'),
            const SizedBox(height: 20),
            const Text(
              'Situation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Âge',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            if (widget.estEtudiant != null)
              Row(
                children: [
                  Text('Étudiant: ${widget.estEtudiant}'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: widget.onClearEtudiantStatus,
                  )
                ],
              )
            else
              DropdownButtonFormField<String>(
                hint: const Text('Étudiant ?'),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    widget.onSetEtudiantStatus!(newValue);
                  }
                },
                items: <String>['Oui', 'Non']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Département',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: '75010',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
