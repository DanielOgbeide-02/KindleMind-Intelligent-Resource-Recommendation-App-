import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';

class ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const ProfileInfoItem({
    Key? key,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: AppTheme.primary
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.pinkAccent),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          Icon(
            Icons.arrow_right,
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
