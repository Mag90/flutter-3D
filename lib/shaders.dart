import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:flutter/foundation.dart';

const String _kShaderBundlePath = 'build/shaderbundles/my_renderer.shaderbundle';

gpu.ShaderLibrary? _shaderLibrary;
gpu.ShaderLibrary get shaderLibrary {
  if (_shaderLibrary != null) {
    return _shaderLibrary!;
  }

  try {
    debugPrint('Loading shader bundle from: $_kShaderBundlePath');
    _shaderLibrary = gpu.ShaderLibrary.fromAsset(_kShaderBundlePath);

    if (_shaderLibrary == null) {
      throw Exception('ShaderLibrary.fromAsset returned null');
    }

    // Verify shaders are present
    final triangleVert = _shaderLibrary!['TriangleVertex'];
    final triangleFrag = _shaderLibrary!['TriangleFragment'];
    final cubeVert = _shaderLibrary!['SimpleCubeVertex'];
    final cubeFrag = _shaderLibrary!['SimpleCubeFragment'];
    final shadedCubeVert = _shaderLibrary!['ShadedCubeVertex'];
    final shadedCubeFrag = _shaderLibrary!['ShadedCubeFragment'];

    debugPrint('Shader availability:');
    debugPrint('TriangleVertex: ${triangleVert != null}');
    debugPrint('TriangleFragment: ${triangleFrag != null}');
    debugPrint('SimpleCubeVertex: ${cubeVert != null}');
    debugPrint('SimpleCubeFragment: ${cubeFrag != null}');
    debugPrint('ShadedCubeVertex: ${shadedCubeVert != null}');
    debugPrint('ShadedCubeFragment: ${shadedCubeFrag != null}');

    debugPrint('Successfully loaded shader bundle');
    return _shaderLibrary!;
  } catch (e) {
    debugPrint('Error loading shader bundle: $e');
    rethrow;
  }
}
