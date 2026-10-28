import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';

class ImportProductsScreen extends StatelessWidget {
  const ImportProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
            ),
          ),
        ),
        title: const Text(
          'Importer des produits',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ICON FICHIER VERT/NAVY AVEC FLECHE
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.upload_file_outlined, color: AppTheme.primaryNavy, size: 36),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Votre liste, en une fois',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Une capture d\'écran ou une photo de votre liste, ou un fichier Excel ou CSV avec au moins le nom et le prix de vente. Catégorie, référence et code-barres sont repris s\'ils existent ; le stock se saisit ensuite avec « Saisir le stock existant ». 2000 lignes maximum.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 24),

            // CADRE D'INSTRUCTIONS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Photographiez votre liste, ou utilisez un fichier Excel / CSV',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '2. Relisez : catégories, doublons, prix',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '3. Importez, puis ajoutez les photos',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // BOUTON 1 : PHOTOGRAPHIER MA LISTE
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.white),
                label: const Text(
                  'Photographier ma liste',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ouverture de la caméra pour reconnaissance IA...')),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // BOUTON 2 : CHOISIR UN FICHIER
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryNavy, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                icon: const Icon(Icons.description_outlined, size: 20, color: AppTheme.primaryNavy),
                label: const Text(
                  'Choisir un fichier',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sélectionnez un fichier Excel (.xlsx) ou CSV')),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // LIEN : TELECHARGER LE MODELE CSV
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Modèle CSV téléchargé avec succès !')),
                );
              },
              icon: const Icon(Icons.file_download_outlined, color: AppTheme.primaryNavy, size: 18),
              label: const Text(
                'Télécharger le modèle CSV',
                style: TextStyle(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
