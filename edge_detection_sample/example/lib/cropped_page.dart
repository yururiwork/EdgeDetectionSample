import 'dart:io';

import 'package:flutter/material.dart';

class CroppedPage extends StatefulWidget {
  final String imagePath;

  const CroppedPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<CroppedPage> createState() => _CroppedPageState();
}

class _CroppedPageState extends State<CroppedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('結果'),
      ),
      body: Center(
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
