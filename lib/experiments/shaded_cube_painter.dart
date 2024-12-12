import 'dart:typed_data';
import 'package:flutter/material.dart' hide Matrix4;
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math.dart';
import '../meshes/shaded_cube.dart';
import '../shaders.dart';

/// A CustomPainter that renders a 3D cube using Flutter GPU
/// The cube can be rotated using rotationX and rotationY parameters
class ShadedCubePainter extends CustomPainter {
  final double rotationX;
  final double rotationY;

  const ShadedCubePainter({
    required this.rotationX,
    required this.rotationY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a texture to render our 3D scene into
    // This will act as our framebuffer
    final texture = gpu.gpuContext.createTexture(
      gpu.StorageMode.devicePrivate,
      size.width.toInt(),
      size.height.toInt(),
    )!;

    // Create a depth texture for depth testing
    // This ensures proper rendering of 3D objects where closer surfaces occlude farther ones
    final depthTexture = gpu.gpuContext.createTexture(
      gpu.StorageMode.devicePrivate,
      size.width.toInt(),
      size.height.toInt(),
      format: gpu.gpuContext.defaultDepthStencilFormat,
    );

    if (depthTexture == null) {
      throw Exception('Failed to create depth texture');
    }

    // Lighting parameters
    final Vector3 lightPosition = Vector3(1.0, 1.0, 2.0);
    final Vector3 lightColor = Vector3(1.0, 1.0, 1.0);
    final double ambientStrength = 0.2;
    final double specularStrength = 0.5;

    // Set up the render target with color and depth attachments
    // The color attachment will store the final rendered image
    // The depth attachment will handle depth testing during rendering
    final renderTarget = gpu.RenderTarget.singleColor(
      gpu.ColorAttachment(
        texture: texture,
        clearValue: Vector4(0.1, 0.1, 0.1, 1.0), // Dark gray background color
      ),
      depthStencilAttachment: gpu.DepthStencilAttachment(
        texture: depthTexture,
        depthLoadAction: gpu.LoadAction.clear,
        depthStoreAction: gpu.StoreAction.store,
        depthClearValue: 1.0, // Clear depth to 1.0 (far plane)
        stencilLoadAction: gpu.LoadAction.clear,
        stencilStoreAction: gpu.StoreAction.dontCare,
        stencilClearValue: 0,
      ),
    );

    final cubeMesh = ShadedCubeMesh.create();
    final vertexCount = cubeMesh.vertices.length ~/ 9; // 9 components per vertex (pos + normal + color)
    final indexCount = cubeMesh.indices.length;

    // Create buffers
    final verticesBuffer = gpu.gpuContext.createDeviceBufferWithCopy(
      ByteData.sublistView(cubeMesh.vertices),
    )!;

    final indexBuffer = gpu.gpuContext.createDeviceBufferWithCopy(
      ByteData.sublistView(cubeMesh.indices),
    )!;

    // Create transformation matrices
    final aspect = size.width / size.height;
    final projection = makePerspectiveMatrix(45 * (3.14159 / 180.0), aspect, 0.1, 100.0);
    final view = makeViewMatrix(
      Vector3(0, 0, 4),
      Vector3(0, 0, 0),
      Vector3(0, 1, 0),
    );
    final model = Matrix4.identity()
      ..rotateY(rotationY)
      ..rotateX(rotationX * 0.5);
    final Matrix4 mvp = projection * view * model;

    // Create uniform buffer with all transformation and lighting data
    final uniformData = Float32List(16 + 16 + 4 + 4 + 4);
    int offset = 0;

    uniformData.setAll(offset, mvp.storage);
    offset += 16;

    uniformData.setAll(offset, model.storage);
    offset += 16;

    uniformData[offset++] = lightPosition.x;
    uniformData[offset++] = lightPosition.y;
    uniformData[offset++] = lightPosition.z;
    uniformData[offset++] = 0.0;

    uniformData[offset++] = lightColor.x;
    uniformData[offset++] = lightColor.y;
    uniformData[offset++] = lightColor.z;
    uniformData[offset++] = 0.0;

    uniformData[offset++] = ambientStrength;
    uniformData[offset++] = specularStrength;
    uniformData[offset++] = 0.5;
    uniformData[offset++] = 0.0;

    final uniformBuffer = gpu.gpuContext.createDeviceBufferWithCopy(
      ByteData.sublistView(uniformData),
    )!;

    // Get shaders and create pipeline
    final vert = shaderLibrary['ShadedCubeVertex']!;
    final frag = shaderLibrary['ShadedCubeFragment']!;
    final pipeline = gpu.gpuContext.createRenderPipeline(vert, frag);

    // Set up command buffer and render pass
    final commandBuffer = gpu.gpuContext.createCommandBuffer();
    final gpu.RenderPass renderPass = commandBuffer.createRenderPass(renderTarget);
    // Enable depth testing
    renderPass.setDepthWriteEnable(true);
    renderPass.setDepthCompareOperation(gpu.CompareFunction.less);

    // Bind pipeline, vertex buffer, index buffer, and uniforms
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

    renderPass.bindUniform(
        vert.getUniformSlot('Transforms'),
        gpu.BufferView(
          uniformBuffer,
          offsetInBytes: 0,
          lengthInBytes: uniformBuffer.sizeInBytes,
        ));

    renderPass.bindUniform(
        frag.getUniformSlot('Transforms'),
        gpu.BufferView(
          uniformBuffer,
          offsetInBytes: 0,
          lengthInBytes: uniformBuffer.sizeInBytes,
        ));

    // Execute the draw command and submit the command buffer
    renderPass.draw();
    commandBuffer.submit();

    // Convert the rendered texture to an image and draw it to the canvas
    final image = texture.asImage();
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
