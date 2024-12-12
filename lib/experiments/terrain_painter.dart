import 'dart:typed_data';
import 'package:flutter/material.dart' hide Matrix4;
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math.dart';
import '../meshes/terrain_mesh.dart';
import '../camera/orbit_camera.dart';
import '../shaders.dart';

class TerrainPainter extends CustomPainter {
  final TerrainMesh terrainMesh;
  final OrbitCamera camera;

  const TerrainPainter({
    required this.terrainMesh,
    required this.camera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a texture to render our 3D scene into
    final texture = gpu.gpuContext.createTexture(
      gpu.StorageMode.devicePrivate,
      size.width.toInt(),
      size.height.toInt(),
    )!;

    // Create a depth texture for depth testing
    final depthTexture = gpu.gpuContext.createTexture(
      gpu.StorageMode.devicePrivate,
      size.width.toInt(),
      size.height.toInt(),
      format: gpu.gpuContext.defaultDepthStencilFormat,
    );

    if (depthTexture == null) {
      throw Exception('Failed to create depth texture');
    }

    // Set up the render target
    final renderTarget = gpu.RenderTarget.singleColor(
      gpu.ColorAttachment(
        texture: texture,
        clearValue: Vector4(0.1, 0.1, 0.1, 1.0),
      ),
      depthStencilAttachment: gpu.DepthStencilAttachment(
        texture: depthTexture,
        depthLoadAction: gpu.LoadAction.clear,
        depthStoreAction: gpu.StoreAction.store,
        depthClearValue: 1.0,
        stencilLoadAction: gpu.LoadAction.clear,
        stencilStoreAction: gpu.StoreAction.dontCare,
        stencilClearValue: 0,
      ),
    );

    final vertexCount = terrainMesh.vertices.length ~/ 8; // 8 components per vertex (pos + normal + uv)
    final indexCount = terrainMesh.indices.length;

    // Create buffers
    final verticesBuffer = gpu.gpuContext.createDeviceBufferWithCopy(
      ByteData.sublistView(terrainMesh.vertices),
    )!;

    final indexBuffer = gpu.gpuContext.createDeviceBufferWithCopy(
      ByteData.sublistView(terrainMesh.indices),
    )!;

    // Create transformation matrices
    final aspect = size.width / size.height;
    final projection = camera.getProjectionMatrix(aspect);
    final view = camera.getViewMatrix();
    final model = Matrix4.identity();
    final mvp = projection * view * model;

    // Calculate camera position for light placement
    final viewInverse = view.clone()..invert();
    final cameraPosition = viewInverse.getTranslation(); // Correct way

    // Lighting parameters
    final Vector3 lightColor = Vector3(1.0, 1.0, 1.0);
    final double ambientStrength = 0.3;
    final double specularStrength = 0.7;

    // Create uniform buffer
    final uniformData = Float32List(16 + 16 + 4 + 4 + 4);
    int offset = 0;

    // Pass MVP matrix
    uniformData.setAll(offset, mvp.storage);
    offset += 16;

    // Pass model-view matrix for normal transformation
    final modelView = view * model;
    uniformData.setAll(offset, modelView.storage);
    offset += 16;

    // Pass light position in view space
    //final lightPosViewSpace = view.transform3(cameraPosition);
    final Vector3 lightPositionWorld = cameraPosition + Vector3(5.0, 5.0, 0.0);
    uniformData[offset++] = lightPositionWorld.x;
    uniformData[offset++] = lightPositionWorld.y;
    uniformData[offset++] = lightPositionWorld.z;
    uniformData[offset++] = 1.0;

    uniformData[offset++] = lightColor.x;
    uniformData[offset++] = lightColor.y;
    uniformData[offset++] = lightColor.z;
    uniformData[offset++] = 0.0;

    uniformData[offset++] = ambientStrength;
    uniformData[offset++] = specularStrength;
    uniformData[offset++] = 0.0;
    uniformData[offset++] = 0.0;

    final uniformBuffer = gpu.gpuContext.createDeviceBufferWithCopy(
      ByteData.sublistView(uniformData),
    )!;

    // Get shaders and create pipeline
    final vert = shaderLibrary['TerrainVertex']!;
    final frag = shaderLibrary['TerrainFragment']!;
    final pipeline = gpu.gpuContext.createRenderPipeline(vert, frag);

    // Set up command buffer and render pass
    final commandBuffer = gpu.gpuContext.createCommandBuffer();
    final renderPass = commandBuffer.createRenderPass(renderTarget);
    renderPass.setDepthWriteEnable(true);
    renderPass.setDepthCompareOperation(gpu.CompareFunction.less);

    // Bind pipeline and buffers
    renderPass.bindPipeline(pipeline);
    renderPass.bindVertexBuffer(
      gpu.BufferView(
        verticesBuffer,
        offsetInBytes: 0,
        lengthInBytes: verticesBuffer.sizeInBytes,
      ),
      vertexCount,
    );

    renderPass.bindIndexBuffer(
      gpu.BufferView(
        indexBuffer,
        offsetInBytes: 0,
        lengthInBytes: indexBuffer.sizeInBytes,
      ),
      gpu.IndexType.int16,
      indexCount,
    );

    // Bind uniforms to both vertex and fragment shaders
    renderPass.bindUniform(
      vert.getUniformSlot('Transforms'),
      gpu.BufferView(
        uniformBuffer,
        offsetInBytes: 0,
        lengthInBytes: uniformBuffer.sizeInBytes,
      ),
    );

    renderPass.bindUniform(
      frag.getUniformSlot('Transforms'),
      gpu.BufferView(
        uniformBuffer,
        offsetInBytes: 0,
        lengthInBytes: uniformBuffer.sizeInBytes,
      ),
    );

    // Draw and submit
    renderPass.draw();
    commandBuffer.submit();

    // Draw the result to the canvas
    final image = texture.asImage();
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant TerrainPainter oldDelegate) {
    return true; // Always repaint when camera changes
  }
}
