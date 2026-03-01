import 'package:flutter/material.dart';

import 'package:expence_tracker/shared/widgets/app_button.dart';

import 'custom_text_field.dart';

Future<void> oneLineDialogBox({
  required BuildContext context,
  required String title,
  required String hintText,
  required String buttonText,
  required void Function(String value) onPressed,
  String? editText,
}) async {
  TextEditingController priceController = TextEditingController();
  priceController.text = editText ?? "";

  ValueNotifier<bool> isFilled = ValueNotifier(false);

  priceController.addListener(() {
    isFilled.value = priceController.text.isNotEmpty;
  });

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title == "Add Purse") ...[
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),

            CustomTextField(controller: priceController, hintText: hintText,),

            const SizedBox(height: 18),

            ValueListenableBuilder<bool>(
              valueListenable: isFilled,
              builder: (_, filled, _) {
                return AppButton(
                  label: buttonText,
                  onPressed: filled
                      ? () {
                          onPressed(priceController.text);
                          Navigator.pop(context);
                        }
                      : null,
                  borderRadius: 12,
                  height: 48,
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
