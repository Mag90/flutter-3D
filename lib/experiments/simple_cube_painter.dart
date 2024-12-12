import 'dart:typed_data';
import 'package:flutter/material.dart' hide Matrix4;
import 'package:flutter_3d/meshes/simple_cube.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math.dart';
import '../shaders.dart';

/// A CustomPainter that renders a 3D cube using Flutter GPU
/// The cube can be rotated using rotationX and rotationY parameters
class SimpleCubePainter extends CustomPainter {
  final double rotationX;
  final double rotationY;

  SimpleCubePainter({required this.rotationX, required this.rotationY});

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

    // Create cube mesh geometry (vertices and indices)
    final simpleCubeMesh = SimpleCube.createCube();
    final vertexCount = simpleCubeMesh.vertices.length ~/ 6; // 6 components per vertex (pos + color)
    final indexCount = simpleCubeMesh.indices.length;

    // Create GPU buffers for vertex and index data
    final verticesBuffer = gpu.gpuContext.createDeviceBufferWithCopy(
      ByteData.sublistView(simpleCubeMesh.vertices),
    )!;

    final indexBuffer = gpu.gpuContext.createDeviceBufferWithCopy(
      ByteData.sublistView(simpleCubeMesh.indices),
    )!;

    // Set up the camera and transformation matrices
    final aspect = size.width / size.height;
    // Create perspective projection matrix (45 degree FOV)
    final projection = makePerspectiveMatrix(45 * (3.14159 / 180.0), aspect, 0.1, 100.0);
    // Create view matrix (camera at (0,0,4) looking at origin)
    final view = makeViewMatrix(
      Vector3(0, 0, 4), // Camera position
      Vector3(0, 0, 0), // Look at point
      Vector3(0, 1, 0), // Up vector
    );
    // Create model matrix with rotation
    final model = Matrix4.identity()
      ..rotateY(rotationY)
      ..rotateX(rotationX * 0.5);
    // Combine matrices: MVP = Projection * View * Model
    final mvp = projection * view * model;

    // Create uniform buffer for MVP matrix
    final uniformBuffer = gpu.gpuContext.createDeviceBufferWithCopy(
      ByteData.sublistView(Float32List.fromList(mvp.storage)),
    )!;

    // Get shader programs from shader library and create rendering pipeline
    final vert = shaderLibrary['SimpleCubeVertex']!;
    final frag = shaderLibrary['SimpleCubeFragment']!;
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
