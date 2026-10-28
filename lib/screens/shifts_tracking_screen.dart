import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ShiftsTrackingScreen extends StatefulWidget {
  const ShiftsTrackingScreen({super.key});

  @override
  State<ShiftsTrackingScreen> createState() => _ShiftsTrackingScreenState();
}

class _ShiftsTrackingScreenState extends State<ShiftsTrackingScreen> {
  bool _isShiftsEnabled = false;

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
          'Suivi des shifts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Suivi par service (shift)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),

          // OPTION 1: DESACTIVE (RECOMMANDÉ)
          InkWell(
            onTap: () => setState(() => _isShiftsEnabled = false),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: !_isShiftsEnabled ? const Color(0xFFA7F3D0).withValues(alpha: 0.7) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !_isShiftsEnabled ? const Color(0xFF059669) : const Color(0xFFE5E7EB),
                  width: !_isShiftsEnabled ? 1.5 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    !_isShiftsEnabled ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: !_isShiftsEnabled ? const Color(0xFF047857) : const Color(0xFF9CA3AF),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Désactivé',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Aucune mention de service dans le POS. Recommandé pour les boutiques solo.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // OPTION 2: ACTIVE
          InkWell(
            onTap: () => setState(() => _isShiftsEnabled = true),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isShiftsEnabled ? const Color(0xFFA7F3D0).withValues(alpha: 0.7) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isShiftsEnabled ? const Color(0xFF059669) : const Color(0xFFE5E7EB),
                  width: _isShiftsEnabled ? 1.5 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _isShiftsEnabled ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _isShiftsEnabled ? const Color(0xFF047857) : const Color(0xFF9CA3AF),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activé',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Le caissier ouvre un service (caisse) avant de vendre, puis le clôture pour faire la caisse.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
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
