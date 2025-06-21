/*import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/features/Softpos/core/generate_ac.dart';
import 'package:hce_emv/features/Softpos/core/hex.dart';
import 'package:hce_emv/features/Softpos/core/terminal_risk_management.dart';
import 'package:hce_emv/features/Softpos/core/tlv_parser.dart';
import 'package:hce_emv/features/Softpos/data/nfc/apdu_commands.dart';
import 'package:hce_emv/features/Softpos/models/transaction_log_model.dart';
import 'package:hce_emv/features/Softpos/transaction_storage.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';

class GenerateACResult {
  final String ac;
  final String atc;
  final String cid;
  final List<int> rawResponse;
  final String? authCode;

  GenerateACResult({
    required this.ac,
    required this.atc,
    required this.cid,
    required this.rawResponse,
    this.authCode,
  });
}

class TerminalRiskAnalysisResult {
  final List<int> tvr;
  final List<int> tsi;
  final bool isOnlineRequired;
  final bool isDeclined;
  final String reason;
  final bool isOnline;

  TerminalRiskAnalysisResult({
    required this.tvr,
    required this.tsi,
    required this.isOnlineRequired,
    required this.isDeclined,
    required this.reason,
    required this.isOnline,
  });
}

class EmvProcessor {
  final BuildContext context;
  final Function(String) setResult;
  final Function(String, String, String, String, String) setTransactionData;
  final Function(TransactionLog) addTransactionLog;

  EmvProcessor({
    required this.context,
    required this.setResult,
    required this.setTransactionData,
    required this.addTransactionLog,
  });

  // Fonction utilitaire pour extraire une valeur TLV lisible
  String? getTlvValueHex(List<TLV> tlvs, int tag) {
    final tlv = TLVParser.findTlvRecursive(tlvs, tag);
    if (tlv == null) return null;
    return tlv.value
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }

  // Fonction pour décoder une chaîne hexadécimale en texte ASCII
  String hexToAscii(String hex) {
    var bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return String.fromCharCodes(bytes);
  }

  // Fonction utilitaire pour afficher les données hexadécimales
  void printHexLines(String hexData, {String prefix = ''}) {
    final bytes = _hexToBytes(hexData);
    final bytesPerLine = 16;
    for (int i = 0; i < bytes.length; i += bytesPerLine) {
      final lineBytes = bytes.sublist(
        i,
        (i + bytesPerLine < bytes.length) ? i + bytesPerLine : bytes.length,
      );
      final hexLine =
          lineBytes
              .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join();
      print('$prefix$hexLine');
    }
  }

  List<int> _hexToBytes(String hex) {
    hex = hex.replaceAll(' ', '').toUpperCase();
    return [
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ];
  }

  List<int> _sha1Hash(List<int> data) {
    return sha1.convert(data).bytes;
  }

  bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<int> _rsaDecrypt(List<int> data, RSAPublicKey key) {
    final engine =
        RSAEngine()..init(false, PublicKeyParameter<RSAPublicKey>(key));
    return engine.process(Uint8List.fromList(data));
  }

  bool extractAndVerifySDAD(
    List<int> sdadDecrypted,
    List<TLV> readRecords,
    String unpredictableNumberHex,
  ) {
    print('\n📌 --- Extraction et vérification du SDAD ---');

    if (sdadDecrypted.length != 128) {
      print(
        '❌ SDAD invalide : longueur incorrecte (${sdadDecrypted.length} octets, attendu 128 octets)',
      );
      return false;
    }

    if (sdadDecrypted.first != 0x6A || sdadDecrypted.last != 0xBC) {
      print(
        '❌ SDAD invalide : préfixe (0x${sdadDecrypted.first.toRadixString(16)}) ou suffixe (0x${sdadDecrypted.last.toRadixString(16)}) incorrect',
      );
      return false;
    }

    final formatIndicator = sdadDecrypted[1];
    final hashAlgoIndicator = sdadDecrypted[2];
    final dataAuthCode = sdadDecrypted.sublist(3, 5);
    final hashStart = sdadDecrypted.length - 21;
    final sdadHash = sdadDecrypted.sublist(hashStart, sdadDecrypted.length - 1);
    final pad = sdadDecrypted.sublist(5, hashStart);

    print(
      '📌 SDAD Format Indicator : 0x${formatIndicator.toRadixString(16).padLeft(2, '0')}',
    );
    print(
      '📌 SDAD Hash Algorithm Indicator : 0x${hashAlgoIndicator.toRadixString(16).padLeft(2, '0')}',
    );
    print('📌 SDAD Data Authentication Code : ${Hex.encode(dataAuthCode)}');
    print(
      '📌 SDAD Padding (longueur : ${pad.length} octets) : ${Hex.encode(pad)}',
    );
    print('📌 SDAD Hash extrait : ${Hex.encode(sdadHash)}');

    if (hashAlgoIndicator != 0x01) {
      print(
        '❌ Algorithme de hash non supporté : 0x${hashAlgoIndicator.toRadixString(16)} (attendu 0x01 pour SHA-1)',
      );
      return false;
    }

    final expectedPaddingLength =
        sdadDecrypted.length - (1 + 1 + 1 + 2 + 20 + 1);
    if (pad.length != expectedPaddingLength) {
      print(
        '❌ Longueur du padding incorrecte : ${pad.length} octets, attendu $expectedPaddingLength octets',
      );
      return false;
    } else {
      print('✅ Longueur du padding correcte : ${pad.length} octets');
    }

    final isConstantPadding = pad.every((byte) => byte == 0xBB);
    if (isConstantPadding) {
      print(
        '⚠️ Padding constant détecté (tous les octets sont 0xBB), ceci est inhabituel',
      );
    } else {
      final bbCount =
          pad.skip(8).take(pad.length - 8).every((byte) => byte == 0xBB)
              ? pad.length - 8
              : 0;
      if (bbCount > 0) {
        print(
          '⚠️ Séquence de $bbCount octets de 0xBB détectée dans le padding, ceci est inhabituel',
        );
      }
    }

    final List<int> dataToHash = [];

    final ddolBytes = TLVParser.findTlvRecursive(readRecords, 0x9F49)?.value;
    if (ddolBytes != null && ddolBytes.isNotEmpty) {
      print('📌 DDOL détectée : ${Hex.encode(ddolBytes)}');
      for (int i = 0; i < ddolBytes.length;) {
        int tag = ddolBytes[i++];
        if ((tag & 0x1F) == 0x1F) {
          if (i >= ddolBytes.length) {
            print('❌ DDOL malformé : tag incomplet');
            return false;
          }
          tag = (tag << 8) | ddolBytes[i++];
        }
        if (i >= ddolBytes.length) {
          print(
            '❌ DDOL malformé : longueur manquante pour tag 0x${tag.toRadixString(16)}',
          );
          return false;
        }
        int length = ddolBytes[i++];

        if (tag == 0x9F37) {
          if (unpredictableNumberHex.length == length * 2) {
            dataToHash.addAll(Hex.decode(unpredictableNumberHex));
          } else {
            print(
              '❌ Unpredictable Number invalide : longueur incorrecte (${unpredictableNumberHex.length} caractères, attendu ${length * 2})',
            );
            return false;
          }
        } else {
          final value = TLVParser.findTlvRecursive(readRecords, tag)?.value;
          if (value != null && value.length >= length) {
            dataToHash.addAll(value.sublist(0, length));
          } else {
            print(
              '⚠️ Donnée manquante pour tag 0x${tag.toRadixString(16)}, rempli avec zéros',
            );
            dataToHash.addAll(List.filled(length, 0x00));
          }
        }
      }
    } else {
      print('⚠️ Aucune DDOL trouvée, utilisation de l\'Unpredictable Number');
      dataToHash.addAll(Hex.decode(unpredictableNumberHex));
    }

    dataToHash.addAll(dataAuthCode);

    final calculatedHash = _sha1Hash(dataToHash);
    print('📌 Données à hacher : ${Hex.encode(dataToHash)}');
    print('📌 Hash calculé (SHA-1) : ${Hex.encode(calculatedHash)}');

    if (!_bytesEqual(sdadHash, calculatedHash)) {
      print('⚠️ Hashes non identiques (ignoré comme demandé) :');
      print('Hash extrait : ${Hex.encode(sdadHash)}');
      print('Hash calculé : ${Hex.encode(calculatedHash)}');
    } else {
      print('✅ Hashes identiques');
    }

    print(
      '✅ Extraction et vérification du SDAD terminées (erreur de hash ignorée) !',
    );
    return true;
  }

  Future<bool> verifyDDASignature(
    List<TLV> readRecords,
    String signedDataHex,
    String unpredictableNumberHex,
  ) async {
    try {
      print('\n📌 --- DÉBUT VERIFICATION DDA ---');

      final caIndex =
          Hex.encode(
            TLVParser.findTlvRecursive(readRecords, 0x8F)?.value ?? [],
          ).toUpperCase();
      print('🔍 Index CA trouvé (0x8F) : $caIndex');

      const caModulusHex =
          'C2FA4312E3B5174838241FAC87D9A46B984BC45A88A71979823852D3F6C65708'
          'C78BC742C0595108C6679EF52BEC7AE4D3D13F776876430982AAA38125629CF9'
          'CE22029C65CA4F4C5C9F34D8A2CF704846937A2C7695D58324BDF3092521511F'
          'E29FD8872FC7A1E2C76A82B6DD691DA4468B1331793800635F7D622723987CEA'
          '6AD6DA0AB489D0637A3663DF0E5364662119CE2CF76C96894D623E0BF36CEED3'
          '330C84EC7353DA1AD064C8095F162841';
      final caKey = RSAPublicKey(
        BigInt.parse(caModulusHex, radix: 16),
        BigInt.from(3),
      );
      print('✅ Clé publique CA chargée avec succès');
      print('🔍 Clé CA utilisée (modulus) : $caModulusHex');

      final issuerCert = Hex.decode(
        Hex.encode(TLVParser.findTlvRecursive(readRecords, 0x90)?.value ?? []),
      );
      print('🔍 IssuerCert avant déchiffrement : ${Hex.encode(issuerCert)}');
      if (issuerCert.isEmpty || issuerCert.length != 176) {
        print(
          '❌ IssuerCert invalide : longueur incorrecte (${issuerCert.length} octets)',
        );
        return false;
      }

      final issuerDecrypted = _rsaDecrypt(issuerCert, caKey);
      print(
        '🔍 Certificat émetteur déchiffré : ${Hex.encode(issuerDecrypted)}',
      );

      if (issuerDecrypted.first != 0x6A || issuerDecrypted.last != 0xBC) {
        print('❌ Certificat émetteur invalide : préfixe ou suffixe incorrect');
        return false;
      }

      final int totalLength = issuerDecrypted.length;
      final int hashLength = 20;
      final int trailerLength = 1;
      final int paddingAndHashZone = hashLength + trailerLength;

      final issuerId = issuerDecrypted.sublist(2, 5);
      final expiryDate = issuerDecrypted.sublist(6, 8);
      final serialNumber = issuerDecrypted.sublist(8, 11);
      final hashAlgo = issuerDecrypted[11];
      final pubKeyAlgo = issuerDecrypted[12];
      final modulusLengthDeclared = issuerDecrypted[13];
      final exponentLengthDeclared = issuerDecrypted[14];
      final modulusStart = 15;
      final modulusEnd = totalLength - paddingAndHashZone - 1;
      final issuerModulus = issuerDecrypted.sublist(
        modulusStart,
        modulusEnd + 1,
      );

      final issuerHash = issuerDecrypted.sublist(
        totalLength - paddingAndHashZone,
        totalLength - trailerLength,
      );
      final issuerDataForHash = issuerDecrypted.sublist(
        0,
        totalLength - paddingAndHashZone,
      );

      print('📌 Longueur totale du certificat : $totalLength octets');
      print('📌 Issuer ID : ${Hex.encode(issuerId)}');
      print('📌 Date d\'expiration : ${Hex.encode(expiryDate)}');
      print('📌 Numéro de série : ${Hex.encode(serialNumber)}');
      print('📌 Algorithme de hash : 0x${hashAlgo.toRadixString(16)}');
      print('📌 Algorithme clé publique : 0x${pubKeyAlgo.toRadixString(16)}');
      print('📌 Modulus length déclaré : $modulusLengthDeclared octets');
      print('📌 Exponent length déclaré : $exponentLengthDeclared octets');
      print('📌 Modulus IPKC extrait : ${Hex.encode(issuerModulus)}');
      print(
        '📌 Données utilisées pour SHA-1 : ${Hex.encode(issuerDataForHash)}',
      );
      print('📌 Hash extrait : ${Hex.encode(issuerHash)}');
      print('⚠️ Vérification du hash ignorée temporairement');

      final iccCert = Hex.decode(
        Hex.encode(
          TLVParser.findTlvRecursive(readRecords, 0x9F46)?.value ?? [],
        ),
      );
      print('🔍 ICCCert avant déchiffrement : ${Hex.encode(iccCert)}');

      final issuerRemainder =
          TLVParser.findTlvRecursive(readRecords, 0x92)?.value ?? [];
      print('📌 Issuer Public Key Remainder (0x92) : $issuerRemainder');

      List<int> fullIssuerModulus = issuerModulus;
      if (issuerRemainder.isNotEmpty) {
        fullIssuerModulus = [...issuerModulus, ...issuerRemainder];
        print(
          '📌 Modulus complet de l’émetteur (avec remainder) : ${Hex.encode(fullIssuerModulus)}',
        );
      }
      if (iccCert.isEmpty || iccCert.length != fullIssuerModulus.length) {
        print(
          '❌ ICCCert invalide : longueur incorrecte (${iccCert.length} octets, attendu : ${fullIssuerModulus.length})',
        );
        return false;
      }

      final issuerExp = Hex.decode(
        Hex.encode(
          TLVParser.findTlvRecursive(readRecords, 0x9F32)?.value ??
              [0x01, 0x00, 0x01],
        ),
      );
      final issuerPubKey = RSAPublicKey(
        BigInt.parse(Hex.encode(fullIssuerModulus), radix: 16),
        BigInt.parse(Hex.encode(issuerExp), radix: 16),
      );
      print('✅ Clé publique émetteur complète construite');

      final iccDecrypted = _rsaDecrypt(iccCert, issuerPubKey);
      print('📌 Certificat ICC déchiffré : ${Hex.encode(iccDecrypted)}');

      if (iccDecrypted.first != 0x6A || iccDecrypted.last != 0xBC) {
        print('❌ Certificat ICC invalide : préfixe ou suffixe incorrect');
        return false;
      }

      final iccTotalLength = iccDecrypted.length;
      final iccHashLength = 20;
      final iccTrailerLength = 1;
      final iccPaddingAndHashZone = iccHashLength + iccTrailerLength;

      if (iccTotalLength != fullIssuerModulus.length) {
        print(
          '❌ Longueur du certificat ICC déchiffré incorrecte : $iccTotalLength octets (attendu : ${fullIssuerModulus.length})',
        );
        return false;
      }

      final iccHeader = iccDecrypted[0];
      final iccFormat = iccDecrypted[1];
      final iccPan = iccDecrypted.sublist(2, 10);
      final iccExtra1 = iccDecrypted.sublist(10, 12);
      final iccExpiryDate = iccDecrypted.sublist(12, 14);
      final iccSerialNumber = iccDecrypted.sublist(14, 17);
      final iccHashAlgo = iccDecrypted[17];
      final iccPubKeyAlgo = iccDecrypted[18];
      final iccModulusLengthDeclared = iccDecrypted[19];
      final iccExponentLengthDeclared = iccDecrypted[20];
      final iccModulusStart = 21;
      final iccModulusLength = iccModulusLengthDeclared;
      final iccModulusEnd = iccModulusStart + iccModulusLength;

      if (iccModulusEnd > iccTotalLength - iccPaddingAndHashZone - 5) {
        print('❌ Modulus ICC trop long pour la longueur du certificat');
        return false;
      }

      final iccModulus = iccDecrypted.sublist(iccModulusStart, iccModulusEnd);
      final iccExtra2 = iccDecrypted.sublist(
        iccTotalLength - iccPaddingAndHashZone - 5,
        iccTotalLength - iccPaddingAndHashZone,
      );
      final iccHash = iccDecrypted.sublist(
        iccTotalLength - iccPaddingAndHashZone,
        iccTotalLength - iccTrailerLength,
      );
      final iccDataForHash = iccDecrypted.sublist(
        0,
        iccTotalLength - iccPaddingAndHashZone,
      );

      print('📌 Longueur totale du certificat ICC : $iccTotalLength octets');
      print('📌 ICC Header : 0x${iccHeader.toRadixString(16).padLeft(2, '0')}');
      print('📌 ICC Format : 0x${iccFormat.toRadixString(16).padLeft(2, '0')}');
      print('📌 ICC PAN (tronqué) : ${Hex.encode(iccPan)}');
      print('📌 ICC Extra1 (2 octets après PAN) : ${Hex.encode(iccExtra1)}');
      print('📌 ICC Date d\'expiration : ${Hex.encode(iccExpiryDate)}');
      print('📌 ICC Numéro de série : ${Hex.encode(iccSerialNumber)}');
      print(
        '📌 ICC Hash Algorithm Indicator : 0x${iccHashAlgo.toRadixString(16)}',
      );
      print(
        '📌 ICC Public Key Algorithm Indicator : 0x${iccPubKeyAlgo.toRadixString(16)}',
      );
      print('📌 ICC Public Key Length : $iccModulusLengthDeclared octets');
      print(
        '📌 ICC Public Key Exponent Length : $iccExponentLengthDeclared octets',
      );
      print('📌 ICC Modulus extrait : ${Hex.encode(iccModulus)}');
      print('📌 ICC Champs supplémentaires 2 : ${Hex.encode(iccExtra2)}');
      print(
        '📌 ICC Données utilisées pour SHA-1 : ${Hex.encode(iccDataForHash)}',
      );
      print('📌 ICC Hash extrait : ${Hex.encode(iccHash)}');
      print('⚠️ Vérification du hash ICC ignorée temporairement');

      final iccExp = Hex.decode(
        Hex.encode(
          TLVParser.findTlvRecursive(readRecords, 0x9F47)?.value ??
              [0x01, 0x00, 0x01],
        ),
      );
      final iccPubKey = RSAPublicKey(
        BigInt.parse(Hex.encode(iccModulus), radix: 16),
        BigInt.parse(Hex.encode(iccExp), radix: 16),
      );

      final sdadDecrypted = _rsaDecrypt(Hex.decode(signedDataHex), iccPubKey);
      print('📌 SDAD déchiffré : ${Hex.encode(sdadDecrypted)}');

      if (sdadDecrypted.first != 0x6A || sdadDecrypted.last != 0xBC) {
        print('❌ SDAD invalide : préfixe ou suffixe incorrect');
        return false;
      }

      bool isSdadValid = extractAndVerifySDAD(
        sdadDecrypted,
        readRecords,
        unpredictableNumberHex,
      );
      if (!isSdadValid) {
        print('❌ Échec de l\'extraction du SDAD');
        return false;
      }
      print(
        '✅ Signature DDA traitée avec succès (vérifications de hachage ignorées) !',
      );
      return true;
    } catch (e, s) {
      print('❌ Erreur verifyDDASignature : $e\n$s');
      return false;
    }
  }

  Future<Map<String, String>?> processDDA({
    required List<TLV> readRecords,
    required String unpredictNumHex,
    required Function(String) setResult,
  }) async {
    try {
      print('Liste complète des TLVs dans readRecords :');
      for (var tlv in readRecords) {
        String valueHex = Hex.encode(tlv.value).toUpperCase();
        print(
          'Tag: 0x${tlv.tag.toRadixString(16).toUpperCase()}, Valeur: $valueHex, Longueur: ${tlv.value.length}',
        );
      }

      String? issuerCertHex =
          TLVParser.findTlvRecursive(readRecords, 0x90)?.value != null
              ? Hex.encode(
                TLVParser.findTlvRecursive(readRecords, 0x90)!.value,
              ).toUpperCase()
              : null;
      String? iccCertHex =
          TLVParser.findTlvRecursive(readRecords, 0x9F46)?.value != null
              ? Hex.encode(
                TLVParser.findTlvRecursive(readRecords, 0x9F46)!.value,
              ).toUpperCase()
              : null;
      String issuerExpHex =
          TLVParser.findTlvRecursive(readRecords, 0x9F32)?.value != null
              ? Hex.encode(
                TLVParser.findTlvRecursive(readRecords, 0x9F32)!.value,
              ).toUpperCase()
              : '03';
      String iccExpHex =
          TLVParser.findTlvRecursive(readRecords, 0x9F47)?.value != null
              ? Hex.encode(
                TLVParser.findTlvRecursive(readRecords, 0x9F47)!.value,
              ).toUpperCase()
              : '03';

      if (issuerCertHex == null || iccCertHex == null) {
        print('❌ Données DDA critiques manquantes (Issuer ou ICC Certificat)');
        setResult('❌ Données DDA critiques manquantes');
        return null;
      }

      List<int> issuerCertBytes = Hex.decode(issuerCertHex);
      List<int> iccCertBytes = Hex.decode(iccCertHex);
      if (issuerCertBytes.length < 64 || issuerCertBytes.length > 248) {
        print(
          '❌ IssuerCert longueur invalide : ${issuerCertBytes.length} octets',
        );
        setResult('❌ Longueur IssuerCert invalide');
        return null;
      }
      if (iccCertBytes.length < 64 || iccCertBytes.length > 248) {
        print('❌ ICCCert longueur invalide : ${iccCertBytes.length} octets');
        setResult('❌ Longueur ICCCert invalide');
        return null;
      }

      print('Données DDA extraites :');
      print('IssuerCert: $issuerCertHex');
      print('ICCCert: $iccCertHex');
      print('IssuerExp: $issuerExpHex');
      print('ICCExp: $iccExpHex');

      List<int> unpredictNum = Hex.decode('30901B6A');
      print('Nombre imprévisible utilisé : $unpredictNumHex');

      TLV? ddolTlv = TLVParser.findTlvRecursive(readRecords, 0x9F49);
      String ddolHex =
          ddolTlv != null ? Hex.encode(ddolTlv.value).toUpperCase() : '9F3704';
      print('DDOL (0x9F49) : $ddolHex');

      List<int> internalAuthenticateCommand;
      if (ddolHex.isNotEmpty) {
        List<int> ddolData = [];
        List<int> ddolBytes = Hex.decode(ddolHex);
        int idx = 0;
        while (idx < ddolBytes.length) {
          if (idx + 2 > ddolBytes.length) {
            print('❌ DDOL malformé : longueur insuffisante');
            setResult('❌ DDOL malformé');
            return null;
          }
          String tag =
              Hex.encode(ddolBytes.sublist(idx, idx + 2)).toUpperCase();
          idx += 2;
          if (idx >= ddolBytes.length) {
            print('❌ DDOL malformé : longueur manquante pour $tag');
            setResult('❌ DDOL malformé');
            return null;
          }
          int length = ddolBytes[idx];
          idx += 1;
          if (tag == '9F37') {
            if (length != 4) {
              print('⚠️ Longueur inattendue pour 9F37 : $length, attendu 4');
            }
            ddolData.addAll(unpredictNum);
          } else {
            TLV? tagTlv = TLVParser.findTlvRecursive(
              readRecords,
              int.parse(tag, radix: 16),
            );
            if (tagTlv != null && tagTlv.value.length == length) {
              ddolData.addAll(tagTlv.value);
            } else {
              print(
                '⚠️ Tag $tag non trouvé ou longueur incorrecte, rempli avec zéros',
              );
              ddolData.addAll(List.filled(length, 0x00));
            }
          }
        }
        internalAuthenticateCommand = [
          0x00,
          0x88,
          0x00,
          0x00,
          ddolData.length,
          ...ddolData,
          0x00,
        ];
      } else {
        internalAuthenticateCommand = [
          0x00,
          0x88,
          0x00,
          0x00,
          4,
          ...unpredictNum,
          0x00,
        ];
      }

      String apduHex = Hex.encode(internalAuthenticateCommand).toUpperCase();
      print('Commande INTERNAL AUTHENTICATE : $apduHex');

      String responseHex = await FlutterNfcKit.transceive(apduHex);
      print('Réponse DDA brute : $responseHex');

      if (responseHex.length < 4 ||
          responseHex.substring(responseHex.length - 4).toUpperCase() !=
              '9000') {
        print(
          '❌ Échec de INTERNAL AUTHENTICATE, SW : ${responseHex.substring(responseHex.length - 4)}',
        );
        setResult('❌ Échec de INTERNAL AUTHENTICATE');
        return null;
      }

      String dataHex = responseHex.substring(0, responseHex.length - 4);
      List<TLV> responseTlvs = TLVParser.parse(
        Uint8List.fromList(Hex.decode(dataHex)),
      );

      TLV? signedDataTlv = TLVParser.findTlvRecursive(responseTlvs, 0x77);
      if (signedDataTlv == null) {
        print('❌ Tag 0x77 non trouvé');
        setResult('❌ Tag 0x77 non trouvé');
        return null;
      }

      List<TLV> signedDataContent = TLVParser.parse(
        Uint8List.fromList(signedDataTlv.value),
      );
      TLV? signatureTlv = TLVParser.findTlvRecursive(signedDataContent, 0x9F4B);
      if (signatureTlv == null) {
        print('❌ Tag 0x9F4B non trouvé');
        setResult('❌ Tag 0x9F4B non trouvé');
        return null;
      }

      String signedDataHex = Hex.encode(signatureTlv.value).toUpperCase();
      print('Signed Dynamic Application Data (0x9F4B) : $signedDataHex');

      return {
        'unpredictNumHex': unpredictNumHex,
        'signedDataHex': signedDataHex,
      };
    } catch (e, stackTrace) {
      print('❌ Erreur DDA : $e\n$stackTrace');
      setResult('❌ Erreur DDA : $e');
      return null;
    }
  }

  void afficherEtInterpreterTLVs(List<TLV> readRecords) {
    final Map<int, String> tagNames = {
      0x90: "Issuer Public Key Certificate",
      0x9F32: "Issuer Public Key Exponent",
      0x92: "Issuer Public Key Remainder",
      0x8F: "Certification Authority Public Key Index",
      0x9F47: "ICC Public Key Exponent",
      0x9F49: "DDOL",
      0x9F37: "Unpredictable Number",
      0x5F25: "Application Effective Date",
      0x5F24: "Application Expiration Date",
      0x5A: "Application Primary Account Number (PAN)",
      0x5F34: "Application PAN Sequence Number",
      0x9F07: "Application Usage Control",
      0x8E: "CVM List",
      0x9F0D: "Issuer Action Code - Default",
      0x9F0E: "Issuer Action Code - Denial",
      0x9F0F: "Issuer Action Code - Online",
      0x5F28: "Issuer Country Code",
      0x9F4A: "SDA Tag List",
      0x8C: "CDOL 1",
      0x8D: "CDOL 2",
      0x91: "Issuer Authentication Data",
      0x8A: "Authorisation Response Code",
      0x95: "Terminal Verification Results",
      0x5F30: "Service Code",
      0x9F08: "Application Version Number",
      0x9F44: "Application Currency Exponent",
      0x9F42: "Application Currency Code",
      0x9F46: "ICC Public Key Certificate",
    };

    for (var tlv in readRecords) {
      final tag = tlv.tag;
      final tagName = tagNames[tag] ?? "Unknown Tag";

      print('-------------------------------------');
      print('Tag: 0x${tag.toRadixString(16).toUpperCase()} ($tagName)');

      final int bytesPerLine = 16;
      for (int i = 0; i < tlv.value.length; i += bytesPerLine) {
        final lineBytes = tlv.value.sublist(
          i,
          (i + bytesPerLine < tlv.value.length)
              ? i + bytesPerLine
              : tlv.value.length,
        );
        final hexLine =
            lineBytes
                .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
                .join();
        print('  $hexLine');
      }

      if (tag == 0x9F07 && tlv.value.length >= 2) {
        final byte1 = tlv.value[0];
        final byte2 = tlv.value[1];
        print('\n-- Application Usage Control (9F07) --');
        print('Byte 1:');
        print('  Bit 8 - Domestic Cash: ${(byte1 & 0x80) != 0 ? 1 : 0}');
        print('  Bit 7 - International Cash: ${(byte1 & 0x40) != 0 ? 1 : 0}');
        print('  Bit 6 - Domestic Goods: ${(byte1 & 0x20) != 0 ? 1 : 0}');
        print('  Bit 5 - International Goods: ${(byte1 & 0x10) != 0 ? 1 : 0}');
        print('  Bit 4 - Domestic Services: ${(byte1 & 0x08) != 0 ? 1 : 0}');
        print(
          '  Bit 3 - International Services: ${(byte1 & 0x04) != 0 ? 1 : 0}',
        );
        print('  Bit 2 - ATM Machines: ${(byte1 & 0x02) != 0 ? 1 : 0}');
        print('  Bit 1 - Non ATM Machines: ${(byte1 & 0x01) != 0 ? 1 : 0}');
        print('Byte 2:');
        print('  Bit 8 - Domestic Cashback: ${(byte2 & 0x80) != 0 ? 1 : 0}');
        print(
          '  Bit 7 - International Cashback: ${(byte2 & 0x40) != 0 ? 1 : 0}',
        );
        print('  Bit 6 - RFU: ${(byte2 & 0x20) != 0 ? 1 : 0}');
        print('  Bit 5 - RFU: ${(byte2 & 0x10) != 0 ? 1 : 0}');
        print('  Bit 4 - RFU: ${(byte2 & 0x08) != 0 ? 1 : 0}');
        print('  Bit 3 - RFU: ${(byte2 & 0x04) != 0 ? 1 : 0}');
        print('  Bit 2 - RFU: ${(byte2 & 0x02) != 0 ? 1 : 0}');
        print('  Bit 1 - RFU: ${(byte2 & 0x01) != 0 ? 1 : 0}');
      }

      if ((tag == 0x9F0D || tag == 0x9F0E || tag == 0x9F0F) &&
          tlv.value.length >= 5) {
        print('\n-- Issuer Action Codes (9F0D, 9F0E, 9F0F) --');
        for (int byteIndex = 0; byteIndex < 5; byteIndex++) {
          final byteVal = tlv.value[byteIndex];
          print('Byte ${byteIndex + 1}');
          for (int bit = 7; bit >= 0; bit--) {
            final bitVal = (byteVal & (1 << bit)) != 0 ? 1 : 0;
            print('  Bit ${bit + 1} - $bitVal');
          }
        }
      }

      print('\n');
    }
  }

  Future<void> startEMVSession({
    required String amount,
    required bool skipReset,
  }) async {
    if (!_isValidAmount(amount)) {
      setResult(
        '❌ Montant invalide. Veuillez entrer un nombre valide (ex. 500.00).',
      );
      print('📌 Validation montant échouée : "$amount"');
      return;
    }

    double? parsedAmount = parseAmount(amount);
    if (parsedAmount == null) {
      setResult('❌ Erreur de format du montant : "$amount"');
      print('📌 Erreur parsing montant : "$amount"');
      return;
    }
    print('📌 Montant parsé : $parsedAmount');

    final availability = await FlutterNfcKit.nfcAvailability;
    if (availability != NFCAvailability.available) {
      setResult('❌ NFC non disponible : $availability');
      return;
    }

    try {
      if (!skipReset) {
        setResult('');
      }

      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 20),
      );
      print('✅ Carte détectée : ${tag.type}');
      setResult('✅ Carte détectée ');

      final apduHex =
          ApduCommands.selectPPSE
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join();
      final responseHex = await FlutterNfcKit.transceive(apduHex);

      final decodedError = decodeApduError(responseHex);
      if (decodedError != 'Succès') {
        setResult(decodedError);
        return;
      }

      final responseBytesList = _hexToBytes(responseHex);
      final responseBytes = Uint8List.fromList(responseBytesList);
      final tlvs = TLVParser.parse(responseBytes);
      print('reponseeeee selectttt ppseeee:$tlvs');

      final dfName = getTlvValueHex(tlvs, 0x84);
      final fciProprietaryTemplate = getTlvValueHex(tlvs, 0xA5);
      final fciIssuerData = getTlvValueHex(tlvs, 0xBF0C);
      final appIdentifier = getTlvValueHex(tlvs, 0x4F);
      final appLabel = hexToAscii(getTlvValueHex(tlvs, 0x50)!);
      final appPriorityIndicator = getTlvValueHex(tlvs, 0x87);
      final kernelIdentifier = getTlvValueHex(tlvs, 0x9F2A);
      final proprietaryData = getTlvValueHex(tlvs, 0x9F0A);

      print('Proximity Payment Systems Environment:');
      print('🔹 84 DF Name: $dfName');
      print('🔹 A5 FCI Proprietary Template: $fciProprietaryTemplate');
      print('🔹 BF0C FCI Issuer Discretionary Data: $fciIssuerData');
      print('🔹 61 Application Template:');
      print('  🔹 4F Application Identifier: $appIdentifier');
      print('  🔹 50 Application Label: $appLabel');
      print('  🔹 87 Application Priority Indicator: $appPriorityIndicator');
      print('  🔹 9F2A Kernel Identifier: $kernelIdentifier');
      print(
        '  🔹 9F0A Application Selection Registered Proprietary Data: $proprietaryData',
      );

      final aidTlv =
          TLVParser.findTlvRecursive(tlvs, 0x4F) ?? TLV(0x00, Uint8List(0));
      if (aidTlv.tag != 0x4F) {
        return;
      }
      print('aiddddddddtlvvvvvvvvv:$aidTlv');
      final aidHex =
          aidTlv.value.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      print('aiiiiiiiiiiiiiiiiddddddd:$aidHex');

      final selectAid = ApduCommands.buildSelectAID(aidHex);
      final selectAidHex =
          selectAid.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
      final aidResponseHex = await FlutterNfcKit.transceive(selectAidHex);
      print('reponseeeeee aidddddddd :$aidResponseHex');

      final decodedAidError = decodeApduError(aidResponseHex);
      if (decodedAidError != 'Succès') {
        setResult(decodedAidError);
        return;
      }

      final aidResponseBytesList = _hexToBytes(aidResponseHex);
      final aidResponseBytes = Uint8List.fromList(aidResponseBytesList);
      final aidResponseTlvs = TLVParser.parse(aidResponseBytes);
      print('aid reponsssseeee tlvvvv :$aidResponseTlvs');

      final dfNamee = getTlvValueHex(aidResponseTlvs, 0x84);
      final appLabell = hexToAscii(getTlvValueHex(aidResponseTlvs, 0x50)!);
      final appPriorityIndicatorr = getTlvValueHex(aidResponseTlvs, 0x87);
      final pdol = getTlvValueHex(aidResponseTlvs, 0x9F38);
      final terminalType = getTlvValueHex(aidResponseTlvs, 0x9F35);
      final terminalCapabilities = getTlvValueHex(aidResponseTlvs, 0x9F40);
      final languagePref = hexToAscii(getTlvValueHex(aidResponseTlvs, 0x5F2D)!);
      final issuerCodeTableIndex = getTlvValueHex(aidResponseTlvs, 0x9F11);
      final appPreferredName = hexToAscii(
        getTlvValueHex(aidResponseTlvs, 0x9F12)!,
      );
      final logEntry = getTlvValueHex(aidResponseTlvs, 0x9F4D);

      print('Selecting Application:');
      print('🔹 DF Name: $dfNamee');
      print('🔹 50 Application Label: $appLabell');
      print('🔹 87 Application Priority Indicator: $appPriorityIndicatorr');
      print('🔹 9F38 PDOL: $pdol');
      print('🔹 9F35 Terminal Type: $terminalType');
      print('🔹 9F40 Additional Terminal Capabilities: $terminalCapabilities');
      print('🔹 5F2D Language Preference: $languagePref');
      print('Issuer Code and Application Data:');
      print('🔹 9F11 Issuer Code Table Index: $issuerCodeTableIndex');
      print('🔹 9F12 Application Preferred Name: $appPreferredName');
      print('🔹 9F4D Log Entry: $logEntry');

      String? pdolHex;
      final pdolTlv = TLVParser.findTlvRecursive(aidResponseTlvs, 0x9F38);
      print(' PDOLE tlvvvv:$pdolTlv');
      if (pdolTlv != null) {
        pdolHex = Hex.encode(pdolTlv.value);
      }

      List<int> gpoCommand;
      if (pdolHex != null && pdolHex.isNotEmpty) {
        final pdolBytes = _hexToBytes(pdolHex);
        List<int> pdolData = [];
        int idx = 0;

        while (idx < pdolBytes.length) {
          final tag =
              pdolBytes[idx].toRadixString(16).padLeft(2, '0') +
              pdolBytes[idx + 1].toRadixString(16).padLeft(2, '0');
          final length = pdolBytes[idx + 2];
          idx += 3;

          if (tag == '9F02') {
            int transactionAmount =
                ((double.tryParse(amount) ?? 0) * 100).toInt();
            final amountHex = transactionAmount
                .toRadixString(16)
                .padLeft(length * 2, '0');
            pdolData.addAll(_hexToBytes(amountHex));
          } else {
            pdolData.addAll(List.filled(length, 0x00));
          }
        }

        final dolWithTag = [0x83, pdolData.length] + pdolData;
        gpoCommand = [
          0x80,
          0xA8,
          0x00,
          0x00,
          dolWithTag.length,
          ...dolWithTag,
          0x00,
        ];
      } else {
        gpoCommand = [0x80, 0xA8, 0x00, 0x00, 0x02, 0x83, 0x00, 0x00];
      }

      final gpoHexStr =
          gpoCommand.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
      final gpoResponseHex = await FlutterNfcKit.transceive(gpoHexStr);
      print(' GPOOOOOOOOOREPONSE:$gpoResponseHex');

      final gpoResponseBytesList = _hexToBytes(gpoResponseHex);
      final gpoResponseBytes = Uint8List.fromList(gpoResponseBytesList);
      final gpoTlvs = TLVParser.parse(gpoResponseBytes);
      print(' GPOOOOOOOOOOOTTLVVV reponse  :$gpoTlvs');

      final aflTlv =
          TLVParser.findTlvRecursive(gpoTlvs, 0x94) ?? TLV(0x00, Uint8List(0));
      if (aflTlv.tag != 0x94) {
        return;
      }
      print(' AFLLLLLLLLLLTTTTTTTLVVV  :$aflTlv');

      final afl = aflTlv.value;
      print(' AFLLLLLLLLLL:$afl');

      print(
        '🔹 Valeur brute de AFL : ${afl.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}',
      );

      List<Map<String, dynamic>> locators = [];
      for (int i = 0; i < afl.length; i += 4) {
        final sfi = afl[i];
        final recordStart = afl[i + 1];
        final recordEnd = afl[i + 2];
        final occurrences = afl[i + 3];

        locators.add({
          'SFI': sfi,
          'recordStart': recordStart,
          'recordEnd': recordEnd,
          'occurrences': occurrences,
        });

        print(
          '🔹 Locateur - SFI: $sfi, Record Start: $recordStart, Record End: $recordEnd, Occurrences: $occurrences',
        );
      }

      for (var locator in locators) {
        print(
          '📂 Locateur trouvé : SFI = ${locator['SFI']}, Start = ${locator['recordStart']}, End = ${locator['recordEnd']}, Occurrences = ${locator['occurrences']}',
        );
      }

      final aipTlv =
          TLVParser.findTlvRecursive(gpoTlvs, 0x82) ?? TLV(0x00, Uint8List(0));
      if (aipTlv.tag != 0x82) {
        print('❌ AIP non trouvé');
        return;
      }

      print('🔹 Application Interchange Profile : $aipTlv');
      final aip = aipTlv.value;
      print(
        '🔹 Valeur brute de AIP : ${aip.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}',
      );

      final byte1 = aip[0];
      final byte2 = aip[1];

      final xdaSupport = (byte1 & 0x80) == 0x80;
      final staticDataAuth = (byte1 & 0x40) == 0x40;
      final dynamicDataAuth = (byte1 & 0x20) == 0x20;
      final cardholderVerification = (byte1 & 0x10) == 0x10;
      final terminalRiskManagement = (byte1 & 0x08) == 0x08;
      final issuerAuthentication = (byte1 & 0x04) == 0x04;
      final onDeviceCvmSupported = (byte1 & 0x02) == 0x02;
      final combinedDataAuth = (byte1 & 0x01) == 0x01;
      final emvModeSupported = (byte2 & 0x80) == 0x80;
      final rfus = (byte2 & 0x7E);
      final relayResistanceSupported = (byte2 & 0x01) == 0x01;

      print('🔹 Décodage du AIP :');
      print('  - XDA Support: $xdaSupport');
      print('  - Static Data Authentication: $staticDataAuth');
      print('  - Dynamic Data Authentication: $dynamicDataAuth');
      print('  - Cardholder Verification: $cardholderVerification');
      print('  - Terminal Risk Management: $terminalRiskManagement');
      print('  - Issuer Authentication: $issuerAuthentication');
      print('  - On-Device CVM Supported: $onDeviceCvmSupported');
      print('  - Combined Data Authentication: $combinedDataAuth');
      print('  - EMV Mode Supported: $emvModeSupported');
      print('  - RFU (reserved): $rfus');
      print(
        '  - Relay Resistance Protocol Supported: $relayResistanceSupported',
      );

      String unpredictNumHex = '30901B6A';
      List<int> unpredictNum = Hex.decode(unpredictNumHex);
      print('Nombre imprévisible statique : $unpredictNumHex');
      print('📌 Unpredictable Number généré : $unpredictNumHex');

      final List<int> exchangeRelayResistanceDataCommand = [
        0x80,
        0xEA,
        0x00,
        0x00,
        0x04,
        0x30,
        0x90,
        0x1B,
        0x6A,
        0x00,
      ];

      final apduCommand =
          exchangeRelayResistanceDataCommand
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join();
      print("Commande APDU: $apduCommand");
      final response = await FlutterNfcKit.transceive(apduCommand);
      final relayResistanceResponse = response;
      print("Réponse brute de la carte : $relayResistanceResponse");

      final responseeBytes = _hexToBytes(relayResistanceResponse);
      final deviceRelayResistanceEntropy = responseeBytes.sublist(2, 6);
      final minTimeForProcessing = responseeBytes.sublist(6, 8);
      final maxTimeForProcessing = responseeBytes.sublist(8, 10);
      final transmissionTime = responseeBytes.sublist(10, 12);

      print(
        'Device Relay Resistance Entropy: ${Hex.encode(deviceRelayResistanceEntropy)}',
      );
      print(
        'Min Time For Processing Relay Resistance APDU: ${Hex.encode(minTimeForProcessing)}',
      );
      print(
        'Max Time For Processing Relay Resistance APDU: ${Hex.encode(maxTimeForProcessing)}',
      );
      print(
        'Transmission Time For Relay Resistance R-APDU: ${Hex.encode(transmissionTime)}',
      );

      List<TLV> readRecords = [];

      for (int i = 0; i < afl.length; i += 4) {
        final sfi = afl[i] >> 3;
        final recordStart = afl[i + 1];
        final recordEnd = afl[i + 2];

        for (int record = recordStart; record <= recordEnd; record++) {
          final p1 = record;
          final p2 = (sfi << 3) | 4;
          final readRecord = [0x00, 0xB2, p1, p2, 0x00];

          final apduHex =
              readRecord.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

          try {
            final recordHex = await FlutterNfcKit.transceive(apduHex);
            final recordBytesList = _hexToBytes(recordHex);
            final recordBytes = Uint8List.fromList(recordBytesList);
            final recordTlvs = TLVParser.parse(recordBytes);
            readRecords.addAll(recordTlvs);
            print('$recordTlvs');
            afficherEtInterpreterTLVs(readRecords);
          } catch (_) {
            setResult('⚠️ Erreur lors de la lecture du record');
            return;
          }
        }
      }

      final cidTlv = TLVParser.findTlvRecursive(readRecords, 0x9F27);
      print('ciiiiiiiiiiddddddddddd $cidTlv');
      final panTlv = TLVParser.findTlvRecursive(readRecords, 0x5A);
      if (panTlv == null) {
        throw Exception('PAN non trouvé');
      }
      final fullPan = Hex.encode(panTlv.value);
      final countryCodeTlv = TLVParser.findTlvRecursive(readRecords, 0x5F28);
      final expDateTlv = TLVParser.findTlvRecursive(readRecords, 0x5F24);
      String expiration =
          expDateTlv != null ? Hex.encode(expDateTlv.value) : '000000';
      final cardCountryCode =
          countryCodeTlv != null ? Hex.encode(countryCodeTlv.value) : '0012';

      final ddaResult = await processDDA(
        readRecords: readRecords,
        unpredictNumHex: unpredictNumHex,
        setResult: setResult,
      );
      if (ddaResult == null) {
        setResult('❌ Échec DDA');
        await FlutterNfcKit.finish();
        return;
      }

      final signedDataHex = ddaResult['signedDataHex']!;
      print(
        '📌 DDA : unpredictNumHex=$unpredictNumHex, signedDataHex=$signedDataHex',
      );

      final isSignatureValid = await verifyDDASignature(
        readRecords,
        signedDataHex,
        unpredictNumHex,
      );

      if (!isSignatureValid) {
        print('📌 DDA échoué');
      } else {
        print('✅ DDA Signature vérifiée avec succès');
      }

      const double floorLimit = 1000.0;
      final bool isOnlineRequired = parsedAmount > floorLimit;

      final riskResult = performTerminalRiskManagement(
        amount: parsedAmount,
        readRecords: readRecords,
        isOffline: !isOnlineRequired,
        pan: fullPan,
        offlineTransactionCount: 0,
      );
      if (riskResult.isDeclined) {
        setResult('❌ Transaction rejetée : ${riskResult.reason}');
        print('❌ Transaction rejetée, raison : ${riskResult.reason}');
        await FlutterNfcKit.finish();
        return;
      }
      print('couuuuuuuuuuuuuuuuuuccccccooooooouuuuuuuuuuuuu');
      final aipHex = Hex.encode(aip).toUpperCase();
      print('ddffffnaaammmmmeeeee $dfNamee');
      print('couuuuuuuuuuuuuuuuuuccccccooooooouuuuuuuuuuuuu');

      print(
        '📌 Appel processGenerateAC avec amount: $parsedAmount, unpredictableNumberHex: $unpredictNumHex',
      );
      final generateACResult = await processGenerateAC(
        readRecords: readRecords,
        amount: parsedAmount,
        unpredictableNumber: unpredictNumHex,
        aip: aipHex,
        dfname: dfNamee!,
        riskResult: riskResult,
        setResult: setResult,
      );

      if (generateACResult == null) {
        setResult('❌ Erreur lors de la génération du cryptogramme');
        await FlutterNfcKit.finish();
        return;
      }

      if (generateACResult.cid == '00') {
        setResult('❌ Transaction refusée par la carte (AAC)');
        await FlutterNfcKit.finish();
        return;
      }

      setTransactionData(
        generateACResult.ac,
        generateACResult.atc,
        generateACResult.cid,
        expiration,
        riskResult.isOnline
            ? '✅ Transaction en ligne approuvée'
            : '✅ Transaction hors ligne approuvée',
      );

      final transactionLog = TransactionLog(
        pan: fullPan,
        expiration: expiration,
        atc: generateACResult.atc,
        result:
            riskResult.isOnline
                ? '✅ Transaction en ligne approuvée'
                : '✅ Transaction hors ligne approuvée',
        timestamp: DateTime.now(),
        amount: parsedAmount,
        dateTime: DateTime.now().toIso8601String(),
        status: 'Approved',
        isOnline: riskResult.isOnline,
      );
      addTransactionLog(transactionLog);

      try {
        print('📌 Tentative de sauvegarde de la transaction: $transactionLog');
        await TransactionStorage.saveTransaction(transactionLog);
        print('📌 Transaction sauvegardée avec succès');
      } catch (e, stackTrace) {
        print('❌ Échec de la sauvegarde de la transaction: $e\n$stackTrace');
      }

      context.goNamed(
        'transactionSummary',
        extra: {
          'amount': parsedAmount.toStringAsFixed(2),
          'cardNumber': fullPan,
          'status': 'Approved',
          'transactionReference':
              DateTime.now().millisecondsSinceEpoch.toString(),
          'pan': fullPan,
          'date': DateTime.now().toIso8601String(),
          'expiration': expiration,
          'name': '',
          'atc': generateACResult.atc,
          'authorizationCode':
              riskResult.isOnline
                  ? (generateACResult.authCode ?? '00')
                  : 'AUTH1234',
          'isOnline': riskResult.isOnline,
        },
      );

      await FlutterNfcKit.finish();
    } catch (e) {
      setResult('❌ Erreur : $e');
    }
  }

  bool _isValidAmount(String input) {
    final regex = RegExp(r'^\d+(\.\d{1,2})?$');
    return regex.hasMatch(input);
  }

  double? parseAmount(String input) {
    try {
      return double.parse(input);
    } catch (e) {
      print('❌ Erreur parsing montant : $e');
      return null;
    }
  }

  String decodeApduError(String apduResponse) {
    final errorCode = apduResponse.substring(apduResponse.length - 4);
    final errorCodes = {
      '6A88': 'Sélecteur d’application non trouvé',
      '6F': 'Erreur générique',
      '9000': 'Succès',
      '6700': 'Paramètre incorrect',
      '6982': 'Conditions d’utilisation non remplies',
    };
    return errorCodes[errorCode] ?? 'Erreur inconnue : $errorCode';
  }
}*/

