import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '/model/model.dart';
import '/screens/screens.dart';

class Downloads extends StatefulWidget {
  const Downloads({super.key});

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  late Future _future;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.progressiveDots(
                  color: Theme.of(context).primaryColor, size: 40),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            return groupedVideoDetails.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ResponsiveGridList(
                      shrinkWrap: true,
                      desiredItemWidth: 150,
                      minSpacing: 10,
                      children: [
                        for (var index = 0;
                            index < groupedVideoDetails.keys.length;
                            index++)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DownloadsList(
                                      heading: groupedVideoDetails.keys
                                          .elementAt(index),
                                      videoList: groupedVideoDetails[
                                          groupedVideoDetails.keys
                                              .elementAt(index)]!),
                                ),
                              );
                            },
                            child: Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: blueLightColor,
                              ),
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Iconsax.book_1,
                                          size: 30,
                                          color: blueDarkColor,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          groupedVideoDetails.keys
                                              .elementAt(index),
                                          style: TextStyle(
                                            color: blueDarkColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: IconButton(
                                      tooltip: "Show Videos",
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => DownloadsList(
                                                    heading: groupedVideoDetails
                                                        .keys
                                                        .elementAt(index),
                                                    videoList:
                                                        groupedVideoDetails[
                                                            groupedVideoDetails
                                                                .keys
                                                                .elementAt(
                                                                    index)]!)));
                                      },
                                      icon: Icon(
                                        Iconsax.arrow_circle_right,
                                        color: redDarkColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  )
                : noDataError();
          }
        },
      ),
    );
  }

  Map<String, List<VideoModel>> groupedVideoDetails = {};

  @override
  void initState() {
    super.initState();
    _future = loadJsonData();
  }

  Future loadJsonData() async {
    try {
      final appData = await getTemporaryDirectory();
      var appDataDir = Directory("${appData.path}/dolphinprimarybooks");
      var metaDir = Directory("${appDataDir.path}/metadata/");
      var metadataFile = File("${metaDir.path}/metadata.json");

      if (metadataFile.existsSync()) {
        final jsonString = metadataFile.readAsStringSync();
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);

        for (var key in jsonData.keys) {
          List<VideoModel> videoList = [];
          for (var video in jsonData[key]) {
            videoList.add(
              VideoModel(
                title: video['title'] ?? '',
                description: video['description'] ?? '',
                videoUrl: video['video_path'] ?? '',
                thumbnailUrl: video['thumbnail_path'] ?? '',
                pageNo: video['pageNo'] ?? '',
              ),
            );
          }
          groupedVideoDetails[key] = videoList;
        }
      }
    } catch (e) {
      throw "Error loading JSON data: $e";
    }
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
        "Downloads",
        style: TextStyle(color: whiteColor),
      ),
      actions: const [],
    );
  }
}
