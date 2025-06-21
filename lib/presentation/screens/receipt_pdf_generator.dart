import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

Future<Uint8List> generateReceiptPdf({
  required String pan,
  required String expiration,
  required String name,
  required String atc,
  required String status,
  required String amount,
  required String transactionReference,
  required String authorizationCode,
  required String dateTime,
}) async {
  final pdf = pw.Document();

  final isSuccess = status.toLowerCase().contains('acceptée') || status.toLowerCase().contains('approuvée');

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'REÇU DE TRANSACTION',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: isSuccess ? PdfColors.green : PdfColors.red,
                ),
              ),
            ),
            pw.SizedBox(height: 24),
            _buildLine('Nom', name.isEmpty ? 'Non spécifié' : name),
            _buildLine('Carte', '****-${pan.substring(pan.length - 4)}'),
            _buildLine('Expiration', expiration),
            _buildLine('Montant', '$amount DA'),
            _buildLine('Date', dateTime),
            _buildLine('Référence', transactionReference),
            _buildLine('Code Autorisation', authorizationCode),
            _buildLine('ATC', atc),
            _buildLine('Statut', status),
          ],
        ),
      ),
    ),
  );

  return await pdf.save();
}

pw.Widget _buildLine(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            '$label :',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(flex: 5, child: pw.Text(value)),
      ],
    ),
  );
}