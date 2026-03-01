import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String? value;
  final List<DropdownMenuItem<String>> list;
  final void Function(String?)? onChanged;
  final String type;

  const CustomDropdown({super.key, required this.value, required this.list, required this.onChanged, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text("Select $type", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
          items: list,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }
}