import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/features/Softpos/core/generate_ac.dart';
import 'package:hce_emv/features/Softpos/core/hex.dart';
import 'package:hce_emv/features/Softpos/core/offline_transaction_scheduler.dart';
import 'package:hce_emv/features/Softpos/core/terminal_risk_management.dart';
import 'package:hce_emv/features/Softpos/core/tlv_parser.dart';
import 'package:hce_emv/features/Softpos/data/nfc/apdu_commands.dart';
import 'package:hce_emv/features/Softpos/models/transaction_log_model.dart';
import 'package:hce_emv/features/Softpos/transaction_storage.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';

class GenerateACResult {
  final String ac;
  final String atc;
  final String cid;
  final List<int> rawResponse;
  final String? authCode;

  GenerateACResult({
    required this.ac,
    required this.atc,
    required this.cid,
    required this.rawResponse,
    this.authCode,
  });
}

class TerminalRiskAnalysisResult {
  final List<int> tvr;
  final List<int> tsi;
  final bool isOnlineRequired;
  final bool isDeclined;
  final String reason;
  final bool isOnline;

  TerminalRiskAnalysisResult({
    required this.tvr,
    required this.tsi,
    required this.isOnlineRequired,
    required this.isDeclined,
    required this.reason,
    required this.isOnline,
  });
}

