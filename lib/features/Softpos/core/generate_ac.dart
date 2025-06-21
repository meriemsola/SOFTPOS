/*import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:hce_emv/features/Softpos/core/hex.dart';
import 'package:intl/intl.dart';

import 'tlv_parser.dart';
import 'terminal_risk_management.dart';
import 'backend_service.dart';

class GenerateACResult {
  final String ac;
  final String cid;
  final String atc;
  final String? authCode;
  final List<int> rawResponse;

  GenerateACResult({
    required this.ac,
    required this.cid,
    required this.atc,
    this.authCode,
    required this.rawResponse,
  });
}
Future<GenerateACResult?> processGenerateAC({
  required List<TLV> readRecords,
  required double amount,
  required String unpredictableNumber,
  required String aip,
  required String dfname,
  required TerminalRiskAnalysisResult riskResult,
  required void Function(String) setResult,
}) async {
  print(
    '📌 processGenerateAC called, montant : $amount, online : ${riskResult.isOnline}',
  );

  // Vérification du montant
  if (amount <= 0) {
    print('❌ Montant invalide : $amount');
    setResult('❌ Montant invalide');
    return null;
  }
  int amountInCents = (amount * 100).toInt();
  /*if (amountInCents > 99999999) { // Limite de 999999.99
    print('❌ Montant trop élevé : $amount');
    setResult('❌ Montant trop élevé');
    return null;
  }*/

  if (riskResult.isDeclined) {
    print('❌ Transaction refusée : ${riskResult.reason}');
    setResult('❌ Transaction refusée : ${riskResult.reason}');
    return null;
  }

  // Récupérer les données dynamiques
  final panTlv = TLVParser.findTlvRecursive(readRecords, 0x5A);
  final panSequenceNumberTlv = TLVParser.findTlvRecursive(readRecords, 0x5F34);
  final currencyCodeTlv = TLVParser.findTlvRecursive(readRecords, 0x5F2A);
  final transactionTypeTlv = TLVParser.findTlvRecursive(readRecords, 0x9C);
  final expiryDateTlv = TLVParser.findTlvRecursive(
    readRecords,
    0x5F24,
  ); // Ajout de la date d'expiration
  final terminalCountryCodeTlv = TLVParser.findTlvRecursive(
    readRecords,
    0x9F1A,
  );
  final terminalCapabilitiesTlv = TLVParser.findTlvRecursive(
    readRecords,
    0x9F33,
  );
  if (panTlv == null) {
    print('❌ PAN (0x5A) non trouvé');
    setResult('❌ PAN non trouvé');
    return null;
  }

  String pan = Hex.encode(
    panTlv.value,
  ).toUpperCase().replaceAll(RegExp(r'0+$'), '');
  String panSequenceNumber =
      panSequenceNumberTlv != null
          ? Hex.encode(panSequenceNumberTlv.value).toUpperCase()
          : '00';
  String currencyCode =
      currencyCodeTlv != null
          ? Hex.encode(currencyCodeTlv.value).toUpperCase()
          : '0978'; // EUR
  String transactionType =
      transactionTypeTlv != null
          ? Hex.encode(transactionTypeTlv.value).toUpperCase()
          : '00';
  String terminalCountryCode =
      terminalCountryCodeTlv != null
          ? Hex.encode(terminalCountryCodeTlv.value).toUpperCase()
          : '0250'; // France
  String terminalCapabilities =
      terminalCapabilitiesTlv != null
          ? Hex.encode(terminalCapabilitiesTlv.value).toUpperCase()
          : 'E0B0C8'; // Exemple de la table B-3

  // Construire CDOL1
  List<int> cdol1Data = [];
  String amountAuthorised =
      amountInCents.toRadixString(16).padLeft(12, '0').toUpperCase();
  String amountOther = '000000000003';
  String tvr = Hex.encode(riskResult.tvr).toUpperCase();
  String transactionDate = DateFormat('yyMMdd').format(DateTime.now());
  String transactionTime = DateFormat(
    'HHmmss',
  ).format(DateTime.now()); // Ajout pour 9F21
  String terminalType = riskResult.isOnline ? '22' : '23';
  String cvmResults = '000000'; // Exemple de la table B-3
  String expiryDate =
      expiryDateTlv != null
          ? Hex.encode(expiryDateTlv.value)
              .toUpperCase() // Format MMYY
          : '0000'; // Valeur par défaut si absente

  final cdol1Tlv = TLVParser.findTlvRecursive(readRecords, 0x8C);
  if (cdol1Tlv == null) {
    print('❌ CDOL1 non trouvé');
    setResult('❌ CDOL1 non trouvé');
    return null;
  }

  final cdol1Bytes = cdol1Tlv.value;
  int idx = 0;
  while (idx < cdol1Bytes.length) {
    int tag = cdol1Bytes[idx++];
    if ((tag & 0x1F) == 0x1F) {
      if (idx >= cdol1Bytes.length) {
        print('❌ CDOL1 malformé : tag incomplet');
        setResult('❌ CDOL1 malformé');
        return null;
      }
      tag = (tag << 8) | cdol1Bytes[idx++];
    }
    int length = cdol1Bytes[idx++];

    if (tag == 0x9F02) {
      cdol1Data.addAll(Hex.decode(amountAuthorised));
    } else if (tag == 0x9F03) {
      cdol1Data.addAll(Hex.decode(amountOther));
    } else if (tag == 0x9F1A) {
      cdol1Data.addAll(Hex.decode(terminalCountryCode));
    } else if (tag == 0x95) {
      cdol1Data.addAll(riskResult.tvr);
    } else if (tag == 0x5F2A) {
      cdol1Data.addAll(Hex.decode(currencyCode));
    } else if (tag == 0x9A) {
      cdol1Data.addAll(Hex.decode(transactionDate));
    } else if (tag == 0x9C) {
      cdol1Data.addAll(Hex.decode(transactionType));
    } else if (tag == 0x9F37) {
      cdol1Data.addAll(Hex.decode(unpredictableNumber));
    } else if (tag == 0x9F35) {
      cdol1Data.addAll(Hex.decode(terminalType));
    } else if (tag == 0x9F34) {
      cdol1Data.addAll(Hex.decode(cvmResults));
    } else if (tag == 0x9F21) {
      // Transaction Time
      cdol1Data.addAll(Hex.decode(transactionTime));
    } else if (tag == 0x9F33) {
      // Terminal Capabilities
      cdol1Data.addAll(Hex.decode(terminalCapabilities));
    } else {
      cdol1Data.addAll(List.filled(length, 0x00));
    }
  }

  // Première commande GENERATE AC
  final acType = riskResult.isOnline ? 0x80 : 0x40;
  final generateAcCommand = [
    0x80,
    0xAE,
    acType,
    0x00,
    cdol1Data.length,
    ...cdol1Data,
    0x00,
  ];

  final apduHex = Hex.encode(generateAcCommand).toUpperCase();
  print('📌 Première commande GENERATE AC : $apduHex');

  final responseHex = await FlutterNfcKit.transceive(apduHex);
  print('📌 Réponse première GENERATE AC : $responseHex');

  if (responseHex.length < 4 ||
      responseHex.substring(responseHex.length - 4).toUpperCase() != '9000') {
    print(
      '❌ Échec première GENERATE AC, SW : ${responseHex.length >= 4 ? responseHex.substring(responseHex.length - 4) : 'Invalide'}',
    );
    setResult('❌ Échec première GENERATE AC');
    return null;
  }
  final responseBytes = Hex.decode(
    responseHex.substring(0, responseHex.length - 4),
  );
  final responseTlvs = TLVParser.parse(Uint8List.fromList(responseBytes));

  final acTlv = TLVParser.findTlvRecursive(responseTlvs, 0x9F26);
  final cidTlv = TLVParser.findTlvRecursive(responseTlvs, 0x9F27);
  final atcTlv = TLVParser.findTlvRecursive(responseTlvs, 0x9F36);
  final issuerApplicationDataTlv = TLVParser.findTlvRecursive(
    responseTlvs,
    0x9F10,
  );

  if (acTlv == null || cidTlv == null || atcTlv == null) {
    print('❌ Données AC manquantes (9F26, 9F27, 9F36)');
    setResult('❌ Données AC manquantes');
    return null;
  }

  String ac = Hex.encode(acTlv.value).toUpperCase();
  String cid = Hex.encode(cidTlv.value).toUpperCase();
  String atc = Hex.encode(atcTlv.value).toUpperCase();
  String? issuerApplicationData =
      issuerApplicationDataTlv != null
          ? Hex.encode(issuerApplicationDataTlv.value).toUpperCase()
          : null;
  print('$issuerApplicationData');

  if (riskResult.isOnline && cid != '80') {
    print('❌ ARQC attendu, reçu CID : $cid');
    setResult('❌ ARQC attendu, reçu CID : $cid');
    return null;
  } else if (!riskResult.isOnline && cid != '40') {
    print('❌ TC attendu, reçu CID : $cid');
    setResult('❌ TC attendu, reçu CID : $cid');
    return null;
  }

  if (cid == '00') {
    print('❌ Transaction refusée par la carte (AAC)');
    setResult('❌ Transaction refusée par la carte (AAC)');
    return null;
  }

  String? authCode;
  List<int> finalResponseBytes = responseBytes;

  // Appeler le backend si en ligne
  if (riskResult.isOnline) {
    final backendResult = await sendToBackend(
      pan: pan,
      panSequenceNumber: panSequenceNumber,
      ac: ac,
      atc: atc,
      amountAuthorised: amountAuthorised,
      expiryDate: expiryDate, // Ajout de la date d'expiration
      amountOther: amountOther,
      terminalCountryCode: terminalCountryCode,
      tvr: tvr,
      transactionCurrencyCode: currencyCode,
      transactionDate: transactionDate,
      transactionType: transactionType,
      unpredictableNumber: unpredictableNumber,
      issuerApplicationData: issuerApplicationData,
      aip: aip,
      cid: cid,
    );
    if (backendResult == null) {
      print('❌ Échec de l’autorisation en ligne');
      setResult('❌ Échec de l’autorisation en ligne');
      return null;
    }
    print(panSequenceNumber);
    final arpc = backendResult['arpc'];
    authCode = backendResult['authCode'];

    final Uint8List authAscii = Uint8List.fromList(ascii.encode(authCode!));
    print(Hex.encode(authAscii)); // Affiche "3030"
    final csu = '00820000';
    final String issuerAuthData = arpc + csu;
    print('🔐 Issuer Authentication Data : $issuerAuthData');
    // Log des variables pour débogage
    print(
      '📌 issuerAuthData: $issuerAuthData (${Hex.decode(issuerAuthData).length} octets)',
    );
    print('📌 authCode: $authCode (${Hex.decode(authCode).length} octets)');
    print(
      '📌 riskResult.tvr: ${Hex.encode(riskResult.tvr)} (${riskResult.tvr.length} octets)',
    );
    print(
      '📌 unpredictableNumber: $unpredictableNumber (${Hex.decode(unpredictableNumber).length} octets)',
    );

    List<int> cdol2Data = [];
    final cdol2Tlv = TLVParser.findTlvRecursive(readRecords, 0x8D);
    if (cdol2Tlv == null) {
      print('❌ CDOL2 non trouvé');
      setResult('❌ CDOL2 non trouvé');
      return null;
    }

    print(
      '📌 CDOL2 (Tag 8D): ${Hex.encode(cdol2Tlv.value).toUpperCase()}',
    ); // Log du CDOL2

    final cdol2Bytes = cdol2Tlv.value;
    int idx = 0;
    while (idx < cdol2Bytes.length) {
      int tag = cdol2Bytes[idx++];
      if ((tag & 0x1F) == 0x1F) {
        // Gestion des tags sur 2 octets
        if (idx >= cdol2Bytes.length) {
          print('❌ CDOL2 malformé : tag incomplet');
          setResult('❌ CDOL2 malformé');
          return null;
        }
        tag = (tag << 8) | cdol2Bytes[idx++];
      }
      idx++; // Ignorer la longueur du tag

      if (tag == 0x91) {
        // Issuer Authentication Data
        cdol2Data.addAll(Hex.decode(issuerAuthData));
        print(
          '📌 Ajout Tag 91: ${Hex.encode(Hex.decode(issuerAuthData)).toUpperCase()}',
        );
      } else if (tag == 0x8A) {
        // Authorization Response Code (2 octets)
        cdol2Data.addAll(
          Hex.decode('3030'),
        ); // Convertir en 2 octets (ex. "3030" -> [0x30, 0x30])
        print(
          '📌 Ajout Tag 8A: ${Hex.encode(Hex.decode(authCode)).toUpperCase()}',
        );
      } else if (tag == 0x95) {
        // Terminal Verification Results
        cdol2Data.addAll(riskResult.tvr);
        print('📌 Ajout Tag 95: ${Hex.encode(riskResult.tvr).toUpperCase()}');
      } else if (tag == 0x9F37) {
        // Unpredictable Number
        cdol2Data.addAll(Hex.decode(unpredictableNumber));
        print(
          '📌 Ajout Tag 9F37: ${Hex.encode(Hex.decode(unpredictableNumber)).toUpperCase()}',
        );
      }
    }

    // Seconde commande GENERATE AC
    final secondAcCommand = [
      0x80, // CLA
      0xAE, // INS
      0x40, // P1 (TC)
      0x00, // P2
      0x13, // Lc
      ...cdol2Data, // Données CDOL2
      0x00, // Le
    ];

    final secondApduHex = Hex.encode(secondAcCommand).toUpperCase();
    print('📌 Seconde commande GENERATE AC : $secondApduHex');

    final secondResponseHex = await FlutterNfcKit.transceive(secondApduHex);
    print('📌 Réponse seconde GENERATE AC : $secondResponseHex');

    if (secondResponseHex.length < 4 ||
        secondResponseHex
                .substring(secondResponseHex.length - 4)
                .toUpperCase() !=
            '9000') {
      print(
        '❌ Échec seconde GENERATE AC, SW : ${secondResponseHex.length >= 4 ? secondResponseHex.substring(secondResponseHex.length - 4) : 'Invalide'}',
      );
      setResult('❌ Échec seconde GENERATE AC');
      return null;
    }

    final secondResponseBytes = Hex.decode(
      secondResponseHex.substring(0, secondResponseHex.length - 4),
    );
    finalResponseBytes = secondResponseBytes;
    final secondResponseTlvs = TLVParser.parse(
      Uint8List.fromList(secondResponseBytes),
    );

    final secondAcTlv = TLVParser.findTlvRecursive(secondResponseTlvs, 0x9F26);
    final secondCidTlv = TLVParser.findTlvRecursive(secondResponseTlvs, 0x9F27);
    final secondAtcTlv = TLVParser.findTlvRecursive(secondResponseTlvs, 0x9F36);

    if (secondAcTlv == null || secondCidTlv == null || secondAtcTlv == null) {
      print('❌ Données AC manquantes (9F26, 9F27, 9F36) dans seconde réponse');
      setResult('❌ Données AC manquantes dans seconde réponse');
      return null;
    }

    ac = Hex.encode(secondAcTlv.value).toUpperCase();
    cid = Hex.encode(secondCidTlv.value).toUpperCase();
    atc = Hex.encode(secondAtcTlv.value).toUpperCase();

    if (cid != '40') {
      print('❌ TC attendu dans seconde réponse, reçu CID : $cid');
      setResult('❌ TC attendu dans seconde réponse, reçu CID : $cid');
      return null;
    }

    if (cid == '00') {
      print('❌ Transaction refusée par la carte (AAC) dans seconde réponse');
      setResult(
        '❌ Transaction refusée par la carte (AAC) dans seconde réponse',
      );
      return null;
    }

  return GenerateACResult(
    ac: ac,
    cid: cid,
    atc: atc,
    authCode: authCode,
    rawResponse: finalResponseBytes,
  );
}
}*/
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:hce_emv/features/Softpos/core/hex.dart';
import 'package:intl/intl.dart';
import 'tlv_parser.dart';
import 'terminal_risk_management.dart';
import 'backend_service.dart';

