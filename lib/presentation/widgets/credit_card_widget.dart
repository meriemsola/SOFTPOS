import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class CreditCardWidget extends StatefulWidget {
  final String maskedPan;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;

  const CreditCardWidget({
    super.key,
    required this.maskedPan,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolderName,
  });

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatCardNumber(String input) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      buffer.write(input[i]);
      if ((i + 1) % 4 == 0 && i != input.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: AspectRatio(
            aspectRatio: 85 / 53,
            child: FlipCard(
              direction: FlipDirection.HORIZONTAL,
              front: _buildFrontCard(),
              back: _buildBackCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrontCard() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: _animation.value,
              end: Alignment.center,
              colors: [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            painter: WavesPainter(),
            child: Stack(
              children: [
                // Logo HB Technologies Pay
                Positioned(
                  top: 20,
                  right: 20,
                  child: Text(
                    'HB Technologies Pay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 1,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ],
                    ),
                  ),
                ),
                // Puce dorée
                Positioned(
                  top: 80,
                  left: 20,
                  child: Container(
                    width: 50,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.amber[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                // Icône NFC
                Positioned(
                  top: 90,
                  left: 80,
                  child: Icon(Icons.wifi, color: Colors.white, size: 24),
                ),
                // Numéro de carte centré
                Positioned(
                  bottom: 80,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: Text(
                      formatCardNumber(widget.maskedPan),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 2.5,
                        fontFamily: 'RobotoMono',
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 1,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Nom de la société
                Positioned(
                  bottom: 40,
                  left: 20,
                  child: Text(
                    'HB TECHNOLOGIES',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 1,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
                // Date d'expiration
                Positioned(
                  bottom: 40,
                  right: 20,
                  child: Text(
                    widget.expiryDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 1,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(height: 40, color: Colors.black87),
          ),
          Positioned(
            bottom: 70,
            left: 20,
            right: 20,
            child: Container(
              height: 40,
              color: Colors.white,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.cvv,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: const Text(
              'AUTHORIZED SIGNATURE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dessin des vagues de fond
class WavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final path = Path();
    for (double i = 0; i < size.height; i += 15) {
      path.moveTo(0, i);
      path.quadraticBezierTo(size.width * 0.25, i - 5, size.width * 0.5, i);
      path.quadraticBezierTo(size.width * 0.75, i + 5, size.width, i);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