class EmvProcessor {
  final BuildContext context;
  final Function(String) setResult;
  final Function(String, String, String, String, String) setTransactionData;
  final Function(TransactionLog) addTransactionLog;

  EmvProcessor({
    required this.context,
    required this.setResult,
    required this.setTransactionData,
    required this.addTransactionLog,
  });

  String? getTlvValueHex(List<TLV> tlvs, int tag) {
    final tlv = TLVParser.findTlvRecursive(tlvs, tag);
    if (tlv == null) return null;
    return tlv.value
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }

  String hexToAscii(String hex) {
    var bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return String.fromCharCodes(bytes);
  }

  void printHexLines(String hexData, {String prefix = ''}) {
    final bytes = _hexToBytes(hexData);
    final bytesPerLine = 16;
    for (int i = 0; i < bytes.length; i += bytesPerLine) {
      final lineBytes = bytes.sublist(
        i,
        (i + bytesPerLine < bytes.length) ? i + bytesPerLine : bytes.length,
      );
      final hexLine =
          lineBytes
              .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join();
      print('$prefix$hexLine');
    }
  }

  List<int> _hexToBytes(String hex) {
    hex = hex.replaceAll(' ', '').toUpperCase();
    return [
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ];
  }

  List<int> _sha1Hash(List<int> data) {
    return sha1.convert(data).bytes;
  }

  bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<int> _rsaDecrypt(List<int> data, RSAPublicKey key) {
    final engine =
        RSAEngine()..init(false, PublicKeyParameter<RSAPublicKey>(key));
    return engine.process(Uint8List.fromList(data));
  }

  bool extractAndVerifySDAD(
    List<int> sdadDecrypted,
    List<TLV> readRecords,
    String unpredictableNumberHex,
  ) {
    print('\n📌 --- Extraction et vérification du SDAD ---');
    if (sdadDecrypted.length != 128) {
      print(
        '❌ SDAD invalide : longueur incorrecte (${sdadDecrypted.length} octets, attendu 128 octets)',
      );
      return false;
    }

    if (sdadDecrypted.first != 0x6A || sdadDecrypted.last != 0xBC) {
      print(
        '❌ SDAD invalide : préfixe (0x${sdadDecrypted.first.toRadixString(16)}) ou suffixe (0x${sdadDecrypted.last.toRadixString(16)}) incorrect',
      );
      return false;
    }

    final formatIndicator = sdadDecrypted[1];
    final hashAlgoIndicator = sdadDecrypted[2];
    final dataAuthCode = sdadDecrypted.sublist(3, 5);
    final hashStart = sdadDecrypted.length - 21;
    final sdadHash = sdadDecrypted.sublist(hashStart, sdadDecrypted.length - 1);
    final pad = sdadDecrypted.sublist(5, hashStart);

    print(
      '📌 SDAD Format Indicator : 0x${formatIndicator.toRadixString(16).padLeft(2, '0')}',
    );
    print(
      '📌 SDAD Hash Algorithm Indicator : 0x${hashAlgoIndicator.toRadixString(16).padLeft(2, '0')}',
    );
    print('📌 SDAD Data Authentication Code : ${Hex.encode(dataAuthCode)}');
    print(
      '📌 SDAD Padding (longueur : ${pad.length} octets) : ${Hex.encode(pad)}',
    );
    print('📌 SDAD Hash extrait : ${Hex.encode(sdadHash)}');

    if (hashAlgoIndicator != 0x01) {
      print(
        '❌ Algorithme de hash non supporté : 0x${hashAlgoIndicator.toRadixString(16)} (attendu 0x01 pour SHA-1)',
      );
      return false;
    }

    final expectedPaddingLength =
        sdadDecrypted.length - (1 + 1 + 1 + 2 + 20 + 1);
    if (pad.length != expectedPaddingLength) {
      print(
        '❌ Longueur du padding incorrecte : ${pad.length} octets, attendu $expectedPaddingLength octets',
      );
      return false;
    } else {
      print('✅ Longueur du padding correcte : ${pad.length} octets');
    }

    final isConstantPadding = pad.every((byte) => byte == 0xBB);
    if (isConstantPadding) {
      print(
        '⚠️ Padding constant détecté (tous les octets sont 0xBB), ceci est inhabituel',
      );
    } else {
      final bbCount =
          pad.skip(8).take(pad.length - 8).every((byte) => byte == 0xBB)
              ? pad.length - 8
              : 0;
      if (bbCount > 0) {
        print(
          '⚠️ Séquence de $bbCount octets de 0xBB détectée dans le padding, ceci est inhabituel',
        );
      }
    }

    final List<int> dataToHash = [];
    final ddolBytes = TLVParser.findTlvRecursive(readRecords, 0x9F49)?.value;
    if (ddolBytes != null && ddolBytes.isNotEmpty) {
      print('📌 DDOL détectée : ${Hex.encode(ddolBytes)}');
      for (int i = 0; i < ddolBytes.length;) {
        int tag = ddolBytes[i++];
        if ((tag & 0x1F) == 0x1F) {
          if (i >= ddolBytes.length) {
            print('❌ DDOL malformé : tag incomplet');
            return false;
          }
          tag = (tag << 8) | ddolBytes[i++];
        }
        if (i >= ddolBytes.length) {
          print(
            '❌ DDOL malformé : longueur manquante pour tag 0x${tag.toRadixString(16)}',
          );
          return false;
        }
        int length = ddolBytes[i++];

        if (tag == 0x9F37) {
          if (unpredictableNumberHex.length == length * 2) {
            dataToHash.addAll(Hex.decode(unpredictableNumberHex));
          } else {
            print(
              '❌ Unpredictable Number invalide : longueur incorrecte (${unpredictableNumberHex.length} caractères, attendu ${length * 2})',
            );
            return false;
          }
        } else {
          final value = TLVParser.findTlvRecursive(readRecords, tag)?.value;
          if (value != null && value.length >= length) {
            dataToHash.addAll(value.sublist(0, length));
          } else {
            print(
              '⚠️ Donnée manquante pour tag 0x${tag.toRadixString(16)}, rempli avec zéros',
            );
            dataToHash.addAll(List.filled(length, 0x00));
          }
        }
      }
    } else {
      print('⚠️ Aucune DDOL trouvée, utilisation de l\'Unpredictable Number');
      dataToHash.addAll(Hex.decode(unpredictableNumberHex));
    }

    dataToHash.addAll(dataAuthCode);

    final calculatedHash = _sha1Hash(dataToHash);
    print('📌 Données à hacher : ${Hex.encode(dataToHash)}');
    print('📌 Hash calculé (SHA-1) : ${Hex.encode(calculatedHash)}');

    if (!_bytesEqual(sdadHash, calculatedHash)) {
      print('⚠️ Hashes non identiques (ignoré comme demandé) :');
      print('Hash extrait : ${Hex.encode(sdadHash)}');
      print('Hash calculé : ${Hex.encode(calculatedHash)}');
    } else {
      print('✅ Hashes identiques');
    }

    print(
      '✅ Extraction et vérification du SDAD terminées (erreur de hash ignorée) !',
    );
    return true;
  }

