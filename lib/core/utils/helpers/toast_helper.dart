import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hce_emv/core/network/network_interceptor.dart';

class ToastHelper {
  // Show error toast
  static void showError(String message) {
    BotToast.showText(
      text: message,
      contentColor: Colors.red.shade700,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      duration: const Duration(seconds: 3),
      align: Alignment.bottomCenter,
    );
  }

  // Show success toast
  static void showSuccess(String message) {
    BotToast.showText(
      text: message,
      contentColor: Colors.green.shade700,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      duration: const Duration(seconds: 2),
      align: Alignment.bottomCenter,
    );
  }

  // Show info toast
  static void showInfo(String message) {
    BotToast.showText(
      text: message,
      contentColor: Colors.blue.shade700,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      duration: const Duration(seconds: 2),
      align: Alignment.bottomCenter,
    );
  }

  // Show loading dialog
  static CancelFunc showLoading({String? message}) {
    return BotToast.showLoading(
      backButtonBehavior: BackButtonBehavior.ignore,
      allowClick: false,
      clickClose: false,
      crossPage: true,
    );
  }

  // Show a user-friendly error toast
  static void showFriendlyError(Object error, {String? fallbackMessage}) {
    String message;
    if (error is DioException) {
      // Use DioErrorHandler if available
      message = DioErrorHandler.handleError(error);
    } else if (error is Exception) {
      message = error.toString();
    } else {
      message =
          fallbackMessage ?? 'An unexpected error occurred. Please try again.';
    }
    showError(message);
  }
}