class GenerateACResult {
  final String ac;
  final String cid;
  final String atc;
  final String? authCode;
  final List<int> rawResponse;

  GenerateACResult({
    required this.ac,
    required this.cid,
    required this.atc,
    this.authCode,
    required this.rawResponse,
  });
}

Future<GenerateACResult?> processGenerateAC({
  required List<TLV> readRecords,
  required double amount,
  required String unpredictableNumber,
  required String aip,
  required String dfname,
  required TerminalRiskAnalysisResult riskResult,
  required void Function(String) setResult,
}) async {
  print(
    '📌 processGenerateAC called, montant : $amount, online : ${riskResult.isOnline}, tvr : ${Hex.encode(riskResult.tvr)}',
  );

  // Vérification du montant
  if (amount <= 0) {
    print('❌ Montant invalide : $amount');
    setResult('❌ Montant invalide');
    return null;
  }
  int amountInCents = (amount * 100).toInt();

  if (riskResult.isDeclined) {
    print('❌ Transaction refusée : ${riskResult.reason}');
    setResult('❌ Transaction refusée : ${riskResult.reason}');
    return null;
  }

  // Vérifier AIP pour la prise en charge des transactions en ligne
  final aipBytes = Hex.decode(aip);
  final supportsOnline = aipBytes.length >= 2 && (aipBytes[0] & 0x10) != 0; // Bit 5 : Online PIN supported
  print('📌 AIP : $aip, Supporte transactions en ligne : $supportsOnline');

  // Récupérer les données dynamiques
  final panTlv = TLVParser.findTlvRecursive(readRecords, 0x5A);
  final panSequenceNumberTlv = TLVParser.findTlvRecursive(readRecords, 0x5F34);
  final currencyCodeTlv = TLVParser.findTlvRecursive(readRecords, 0x5F2A);
  final transactionTypeTlv = TLVParser.findTlvRecursive(readRecords, 0x9C);
  final expiryDateTlv = TLVParser.findTlvRecursive(readRecords, 0x5F24);
  final terminalCountryCodeTlv = TLVParser.findTlvRecursive(readRecords, 0x9F1A);
  final terminalCapabilitiesTlv = TLVParser.findTlvRecursive(readRecords, 0x9F33);
  if (panTlv == null) {
    print('❌ PAN (0x5A) non trouvé');
    setResult('❌ PAN non trouvé');
    return null;
  }

  String pan = Hex.encode(panTlv.value).toUpperCase().replaceAll(RegExp(r'0+$'), '');
  String panSequenceNumber = panSequenceNumberTlv != null ? Hex.encode(panSequenceNumberTlv.value).toUpperCase() : '00';
  String currencyCode = currencyCodeTlv != null ? Hex.encode(currencyCodeTlv.value).toUpperCase() : '0978'; // EUR
  String transactionType = transactionTypeTlv != null ? Hex.encode(transactionTypeTlv.value).toUpperCase() : '00';
  String terminalCountryCode = terminalCountryCodeTlv != null ? Hex.encode(terminalCountryCodeTlv.value).toUpperCase() : '0250'; // France
  String terminalCapabilities = terminalCapabilitiesTlv != null ? Hex.encode(terminalCapabilitiesTlv.value).toUpperCase() : 'E0B0C8';
  String expiryDate = expiryDateTlv != null ? Hex.encode(expiryDateTlv.value).toUpperCase() : '0000';

  // Construire CDOL1
  List<int> cdol1Data = [];
  String amountAuthorised = amountInCents.toRadixString(16).padLeft(12, '0').toUpperCase();
  String amountOther = '000000000003';
  String tvr = Hex.encode(riskResult.tvr).toUpperCase();
  String transactionDate = DateFormat('yyMMdd').format(DateTime.now());
  String transactionTime = DateFormat('HHmmss').format(DateTime.now());
  String terminalType = riskResult.isOnline ? '22' : '23';
  String cvmResults = '000000';

  final cdol1Tlv = TLVParser.findTlvRecursive(readRecords, 0x8C);
  if (cdol1Tlv == null) {
    print('❌ CDOL1 non trouvé');
    setResult('❌ CDOL1 non trouvé');
    return null;
  }

  final cdol1Bytes = cdol1Tlv.value;
  int idx = 0;
  while (idx < cdol1Bytes.length) {
    int tag = cdol1Bytes[idx++];
    if ((tag & 0x1F) == 0x1F) {
      if (idx >= cdol1Bytes.length) {
        print('❌ CDOL1 malformé : tag incomplet');
        setResult('❌ CDOL1 malformé');
        return null;
      }
      tag = (tag << 8) | cdol1Bytes[idx++];
    }
    int length = cdol1Bytes[idx++];

    if (tag == 0x9F02) {
      cdol1Data.addAll(Hex.decode(amountAuthorised));
    } else if (tag == 0x9F03) {
      cdol1Data.addAll(Hex.decode(amountOther));
    } else if (tag == 0x9F1A) {
      cdol1Data.addAll(Hex.decode(terminalCountryCode));
    } else if (tag == 0x95) {
      cdol1Data.addAll(riskResult.tvr);
    } else if (tag == 0x5F2A) {
      cdol1Data.addAll(Hex.decode(currencyCode));
    } else if (tag == 0x9A) {
      cdol1Data.addAll(Hex.decode(transactionDate));
    } else if (tag == 0x9C) {
      cdol1Data.addAll(Hex.decode(transactionType));
    } else if (tag == 0x9F37) {
      cdol1Data.addAll(Hex.decode(unpredictableNumber));
    } else if (tag == 0x9F35) {
      cdol1Data.addAll(Hex.decode(terminalType));
    } else if (tag == 0x9F34) {
      cdol1Data.addAll(Hex.decode(cvmResults));
    } else if (tag == 0x9F21) {
      cdol1Data.addAll(Hex.decode(transactionTime));
    } else if (tag == 0x9F33) {
      cdol1Data.addAll(Hex.decode(terminalCapabilities));
    } else {
      cdol1Data.addAll(List.filled(length, 0x00));
    }
  }

  // Première commande GENERATE AC
  final acType = riskResult.isOnline ? 0x80 : 0x40;
  final generateAcCommand = [
    0x80,
    0xAE,
    acType,
    0x00,
    cdol1Data.length,
    ...cdol1Data,
    0x00,
  ];

  final apduHex = Hex.encode(generateAcCommand).toUpperCase();
  print('📌 Première commande GENERATE AC : $apduHex');

  final responseHex = await FlutterNfcKit.transceive(apduHex);
  print('📌 Réponse première GENERATE AC : $responseHex');

  if (responseHex.length < 4 || responseHex.substring(responseHex.length - 4).toUpperCase() != '9000') {
    print('❌ Échec première GENERATE AC, SW : ${responseHex.length >= 4 ? responseHex.substring(responseHex.length - 4) : 'Invalide'}');
    setResult('❌ Échec première GENERATE AC');
    return null;
  }
  final responseBytes = Hex.decode(responseHex.substring(0, responseHex.length - 4));
  final responseTlvs = TLVParser.parse(Uint8List.fromList(responseBytes));

  final acTlv = TLVParser.findTlvRecursive(responseTlvs, 0x9F26);
  final cidTlv = TLVParser.findTlvRecursive(responseTlvs, 0x9F27);
  final atcTlv = TLVParser.findTlvRecursive(responseTlvs, 0x9F36);
  final issuerApplicationDataTlv = TLVParser.findTlvRecursive(responseTlvs, 0x9F10);

  if (acTlv == null || cidTlv == null || atcTlv == null) {
    print('❌ Données AC manquantes (9F26, 9F27, 9F36)');
    setResult('❌ Données AC manquantes');
    return null;
  }

  String ac = Hex.encode(acTlv.value).toUpperCase();
  String cid = Hex.encode(cidTlv.value).toUpperCase();
  String atc = Hex.encode(atcTlv.value).toUpperCase();
  String? issuerApplicationData = issuerApplicationDataTlv != null ? Hex.encode(issuerApplicationDataTlv.value).toUpperCase() : null;

  if (riskResult.isOnline && cid != '80') {
    print('⚠️ ARQC attendu, reçu CID : $cid');
    setResult('⚠️ Transaction hors ligne (TC) reçue au lieu d\'ARQC');
    // Accepter TC si la carte insiste, mais signaler l'anomalie
  } else if (!riskResult.isOnline && cid != '40') {
    print('❌ TC attendu, reçu CID : $cid');
    setResult('❌ TC attendu, reçu CID : $cid');
    return null;
  }

  if (cid == '00') {
    print('❌ Transaction refusée par la carte (AAC)');
    setResult('❌ Transaction refusée par la carte (AAC)');
    return null;
  }

  String? authCode;
  List<int> finalResponseBytes = responseBytes;

  // Appeler le backend si en ligne
  if (riskResult.isOnline) {
    final backendResult = await sendToBackend(
      pan: pan,
      panSequenceNumber: panSequenceNumber,
      ac: ac,
      atc: atc,
      amountAuthorised: amountAuthorised,
      expiryDate: expiryDate,
      amountOther: amountOther,
      terminalCountryCode: terminalCountryCode,
      tvr: tvr,
      transactionCurrencyCode: currencyCode,
      transactionDate: transactionDate,
      transactionType: transactionType,
      unpredictableNumber: unpredictableNumber,
      issuerApplicationData: issuerApplicationData,
      aip: aip,
      cid: cid,
    );
    if (backendResult == null) {
      print('❌ Échec de l’autorisation en ligne');
      setResult('❌ Échec de l’autorisation en ligne');
      return null;
    }
    final arpc = backendResult['arpc'];
    authCode = backendResult['authCode'];

    final csu = '00820000';
    final String issuerAuthData = arpc + csu;

    List<int> cdol2Data = [];
    final cdol2Tlv = TLVParser.findTlvRecursive(readRecords, 0x8D);
    if (cdol2Tlv == null) {
      print('❌ CDOL2 non trouvé');
      setResult('❌ CDOL2 non trouvé');
      return null;
    }

    final cdol2Bytes = cdol2Tlv.value;
    idx = 0;
    while (idx < cdol2Bytes.length) {
      int tag = cdol2Bytes[idx++];
      if ((tag & 0x1F) == 0x1F) {
        if (idx >= cdol2Bytes.length) {
          print('❌ CDOL2 malformé : tag incomplet');
          setResult('❌ CDOL2 malformé');
          return null;
        }
        tag = (tag << 8) | cdol2Bytes[idx++];
      }
      int length = cdol2Bytes[idx++];

      if (tag == 0x91) {
        cdol2Data.addAll(Hex.decode(issuerAuthData));
      } else if (tag == 0x8A) {
        cdol2Data.addAll(Hex.decode('3030'));
      } else if (tag == 0x95) {
        cdol2Data.addAll(riskResult.tvr);
      } else if (tag == 0x9F37) {
        cdol2Data.addAll(Hex.decode(unpredictableNumber));
      } else {
        cdol2Data.addAll(List.filled(length, 0x00));
      }
    }

    // Seconde commande GENERATE AC
    final secondAcCommand = [
      0x80,
      0xAE,
      0x40,
      0x00,
      cdol2Data.length,
      ...cdol2Data,
      0x00,
    ];

    final secondApduHex = Hex.encode(secondAcCommand).toUpperCase();
    print('📌 Seconde commande GENERATE AC : $secondApduHex');

    final secondResponseHex = await FlutterNfcKit.transceive(secondApduHex);
    print('📌 Réponse seconde GENERATE AC : $secondResponseHex');

    if (secondResponseHex.length < 4 || secondResponseHex.substring(secondResponseHex.length - 4).toUpperCase() != '9000') {
      print('❌ Échec seconde GENERATE AC, SW : ${secondResponseHex.length >= 4 ? secondResponseHex.substring(secondResponseHex.length - 4) : 'Invalide'}');
      setResult('❌ Échec seconde GENERATE AC');
      return null;
    }

    final secondResponseBytes = Hex.decode(secondResponseHex.substring(0, secondResponseHex.length - 4));
    final secondResponseTlvs = TLVParser.parse(Uint8List.fromList(secondResponseBytes));

    final secondAcTlv = TLVParser.findTlvRecursive(secondResponseTlvs, 0x9F26);
    final secondCidTlv = TLVParser.findTlvRecursive(secondResponseTlvs, 0x9F27);
    final secondAtcTlv = TLVParser.findTlvRecursive(secondResponseTlvs, 0x9F36);
    final secondIssuerApplicationDataTlv = TLVParser.findTlvRecursive(secondResponseTlvs, 0x9F10);

    if (secondAcTlv == null || secondCidTlv == null || secondAtcTlv == null) {
      print('❌ Données AC manquantes (9F26, 9F27, 9F36) dans seconde réponse');
      setResult('❌ Données AC manquantes dans seconde réponse');
      return null;
    }

    ac = Hex.encode(secondAcTlv.value).toUpperCase();
    cid = Hex.encode(secondCidTlv.value).toUpperCase();
    atc = Hex.encode(secondAtcTlv.value).toUpperCase();
    issuerApplicationData = secondIssuerApplicationDataTlv != null ? Hex.encode(secondIssuerApplicationDataTlv.value).toUpperCase() : null;

    if (cid == '00') {
      print('❌ Transaction refusée par la carte (AAC) dans seconde réponse');
      setResult('❌ Transaction refusée par la carte (AAC) dans seconde réponse');
      return null;
    }

    // Envoyer le TC au backend
    final tcBackendResult = await sendToBackend(
      pan: pan,
      panSequenceNumber: panSequenceNumber,
      ac: ac,
      atc: atc,
      amountAuthorised: amountAuthorised,
      expiryDate: expiryDate,
      amountOther: amountOther,
      terminalCountryCode: terminalCountryCode,
      tvr: tvr,
      transactionCurrencyCode: currencyCode,
      transactionDate: transactionDate,
      transactionType: transactionType,
      unpredictableNumber: unpredictableNumber,
      issuerApplicationData: issuerApplicationData,
      aip: aip,
      cid: cid,
    );
    if (tcBackendResult == null) {
      print('❌ Échec de la validation TC en ligne');
      setResult('❌ Échec de la validation TC en ligne');
      return null;
    }
    authCode = tcBackendResult['authCode'] ?? authCode;
  }

  return GenerateACResult(
    ac: ac,
    cid: cid,
    atc: atc,
    authCode: authCode,
    rawResponse: finalResponseBytes,
  );
}