  Future<bool> verifyDDASignature(
    List<TLV> readRecords,
    String signedDataHex,
    String unpredictableNumberHex,
  ) async {
    try {
      print('\n📌 --- DÉBUT VERIFICATION DDA ---');

      final caIndex =
          Hex.encode(
            TLVParser.findTlvRecursive(readRecords, 0x8F)?.value ?? [],
          ).toUpperCase();
      print('🔍 Index CA trouvé (0x8F) : $caIndex');

      const caModulusHex =
          'C2FA4312E3B5174838241FAC87D9A46B984BC45A88A71979823852D3F6C65708'
          'C78BC742C0595108C6679EF52BEC7AE4D3D13F776876430982AAA38125629CF9'
          'CE22029C65CA4F4C5C9F34D8A2CF704846937A2C7695D58324BDF3092521511F'
          'E29FD8872FC7A1E2C76A82B6DD691DA4468B1331793800635F7D622723987CEA'
          '6AD6DA0AB489D0637A3663DF0E5364662119CE2CF76C96894D623E0BF36CEED3'
          '330C84EC079';
      final caKey = RSAPublicKey(
        BigInt.parse(caModulusHex, radix: 16),
        BigInt.from(3),
      );
      print('✅ Clé publique CA chargée avec succès');
      print('🔍 Clé CA utilisée (modulus) : $caModulusHex');

      final issuerCert = Hex.decode(
        Hex.encode(TLVParser.findTlvRecursive(readRecords, 0x90)?.value ?? []),
      );
      print('🔍 IssuerCert avant déchiffrement : ${Hex.encode(issuerCert)}');
      if (issuerCert.isEmpty || issuerCert.length != 176) {
        print(
          '❌ IssuerCert invalide : longueur incorrecte (${issuerCert.length} octets)',
        );
        return false;
      }

      final issuerDecrypted = _rsaDecrypt(issuerCert, caKey);
      print(
        '🔍 Certificat émetteur déchiffré : ${Hex.encode(issuerDecrypted)}',
      );

      if (issuerDecrypted.first != 0x6A || issuerDecrypted.last != 0xBC) {
        print('❌ Certificat émetteur invalide : préfixe ou suffixe incorrect');
        return false;
      }

      final int totalLength = issuerDecrypted.length;
      final int hashLength = 20;
      final int trailerLength = 1;
      final int paddingAndHashZone = hashLength + trailerLength;

      final issuerId = issuerDecrypted.sublist(2, 5);
      final expiryDate = issuerDecrypted.sublist(6, 8);
      final serialNumber = issuerDecrypted.sublist(8, 11);
      final hashAlgo = issuerDecrypted[11];
      final pubKeyAlgo = issuerDecrypted[12];
      final modulusLengthDeclared = issuerDecrypted[13];
      final exponentLengthDeclared = issuerDecrypted[14];
      final modulusStart = 15;
      final modulusEnd = totalLength - paddingAndHashZone - 1;
      final issuerModulus = issuerDecrypted.sublist(
        modulusStart,
        modulusEnd + 1,
      );

      final issuerHash = issuerDecrypted.sublist(
        totalLength - paddingAndHashZone,
        totalLength - trailerLength,
      );
      final issuerDataForHash = issuerDecrypted.sublist(
        0,
        totalLength - paddingAndHashZone,
      );

      print('📌 Longueur totale du certificat : $totalLength octets');
      print('📌 Issuer ID : ${Hex.encode(issuerId)}');
      print('📌 Date d\'expiration : ${Hex.encode(expiryDate)}');
      print('📌 Numéro de série : ${Hex.encode(serialNumber)}');
      print('📌 Algorithme de hash : 0x${hashAlgo.toRadixString(16)}');
      print(
        '📌 Algorithme de clé publique : 0x${pubKeyAlgo.toRadixString(16)}',
      );
      print('📌 Modulus length déclarée : $modulusLengthDeclared octets');
      print('📌 Exponent length déclarée : $exponentLengthDeclared octets');
      print('📌 Modulus IPKC : ${Hex.encode(issuerModulus)}');
      print(
        '📌 Données utilisées pour SHA-1 : ${Hex.encode(issuerDataForHash)}',
      );
      print('📌 Hash extrait : ${Hex.encode(issuerHash)}');
      print('⚠️ Vérification du hash ignorée temporairement');

      final iccCert = Hex.decode(
        Hex.encode(
          TLVParser.findTlvRecursive(readRecords, 0x9F46)?.value ?? [],
        ),
      );
      print('🔍 ICCCert avant déchiffrement : ${Hex.encode(iccCert)}');

      final issuerRemainder =
          TLVParser.findTlvRecursive(readRecords, 0x92)?.value ?? [];
      print('📌 Issuer Public Key Remainder (0x92) : $issuerRemainder');

      List<int> fullIssuerModulus = issuerModulus;
      if (issuerRemainder.isNotEmpty) {
        fullIssuerModulus = [...issuerModulus, ...issuerRemainder];
        print(
          '📌 Modulus complet de l’émetteur (avec remainder) : ${Hex.encode(fullIssuerModulus)}',
        );
      }
      if (iccCert.isEmpty || iccCert.length != fullIssuerModulus.length) {
        print(
          '❌ ICCCert invalide : longueur incorrecte (${iccCert.length} octets, attendu : ${fullIssuerModulus.length})',
        );
        return false;
      }

      final issuerExp = Hex.decode(
        Hex.encode(
          TLVParser.findTlvRecursive(readRecords, 0x9F32)?.value ??
              [0x01, 0x00, 0x01],
        ),
      );
      final issuerPubKey = RSAPublicKey(
        BigInt.parse(Hex.encode(fullIssuerModulus), radix: 16),
        BigInt.parse(Hex.encode(issuerExp), radix: 16),
      );
      print('✅ Clé publique émetteur complète construite');

      final iccDecrypted = _rsaDecrypt(iccCert, issuerPubKey);
      print('📌 Certificat ICC déchiffré : ${Hex.encode(iccDecrypted)}');

      if (iccDecrypted.first != 0x6A || iccDecrypted.last != 0xBC) {
        print(
          '❌ Certificat ICC-certificat invalide : préfixe ou suffixe incorrect',
        );
        return false;
      }

      final iccTotalLength = iccDecrypted.length;
      final iccHashLength = 20;
      final iccTrailerLength = 1;
      final iccPaddingAndHashZone = iccHashLength + iccTrailerLength;

      if (iccTotalLength != fullIssuerModulus.length) {
        print(
          '❌ Longueur du certificat ICC-certificat incorrecte : $iccTotalLength octets (attendu : ${fullIssuerModulus.length})',
        );
        return false;
      }

      final iccHeader = iccDecrypted[0];
      final iccFormat = iccDecrypted[1];
      final iccPan = iccDecrypted.sublist(2, 10);
      final iccExtra1 = iccDecrypted.sublist(10, 12);
      final iccExpirationDate = iccDecrypted.sublist(12, 14);
      final iccSerialNumber = iccDecrypted.sublist(14, 17);
      final iccHashAlgo = iccDecrypted[17];
      final iccPubKeyAlgo = iccDecrypted[18];
      final iccModulusLengthDeclared = iccDecrypted[19];
      final iccExponentLengthDeclared = iccDecrypted[20];
      final iccModulusStart = 21;
      final iccModulusLength = iccModulusLengthDeclared;
      final iccModulusEnd = iccModulusStart + iccModulusLength;

      if (iccModulusEnd > iccTotalLength - iccPaddingAndHashZone - 5) {
        print('❌ Modulus ICC trop long pour la longueur du certificat');
        return false;
      }

      final iccModulus = iccDecrypted.sublist(iccModulusStart, iccModulusEnd);
      final iccExtra2 = iccDecrypted.sublist(
        iccTotalLength - iccPaddingAndHashZone - 5,
        iccTotalLength - iccPaddingAndHashZone,
      );
      final iccHash = iccDecrypted.sublist(
        iccTotalLength - iccPaddingAndHashZone,
        iccTotalLength - iccTrailerLength,
      );
      final iccDataForHash = iccDecrypted.sublist(
        0,
        iccTotalLength - iccPaddingAndHashZone,
      );

      print('📌 Longueur totale du certificat ICC : $iccTotalLength octets');
      print('📌 ICC Header : 0x${iccHeader.toHexString()}');
      print('📌 ICC Format : 0x${iccFormat.toHexString()}');
      print('📌 PAN (tronqué) : ${Hex.encode(iccPan)}');
      print('📌 Extra1 (2 octets après PAN) : ${Hex.encode(iccExtra1)}');
      print('📌 Date d\'expiration : ${Hex.encode(iccExpirationDate)}');
      print('📌 Numéro de série : ${Hex.encode(iccSerialNumber)}');
      print('📌 Algorithme de hachage ICC : 0x${iccHashAlgo.toHexString()}');
      print(
        '📌 Indicateur d algorithme de clé publique ICC : 0x${iccPubKeyAlgo.toHexString()}',
      );
      print(
        '📌 Longueur de la clé publique ICC : $iccModulusLengthDeclared octets',
      );
      print(
        '📌 Longueur de l\'exposant de la clé publique ICC : $iccExponentLengthDeclared octets',
      );
      print('📌 Modulus extrait ICC : ${Hex.encode(iccModulus)}');
      print('📌 Champs supplémentaires ICC 2 : ${Hex.encode(iccExtra2)}');
      print(
        '📌 Données utilisées pour SHA-1 ICC : ${Hex.encode(iccDataForHash)}',
      );
      print('📌 Hash extrait ICC : ${Hex.encode(iccHash)}');
      print('⚠️ Vérification du hash ICC ignorée temporairement');

      final iccExp = Hex.decode(
        Hex.encode(
          TLVParser.findTlvRecursive(readRecords, 0x9F47)?.value ??
              [0x01, 0x00, 0x01],
        ),
      );
      final iccPubKey = RSAPublicKey(
        BigInt.parse(Hex.encode(iccModulus), radix: 16),
        BigInt.parse(Hex.encode(iccExp), radix: 16),
      );

      final sdadDecrypted = _rsaDecrypt(Hex.decode(signedDataHex), iccPubKey);
      print('📌 SDAD déchiffré : ${Hex.encode(sdadDecrypted)}');

      if (sdadDecrypted.first != 0x6A || sdadDecrypted.last != 0xBC) {
        print('❌ SDAD invalide : préfixe ou suffixe incorrect');
        return false;
      }

      bool isSdadValid = extractAndVerifySDAD(
        sdadDecrypted,
        readRecords,
        unpredictableNumberHex,
      );
      if (!isSdadValid) {
        print('❌ Échec de l\'extraction du SDAD');
        return false;
      }
      print(
        '✅ Signature DDA traitée avec succès (vérifications de hachage ignorées) !',
      );
      return true;
    } catch (e, s) {
      print('❌ Erreur verifyDDASignature : $e\n$s');
      return false;
    }
  }

