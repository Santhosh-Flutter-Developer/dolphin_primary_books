import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '/model/model.dart';
import '/screens/screens.dart';

class DownloadsList extends StatefulWidget {
  final String heading;
  final List<VideoModel> videoList;
  const DownloadsList(
      {super.key, required this.heading, required this.videoList});

  @override
  State<DownloadsList> createState() => _DownloadsListState();
}

class _DownloadsListState extends State<DownloadsList> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      appBar: appbar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ResponsiveGridList(
          shrinkWrap: true,
          desiredItemWidth: 250,
          minSpacing: 10,
          children: [
            for (var index = 0; index < widget.videoList.length; index++)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DownloadPlay(
                        path: widget.videoList[index].videoUrl,
                        heading: widget.videoList[index].title,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: File(widget.videoList[index].thumbnailUrl)
                                  .existsSync()
                              ? Image.file(
                                  File(widget.videoList[index].thumbnailUrl),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Icon(
                                  Iconsax.video,
                                  size: 50,
                                  color: blueDarkColor,
                                ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Expanded(flex: 1, child: Icon(Iconsax.video)),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.videoList[index].title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: blueDarkColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  "Page No. ${widget.videoList[index].pageNo}",
                                  style: TextStyle(
                                      color: blueDarkColor, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Iconsax.trash),
                            onPressed: () {
                              deleteVideo(widget.videoList[index]);
                            },
                            tooltip: "Delete Video",
                          )
                          // Expanded(
                          //   flex: 1,
                          //   child: FutureBuilder<bool>(
                          //     future: LocalDBConfig().checkFavorite(
                          //         "${widget.heading},${widget.videoList[index].title},${widget.videoList[index].pageNo},${widget.videoList[index].videoUrl}"),
                          //     builder: (context, snapshot) {
                          //       if (snapshot.connectionState ==
                          //           ConnectionState.waiting) {
                          //         return const Center(
                          //             child: CircularProgressIndicator());
                          //       } else if (snapshot.hasError) {
                          //         return const Icon(Icons.error);
                          //       } else {
                          //         bool isFavorite = snapshot.data ?? false;
                          //         return IconButton(
                          //           tooltip: "Remove From Favorites",
                          //           onPressed: () async {
                          //             if (isFavorite) {
                          //               await LocalDBConfig().removeFavorite(
                          //                   "${widget.heading},${widget.videoList[index].title},${widget.videoList[index].pageNo},${widget.videoList[index].videoUrl}");
                          //               showSnackbar(context,
                          //                   content:
                          //                       "Video removed from favorites",
                          //                   isSuccess: true);
                          //             } else {
                          //               await LocalDBConfig().setFavorite(
                          //                   videoDetails:
                          //                       "${widget.heading},${widget.videoList[index].title},${widget.videoList[index].pageNo},${widget.videoList[index].videoUrl}");
                          //               showSnackbar(context,
                          //                   content: "Video added to favorites",
                          //                   isSuccess: true);
                          //             }
                          //             setState(() {});
                          //           },
                          //           icon: isFavorite
                          //               ? Icon(
                          //                   Icons.favorite,
                          //                   color: redColor,
                          //                 )
                          //               : const Icon(
                          //                   Icons.favorite_border,
                          //                 ),
                          //         );
                          //       }
                          //     },
                          //   ),
                          // )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  AppBar appbar() {
    return AppBar(
      leading: IconButton(
        tooltip: "Back",
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: whiteColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: whiteColor),
      backgroundColor: redColor,
      title: Text(
        widget.heading,
        style: TextStyle(color: whiteColor),
      ),
      actions: [
        IconButton(
            tooltip: "Delete Videos",
            onPressed: () async {
              deleteAllVideos();
            },
            icon: const Icon(Iconsax.trash))
      ],
    );
  }

  void deleteVideo(VideoModel video) {
    showDialog(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: "Alert",
        content: "Do you want to Delete Video?",
      ),
    ).then((result) async {
      if (result != null && result) {
        final videoFile = File(video.videoUrl);
        final thumbFile = File(video.thumbnailUrl);

        if (await thumbFile.exists()) {
          await thumbFile.delete();
        }
        if (await videoFile.exists()) {
          await videoFile.delete();
        }

        final appData = await getTemporaryDirectory();
        var appDataDir = Directory("${appData.path}/dolphinprimarybooks");

        final metaDir = Directory("${appDataDir.path}/metadata/");
        var metadataFile = File("${metaDir.path}/metadata.json");

        if (await metadataFile.exists()) {
          final metadataJson = await metadataFile.readAsString();
          final Map<String, dynamic> metadataMap = json.decode(metadataJson);

          // Find the list under the heading
          final List<dynamic>? videoList = metadataMap[widget.heading];
          if (videoList != null) {
            videoList.removeWhere((entry) =>
                entry['title'] == video.title &&
                entry['video_path'] == video.videoUrl &&
                entry['thumbnail_path'] == video.thumbnailUrl);

            // If list is empty after removal, delete the key from the map
            if (videoList.isEmpty) {
              metadataMap.remove(widget.heading);
            }

            // Save updated metadata
            await metadataFile.writeAsString(jsonEncode(metadataMap));
          }
        }

        // Remove from current widget list
        setState(() {
          widget.videoList.remove(video);
        });
      }
    });
  }

  void deleteAllVideos() {
    showDialog(
      context: context,
      builder: (context) => const ConfirmDialog(
        title: "Alert",
        content: "Do you want to Delete All Videos?",
      ),
    ).then((result) async {
      if (result != null && result) {
        for (var video in widget.videoList) {
          final videoFile = File(video.videoUrl);
          final thumbFile = File(video.thumbnailUrl);

          if (await thumbFile.exists()) {
            await thumbFile.delete();
          }
          if (await videoFile.exists()) {
            await videoFile.delete();
          }

          final appData = await getTemporaryDirectory();
          final appDataDir = Directory("$appData/dolphinprimarybooks");
          final metaDir = Directory("${appDataDir.path}/metadata/");
          final metadataFile = File("${metaDir.path}/metadata.json");

          if (await metadataFile.exists()) {
            final metadataJson = await metadataFile.readAsString();
            final Map<String, dynamic> metadataMap = json.decode(metadataJson);

            final List<dynamic>? videoList = metadataMap[widget.heading];
            if (videoList != null) {
              videoList.removeWhere((entry) =>
                  entry['title'] == video.title &&
                  entry['video_path'] == video.videoUrl &&
                  entry['thumbnail_path'] == video.thumbnailUrl);

              // If list is empty after removal, delete the key from the map
              if (videoList.isEmpty) {
                metadataMap.remove(widget.heading);
              }

              // Save updated metadata
              await metadataFile.writeAsString(jsonEncode(metadataMap));
            }
          }
        }
      }

      widget.videoList.clear();
      setState(() {});
    });
  }
}
