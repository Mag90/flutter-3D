import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Matrix4;
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math.dart';
import '../meshes/terrain_mesh.dart';
import '../shaders.dart';

class TerrainPainter extends CustomPainter {
  final double rotationX;
  final double rotationY;
  final ui.Image heightmap;

  TerrainPainter({
    required this.rotationX,
    required this.rotationY,
    required this.heightmap,
  }) 

  @override
  void paint(Canvas canvas, Size size) async {

    // Create terrain mesh from heightmap
    final terrainMesh = await TerrainMesh.create(
      heightmap: heightmap,
      width: 10.0,
      height: 2.0,
      depth: 10.0,
      resolution: 100,
    );

    // Rest of the rendering code...
  }

  @override
  bool shouldRepaint(covariant TerrainPainter oldDelegate) {
    return rotationX != oldDelegate.rotationX || rotationY != oldDelegate.rotationY;
  }
}
