import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ValueChanged<String>? onChanged;
  final TextEditingController controller;
  final bool? isEnabled;

  const InfoItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.onChanged, required this.controller,
    this.isEnabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: AppTheme.primary
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.pinkAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          SizedBox(
            width: 160, // You can adjust width as needed
            child: TextField(
              enabled: isEnabled,
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
