import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'edge_detection_sample_platform_interface.dart';

/// An implementation of [EdgeDetectionSamplePlatform] that uses method channels.
class MethodChannelEdgeDetectionSample extends EdgeDetectionSamplePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('edge_detection_sample');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
