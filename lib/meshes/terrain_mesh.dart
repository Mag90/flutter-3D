import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:vector_math/vector_math.dart';

class TerrainMesh {
  final Float32List vertices;
  final Uint16List indices;

  TerrainMesh({required this.vertices, required this.indices});

  static Future<TerrainMesh> create({
    required ui.Image heightmap,
    double width = 10.0,
    double height = 2.0,
    double depth = 10.0,
    int resolution = 100,
  }) async {
    // Get heightmap data
    final bytes = await heightmap.toByteData();
    if (bytes == null) throw Exception('Failed to get heightmap data');

    final gridX = resolution;
    final gridZ = resolution;

    // Create vertices array: position (3) + normal (3) + uv (2)
    final vertices = Float32List(gridX * gridZ * 8);
    int vIndex = 0;

    // Create vertices
    for (int z = 0; z < gridZ; z++) {
      for (int x = 0; x < gridX; x++) {
        // Calculate position
        final xPos = (x / (gridX - 1) - 0.5) * width;
        final zPos = (z / (gridZ - 1) - 0.5) * depth;

        // Get height from heightmap
        final imgX = (x / (gridX - 1) * (heightmap.width - 1)).round();
        final imgY = (z / (gridZ - 1) * (heightmap.height - 1)).round();
        final pixel = bytes.getUint8((imgY * heightmap.width + imgX) * 4);
        final yPos = (pixel / 255.0 - 0.5) * height;

        // Calculate normal
        final normal = _calculateNormal(x, z, gridX, gridZ, vertices, width, height, depth);

        // Store vertex data
        vertices[vIndex++] = xPos; // position.x
        vertices[vIndex++] = yPos; // position.y
        vertices[vIndex++] = zPos; // position.z
        vertices[vIndex++] = normal.x; // normal.x
        vertices[vIndex++] = normal.y; // normal.y
        vertices[vIndex++] = normal.z; // normal.z
        vertices[vIndex++] = x / (gridX - 1); // u
        vertices[vIndex++] = z / (gridZ - 1); // v
      }
    }

    // Create indices for triangles
    final indices = Uint16List((gridX - 1) * (gridZ - 1) * 6);
    int iIndex = 0;

    for (int z = 0; z < gridZ - 1; z++) {
      for (int x = 0; x < gridX - 1; x++) {
        final topLeft = z * gridX + x;
        final topRight = topLeft + 1;
        final bottomLeft = (z + 1) * gridX + x;
        final bottomRight = bottomLeft + 1;

        // First triangle
        indices[iIndex++] = topLeft;
        indices[iIndex++] = bottomLeft;
        indices[iIndex++] = topRight;

        // Second triangle
        indices[iIndex++] = topRight;
        indices[iIndex++] = bottomLeft;
        indices[iIndex++] = bottomRight;
      }
    }

    return TerrainMesh(vertices: vertices, indices: indices);
  }

  static Vector3 _calculateNormal(
    int x,
    int z,
    int gridX,
    int gridZ,
    Float32List vertices,
    double width,
    double height,
    double depth,
  ) {
    // Calculate normal based on surrounding vertices
    final pos = Vector3(
      (x / (gridX - 1) - 0.5) * width,
      0,
      (z / (gridZ - 1) - 0.5) * depth,
    );

    final right = Vector3(
      ((x + 1).clamp(0, gridX - 1) / (gridX - 1) - 0.5) * width,
      0,
      (z / (gridZ - 1) - 0.5) * depth,
    );

    final forward = Vector3(
      (x / (gridX - 1) - 0.5) * width,
      0,
      ((z + 1).clamp(0, gridZ - 1) / (gridZ - 1) - 0.5) * depth,
    );

    final tangent = right - pos;
    final bitangent = forward - pos;
    return tangent.cross(bitangent).normalized();
  }
}
