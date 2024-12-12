import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';

class HeightmapGenerator {
  /// Generates a simple gradient heightmap
  static Future<ui.Image> generateGradient({
    required int width,
    required int height,
    double angle = 0.0, // angle in radians
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());

    // Create gradient
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Colors.black, Colors.white],
      transform: GradientRotation(angle),
    );

    // Draw gradient
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);

    return image;
  }

  /// Generates a heightmap with perlin noise
  static Future<ui.Image> generateNoise({
    required int width,
    required int height,
    int octaves = 4,
    double persistence = 0.5,
    double scale = 50.0,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);

    // Create noise texture
    paint.color = Colors.white;
    final random = math.Random(42); // Fixed seed for consistent results

    for (int octave = 0; octave < octaves; octave++) {
      final frequency = math.pow(2, octave).toDouble();
      final amplitude = math.pow(persistence, octave).toDouble();

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final value = _noise2D(
            x * frequency / scale,
            y * frequency / scale,
            random,
          );

          paint.color = Color.fromRGBO(
            255,
            255,
            255,
            (value * amplitude).clamp(0.0, 1.0),
          );

          canvas.drawRect(
            Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
            paint,
          );
        }
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);

    return image;
  }

  /// Simple 2D noise function
  static double _noise2D(double x, double y, math.Random random) {
    return random.nextDouble();
  }

  /// Generates a circular heightmap (like a cone or volcano)
  static Future<ui.Image> generateCircular({
    required int width,
    required int height,
    bool inverse = false,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final center = Offset(width / 2, height / 2);
    final radius = math.min(width, height) / 2;

    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: inverse ? [Colors.white, Colors.black] : [Colors.black, Colors.white],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(
          center: center,
          width: width.toDouble(),
          height: height.toDouble(),
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      paint,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);

    return image;
  }
}
