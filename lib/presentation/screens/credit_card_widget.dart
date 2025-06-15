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
  late Animation<Alignment> _gradientAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatCardNumber(String input) {
    if (input.length < 4) return '**** **** **** ****';
    final lastFour = input.substring(input.length - 4);
    return '**** **** **** $lastFour';
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
              begin: _gradientAnimation.value,
              end: Alignment.center,
              colors: const [
                Color.fromARGB(255, 206, 194, 252), // Night blue
                Color.fromARGB(255, 122, 194, 242), // Light blue
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: CustomPaint(
            painter: HolographicPainter(waveOffset: _waveAnimation.value),
            child: Stack(
              children: [
                // Logo HB Technologies Pay
                Positioned(
                  top: 16,
                  right: 16,
                  child: Text(
                    'HB Technologies Pay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
                // Golden Chip
                Positioned(top: 60, left: 20, child: _buildRealisticChip()),
                // Card Number
                Positioned(
                  bottom: 90,
                  left: 90,
                  right: 20,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatCardNumber(widget.maskedPan),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 3,
                        fontFamily: 'RobotoMono',
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Cardholder Name
                Positioned(
                  bottom: 30,
                  left: 20,
                  child: Text(
                    widget.cardHolderName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
                // Expiry Date
                Positioned(
                  bottom: 30,
                  right: 20,
                  child: Text(
                    widget.expiryDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
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

  Widget _buildRealisticChip() {
    return Container(
      width: 60,
      height: 45,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: ChipCircuitPainter())),
          Positioned(
            top: 2,
            left: 2,
            right: 2,
            bottom: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 31, 141, 151),
            Color.fromARGB(255, 153, 174, 242),
          ], // Night blue to light blue
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Magnetic Strip
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border.all(color: Colors.black12),
              ),
              child: CustomPaint(painter: MagneticStripPainter()),
            ),
          ),
          // Signature Strip with CVV
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AUTHORIZED SIGNATURE',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.cvv,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Customer Service
          Positioned(
            bottom: 20,
            left: 20,
            child: const Text(
              'Customer Service: 1-800-HB-TECH',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Holographic effect with animated waves
class HolographicPainter extends CustomPainter {
  final double waveOffset;

  HolographicPainter({required this.waveOffset});

  @override
  void paint(Canvas canvas, Size size) {
    // Holographic shimmer
    final shimmerPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

    final shimmerPath = Path();
    shimmerPath.moveTo(0, size.height * 0.3);
    shimmerPath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.3,
    );
    shimmerPath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.4,
      size.width,
      size.height * 0.3,
    );
    shimmerPath.lineTo(size.width, 0);
    shimmerPath.lineTo(0, 0);
    shimmerPath.close();
    canvas.drawPath(shimmerPath, shimmerPaint);

    // Animated waves
    final wavePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final wavePath = Path();
    for (double i = 0; i < size.height; i += 15) {
      wavePath.moveTo(0, i + waveOffset % 15);
      wavePath.quadraticBezierTo(
        size.width * 0.25,
        i - 5 + waveOffset % 15,
        size.width * 0.5,
        i + waveOffset % 15,
      );
      wavePath.quadraticBezierTo(
        size.width * 0.75,
        i + 5 + waveOffset % 15,
        size.width,
        i + waveOffset % 15,
      );
    }
    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(HolographicPainter oldDelegate) =>
      oldDelegate.waveOffset != waveOffset;
}

// Circuit pattern for chip
class ChipCircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    path.moveTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.7);
    path.moveTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.5, size.height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Magnetic strip texture
class MagneticStripPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < size.width; i += 5) {
      canvas.drawRect(
        Rect.fromLTWH(i.toDouble(), 0, 2, size.height),
        paint..color = Colors.black.withOpacity(0.1 + (i % 2) * 0.05),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
