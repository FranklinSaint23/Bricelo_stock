import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';
import 'package:stock_prime/screens/screens.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final List<Map<String, dynamic>> _quotes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Devis',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: _quotes.isEmpty
          ? const Center(
              child: Text(
                'Aucun devis pour le moment.',
                style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w400),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _quotes.length,
              itemBuilder: (context, idx) {
                final q = _quotes[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(q['client'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Valable jusqu\'au ${q['validUntil']}'),
                    trailing: Text(
                      AppTheme.formatFCFA(q['total'] as num),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFA7F3D0),
        foregroundColor: const Color(0xFF064E3B),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Nouveau devis',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewQuoteScreen()),
          );
          if (res != null && res is Map<String, dynamic>) {
            setState(() => _quotes.add(res));
          }
        },
      ),
    );
  }
}
