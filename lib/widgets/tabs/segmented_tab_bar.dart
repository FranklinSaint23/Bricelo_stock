import 'package:flutter/material.dart';

class SegmentedTabBar extends StatelessWidget {
  final List<String> tabs;
  final String selectedTab;
  final ValueChanged<String> onTabSelected;
  final Color activeColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final Color borderColor;
  final double height;

  const SegmentedTabBar({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
    this.activeColor = const Color(0xFFFFDFBA),
    this.activeTextColor = const Color(0xFF111827),
    this.inactiveTextColor = const Color(0xFF374151),
    this.borderColor = const Color(0xFF6B7280),
    this.height = 42,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: List.generate(tabs.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Container(width: 0.9, height: height, color: borderColor);
          }
          final tabIndex = index ~/ 2;
          final tab = tabs[tabIndex];
          final isSelected = tab == selectedTab;
          final isFirst = tabIndex == 0;
          final isLast = tabIndex == tabs.length - 1;

          BorderRadius? borderRadius;
          if (isFirst) {
            borderRadius = const BorderRadius.horizontal(left: Radius.circular(24));
          } else if (isLast) {
            borderRadius = const BorderRadius.horizontal(right: Radius.circular(24));
          }

          return Expanded(
            child: InkWell(
              onTap: () => onTabSelected(tab),
              borderRadius: borderRadius,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: borderRadius,
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                      color: isSelected ? activeTextColor : inactiveTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
