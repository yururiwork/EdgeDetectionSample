import 'dart:io';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img_lib;

///
/// Converts a [CameraImage] in YUV420 format to [image_lib.Image] in RGB format
///
img_lib.Image convertCameraImage(CameraImage cameraImage) {
  late img_lib.Image image;
  if (cameraImage.format.group == ImageFormatGroup.yuv420) {
    image = convertYUV420ToImage(cameraImage);
  } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
    image = convertBGRA8888ToImage(cameraImage);
  } else {
    throw Exception('Undefined image type.');
  }
  return img_lib.copyRotate(image, angle: 90);
}

///
/// Converts a [CameraImage] in BGRA888 format to [image_lib.Image] in RGB format
///
img_lib.Image convertBGRA8888ToImage(CameraImage cameraImage, {bool isIOS = false}) {
  return img_lib.Image.fromBytes(
    width: cameraImage.planes[0].width!,
    height: cameraImage.planes[0].height!,
    bytes: cameraImage.planes[0].bytes.buffer,
    bytesOffset: isIOS ? 28 : 0,
    order: img_lib.ChannelOrder.bgra,
  );
}

///
/// Converts a [CameraImage] in YUV420 format to [image_lib.Image] in RGB format
///
img_lib.Image convertYUV420ToImage(CameraImage cameraImage) {
  final imageWidth = cameraImage.width;
  final imageHeight = cameraImage.height;

  final yBuffer = cameraImage.planes[0].bytes;
  final uBuffer = cameraImage.planes[1].bytes;
  final vBuffer = cameraImage.planes[2].bytes;

  final int yRowStride = cameraImage.planes[0].bytesPerRow;
  final int yPixelStride = cameraImage.planes[0].bytesPerPixel!;

  final int uvRowStride = cameraImage.planes[1].bytesPerRow;
  final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

  final image = img_lib.Image(width: imageWidth, height: imageHeight);

  for (int h = 0; h < imageHeight; h++) {
    int uvh = (h / 2).floor();

    for (int w = 0; w < imageWidth; w++) {
      int uvw = (w / 2).floor();

      final yIndex = (h * yRowStride) + (w * yPixelStride);

      // Y plane should have positive values belonging to [0...255]
      final int y = yBuffer[yIndex];

      // U/V Values are subsampled i.e. each pixel in U/V chanel in a
      // YUV_420 image act as chroma value for 4 neighbouring pixels
      final int uvIndex = (uvh * uvRowStride) + (uvw * uvPixelStride);

      // U/V values ideally fall under [-0.5, 0.5] range. To fit them into
      // [0, 255] range they are scaled up and centered to 128.
      // Operation below brings U/V values to [-128, 127].
      final int u = uBuffer[uvIndex];
      final int v = vBuffer[uvIndex];

      // Compute RGB values per formula above.
      int r = (y + v * 1436 / 1024 - 179).round();
      int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
      int b = (y + u * 1814 / 1024 - 227).round();

      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);

      image.setPixelRgb(w, h, r, g, b);
    }
  }

  return image;
}

void writeAsBytes(Map map) {
  File(map['path'] as String).writeAsBytesSync(map['data'] as List<int>);
}
