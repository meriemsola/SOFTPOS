import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/presentation/screens/receipt_pdf_generator.dart';
import 'package:printing/printing.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';

class ReceiptScreen extends StatefulWidget {
  final String pan;
  final String expiration;
  final String name;
  final String atc;
  final String status;
  final String amount;
  final String transactionReference;
  final String authorizationCode;
  final String dateTime;

  const ReceiptScreen({
    super.key,
    required this.pan,
    required this.expiration,
    required this.name,
    required this.atc,
    required this.status,
    required this.amount,
    required this.transactionReference,
    required this.authorizationCode,
    required this.dateTime,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.lightBackground],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                _buildBackButton(),
                const SizedBox(height: AppSizes.spaceBtwItems),
                Expanded(
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: AppSizes.cardElevation,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardRadiusLg,
                        ),
                      ),
                      color: AppColors.lightCard,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Reçu de Paiement',
                              style: TextStyle(
                                fontSize: AppSizes.fontSizeLg,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoRow(
                              'Carte',
                              '****-${widget.pan.substring(widget.pan.length - 4)}',
                            ),
                            _buildInfoRow('Expiration', widget.expiration),
                            _buildInfoRow('Montant', '${widget.amount} DA'),
                            _buildInfoRow('Date', widget.dateTime),
                            _buildInfoRow(
                              'Référence',
                              widget.transactionReference,
                            ),
                            _buildInfoRow(
                              'Code Autorisation',
                              widget.authorizationCode,
                            ),
                            _buildInfoRow('ATC', widget.atc),
                            _buildInfoRow('Statut', widget.status),
                            const SizedBox(height: 24),
                            _buildActionButton(
                              'Exporter en PDF',
                              Icons.picture_as_pdf,
                              () async {
                                final pdfData = await generateReceiptPdf(
                                  pan: widget.pan,
                                  expiration: widget.expiration,
                                  name: widget.name,
                                  atc: widget.atc,
                                  status: widget.status,
                                  amount: widget.amount,
                                  transactionReference:
                                      widget.transactionReference,
                                  authorizationCode: widget.authorizationCode,
                                  dateTime: widget.dateTime,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('PDF généré avec succès'),
                                  ),
                                );
                                await Printing.layoutPdf(
                                  onLayout: (format) => pdfData,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label :',
            style: TextStyle(
              fontSize: AppSizes.fontSizeMd,
              fontWeight: FontWeight.bold,
              color: AppColors.lightMediumText,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppSizes.fontSizeMd,
                color: AppColors.lightDarkText,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(
            MediaQuery.of(context).size.width * 0.7,
            AppSizes.buttonHeight + 20,
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: () {
          context.pop();
        },
        child: Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Icon(Icons.arrow_back, size: AppSizes.iconMd),
        ),
      ),
    );
  }
}
