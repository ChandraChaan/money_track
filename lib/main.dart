import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(CreditScoreApp());
}

class CreditScoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CreditScoreScreen(),
    );
  }
}

class CreditScoreScreen extends StatefulWidget {
  @override
  _CreditScoreScreenState createState() => _CreditScoreScreenState();
}

class _CreditScoreScreenState extends State<CreditScoreScreen>
    with SingleTickerProviderStateMixin {
  double _currentValue = 00;

  @override
  void initState() {
    super.initState();
    // Simulate smooth transition to a target score (e.g., 720)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentValue = 790;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CIBIL Credit Score'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: CreditScoreIndicator(
          score: _currentValue,
        ),
      ),
    );
  }
}

class CreditScoreIndicator extends StatelessWidget {
  final double score;

  CreditScoreIndicator({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          size: const Size(300, 150),
          painter: CreditScorePainter(score),
        ),
        const SizedBox(height: 50),
        Text(
          'CIBIL SCORE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toInt().toString(),
          style: const TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }
}

class CreditScorePainter extends CustomPainter {
  final double score;

  CreditScorePainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.height;

    // Draw gauge arc
    final colors = [
      Colors.red,
      Colors.red.shade200,
      Colors.yellow.shade400,
      Colors.yellow.shade600,
      Colors.lightGreen,
      Colors.green,
    ];
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25;

    double startAngle = pi;
    const sweepAngle = pi / 6;

    for (var color in colors) {
      paint.color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 15),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw the needle
    final needlePaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 6
      ..style = PaintingStyle.fill;

    final needleAngle = pi + (score / 900) * pi;
    final needleStart = Offset(
      center.dx + 10 * cos(needleAngle - pi / 2),
      center.dy + 10 * sin(needleAngle - pi / 2),
    );
    final needleEnd = Offset(
      center.dx + (radius - 30) * cos(needleAngle),
      center.dy + (radius - 30) * sin(needleAngle),
    );

    // Draw the needle with a tapered style (big to slim)
    final needlePath = Path()
      ..moveTo(needleStart.dx, needleStart.dy)
      ..lineTo(
          center.dx + 11 * cos(needleAngle - pi / 6),
          center.dy + 11 * sin(needleAngle - pi / 6))
      ..lineTo(needleEnd.dx, needleEnd.dy)
      ..lineTo(
          center.dx + 11 * cos(needleAngle + pi / 6),
          center.dy + 11 * sin(needleAngle + pi / 6))
      ..close();

    canvas.drawPath(needlePath, needlePaint);

    // Draw the knob
    final knobPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 30, knobPaint);
    canvas.drawCircle(center, 11, Paint()..color = Colors.blueAccent);

    // Draw text labels above the gauge
    _drawTextLabelsAbove(canvas, size, center, radius);
  }

  void _drawTextLabelsAbove(
      Canvas canvas, Size size, Offset center, double radius) {
    final labels = ["VERY POOR", "POOR", "FAIR", "GOOD", "VERY GOOD", "EXCELLENT"];
    const totalAngle = pi; // Total arc angle
    final labelAngle = totalAngle / (labels.length - 0.8);
    final labelRadius = radius + 10; // Move labels slightly outside the arc

    for (int i = 0; i < labels.length; i++) {
      final angle = pi + (i * labelAngle); // Calculate angle for each label
      final x = center.dx + labelRadius * cos(angle);
      final y = center.dy + labelRadius * sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Offset for proper label placement
      final offsetX = x - textPainter.width / 2;
      final offsetY = y - textPainter.height / 2;

      canvas.save();
      // Translate to the position of the label
      canvas.translate(
          offsetX + textPainter.width / 2, offsetY + textPainter.height / 2);

      // Adjust rotation for readable text
      if (angle > pi && angle <= pi * 1.5) {
        // Right side (GOOD, VERY GOOD, EXCELLENT)
        canvas.rotate(angle - pi / 2 + 22);
      } else {
        // Left side (VERY POOR, POOR, FAIR)
        canvas.rotate(angle - pi / 2 + pi);
      }

      // Center the text painter after rotation
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
