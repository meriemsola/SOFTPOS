import 'dart:math';
import 'package:hce_emv/features/Softpos/core/hex.dart';

import 'tlv_parser.dart';

class TerminalRiskAnalysisResult {
  final List<int> tvr;
  final List<int> tsi;
  final bool isOnline;
  final bool isDeclined;
  final String reason;

  TerminalRiskAnalysisResult({
    required this.tvr,
    required this.tsi,
    required this.isOnline,
    required this.isDeclined,
    required this.reason,
  });
}

TerminalRiskAnalysisResult performTerminalRiskManagement({
  required double amount,
  required List<TLV> readRecords,
  required bool isOffline,
  required String pan, // Nouveau paramètre pour le PAN
  int offlineTransactionCount =
      0, // Nouveau paramètre pour le compteur hors ligne
}) {
  List<int> tvr = [0x00, 0x00, 0x00, 0x00, 0x02];
  List<int> tsi = [0x00, 0x00];
  bool isOnline = false;
  bool isDeclined = false;
  String reason = 'Aucune condition de risque détectée';

  const floorLimit = 1000.0;
  const maxOfflineTransactions =
      10; // Limite de transactions hors ligne (exemple)

  // Liste de PAN blacklistés (exemple statique, à remplacer par une source dynamique)
  final blacklistedPans = ['1234567890123456', '9876543210987654'];

  // Étape 1 : Vérification du montant
  if (amount > floorLimit) {
    tvr[0] |= 0x08; // Transaction exceeds floor limit
    isOnline = true;
    reason = 'Montant dépasse la limite de plancher ($amount > $floorLimit)';
  }

  // Étape 2 : Vérification aléatoire
  if (!isOffline && Random().nextDouble() < 0.1) {
    tvr[4] |= 0x02; // Transaction selected randomly for online
    isOnline = true;
    reason = 'Sélection aléatoire pour autorisation en ligne';
  }

  // Étape 3 : Vérification du PAN blacklisté
  if (blacklistedPans.contains(pan)) {
    tvr[0] |= 0x20; // Card appears on terminal exception file (bit 5, octet 1)
    isDeclined = true;
    reason = 'Carte blacklistée détectée';
  }

  // Étape 4 : Vérification du nombre de transactions hors ligne
  if (!isDeclined &&
      isOffline &&
      offlineTransactionCount > maxOfflineTransactions) {
    tvr[0] |= 0x04; // Offline transaction limit exceeded (bit 3, octet 1)
    isOnline = true;
    reason =
        'Nombre de transactions hors ligne dépassé ($offlineTransactionCount > $maxOfflineTransactions)';
  }

  // Étape 5 : Vérification IAC-Denial
  if (!isDeclined) {
    final iacDenial =
        TLVParser.findTlvRecursive(readRecords, 0x9F0E)?.value ??
        [0x00, 0x00, 0x00, 0x00, 0x00];
    if (iacDenial.length != 5) {
      tvr[4] |= 0x80; // ICC data missing (bit 8, octet 5)
      isDeclined = true;
      reason = 'IAC-Denial manquant ou invalide';
    } else {
      for (int i = 0; i < tvr.length; i++) {
        if ((tvr[i] & iacDenial[i]) != 0) {
          isDeclined = true;
          reason = 'Transaction rejetée par IAC-Denial';
          break;
        }
      }
    }
  }

  // Étape 6 : Vérification IAC-Online
  if (!isDeclined) {
    final iacOnline =
        TLVParser.findTlvRecursive(readRecords, 0x9F0F)?.value ??
        [0x00, 0x00, 0x00, 0x00, 0x00];
    if (iacOnline.length != 5) {
      tvr[4] |= 0x80; // ICC data missing
      isOnline = true;
      reason = 'IAC-Online manquant ou invalide';
    } else {
      for (int i = 0; i < tvr.length; i++) {
        if ((tvr[i] & iacOnline[i]) != 0) {
          isOnline = true;
          reason = 'Autorisation en ligne requise par IAC-Online';
          break;
        }
      }
    }
  }

  // Étape 7 : Mise à jour du TSI
  if (isOnline) {
    tsi[0] |= 0x80; // Online authorization requested
  }
  if (!isDeclined) {
    tsi[0] |= 0x40; // Cardholder verification performed
  }

  print('📌 TVR : ${Hex.encode(tvr)}');
  print('📌 TSI : ${Hex.encode(tsi)}');
  print('📌 Online requis : $isOnline');
  print('📌 Rejeté : $isDeclined');
  print('📌 Raison : $reason');

  return TerminalRiskAnalysisResult(
    tvr: tvr,
    tsi: tsi,
    isOnline: isOnline,
    isDeclined: isDeclined,
    reason: reason,
  );
}