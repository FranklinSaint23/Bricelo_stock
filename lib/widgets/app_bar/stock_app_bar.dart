import 'package:flutter/material.dart';

class StockAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color titleColor;
  final Color backButtonColor;
  final Color backIconColor;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showBottomDivider;

  const StockAppBar({
    super.key,
    required this.title,
    this.backgroundColor = Colors.white,
    this.titleColor = const Color(0xFF111827),
    this.backButtonColor = const Color(0xFFF3F4F6),
    this.backIconColor = const Color(0xFF111827),
    this.showBackButton = true,
    this.onBack,
    this.actions,
    this.showBottomDivider = true,
  });

  factory StockAppBar.forestGreen({
    Key? key,
    required String title,
    VoidCallback? onBack,
    List<Widget>? actions,
  }) {
    return StockAppBar(
      key: key,
      title: title,
      backgroundColor: const Color(0xFF1B5E20),
      titleColor: Colors.white,
      backButtonColor: const Color(0xFF86A789).withValues(alpha: 0.5),
      backIconColor: Colors.black87,
      onBack: onBack,
      actions: actions,
      showBottomDivider: false,
    );
  }

  factory StockAppBar.navy({
    Key? key,
    required String title,
    VoidCallback? onBack,
    List<Widget>? actions,
  }) {
    return StockAppBar(
      key: key,
      title: title,
      backgroundColor: const Color(0xFF0D1B2E),
      titleColor: Colors.white,
      backButtonColor: Colors.white.withValues(alpha: 0.15),
      backIconColor: Colors.white,
      onBack: onBack,
      actions: actions,
      showBottomDivider: false,
    );
  }

  factory StockAppBar.white({
    Key? key,
    required String title,
    VoidCallback? onBack,
    List<Widget>? actions,
    bool showBottomDivider = true,
  }) {
    return StockAppBar(
      key: key,
      title: title,
      backgroundColor: Colors.white,
      titleColor: const Color(0xFF111827),
      backButtonColor: const Color(0xFFF3F4F6),
      backIconColor: const Color(0xFF111827),
      onBack: onBack,
      actions: actions,
      showBottomDivider: showBottomDivider,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (showBottomDivider ? 1.0 : 0.0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: onBack ?? () => Navigator.maybePop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: backButtonColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back_ios_new, color: backIconColor, size: 16),
                ),
              ),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: titleColor),
      ),
      actions: actions,
      bottom: showBottomDivider
          ? const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            )
          : null,
    );
  }
}
