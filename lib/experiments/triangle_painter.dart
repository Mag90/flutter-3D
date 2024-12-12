import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math.dart';
import '../shaders.dart';

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final texture = gpu.gpuContext.createTexture(gpu.StorageMode.devicePrivate, size.width.toInt(), size.height.toInt())!;

    final renderTarget = gpu.RenderTarget.singleColor(gpu.ColorAttachment(texture: texture, clearValue: Vector4(0.5, 0.7, 1.0, 1.0)));

    final vert = shaderLibrary['TriangleVertex']!;
    final frag = shaderLibrary['TriangleFragment']!;
    final pipeline = gpu.gpuContext.createRenderPipeline(vert, frag);

    final vertices = Float32List.fromList([
      -0.5, -0.5, // First vertex
      0.5, -0.5, // Second vertex
      0.0, 0.5, // Third vertex
    ]);

    final verticesDeviceBuffer = gpu.gpuContext.createDeviceBufferWithCopy(ByteData.sublistView(vertices))!;

    final commandBuffer = gpu.gpuContext.createCommandBuffer();
    final renderPass = commandBuffer.createRenderPass(renderTarget);

    renderPass.bindPipeline(pipeline);

    final verticesView = gpu.BufferView(
      verticesDeviceBuffer,
      offsetInBytes: 0,
      lengthInBytes: verticesDeviceBuffer.sizeInBytes,
    );
    renderPass.bindVertexBuffer(verticesView, 3);

    renderPass.draw();
    commandBuffer.submit();

    final image = texture.asImage();
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
