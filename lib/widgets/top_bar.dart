import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onReport;
final VoidCallback onBlock;
final VoidCallback onNext;

  const TopBar({
    super.key,
    required this.onReport,
required this.onBlock,
required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primary,
      elevation: 0,
      leading: const BackButton(color: Colors.white),
      title: const Text(
        "Stranger",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
  IconButton(
    icon: const Icon(Icons.flag, color: Colors.white),
    onPressed: onReport,
  ),
  IconButton(
    icon: const Icon(Icons.block, color: Colors.white),
    onPressed: onBlock,
  ),
  IconButton(
    icon: const Icon(Icons.skip_next, color: Colors.white),
    onPressed: onNext,
  ),
],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
