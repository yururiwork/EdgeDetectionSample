import 'dart:async';
import 'dart:isolate';

import 'package:edge_detection_sample/edge_detection_sample.dart';

class EdgeDetector {
  static Future<void> startEdgeDetectionIsolate(
      EdgeDetectionInput edgeDetectionInput) async {
    if (edgeDetectionInput.inputPath == null) {
      return;
    }
    EdgeDetectionResult result = await EdgeDetectionSample.detectEdges(
      edgeDetectionInput.inputPath!,
    );
    edgeDetectionInput.sendPort?.send(result);
  }

  static Future<void> processImageIsolate(
      ProcessImageInput processImageInput) async {
    if (processImageInput.inputPath == null ||
        processImageInput.edgeDetectionResult == null) {
      return;
    }
    EdgeDetectionSample.processImage(
      processImageInput.inputPath!,
      processImageInput.edgeDetectionResult!,
    );
    processImageInput.sendPort?.send(true);
  }

  Future<EdgeDetectionResult> detectEdges(String filePath) async {
    final port = ReceivePort();

    _spawnIsolate<EdgeDetectionInput>(startEdgeDetectionIsolate,
        EdgeDetectionInput(inputPath: filePath, sendPort: port.sendPort), port);

    return await _subscribeToPort<EdgeDetectionResult>(port);
  }

  Future<bool> processImage(
      String filePath, EdgeDetectionResult edgeDetectionResult) async {
    final port = ReceivePort();

    _spawnIsolate<ProcessImageInput>(
        processImageIsolate,
        ProcessImageInput(
            inputPath: filePath,
            edgeDetectionResult: edgeDetectionResult,
            sendPort: port.sendPort),
        port);

    return await _subscribeToPort<bool>(port);
  }

  void _spawnIsolate<T>(
      void Function(T) function, dynamic input, ReceivePort port) {
    Isolate.spawn<T>(function, input,
        onError: port.sendPort, onExit: port.sendPort);
  }

  Future<T> _subscribeToPort<T>(ReceivePort port) async {
    StreamSubscription? sub;

    var completer = Completer<T>();

    sub = port.listen((result) async {
      await sub?.cancel();
      completer.complete(await result);
    });

    return completer.future;
  }
}

class EdgeDetectionInput {
  EdgeDetectionInput({this.inputPath, this.sendPort});

  String? inputPath;
  SendPort? sendPort;
}

class ProcessImageInput {
  ProcessImageInput({this.inputPath, this.edgeDetectionResult, this.sendPort});

  String? inputPath;
  EdgeDetectionResult? edgeDetectionResult;
  SendPort? sendPort;
}