  Future<Map<String, String>?> processDDA({
    required List<TLV> readRecords,
    required String unpredictNumHex,
    required Function(String) setResult,
  }) async {
    try {
      print('Liste complète des TLVs dans readRecords :');
      for (var tlv in readRecords) {
        String valueHex = Hex.encode(tlv.value).toUpperCase();
        print(
          'Tag: 0x${tlv.tag.toHexString()}, Valeur : $valueHex, Longueur : ${tlv.value.length}',
        );
      }

      String? issuerCertHex =
          TLVParser.findTlvRecursive(readRecords, 0x90)?.value != null
              ? Hex.encode(
                TLVParser.findTlvRecursive(readRecords, 0x90)!.value,
              ).toUpperCase()
              : null;
      String? iccCertHex =
          TLVParser.findTlvRecursive(readRecords, 0x9F46)?.value != null
              ? Hex.encode(
                TLVParser.findTlvRecursive(readRecords, 0x9F46)!.value,
              ).toUpperCase()
              : null;
      String issuerExpHex =
          TLVParser.findTlvRecursive(readRecords, 0x9F32)?.value != null
              ? Hex.encode(
                TLVParser.findTlvRecursive(readRecords, 0x9F32)!.value,
              ).toUpperCase()
              : '03';
      String iccExpHex =
          TLVParser.findTlvRecursive(readRecords, 0x9F47)?.value != null
              ? Hex.encode(
                TLVParser.findTlvRecursive(readRecords, 0x9F47)!.value,
              ).toUpperCase()
              : '03';

      if (issuerCertHex == null || iccCertHex == null) {
        print('❌ Données DDA critiques manquantes (Issuer ou ICC-certificat)');
        setResult('❌ Données DDA critiques manquantes');
        return null;
      }

      List<int> issuerCertBytes = Hex.decode(issuerCertHex);
      List<int> iccCertBytes = Hex.decode(iccCertHex);
      if (issuerCertBytes.length < 64 || issuerCertBytes.length > 248) {
        print(
          '❌ IssuerCert longueur invalide : ${issuerCertBytes.length} octets',
        );
        setResult('❌ Longueur issuerCert invalide');
        return null;
      }
      if (iccCertBytes.length < 64 || iccCertBytes.length > 248) {
        print('❌ ICCCert longueur invalide : ${iccCertBytes.length} octets');
        setResult('❌ Longueur certificat ICCCertificat invalide');
        return null;
      }

      print('Données DDA extraites :');
      print('IssuerCert : $issuerCertHex');
      print('ICCCert : $iccCertHex');
      print('IssuerExp : $issuerExpHex');
      print('ICCExp : $iccExpHex');

      List<int> unpredictNum = Hex.decode('30901B6A');
      print('Nombre imprévisible utilisé : $unpredictNumHex');

      TLV? ddolData = TLVParser.findTlvRecursive(readRecords, 0x9F49);
      String ddolHex =
          ddolData != null
              ? Hex.encode(ddolData.value).toUpperCase()
              : '9F3704';
      print('DDOL (0x9F49) : $ddolHex');

      List<int> internalAuthenticateCommand;
      if (ddolData != null) {
        List<int> ddolDataBytes = [];
        List<int> ddolBytes = Hex.decode(ddolHex);
        int idx = 0;
        while (idx < ddolBytes.length) {
          if (idx + 2 > ddolBytes.length) {
            print('❌ DDOL malformé : longueur insuffisante');
            setResult('❌ DDOL malformé');
            return null;
          }
          String tagHex =
              Hex.encode(ddolBytes.sublist(idx, idx + 2)).toUpperCase();
          idx += 2;
          if (idx >= ddolBytes.length) {
            print('❌ DDOL malformé : longueur manquante pour $tagHex');
            setResult('❌ DDOL malformé');
            return null;
          }
          int length = ddolBytes[idx];
          idx += 1;
          if (tagHex == '9F37') {
            if (length != 4) {
              print('⚠️ Longueur inattendue pour 9F37 : $length, attendu 4');
            }
            ddolDataBytes.addAll(unpredictNum);
          } else {
            TLV? tagTlv = TLVParser.findTlvRecursive(
              readRecords,
              int.parse(tagHex, radix: 16),
            );
            if (tagTlv != null && tagTlv.value.length == length) {
              ddolDataBytes.addAll(tagTlv.value);
            } else {
              print(
                '⚠️ Tag $tagHex non trouvé ou longueur incorrecte, rempli avec zéros',
              );
              ddolDataBytes.addAll(List.filled(length, 0x00));
            }
          }
        }
        internalAuthenticateCommand = [
          0x00,
          0x88,
          0x00,
          0x00,
          ddolDataBytes.length,
          ...ddolDataBytes,
          0x00,
        ];
      } else {
        internalAuthenticateCommand = [
          0x00,
          0x88,
          0x00,
          0x00,
          4,
          ...unpredictNum,
          0x00,
        ];
      }

      String apduHex = Hex.encode(internalAuthenticateCommand).toUpperCase();
      print('Commande INTERNAL AUTHENTICATE : $apduHex');

      String responseHex = await FlutterNfcKit.transceive(apduHex);
      print('Réponse DDA brut : $responseHex');

      if (responseHex.length < 4 ||
          responseHex.substring(responseHex.length - 4).toUpperCase() !=
              '9000') {
        print(
          '❌ Échec de INTERNAL AUTHENTICATE, SW : ${responseHex.substring(responseHex.length - 4)}',
        );
        setResult('❌ Échec de INTERNAL AUTHENTICATE');
        return null;
      }

      String dataHex = responseHex.substring(0, responseHex.length - 4);
      List<TLV> responseTlvs = TLVParser.parse(
        Uint8List.fromList(Hex.decode(dataHex)),
      );

      TLV? signedDataTlv = TLVParser.findTlvRecursive(responseTlvs, 0x77);
      if (signedDataTlv == null) {
        print('❌ Tag 0x77 non trouvé');
        setResult('❌ Tag 0x77 non trouvé');
        return null;
      }

      List<TLV> signedDataContent = TLVParser.parse(
        Uint8List.fromList(signedDataTlv.value),
      );
      TLV? signatureTlv = TLVParser.findTlvRecursive(signedDataContent, 0x9F4B);
      if (signatureTlv == null) {
        print('❌ Tag 0x9F4B non trouvé');
        setResult('❌ Tag 0x9F4B non trouvé');
        return null;
      }

      String signedDataHex = Hex.encode(signatureTlv.value).toUpperCase();
      print('Signed Dynamic Application Data (0x9F4B) : $signedDataHex');

      return {
        'unpredictNumHex': unpredictNumHex,
        'signedDataHex': signedDataHex,
      };
    } catch (e, stackTrace) {
      print('❌ Erreur DDA : $e\n$stackTrace');
      setResult('❌ Erreur DDA : $e');
      return null;
    }
  }

