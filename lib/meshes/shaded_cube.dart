import 'dart:typed_data';

class ShadedCubeMesh {
  final Float32List vertices;
  final Uint16List indices;

  ShadedCubeMesh({required this.vertices, required this.indices});

  static ShadedCubeMesh create() {
    // Define vertices for the cube (position, normal, and color)
    final vertices = Float32List.fromList([
      // Front face (Z+)
      // Position          Normal           Color
      -0.5, -0.5, 0.5, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, // front-bottom-left
      0.5, -0.5, 0.5, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, // front-bottom-right
      0.5, 0.5, 0.5, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, // front-top-right
      -0.5, 0.5, 0.5, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, // front-top-left

      // Back face (Z-)
      -0.5, -0.5, -0.5, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0, // back-bottom-left
      0.5, -0.5, -0.5, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0, // back-bottom-right
      0.5, 0.5, -0.5, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0, // back-top-right
      -0.5, 0.5, -0.5, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0, // back-top-left

      // Right face (X+)
      0.5, -0.5, 0.5, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, // right-bottom-front
      0.5, -0.5, -0.5, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, // right-bottom-back
      0.5, 0.5, -0.5, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, // right-top-back
      0.5, 0.5, 0.5, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, // right-top-front

      // Left face (X-)
      -0.5, -0.5, -0.5, -1.0, 0.0, 0.0, 1.0, 1.0, 0.0, // left-bottom-back
      -0.5, -0.5, 0.5, -1.0, 0.0, 0.0, 1.0, 1.0, 0.0, // left-bottom-front
      -0.5, 0.5, 0.5, -1.0, 0.0, 0.0, 1.0, 1.0, 0.0, // left-top-front
      -0.5, 0.5, -0.5, -1.0, 0.0, 0.0, 1.0, 1.0, 0.0, // left-top-back

      // Top face (Y+)
      -0.5, 0.5, 0.5, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, // top-front-left
      0.5, 0.5, 0.5, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, // top-front-right
      0.5, 0.5, -0.5, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, // top-back-right
      -0.5, 0.5, -0.5, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, // top-back-left

      // Bottom face (Y-)
      -0.5, -0.5, -0.5, 0.0, -1.0, 0.0, 0.0, 1.0, 1.0, // bottom-back-left
      0.5, -0.5, -0.5, 0.0, -1.0, 0.0, 0.0, 1.0, 1.0, // bottom-back-right
      0.5, -0.5, 0.5, 0.0, -1.0, 0.0, 0.0, 1.0, 1.0, // bottom-front-right
      -0.5, -0.5, 0.5, 0.0, -1.0, 0.0, 0.0, 1.0, 1.0, // bottom-front-left
    ]);

    // The indices can remain the same as the simple cube
    final indices = Uint16List.fromList([
      0, 1, 2, 0, 2, 3, // Front
      4, 5, 6, 4, 6, 7, // Back
      8, 9, 10, 8, 10, 11, // Right
      12, 13, 14, 12, 14, 15, // Left
      16, 17, 18, 16, 18, 19, // Top
      20, 21, 22, 20, 22, 23 // Bottom
    ]);

    return ShadedCubeMesh(vertices: vertices, indices: indices);
  }
}
