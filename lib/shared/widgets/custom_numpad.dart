import 'package:flutter/material.dart';

class CustomNumpad extends StatelessWidget {
  final Function(String) onKeyPress;

  const CustomNumpad({super.key, required this.onKeyPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildNumpadRow(context, ["1", "2", "3"]),
        _buildNumpadRow(context, ["4", "5", "6"]),
        _buildNumpadRow(context, ["7", "8", "9"]),
        _buildNumpadRow(context, [".", "0", "back"]),
      ],
    );
  }

  Widget _buildNumpadRow(BuildContext context, List<String> keys) {
    return Expanded(child: Row(children: keys.map((key) => _buildNumpadKey(context, key)).toList()));
  }

  Widget _buildNumpadKey(BuildContext context, String key) {
    bool isBack = key == "back";
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: () => onKeyPress(key),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isBack
                ? Icon(Icons.backspace_outlined, size: 20, color: Theme.of(context).textTheme.bodyMedium?.color)
                : Text(
                    key,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
          ),
        ),
      ),
    );
  }
}
