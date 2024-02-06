import 'package:flutter_test/flutter_test.dart';
import 'package:edge_detection_sample/edge_detection_sample.dart';
import 'package:edge_detection_sample/edge_detection_sample_platform_interface.dart';
import 'package:edge_detection_sample/edge_detection_sample_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEdgeDetectionSamplePlatform
    with MockPlatformInterfaceMixin
    implements EdgeDetectionSamplePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final EdgeDetectionSamplePlatform initialPlatform = EdgeDetectionSamplePlatform.instance;

  test('$MethodChannelEdgeDetectionSample is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEdgeDetectionSample>());
  });

  test('getPlatformVersion', () async {
    EdgeDetectionSample edgeDetectionSamplePlugin = EdgeDetectionSample();
    MockEdgeDetectionSamplePlatform fakePlatform = MockEdgeDetectionSamplePlatform();
    EdgeDetectionSamplePlatform.instance = fakePlatform;

    expect(await edgeDetectionSamplePlugin.getPlatformVersion(), '42');
  });
}
