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
    final permutation = _generatePermutation();

    double maxValue = 0.0;
    final noiseValues = List<double>.filled(width * height, 0.0);

    // Generate noise for each octave
    for (int octave = 0; octave < octaves; octave++) {
      final frequency = math.pow(2, octave).toDouble();
      final amplitude = math.pow(persistence, octave).toDouble();

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final value = _perlinNoise(
            x * frequency / scale,
            y * frequency / scale,
            permutation,
          );

          final index = y * width + x;
          noiseValues[index] += value * amplitude;
          maxValue = math.max(maxValue, noiseValues[index]);
        }
      }
    }

    // Normalize and draw the noise values
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        final normalizedValue = noiseValues[index] / maxValue;

        paint.color = Color.fromRGBO(
          255,
          255,
          255,
          normalizedValue.clamp(0.0, 1.0),
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

  /// Generates a permutation table for Perlin noise
  static List<int> _generatePermutation() {
    final random = math.Random(42); // Fixed seed for consistent results
    final p = List<int>.generate(256, (i) => i);

    // Shuffle the array
    for (int i = p.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = p[i];
      p[i] = p[j];
      p[j] = temp;
    }

    // Extend the permutation table to avoid overflow
    return [...p, ...p];
  }

  /// Fade function for Perlin noise
  static double _fade(double t) {
    return t * t * t * (t * (t * 6 - 15) + 10);
  }

  /// Linear interpolation
  static double _lerp(double t, double a, double b) {
    return a + t * (b - a);
  }

  /// Gradient function for Perlin noise
  static double _grad(int hash, double x, double y) {
    final h = hash & 15;
    final grad_x = 1 + (h & 7); // Gradient x
    final grad_y = 1 + (h >> 4); // Gradient y
    return ((h & 8) != 0 ? -grad_x : grad_x) * x + ((h & 8) != 0 ? -grad_y : grad_y) * y;
  }

  /// 2D Perlin noise implementation
  static double _perlinNoise(double x, double y, List<int> p) {
    // Find unit cube that contains the point
    final X = x.floor() & 255;
    final Y = y.floor() & 255;

    // Find relative x, y of point in cube
    x -= x.floor();
    y -= y.floor();

    // Compute fade curves for each of x, y
    final u = _fade(x);
    final v = _fade(y);

    // Hash coordinates of the 4 cube corners
    final A = p[X] + Y;
    final AA = p[A];
    final AB = p[A + 1];
    final B = p[X + 1] + Y;
    final BA = p[B];
    final BB = p[B + 1];

    // Add blended results from 4 corners of cube
    return _lerp(v, _lerp(u, _grad(p[AA], x, y), _grad(p[BA], x - 1, y)), _lerp(u, _grad(p[AB], x, y - 1), _grad(p[BB], x - 1, y - 1)));
  }

  /// Generates a volcano-shaped heightmap
  static Future<ui.Image> generateVolcano({
    required int width,
    required int height,
    double outerRadius = 0.8,
    double innerRadius = 0.3,
    double craterDepth = 0.4,
    double rimHeight = 0.2,
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