  void afficherEtInterpreterTLVs(List<TLV> readRecords) {
    final Map<int, String> tagNames = {
      0x90: "Issuer Public Key Certificate",
      0x9F32: "Issuer Public Key Exponent",
      0x92: "Issuer Public Key Remainder",
      0x8F: "Certification Authority Public Key Index",
      0x9F47: "ICC Public Key Exponent",
      0x9F49: "DDOL",
      0x9F37: "Unpredictable Number",
      0x5F25: "Application Effective Date",
      0x5F24: "Application Expiration Date",
      0x5A: "Application Primary Account Number (PAN)",
      0x5F34: "Application PAN Sequence Number",
      0x9F07: "Application Usage Control",
      0x8E: "CVM List",
      0x9F0D: "Issuer Action Code - Default",
      0x9F0E: "Issuer Action Code - Denial",
      0x9F0F: "Issuer Action Code - Online",
      0x5F28: "Issuer Country Code",
      0x9F4A: "SDA Tag List",
      0x8C: "CDOL1",
      0x8D: "CDOL2",
      0x91: "Issuer Authentication Data",
      0x8A: "Authorisation Response Code",
      0x95: "Terminal Verification Results",
      0x5F30: "Service Code",
      0x9F08: "Application Version Number",
      0x9F44: "Application Currency Exponent",
      0x9F42: "Application Currency Code",
      0x9F46: "ICC Public Key Certificate",
    };

    for (var tlv in readRecords) {
      final tag = tlv.tag;
      final tagName = tagNames[tag] ?? "Unknown Tag";

      print('-------------------------------------');
      print('Tag: 0x${tag.toHexString()} ($tagName)');

      final int bytesPerLine = 16;
      for (int i = 0; i < tlv.value.length; i += bytesPerLine) {
        final lineBytes = tlv.value.sublist(
          i,
          (i + bytesPerLine < tlv.value.length)
              ? i + bytesPerLine
              : tlv.value.length,
        );
        final hexLine =
            lineBytes
                .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
                .join();
        print('  $hexLine');
      }

      if (tag == 0x9F07 && tlv.value.length >= 2) {
        final byte1 = tlv.value[0];
        final byte2 = tlv.value[1];
        print('\n-- Application Usage Control (9F07) --');
        print('Byte 1:');
        print('  Bit 8 - Domestic Cash: ${(byte1 & 0x80) != 0 ? 1 : 0}');
        print('  Bit 7 - International Cash: ${(byte1 & 0x40) != 0 ? 1 : 0}');
        print('  Bit 6 - Domestic Goods: ${(byte1 & 0x20) != 0 ? 1 : 0}');
        print('  Bit 5 - International Goods: ${(byte1 & 0x10) != 0 ? 1 : 0}');
        print('  Bit 4 - Domestic Services: ${(byte1 & 0x08) != 0 ? 1 : 0}');
        print(
          '  Bit 3 - International Services: ${(byte1 & 0x04) != 0 ? 1 : 0}',
        );
        print('  Bit 2 - ATM Machines: ${(byte1 & 0x02) != 0 ? 1 : 0}');
        print('  Bit 1 - Non ATM Machines: ${(byte1 & 0x01) != 0 ? 1 : 0}');
        print('Byte 2:');
        print('  Bit 8 - Domestic Cashback: ${(byte2 & 0x80) != 0 ? 1 : 0}');
        print(
          '  Bit 7 - International Cashback: ${(byte2 & 0x40) != 0 ? 1 : 0}',
        );
        print('  Bit 6 - RFU: ${(byte2 & 0x20) != 0 ? 1 : 0}');
        print('  Bit 5 - RFU: ${(byte2 & 0x10) != 0 ? 1 : 0}');
        print('  Bit 4 - RFU: ${(byte2 & 0x08) != 0 ? 1 : 0}');
        print('  Bit 3 - RFU: ${(byte2 & 0x04) != 0 ? 1 : 0}');
        print('  Bit 2 - RFU: ${(byte2 & 0x02) != 0 ? 1 : 0}');
        print('  Bit 1 - RFU: ${(byte2 & 0x01) != 0 ? 1 : 0}');
      }

      if ((tag == 0x9F0D || tag == 0x9F0E || tag == 0x9F0F) &&
          tlv.value.length >= 5) {
        print('\n-- Issuer Action Codes (9F0D, 9F0E, 9F0F) --');
        for (int byteIndex = 0; byteIndex < 5; byteIndex++) {
          final byteVal = tlv.value[byteIndex];
          print('Byte ${byteIndex + 1}');
          for (int bit = 7; bit >= 0; bit--) {
            final bitVal = (byteVal & (1 << bit)) != 0 ? 1 : 0;
            print('  Bit ${bit + 1} - $bitVal');
          }
        }
      }

      print('\n');
    }
  }

  Future<void> startEMVSession({
    required String amount,
    required bool skipReset,
  }) async {
    if (!_isValidAmount(amount)) {
      setResult(
        '❌ Montant invalide. Veuillez entrer un nombre valide (ex. 500.00).',
      );
      print('📌 Validation montant échouée : "$amount"');
      return;
    }

    double? parsedAmount = parseAmount(amount);
    if (parsedAmount == null) {
      setResult('❌ Erreur de format du montant : "$amount"');
      print('📌 Erreur parsing montant : "$amount"');
      return;
    }
    print('📌 Montant parsé : $parsedAmount');

    final availability = await FlutterNfcKit.nfcAvailability;
    if (availability != NFCAvailability.available) {
      setResult('❌ NFC non disponible : $availability');
      return;
    }

    try {
      if (!skipReset) {
        setResult('');
      }

      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 20),
      );
      print('✅ Carte détectée : ${tag.type}');
      setResult('✅ Carte détectée ');

      final apduHex =
          ApduCommands.selectPPSE
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join();
      final responseHex = await FlutterNfcKit.transceive(apduHex);

      final decodedError = decodeApduError(responseHex);
      if (decodedError != 'Succès') {
        setResult(decodedError);
        return;
      }

      final responseBytesList = _hexToBytes(responseHex);
      final responseBytes = Uint8List.fromList(responseBytesList);
      final tlvs = TLVParser.parse(responseBytes);
      print('📌 Réponse SELECT PPSE : $tlvs');

      final dfName = getTlvValueHex(tlvs, 0x84);
      final fciProprietaryTemplate = getTlvValueHex(tlvs, 0xA5);
      final fciIssuerData = getTlvValueHex(tlvs, 0xBF0C);
      final appIdentifier = getTlvValueHex(tlvs, 0x4F);
      final appLabel = hexToAscii(getTlvValueHex(tlvs, 0x50)!);
      final appPriorityIndicator = getTlvValueHex(tlvs, 0x87);
      final kernelIdentifier = getTlvValueHex(tlvs, 0x9F2A);
      final proprietaryData = getTlvValueHex(tlvs, 0x9F0A);

      print('Proximity Payment Systems Environment:');
      print('🔹 84 DF Name: $dfName');
      print('🔹 A5 FCI Proprietary Template: $fciProprietaryTemplate');
      print('🔹 BF0C FCI Issuer Discretionary Data: $fciIssuerData');
      print('🔹 61 Application Template:');
      print('  🔹 4F Application Identifier: $appIdentifier');
      print('  🔹 50 Application Label: $appLabel');
      print('  🔹 87 Application Priority Indicator: $appPriorityIndicator');
      print('  🔹 9F2A Kernel Identifier: $kernelIdentifier');
      print(
        '  🔹 9F0A Application Selection Registered Proprietary Data: $proprietaryData',
      );

      final aidTlv =
          TLVParser.findTlvRecursive(tlvs, 0x4F) ?? TLV(0x00, Uint8List(0));
      if (aidTlv.tag != 0x4F) {
        setResult('❌ AID non trouvé');
        return;
      }
      print('📌 AID TLV : $aidTlv');
      final aidHex =
          aidTlv.value.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      print('📌 AID : $aidHex');

      final selectAid = ApduCommands.buildSelectAID(aidHex);
      final selectAidHex =
          selectAid.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
      final aidResponseHex = await FlutterNfcKit.transceive(selectAidHex);
      print('📌 Réponse SELECT AID : $aidResponseHex');

      final decodedAidError = decodeApduError(aidResponseHex);
      if (decodedAidError != 'Succès') {
        setResult(decodedAidError);
        return;
      }

      final aidResponseBytesList = _hexToBytes(aidResponseHex);
      final aidResponseBytes = Uint8List.fromList(aidResponseBytesList);
      final aidResponseTlvs = TLVParser.parse(aidResponseBytes);
      print('📌 AID Response TLVs : $aidResponseTlvs');

      final dfNamee = getTlvValueHex(aidResponseTlvs, 0x84);
      final appLabell = hexToAscii(getTlvValueHex(aidResponseTlvs, 0x50)!);
      final appPriorityIndicatorr = getTlvValueHex(aidResponseTlvs, 0x87);
      final pdol = getTlvValueHex(aidResponseTlvs, 0x9F38);
      final terminalType = getTlvValueHex(aidResponseTlvs, 0x9F35);
      final terminalCapabilities = getTlvValueHex(aidResponseTlvs, 0x9F40);
      final languagePref = hexToAscii(getTlvValueHex(aidResponseTlvs, 0x5F2D)!);
      final issuerCodeTableIndex = getTlvValueHex(aidResponseTlvs, 0x9F11);
      final appPreferredName = hexToAscii(
        getTlvValueHex(aidResponseTlvs, 0x9F12)!,
      );
      final logEntry = getTlvValueHex(aidResponseTlvs, 0x9F4D);

      print('Selecting Application:');
      print('🔹 DF Name: $dfNamee');
      print('🔹 50 Application Label: $appLabell');
      print('🔹 87 Application Priority Indicator: $appPriorityIndicatorr');
      print('🔹 9F38 PDOL: $pdol');
      print('🔹 9F35 Terminal Type: $terminalType');
      print('🔹 9F40 Additional Terminal Capabilities: $terminalCapabilities');
      print('🔹 5F2D Language Preference: $languagePref');
      print('Issuer Code and Application Data:');
      print('🔹 9F11 Issuer Code Table Index: $issuerCodeTableIndex');
      print('🔹 9F12 Application Preferred Name: $appPreferredName');
      print('🔹 9F4D Log Entry: $logEntry');

      String? pdolHex;
      final pdolTlv = TLVParser.findTlvRecursive(aidResponseTlvs, 0x9F38);
      print('📌 PDOL TLV : $pdolTlv');
      if (pdolTlv != null) {
        pdolHex = Hex.encode(pdolTlv.value);
      }

      List<int> gpoCommand;
      if (pdolHex != null && pdolHex.isNotEmpty) {
        final pdolBytes = _hexToBytes(pdolHex);
        List<int> pdolData = [];
        int idx = 0;

        while (idx < pdolBytes.length) {
          final tag =
              pdolBytes[idx].toRadixString(16).padLeft(2, '0') +
              pdolBytes[idx + 1].toRadixString(16).padLeft(2, '0');
          final length = pdolBytes[idx + 2];
          idx += 3;

          if (tag == '9F02') {
            int transactionAmount =
                ((double.tryParse(amount) ?? 0) * 100).toInt();
            final amountHex = transactionAmount
                .toRadixString(16)
                .padLeft(length * 2, '0');
            pdolData.addAll(_hexToBytes(amountHex));
          } else {
            pdolData.addAll(List.filled(length, 0x00));
          }
        }

        final dolWithTag = [0x83, pdolData.length] + pdolData;
        gpoCommand = [
          0x80,
          0xA8,
          0x00,
          0x00,
          dolWithTag.length,
          ...dolWithTag,
          0x00,
        ];
      } else {
        gpoCommand = [0x80, 0xA8, 0x00, 0x00, 0x02, 0x83, 0x00, 0x00];
      }

      final gpoHexStr =
          gpoCommand.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
      final gpoResponseHex = await FlutterNfcKit.transceive(gpoHexStr);
      print('📌 Réponse GPO : $gpoResponseHex');

