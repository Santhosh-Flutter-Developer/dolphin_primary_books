import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class Download {
  static Future<void> downloadFromUrl(
      BuildContext context, String url, String? name) async {
    final dio = Dio();
    int progress = 0;

    var temp = await getTemporaryDirectory();

    var directory = Directory("${temp.path}/dolphin/");
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    String savePath = name != null
        ? '${directory.path}/$name'
        : '${directory.path}/${url.split('/').last}';

    // Create an OverlayEntry to show live progress
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _DownloadProgressIndicator(progress: progress),
        ),
      ),
    );

    // Show overlay progress
    overlayState.insert(overlayEntry);

    try {
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            progress = (received / total * 100).toInt();

            // Rebuild overlay to reflect progress updates
            overlayEntry.markNeedsBuild();
          }
        },
      );

      // Remove overlay when completed
      overlayEntry.remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Download Completed",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[500],
        ),
      );
    } catch (e) {
      overlayEntry.remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Download failed. $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[500],
        ),
      );
    }
  }
}

class _DownloadProgressIndicator extends StatelessWidget {
  final int progress;
  const _DownloadProgressIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(value: progress / 100),
            const SizedBox(width: 10),
            Text('Downloading... $progress%',
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
