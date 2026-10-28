import 'package:flutter/material.dart';
import 'package:stock_prime/theme/app_theme.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  int _selectedTab = 0;

  final List<String> _tabs = ['En attente', 'Demande ap...', 'Rejetées'];

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
          'Approbations',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // BARRE D'ONGLETS SEGMENTEE (Screenshot 5)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: Row(
                children: List.generate(_tabs.length, (idx) {
                  final isSelected = _selectedTab == idx;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = idx),
                      borderRadius: BorderRadius.horizontal(
                        left: idx == 0 ? const Radius.circular(22) : Radius.zero,
                        right: idx == _tabs.length - 1 ? const Radius.circular(22) : Radius.zero,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFEF3C7) : Colors.transparent,
                          borderRadius: BorderRadius.horizontal(
                            left: idx == 0 ? const Radius.circular(22) : Radius.zero,
                            right: idx == _tabs.length - 1 ? const Radius.circular(22) : Radius.zero,
                          ),
                          border: Border(
                            right: idx < _tabs.length - 1 ? const BorderSide(color: Color(0xFFE5E7EB)) : BorderSide.none,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _tabs[idx],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ETAT VIDE AVEC BAC A COURRIER (Screenshot 5)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.move_to_inbox_outlined,
                    size: 56,
                    color: const Color(0xFFD1D5DB),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aucune demande pour le moment.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
