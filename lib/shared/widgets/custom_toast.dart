import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class CustomeToast {
  static void showSuccess(BuildContext context, String message) {
    Toastification().show(
      title: Text(message),
      icon: const Icon(Icons.notifications_active),
      autoCloseDuration: const Duration(seconds: 3),
      style: ToastificationStyle.flatColored,
      primaryColor: Theme.of(context).primaryColor,
      alignment: Alignment.topRight,
    );
  }

  static void showError(BuildContext context, String message) {
    Toastification().show(
      title: Text(message),
      icon: const Icon(Icons.error),
      autoCloseDuration: const Duration(seconds: 3),
      style: ToastificationStyle.flatColored,
      primaryColor: Theme.of(context).colorScheme.error,
      alignment: Alignment.topRight,
    );
  }
}
