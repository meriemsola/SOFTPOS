/*import 'dart:convert';
import 'dart:typed_data';
import 'package:hce_emv/features/Softpos/core/hex.dart';
import 'package:hce_emv/features/Softpos/core/tlv_parser.dart';
import 'package:http/http.dart' as http;
// Fonction utilitaire pour convertir Hex.decode en Uint8List
Uint8List hexDecodeToUint8List(String hex) {
  return Uint8List.fromList(Hex.decode(hex));
}
Future<Map<String, dynamic>?> sendToBackend({
  required String pan,
  required String panSequenceNumber,
  required String amountAuthorised,
  required String amountOther,
  required String expiryDate,
  required String ac,
  required String atc,
  required String cid,
  required String? issuerApplicationData,
  required String terminalCountryCode,
  required String tvr,
  required String transactionCurrencyCode,
  required String transactionDate,
  required String transactionType,
  required String unpredictableNumber,
  required String aip,
}) async {
  try {
    final String expiryDateShort = expiryDate.substring(2, 6); // JJMMYY → MMYY

    // Construction du champ 55 : TLV (Tag + Length + Value)
    final List<TLV> field55Tags = [
      TLV(0x9F26, hexDecodeToUint8List(ac)), // Application Cryptogram
      TLV(0x9F02, hexDecodeToUint8List(amountAuthorised)), // Amount Authorised
      TLV(0x9F03, hexDecodeToUint8List(amountOther)), // Amount Other
      TLV(
        0x9F1A,
        hexDecodeToUint8List(terminalCountryCode),
      ), // Terminal Country Code
      TLV(0x95, hexDecodeToUint8List(tvr)), // TVR
      TLV(
        0x5F2A,
        hexDecodeToUint8List(transactionCurrencyCode),
      ), // Currency Code
      TLV(0x9A, hexDecodeToUint8List(transactionDate)), // Transaction Date
      TLV(0x9C, hexDecodeToUint8List(transactionType)), // Transaction Type
      TLV(
        0x9F37,
        hexDecodeToUint8List(unpredictableNumber),
      ), // Unpredictable Number
      TLV(0x82, hexDecodeToUint8List(aip)), // AIP
      TLV(0x9F36, hexDecodeToUint8List(atc)), // ATC
      if (issuerApplicationData != null)
        TLV(
          0x9F10,
          hexDecodeToUint8List(issuerApplicationData),
        ), // Issuer App Data
    ];

    // Fonction d'encodage TLV
    List<int> tlvListToByteArray(List<TLV> tlvs) {
      List<int> bytes = [];
      for (var tlv in tlvs) {
        int tag = tlv.tag;

        // Encodage du tag
        if (tag <= 0xFF) {
          bytes.add(tag);
        } else {
          bytes.add((tag >> 8) & 0xFF);
          bytes.add(tag & 0xFF);
        }

        // Encodage de la longueur
        int length = tlv.value.length;
        if (length <= 0x7F) {
          bytes.add(length);
        } else if (length <= 0xFF) {
          bytes.add(0x81);
          bytes.add(length);
        } else {
          bytes.add(0x82);
          bytes.add((length >> 8) & 0xFF);
          bytes.add(length & 0xFF);
        }

        // Ajout de la valeur
        bytes.addAll(tlv.value);
      }
      return bytes;
    }

    final String field55Hex =
        Hex.encode(tlvListToByteArray(field55Tags)).toUpperCase();

    final Map<String, dynamic> body = {
      'pan': pan,
      'panSequenceNumber': panSequenceNumber,
      'amount': amountAuthorised,
      'expiryDate': expiryDateShort,
      'field55Hex': field55Hex,
    };

    print('📤 PAN: $pan');
    print('📤 PAN Seq: $panSequenceNumber');
    print('📤 amount: $amountAuthorised');
    print('📤 expiryDate: $expiryDateShort');
    print('📤 field55Hex: $field55Hex');

    final uri = Uri.parse('http://172.20.10.4:8080/process');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print('✅ Réponse backend : $result');

      final String? arpcTag91 = result['de55Hex'];
      final String? authCode = result['de39'];

      if (arpcTag91 == null ||
          !arpcTag91.startsWith("91") ||
          arpcTag91.length < 6) {
        print('❌ Tag 91 manquant ou invalide');
        return null;
      }

      final tag91 = arpcTag91.substring(4); // ignorer tag + longueur
      print('📌 ARPC (91) : $tag91');

      return {'arpc': tag91, 'authCode': authCode};
    } else {
      print('❌ Erreur ${response.statusCode} : ${response.body}');
      return null;
    }
  } catch (e) {
    print('❌ Exception : $e');
    return null;
  }
}*/
import 'dart:convert';
import 'dart:typed_data';
import 'package:hce_emv/features/Softpos/core/hex.dart';
import 'package:hce_emv/features/Softpos/core/tlv_parser.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> sendToBackend({
  required String pan,
  required String panSequenceNumber,
  required String amountAuthorised,
  required String amountOther,
  required String expiryDate,
  required String ac,
  required String atc,
  required String cid,
  required String? issuerApplicationData,
  required String terminalCountryCode,
  required String tvr,
  required String transactionCurrencyCode,
  required String transactionDate,
  required String transactionType,
  required String unpredictableNumber,
  required String aip,
}) async {
  try {
    final String expiryDateShort = expiryDate.substring(2, 6); // JJMMYY → MMYY

    // Construction du champ 55 : TLV
    final List<TLV> field55Tags = [
      TLV(0x9F26, hexDecodeToUint8List(ac)),
      TLV(0x9F02, hexDecodeToUint8List(amountAuthorised)),
      TLV(0x9F03, hexDecodeToUint8List(amountOther)),
      TLV(0x9F1A, hexDecodeToUint8List(terminalCountryCode)),
      TLV(0x95, hexDecodeToUint8List(tvr)),
      TLV(0x5F2A, hexDecodeToUint8List(transactionCurrencyCode)),
      TLV(0x9A, hexDecodeToUint8List(transactionDate)),
      TLV(0x9C, hexDecodeToUint8List(transactionType)),
      TLV(0x9F37, hexDecodeToUint8List(unpredictableNumber)),
      TLV(0x82, hexDecodeToUint8List(aip)),
      TLV(0x9F36, hexDecodeToUint8List(atc)),
      TLV(0x9F27, hexDecodeToUint8List(cid)),
      if (issuerApplicationData != null)
        TLV(0x9F10, hexDecodeToUint8List(issuerApplicationData)),
    ];

    List<int> tlvListToByteArray(List<TLV> tlvs) {
      List<int> bytes = [];
      for (var tlv in tlvs) {
        int tag = tlv.tag;
        if (tag <= 0xFF) {
          bytes.add(tag);
        } else {
          bytes.add((tag >> 8) & 0xFF);
          bytes.add(tag & 0xFF);
        }
        int length = tlv.value.length;
        if (length <= 0x7F) {
          bytes.add(length);
        } else if (length <= 0xFF) {
          bytes.add(0x81);
          bytes.add(length);
        } else {
          bytes.add(0x82);
          bytes.add((length >> 8) & 0xFF);
          bytes.add(length & 0xFF);
        }
        bytes.addAll(tlv.value);
      }
      return bytes;
    }

    final String field55Hex =
        Hex.encode(tlvListToByteArray(field55Tags)).toUpperCase();

    final Map<String, dynamic> body = {
      'pan': pan,
      'panSequenceNumber': panSequenceNumber,
      'amount': amountAuthorised,
      'expiryDate': expiryDateShort,
      'field55Hex': field55Hex,
      'cid': cid, // Ajout du CID pour différencier ARQC et TC
    };

    print('📤 PAN: $pan');
    print('📤 PAN Seq: $panSequenceNumber');
    print('📤 Amount: $amountAuthorised');
    print('📤 ExpiryDate: $expiryDateShort');
    print('📤 Field55Hex: $field55Hex');
    print('📤 CID: $cid');

    final uri = Uri.parse('http://192.168.100.16:8080/process');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print('✅ Réponse backend : $result');

      final String? authCode = result['de39'];
      String? arpcTag91 = result['de55Hex'];

      if (cid == '80') {
        // ARQC
        if (arpcTag91 == null ||
            !arpcTag91.startsWith("91") ||
            arpcTag91.length < 6) {
          print('❌ Tag 91 manquant ou invalide pour ARQC');
          return null;
        }
        final tag91 = arpcTag91.substring(4); // Ignorer tag + longueur
        print('📌 ARPC (91) : $tag91');
        return {'arpc': tag91, 'authCode': authCode};
      } else {
        // TC ou autre
        print('📌 Pas de tag 91 attendu pour CID=$cid');
        return {'authCode': authCode};
      }
    } else {
      print('❌ Erreur ${response.statusCode} : ${response.body}');
      return null;
    }
  } catch (e) {
    print('❌ Exception : $e');
    return null;
  }
}

Uint8List hexDecodeToUint8List(String hex) {
  return Uint8List.fromList(Hex.decode(hex));
}
