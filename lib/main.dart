import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_3d/experiments/shaded_cube_painter.dart';
import 'package:flutter_3d/experiments/terrain_painter.dart';
import 'package:flutter_3d/utils/heightmap_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter GPU Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double rotationX = 0.0;
  double rotationY = 0.0;
  ui.Image? heightmap;

  @override
  void initState() {
    super.initState();
    generateHeightmap();
  }

  void generateHeightmap() async {
    heightmap = await HeightmapGenerator.generateCircular(
      width: 256,
      height: 256,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Builder(
            builder: (context) {
              if (heightmap == null) {
                return const SizedBox(
                  width: 400,
                  height: 400,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return SizedBox(
                width: 400,
                height: 400,
                child: CustomPaint(
                  painter: TerrainPainter(rotationX: rotationX, rotationY: rotationY, heightmap: heightmap!),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('X Rotation: '),
                    Expanded(
                      child: Slider(
                        value: rotationX,
                        min: 0,
                        max: 2 * pi,
                        onChanged: (value) {
                          setState(() {
                            rotationX = value;
                          });
                        },
                      ),
                    ),
                    Text('${(rotationX * 180 / pi).toStringAsFixed(0)}°'),
                  ],
                ),
                Row(
                  children: [
                    const Text('Y Rotation: '),
                    Expanded(
                      child: Slider(
                        value: rotationY,
                        min: 0,
                        max: 2 * pi,
                        onChanged: (value) {
                          setState(() {
                            rotationY = value;
                          });
                        },
                      ),
                    ),
                    Text('${(rotationY * 180 / pi).toStringAsFixed(0)}°'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
