import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '/screens/screens.dart';
import '/model/model.dart';

class DownloadScreen extends StatefulWidget {
  final String heading;
  final List<VideoModel> videos;

  const DownloadScreen(
      {super.key, required this.heading, required this.videos});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final Map<String, dynamic> _metadata = {};
  late Directory appDataDir;
  late File metadataFile;

  final Map<int, double> _progress = {};
  bool _initialized = false;

  int _downloadedCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeAndStartDownload();
  }

  Future<void> _initializeAndStartDownload() async {
    final appData = await getTemporaryDirectory();
    appDataDir = Directory("${appData.path}/dolphinprimarybooks");

    final videoDir = Directory("${appDataDir.path}/videos/");
    final thumbDir = Directory("${appDataDir.path}/thumbnails/");
    final metaDir = Directory("${appDataDir.path}/metadata/");
    metadataFile = File("${metaDir.path}/metadata.json");

    for (var dir in [videoDir, thumbDir, metaDir]) {
      if (!dir.existsSync()) dir.createSync(recursive: true);
    }

    if (!metadataFile.existsSync()) {
      metadataFile.createSync(recursive: true);
      metadataFile.writeAsStringSync(jsonEncode({}));
    }

    final jsonString = metadataFile.readAsStringSync();
    final existingMeta = jsonDecode(jsonString) as Map<String, dynamic>;
    _metadata.addAll(existingMeta);

    if (!_metadata.containsKey(widget.heading)) {
      _metadata[widget.heading] = [];
    }

    setState(() => _initialized = true);

    // Start downloads one by one
    for (int i = 0; i < widget.videos.length; i++) {
      final video = widget.videos[i];

      // Check if already downloaded (by title or URL)
      final alreadyDownloaded = (_metadata[widget.heading] as List).any((item) {
        return item['title'] == video.title ||
            item['video_url'] == video.videoUrl;
      });

      if (!alreadyDownloaded) {
        await _download(i);
        _downloadedCount++;
      } else {
        setState(() => _progress[i] = 1.0);
      }
    }
  }

  Future<void> _download(int index) async {
    final video = widget.videos[index];

    final videoPath = "${appDataDir.path}/videos/${const Uuid().v1()}.mp4";
    final thumbPath = "${appDataDir.path}/thumbnails/${const Uuid().v1()}.jpg";

    final videoFile = File(videoPath);
    final thumbFile = File(thumbPath);

    try {
      final videoRequest = await http.Client()
          .send(http.Request('GET', Uri.parse(video.videoUrl)));
      final contentLength = videoRequest.contentLength ?? 1;
      final sink = videoFile.openWrite();
      int bytes = 0;

      await for (final chunk in videoRequest.stream) {
        bytes += chunk.length;
        sink.add(chunk);
        setState(() => _progress[index] = bytes / contentLength);
      }
      await sink.close();

      final thumbBytes = await http.readBytes(Uri.parse(video.thumbnailUrl));
      await thumbFile.writeAsBytes(thumbBytes);

      // Save metadata including URL
      _metadata[widget.heading].add({
        "title": video.title,
        "description": video.description,
        "video_path": videoPath,
        "thumbnail_path": thumbPath,
        "video_url": video.videoUrl,
        "thumbnail_url": video.thumbnailUrl,
        "page_no": video.pageNo
      });

      await metadataFile.writeAsString(jsonEncode(_metadata));
      setState(() => _progress[index] = 1.0);

      // Encrypt the video file
      videoFile.writeAsBytesSync(videoFile.readAsBytesSync());
    } catch (e) {
      setState(() => _progress[index] = 0.0);
      debugPrint("Error downloading video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Download Videos",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: redColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_downloadedCount == widget.videos.length) {
              Navigator.pop(context, true);
            } else {
              showDialog(
                context: context,
                builder: (context) => const ConfirmDialog(
                  title: "Warning",
                  content: "Download is still in progress.",
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: redColor,
        label: Text(
          "$_downloadedCount / ${widget.videos.length}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: whiteColor,
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: widget.videos.length,
        itemBuilder: (context, index) {
          final video = widget.videos[index];
          final progress = _progress[index] ?? 0.0;

          return ListTile(
            title: Text(
              video.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: blackColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.pageNo != 'NULL'
                    ? 'Page Number : ${video.pageNo}'
                    : ''),
                if (progress > 0 && progress < 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: LinearProgressIndicator(value: progress),
                  ),
                if (progress == 1)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text("Download complete ✅",
                        style: TextStyle(color: Colors.green)),
                  ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          color: Colors.grey,
          height: 1,
        ),
      ),
    );
  }
}
