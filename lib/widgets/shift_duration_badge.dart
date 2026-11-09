import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stock_prime/models/models.dart';

/// Badge affichant la durée d'un shift de caisse en Heures, Minutes, Secondes (HHh MMm SSs).
/// Pour les shifts actifs (non clôturés), un timer interne met à jour les secondes
/// en temps réel chaque seconde sans forcer le rafraîchissement des écrans parents.
class ShiftDurationBadge extends StatefulWidget {
  final CashShift shift;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Border? border;
  final bool showIcon;
  final bool showSeconds;

  const ShiftDurationBadge({
    super.key,
    required this.shift,
    this.textStyle,
    this.backgroundColor,
    this.iconColor,
    this.iconSize = 11,
    this.padding,
    this.borderRadius,
    this.border,
    this.showIcon = true,
    this.showSeconds = true,
  });

  @override
  State<ShiftDurationBadge> createState() => _ShiftDurationBadgeState();
}

class _ShiftDurationBadgeState extends State<ShiftDurationBadge> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startTickerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ShiftDurationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shift.isClosed != widget.shift.isClosed || oldWidget.shift.id != widget.shift.id) {
      _ticker?.cancel();
      _ticker = null;
      _startTickerIfNeeded();
    }
  }

  void _startTickerIfNeeded() {
    if (!widget.shift.isClosed) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.showSeconds ? widget.shift.formattedDurationHms : widget.shift.formattedDuration;
    const defaultColor = Color(0xFF6EE7B7);
    final effectiveTextStyle = widget.textStyle ??
        const TextStyle(color: defaultColor, fontSize: 11, fontWeight: FontWeight.bold);
    final effectiveIconColor = widget.iconColor ?? effectiveTextStyle.color ?? defaultColor;

    return Container(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? const Color(0xFF065F46),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
        border: widget.border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showIcon) ...[
            Icon(Icons.timer_outlined, color: effectiveIconColor, size: widget.iconSize),
            const SizedBox(width: 3.5),
          ],
          Text(
            text,
            style: effectiveTextStyle,
          ),
        ],
      ),
    );
  }
}

