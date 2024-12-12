import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:flutter_gpu_shaders/build.dart';
import 'dart:io';

void main(List<String> args) async {
  print('Building shader bundle...');
  print('Working directory: ${Directory.current}');

  await build(args, (config, output) async {
    print('Building shaders with config: ${config}');
    await buildShaderBundleJson(buildConfig: config, buildOutput: output, manifestFileName: 'my_renderer.shaderbundle.json');
    print('Shader bundle build complete');
  });
}
