import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../camera/orbit_camera.dart';
import '../experiments/terrain_painter.dart';
import '../meshes/terrain_mesh.dart';
import '../utils/heightmap_generator.dart';

class TerrainViewer extends StatefulWidget {
  const TerrainViewer({super.key});

  @override
  State<TerrainViewer> createState() => _TerrainViewerState();
}

class _TerrainViewerState extends State<TerrainViewer> {
  final OrbitCamera camera = OrbitCamera();
  double _lastScale = 1.0;
  TerrainMesh? _terrainMesh;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeTerrain();
  }

  Future<void> _initializeTerrain() async {
    // final heightmap = await HeightmapGenerator.generateVolcano(
    //   width: 256,
    //   height: 256,
    //   outerRadius: 0.8,
    //   innerRadius: 0.1,
    //   craterDepth: 0.6,
    //   rimHeight: 0.15,
    // );

    final heightmap = await HeightmapGenerator.generateNoise(
      width: 512,
      height: 512,
      octaves: 4,
      persistence: 0.5,
      scale: 100.0,
    );

    final mesh = await TerrainMesh.create(
      heightmap: heightmap,
      width: 10.0,
      height: 2.0,
      depth: 10.0,
      resolution: 200,
    );

    setState(() {
      _terrainMesh = mesh;
      _isLoading = false;
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastScale = 1.0;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Handle rotation
      if (details.scale == 1.0) {
        camera.orbit(
          details.focalPointDelta.dx * 0.01,
          -details.focalPointDelta.dy * 0.01,
        );
      }

      // Handle zoom
      if (details.scale != 1.0) {
        final double delta = details.scale / _lastScale;
        camera.zoom(1.0 / delta); // Invert delta for natural zoom direction
        _lastScale = details.scale;
      }
    });
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      setState(() {
        // Zoom in/out based on scroll direction
        final double zoomDelta = event.scrollDelta.dy > 0 ? 1.1 : 0.9;
        camera.zoom(zoomDelta);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        child: CustomPaint(
          painter: TerrainPainter(
            terrainMesh: _terrainMesh!,
            camera: camera,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
