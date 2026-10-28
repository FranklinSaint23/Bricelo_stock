import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';

class PromotionAndShopScreen extends StatelessWidget {
  const PromotionAndShopScreen({super.key});

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
          'Promotion & boutique',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildRow(Icons.local_offer_outlined, 'Promotions', isLocked: true),
                _buildDivider(),
                _buildRow(Icons.campaign_outlined, 'Catalogues à partager', isLocked: true),
                _buildDivider(),
                _buildRow(Icons.storefront_outlined, 'Boutique en ligne', isLocked: false),
                _buildDivider(),
                _buildRow(Icons.shopping_cart_outlined, 'Commandes en ligne', isLocked: false),
                _buildDivider(),
                _buildRow(Icons.assignment_outlined, 'Commande externe', isLocked: false),
                _buildDivider(),
                _buildRow(Icons.movie_creation_outlined, 'Studio vidéo', isLocked: false),
                _buildDivider(),
                _buildRow(Icons.chat_bubble_outline, 'Catalogue WhatsApp & Facebook', isLocked: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String title, {required bool isLocked}) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF374151)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
              ),
            ),
            Icon(
              isLocked ? Icons.lock_outline : Icons.chevron_right,
              size: 20,
              color: isLocked ? const Color(0xFF374151) : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 52, color: Color(0xFFF3F4F6));
  }
}
