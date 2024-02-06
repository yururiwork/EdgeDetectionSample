import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'edge_detection_sample_method_channel.dart';

abstract class EdgeDetectionSamplePlatform extends PlatformInterface {
  /// Constructs a EdgeDetectionSamplePlatform.
  EdgeDetectionSamplePlatform() : super(token: _token);

  static final Object _token = Object();

  static EdgeDetectionSamplePlatform _instance = MethodChannelEdgeDetectionSample();

  /// The default instance of [EdgeDetectionSamplePlatform] to use.
  ///
  /// Defaults to [MethodChannelEdgeDetectionSample].
  static EdgeDetectionSamplePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EdgeDetectionSamplePlatform] when
  /// they register themselves.
  static set instance(EdgeDetectionSamplePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
