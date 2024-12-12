import 'dart:typed_data';

class SimpleCube {
  final Float32List vertices;
  final Uint16List indices;

  SimpleCube({required this.vertices, required this.indices});

  static SimpleCube createCube() {
    // Define vertices for the cube (position and color)
    final vertices = Float32List.fromList([
      // Position (XYZ)      Color (RGB)
      // Front face vertices (RED)
      -0.5, -0.5, 0.5, 1.0, 0.0, 0.0, // 0: front-bottom-left
      0.5, -0.5, 0.5, 1.0, 0.0, 0.0, // 1: front-bottom-right
      0.5, 0.5, 0.5, 1.0, 0.0, 0.0, // 2: front-top-right
      -0.5, 0.5, 0.5, 1.0, 0.0, 0.0, // 3: front-top-left

      // Back face vertices (GREEN)
      -0.5, -0.5, -0.5, 0.0, 1.0, 0.0, // 4: back-bottom-left
      0.5, -0.5, -0.5, 0.0, 1.0, 0.0, // 5: back-bottom-right
      0.5, 0.5, -0.5, 0.0, 1.0, 0.0, // 6: back-top-right
      -0.5, 0.5, -0.5, 0.0, 1.0, 0.0, // 7: back-top-left

      // Right face vertices (BLUE)
      0.5, -0.5, 0.5, 0.0, 0.0, 1.0, // 8: front-bottom-right
      0.5, -0.5, -0.5, 0.0, 0.0, 1.0, // 9: back-bottom-right
      0.5, 0.5, -0.5, 0.0, 0.0, 1.0, // 10: back-top-right
      0.5, 0.5, 0.5, 0.0, 0.0, 1.0, // 11: front-top-right

      // Left face vertices (YELLOW)
      -0.5, -0.5, -0.5, 1.0, 1.0, 0.0, // 12: back-bottom-left
      -0.5, -0.5, 0.5, 1.0, 1.0, 0.0, // 13: front-bottom-left
      -0.5, 0.5, 0.5, 1.0, 1.0, 0.0, // 14: front-top-left
      -0.5, 0.5, -0.5, 1.0, 1.0, 0.0, // 15: back-top-left

      // Top face vertices (MAGENTA)
      -0.5, 0.5, 0.5, 1.0, 0.0, 1.0, // 16: front-top-left
      0.5, 0.5, 0.5, 1.0, 0.0, 1.0, // 17: front-top-right
      0.5, 0.5, -0.5, 1.0, 0.0, 1.0, // 18: back-top-right
      -0.5, 0.5, -0.5, 1.0, 0.0, 1.0, // 19: back-top-left

      // Bottom face vertices (CYAN)
      -0.5, -0.5, -0.5, 0.0, 1.0, 1.0, // 20: back-bottom-left
      0.5, -0.5, -0.5, 0.0, 1.0, 1.0, // 21: back-bottom-right
      0.5, -0.5, 0.5, 0.0, 1.0, 1.0, // 22: front-bottom-right
      -0.5, -0.5, 0.5, 0.0, 1.0, 1.0, // 23: front-bottom-left
    ]);

    // Define indices for the cube faces
    final indices = Uint16List.fromList([
      // Front face (RED: z = 0.5)
      0, 1, 2, 0, 2, 3, // Using vertices 0-3
      // Right face (BLUE: x = 0.5) - reversed winding order
      8, 10, 9, 8, 11, 10, // Using vertices 8-11
      // Back face (GREEN: z = -0.5)
      4, 5, 6, 4, 6, 7, // Using vertices 4-7
      // Left face (YELLOW: x = -0.5)
      12, 13, 14, 12, 14, 15, // Using vertices 12-15
      // Top face (MAGENTA: y = 0.5)
      16, 17, 18, 16, 18, 19, // Using vertices 16-19
      // Bottom face (CYAN: y = -0.5)
      20, 21, 22, 20, 22, 23, // Using vertices 20-23
    ]);

    return SimpleCube(
      vertices: vertices,
      indices: indices,
    );
  }
}