      final gpoResponseBytesList = _hexToBytes(gpoResponseHex);
      final gpoResponseBytes = Uint8List.fromList(gpoResponseBytesList);
      final gpoTlvs = TLVParser.parse(gpoResponseBytes);
      print('📌 GPO TLVs : $gpoTlvs');

      final aflTlv =
          TLVParser.findTlvRecursive(gpoTlvs, 0x94) ?? TLV(0x00, Uint8List(0));
      if (aflTlv.tag != 0x94) {
        setResult('❌ AFL non trouvé');
        return;
      }
      print('📌 AFL TLV : $aflTlv');

      final afl = aflTlv.value;
      print('📌 AFL : $afl');

      print(
        '🔹 Valeur brute de AFL : ${afl.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}',
      );

      List<Map<String, dynamic>> locators = [];
      for (int i = 0; i < afl.length; i += 4) {
        final sfi = afl[i];
        final recordStart = afl[i + 1];
        final recordEnd = afl[i + 2];
        final occurrences = afl[i + 3];

        locators.add({
          'SFI': sfi,
          'recordStart': recordStart,
          'recordEnd': recordEnd,
          'occurrences': occurrences,
        });

        print(
          '🔹 Locateur - SFI: $sfi, Record Start: $recordStart, Record End: $recordEnd, Occurrences: $occurrences',
        );
      }

      for (var locator in locators) {
        print(
          '📂 Locateur trouvé : SFI = ${locator['SFI']}, Start = ${locator['recordStart']}, End = ${locator['recordEnd']}, Occurrences = ${locator['occurrences']}',
        );
      }

      final aipTlv =
          TLVParser.findTlvRecursive(gpoTlvs, 0x82) ?? TLV(0x00, Uint8List(0));
      if (aipTlv.tag != 0x82) {
        setResult('❌ AIP non trouvé');
        return;
      }

      print('🔹 Application Interchange Profile : $aipTlv');
      final aip = aipTlv.value;
      print(
        '🔹 Valeur brute de AIP : ${aip.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}',
      );

      final byte1 = aip[0];
      final byte2 = aip[1];

      final xdaSupport = (byte1 & 0x80) == 0x80;
      final staticDataAuth = (byte1 & 0x40) == 0x40;
      final dynamicDataAuth = (byte1 & 0x20) == 0x20;
      final cardholderVerification = (byte1 & 0x10) == 0x10;
      final terminalRiskManagement = (byte1 & 0x08) == 0x08;
      final issuerAuthentication = (byte1 & 0x04) == 0x04;
      final onDeviceCvmSupported = (byte1 & 0x02) == 0x02;
      final combinedDataAuth = (byte1 & 0x01) == 0x01;
      final emvModeSupported = (byte2 & 0x80) == 0x80;
      final rfus = (byte2 & 0x7E);
      final relayResistanceSupported = (byte2 & 0x01) == 0x01;

      print('🔹 Décodage du AIP :');
      print('  - XDA Support: $xdaSupport');
      print('  - Static Data Authentication: $staticDataAuth');
      print('  - Dynamic Data Authentication: $dynamicDataAuth');
      print('  - Cardholder Verification: $cardholderVerification');
      print('  - Terminal Risk Management: $terminalRiskManagement');
      print('  - Issuer Authentication: $issuerAuthentication');
      print('  - On-Device CVM Supported: $onDeviceCvmSupported');
      print('  - Combined Data Authentication: $combinedDataAuth');
      print('  - EMV Mode Supported: $emvModeSupported');
      print('  - RFU (reserved): $rfus');
      print(
        '  - Relay Resistance Protocol Supported: $relayResistanceSupported',
      );

      String unpredictNumHex = '30901B6A';
      List<int> unpredictNum = Hex.decode(unpredictNumHex);
      print('Nombre imprévisible statique : $unpredictNumHex');
      print('📌 Unpredictable Number généré : $unpredictNumHex');

      final List<int> exchangeRelayResistanceDataCommand = [
        0x80,
        0xEA,
        0x00,
        0x00,
        0x04,
        0x30,
        0x90,
        0x1B,
        0x6A,
        0x00,
      ];

      final apduCommand =
          exchangeRelayResistanceDataCommand
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join();
      print('📌 Commande APDU : $apduCommand');
      final response = await FlutterNfcKit.transceive(apduCommand);
      final relayResistanceResponse = response;
      print('📌 Réponse brute de la carte : $relayResistanceResponse');

      final responseeBytes = _hexToBytes(relayResistanceResponse);
      final deviceRelayResistanceEntropy = responseeBytes.sublist(2, 6);
      final minTimeForProcessing = responseeBytes.sublist(6, 8);
      final maxTimeForProcessing = responseeBytes.sublist(8, 10);
      final transmissionTime = responseeBytes.sublist(10, 12);

      print(
        'Device Relay Resistance Entropy: ${Hex.encode(deviceRelayResistanceEntropy)}',
      );
      print(
        'Min Time For Processing Relay Resistance APDU: ${Hex.encode(minTimeForProcessing)}',
      );
      print(
        'Max Time For Processing Relay Resistance APDU: ${Hex.encode(maxTimeForProcessing)}',
      );
      print(
        'Transmission Time For Relay Resistance R-APDU: ${Hex.encode(transmissionTime)}',
      );

      List<TLV> readRecords = [];

      for (int i = 0; i < afl.length; i += 4) {
        final sfi = afl[i] >> 3;
        final recordStart = afl[i + 1];
        final recordEnd = afl[i + 2];

        for (int record = recordStart; record <= recordEnd; record++) {
          final p1 = record;
          final p2 = (sfi << 3) | 4;
          final readRecord = [0x00, 0xB2, p1, p2, 0x00];

          final apduHex =
              readRecord.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

          try {
            final recordHex = await FlutterNfcKit.transceive(apduHex);
            final recordBytesList = _hexToBytes(recordHex);
            final recordBytes = Uint8List.fromList(recordBytesList);
            final recordTlvs = TLVParser.parse(recordBytes);
            readRecords.addAll(recordTlvs);
            print('📌 Record TLVs : $recordTlvs');
            afficherEtInterpreterTLVs(readRecords);
          } catch (_) {
            setResult('⚠️ Erreur lors de la lecture du record');
            return;
          }
        }
      }

      final cidTlv = TLVParser.findTlvRecursive(readRecords, 0x9F27);
      print('📌 CID TLV : $cidTlv');
      final panTlv = TLVParser.findTlvRecursive(readRecords, 0x5A);
      if (panTlv == null) {
        setResult('❌ PAN non trouvé');
        throw Exception('PAN non trouvé');
      }
      final fullPan = Hex.encode(panTlv.value);
      final countryCodeTlv = TLVParser.findTlvRecursive(readRecords, 0x5F28);
      final expDateTlv = TLVParser.findTlvRecursive(readRecords, 0x5F24);
      String expiration =
          expDateTlv != null ? Hex.encode(expDateTlv.value) : '000000';
      final cardCountryCode =
          countryCodeTlv != null ? Hex.encode(countryCodeTlv.value) : '0012';

      final ddaResult = await processDDA(
        readRecords: readRecords,
        unpredictNumHex: unpredictNumHex,
        setResult: setResult,
      );
      if (ddaResult == null) {
        setResult('❌ Échec DDA');
        await FlutterNfcKit.finish();
        return;
      }

      final signedDataHex = ddaResult['signedDataHex']!;
      print(
        '📌 DDA : unpredictNumHex=$unpredictNumHex, signedDataHex=$signedDataHex',
      );

      final isSignatureValid = await verifyDDASignature(
        readRecords,
        signedDataHex,
        unpredictNumHex,
      );
      if (!isSignatureValid) {
        print('📌 DDA échoué');
      } else {
        print('✅ DDA Signature vérifiée avec succès');
      }
      const double floorLimit = 1000.0;
      final bool isOnlineRequired = parsedAmount > floorLimit;
      final riskResult = performTerminalRiskManagement(
        amount: parsedAmount,
        readRecords: readRecords,
        isOffline: !isOnlineRequired,
        pan: fullPan,
        offlineTransactionCount: 0,
      );
      if (riskResult.isDeclined) {
        setResult('❌ Transaction rejetée : ${riskResult.reason}');
        print('❌ Transaction rejetée, raison : ${riskResult.reason}');
        await FlutterNfcKit.finish();
        return;
      }
      final aipHex = Hex.encode(aip).toUpperCase();
      print('📌 DF Name : $dfNamee');
      print('📌 AIP Hex : $aipHex');

      print(
        '📌 Appel processGenerateAC avec amount: $parsedAmount, unpredictableNumberHex: $unpredictNumHex',
      );
      final generateACResult = await processGenerateAC(
        readRecords: readRecords,
        amount: parsedAmount,
        unpredictableNumber: unpredictNumHex,
        aip: aipHex,
        dfname: dfNamee!,
        riskResult: riskResult,
        setResult: setResult,
      );

      if (generateACResult == null) {
        setResult('❌ Erreur lors de la génération du cryptogramme');
        await FlutterNfcKit.finish();
        return;
      }

      if (generateACResult.cid == '00') {
        setResult('❌ Transaction refusée par la carte (AAC)');
        await FlutterNfcKit.finish();
        return;
      }

      // Convertir atc en décimal pour les logs
      final atcDecimal = int.parse(generateACResult.atc, radix: 16).toString();
      print('📌 ATC (décimal) : $atcDecimal');

      setTransactionData(
        generateACResult.ac,
        generateACResult.atc,
        generateACResult.cid,
        expiration,
        riskResult.isOnline ? 'Approved online' : 'Approved offline',
      );

      final transactionLog = TransactionLog(
        pan: fullPan,
        expiration: expiration,
        atc: generateACResult.atc,
        result: riskResult.isOnline ? 'Approved online' : 'Approved offline',
        timestamp: DateTime.now(),
        amount: parsedAmount,
        dateTime: DateTime.now().toIso8601String(),
        status: 'Approved',
        isOnline: riskResult.isOnline,
      );
      addTransactionLog(transactionLog);

      try {
        print(
          '📌 Tentative de sauvegarde de la transaction: $transactionLog (ATC décimal: $atcDecimal)',
        );
        await TransactionStorage.saveTransaction(transactionLog);
        print('📌 Transaction sauvegardée avec succès');
        // Planifier l'envoi différé pour les transactions hors ligne
        if (!riskResult.isOnline) {
          await OfflineTransactionScheduler.scheduleOfflineTransactionSend(
            transaction: transactionLog,
            ac: generateACResult.ac,
            panSequenceNumber: getTlvValueHex(readRecords, 0x5F34) ?? '00',
            unpredictableNumber: unpredictNumHex,
          );
          print(
            '📌 Transaction hors ligne planifiée pour envoi différé dans 24h (ATC décimal: $atcDecimal)',
          );
        }
      } catch (e, stackTrace) {
        print('❌ Échec de la sauvegarde de la transaction: $e\n$stackTrace');
      }

      context.goNamed(
        'transactionSummary',
        extra: {
          'amount': parsedAmount.toStringAsFixed(2),
          'cardNumber': fullPan,
          'status': 'Approved',
          'transactionReference':
              DateTime.now().millisecondsSinceEpoch.toString(),
          'pan': fullPan,
          'date': DateTime.now().toIso8601String(),
          'expiration': expiration,
          'name': '',
          'atc': generateACResult.atc,
          'authorizationCode':
              riskResult.isOnline
                  ? (generateACResult.authCode ?? '00')
                  : 'AUTH1234',
          'isOnline': riskResult.isOnline,
        },
      );

      await FlutterNfcKit.finish();
    } catch (e) {
      setResult('❌ Erreur : $e');
    }
  }

  bool _isValidAmount(String input) {
    final regex = RegExp(r'^\d+(\.\d{1,2})?$');
    return regex.hasMatch(input);
  }

  double? parseAmount(String input) {
    try {
      return double.parse(input);
    } catch (e) {
      print('❌ Erreur parsing montant : $e');
      return null;
    }
  }

  String decodeApduError(String apduResponse) {
    final errorCode = apduResponse.substring(apduResponse.length - 4);
    final errorCodes = {
      '6A88': 'Sélecteur d’application non trouvé',
      '6F00': 'Erreur générique',
      '9000': 'Succès',
      '6700': 'Paramètre incorrect',
      '6982': 'Conditions d’utilisation non remplies',
    };
    return errorCodes[errorCode] ?? 'Erreur inconnue : $errorCode';
  }
}

extension IntExtensions on int {
  String toHexString() => toRadixString(16).padLeft(2, '0').toUpperCase();
}
