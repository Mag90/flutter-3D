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

  /// Generates a volcano-shaped heightmap
  static Future<ui.Image> generateVolcano({
    required int width,
    required int height,
    double outerRadius = 0.8, // Radius of the volcano base (as fraction of image size)
    double innerRadius = 0.3, // Radius of the crater (as fraction of image size)
    double craterDepth = 0.4, // How deep the crater goes (as fraction of height)
    double rimHeight = 0.2, // Extra height at the crater rim (as fraction of height)
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final center = Offset(width / 2, height / 2);
    final maxRadius = math.min(width, height) / 2;
    final outerRadiusPixels = maxRadius * outerRadius;
    final innerRadiusPixels = maxRadius * innerRadius;

    final paint = Paint()..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final dx = x - center.dx;
        final dy = y - center.dy;
        final distanceFromCenter = math.sqrt(dx * dx + dy * dy);

        // Calculate height based on distance
        double height;
        if (distanceFromCenter > outerRadiusPixels) {
          // Outside the volcano
          height = 0.0;
        } else if (distanceFromCenter < innerRadiusPixels) {
          // Inside the crater
          final craterT = distanceFromCenter / innerRadiusPixels;
          height = 1.0 - craterDepth + (craterT * craterDepth);
        } else {
          // On the volcano slope
          final t = (distanceFromCenter - innerRadiusPixels) / (outerRadiusPixels - innerRadiusPixels);
          final rimT = 1.0 - math.pow((t - 0.2).abs() * 1.25, 2).clamp(0.0, 1.0);
          height = (1.0 - t) + (rimHeight * rimT);
        }

        paint.color = Color.fromRGBO(
          255,
          255,
          255,
          height.clamp(0.0, 1.0),
        );

        canvas.drawRect(
          Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
          paint,
        );
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);

    return image;
  }
}
