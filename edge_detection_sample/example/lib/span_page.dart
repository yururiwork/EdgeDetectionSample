import 'dart:io';

import 'package:camera/camera.dart';
import 'package:edge_detection_sample/edge_detection_sample.dart';
import 'package:edge_detection_sample_example/cropped_page.dart';
import 'package:edge_detection_sample_example/edge_detection_shape.dart';
import 'package:edge_detection_sample_example/edge_detector.dart';
import 'package:edge_detection_sample_example/function.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img_lib;
import 'package:path_provider/path_provider.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  EdgeDetectionResult? _edgeDetectionResult;
  int _lastRun = 0;
  bool _detectionInProgress = false;
  img_lib.Image? _streamImage;
  String? _directoryPath;

  final GlobalKey _cameraPreviewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getTemporaryDirectory().then((directory) {
      _directoryPath = directory.path;
    });
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    final index =
        cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
    if (index < 0) {
      if (kDebugMode) {
        print('No Back camera found.');
      }
      return;
    }

    _cameraController = CameraController(
      cameras[index],
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController?.initialize();
      await _cameraController?.startImageStream(_processCameraImage);
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing camera. ERROR:${e.toString()}');
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Stack(
          children: [
            CameraPreview(
              _cameraController!,
              key: _cameraPreviewKey,
            ),
            _buildEdgeDetectionLayer(),
          ],
        ),
        Flexible(child: _buildControlContainer()),
      ],
    );
  }

  Widget _buildEdgeDetectionLayer() {
    if (_streamImage == null || _edgeDetectionResult == null) {
      return const SizedBox.shrink();
    }

    final renderBox =
        _cameraPreviewKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return const SizedBox.shrink();
    }

    return EdgeDetectionShape(
      renderedImageSize: renderBox.size,
      originalImageSize: Size(
        _streamImage!.width.toDouble(),
        _streamImage!.height.toDouble(),
      ),
      edgeDetectionResult: _edgeDetectionResult!,
    );
  }

  Widget _buildControlContainer() {
    return Container(
      color: Colors.black,
      child: Center(
        child: FloatingActionButton(
          onPressed: _onTakePicture,
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }

  void _processCameraImage(CameraImage cameraImage) async {
    if (_detectionInProgress ||
        _directoryPath == null ||
        !mounted ||
        DateTime.now().millisecondsSinceEpoch - _lastRun < 30) {
      return;
    }

    _detectionInProgress = true;

    final image = await compute<CameraImage, img_lib.Image>(
      convertCameraImage,
      cameraImage,
    );
    final bytes = await compute<img_lib.Image, Uint8List>(
      img_lib.encodeJpg,
      image,
    );
    final path = '${_directoryPath!}/stream_image.jpg';
    final map = {
      'path': path,
      'data': bytes,
    };
    await compute<Map, void>(writeAsBytes, map);

    final result = await EdgeDetector().detectEdges(path);
    setState(() {
      _streamImage = image;
      _edgeDetectionResult = result;
    });

    _lastRun = DateTime.now().millisecondsSinceEpoch;
    _detectionInProgress = false;
  }

  void _onTakePicture() async {
    if (_directoryPath == null || _edgeDetectionResult == null) {
      return;
    }

    final xFile = await _cameraController?.takePicture();
    final filePath = '${_directoryPath!}/picture_image.jpg';
    await xFile?.saveTo(filePath);

    final result = await EdgeDetector().detectEdges(filePath);
    final isSuccess = await EdgeDetector().processImage(
      filePath,
      result,
    );

    if (!isSuccess || !mounted) {
      return;
    }

    setState(() {
      imageCache.clearLiveImages();
      imageCache.clear();
    });

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CroppedPage(imagePath: filePath);
    }));
  }
}
