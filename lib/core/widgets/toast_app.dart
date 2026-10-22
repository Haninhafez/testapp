import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

abstract class AppToast {
  /// Shows an Error Toast
  static void showError({
    required BuildContext context,
    required String message,
    String title = 'Error',
  }) {
    toastification.show(
      context: context,
      alignment: Alignment.bottomLeft,
      type: ToastificationType.error,
      style: ToastificationStyle.minimal,
      backgroundColor: const Color.fromARGB(255, 63, 21, 17),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      primaryColor: const Color.fromARGB(255, 73, 29, 26),
      description: Text(message),
  
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: const Color.fromARGB(255, 73, 29, 26)),
    );
  }

  /// Shows a Success Toast
  static void showSuccess({
    required BuildContext context,
    required String message,
    String title = 'Success',
  }) {
    toastification.show(
      context: context,
      alignment: Alignment.bottomCenter,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Shows an Info / Warning Toast
  static void showInfo({
    required BuildContext context,
    required String message,
    String title = 'Info',
  }) {
    toastification.show(
      context: context,
      alignment: Alignment.bottomCenter,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
    );
  }
}