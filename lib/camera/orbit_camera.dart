import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';

class OrbitCamera {
  Vector3 target = Vector3(0, 0, 0); // Center point to orbit around
  double distance = 10.0; // Distance from target (for zoom)
  double theta = 0.0; // Horizontal orbit angle
  double phi = math.pi / 4; // Vertical orbit angle
  double fov = 45.0; // Field of view in degrees

  // Constraints
  double minDistance = 2.0;
  double maxDistance = 50.0;
  double minPhi = 0.1;
  double maxPhi = math.pi / 2 - 0.1;

  void orbit(double deltaX, double deltaY) {
    theta += deltaX;
    phi = (phi + deltaY).clamp(minPhi, maxPhi);
  }

  void zoom(double factor) {
    distance = (distance * factor).clamp(minDistance, maxDistance);
  }

  Matrix4 getViewMatrix() {
    // Convert spherical to Cartesian coordinates
    double x = distance * math.sin(phi) * math.cos(theta);
    double y = distance * math.cos(phi);
    double z = distance * math.sin(phi) * math.sin(theta);

    Vector3 eye = target + Vector3(x, y, z);
    return makeViewMatrix(eye, target, Vector3(0, 1, 0));
  }

  Matrix4 getProjectionMatrix(double aspect) {
    return makePerspectiveMatrix(
        fov * (math.pi / 180.0), // Convert FOV to radians
        aspect,
        0.1,
        100.0);
  }
}
