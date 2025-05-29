import 'package:flutter/material.dart';
import 'package:hce_emv/data/services/backend_service.dart';
import 'package:hce_emv/presentation/screens/main_navigation_screen.dart';

class CardValidationScreen extends StatefulWidget {
  const CardValidationScreen({super.key});

  @override
  _CardValidationScreenState createState() => _CardValidationScreenState();
}

class _CardValidationScreenState extends State<CardValidationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _panController = TextEditingController();
  final _cvvController = TextEditingController();
  final _expiryController = TextEditingController();
  String _responseMessage = "";
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleValidation() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final pan = _panController.text.trim();
      final cvv = _cvvController.text.trim();
      final expiry = _expiryController.text.trim();

      final message = await BackendService.validateCard(
        pan: pan,
        cvv: cvv,
        expiryDate: expiry,
      );

      setState(() => _isLoading = false);

      if (message.trim().toLowerCase() == "carte valide") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MainNavigationScreen()),
        );
      } else {
        setState(() => _responseMessage = message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF283593), Color(0xFF5C6BC0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.credit_card, color: Color(0xFF283593)),
                            SizedBox(width: 8),
                            Text(
                              "HB Technologies Pay",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF283593),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // PAN
                        TextFormField(
                          controller: _panController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Numéro de carte',
                            prefixIcon: Icon(Icons.credit_card),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.length != 16
                                      ? "Numéro invalide"
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        // CVV
                        TextFormField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.length != 3
                                      ? "CVV invalide"
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        // Expiry
                        TextFormField(
                          controller: _expiryController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Expiration (MMYY)',
                            prefixIcon: Icon(Icons.date_range),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.length != 4
                                      ? "Date invalide"
                                      : null,
                        ),
                        const SizedBox(height: 24),

                        _isLoading
                            ? CircularProgressIndicator(
                              color: Color(0xFF283593),
                            )
                            : ElevatedButton.icon(
                              onPressed: _handleValidation,
                              icon: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Valider",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  52,
                                  63,
                                  145,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                            ),

                        const SizedBox(height: 20),

                        if (_responseMessage.isNotEmpty)
                          Text(
                            _responseMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
