import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/screens/screens.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbar(),
        body: videoList.isNotEmpty
            ? FutureBuilder(
                future: videoHandler,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return futureWaitingLoading();
                  } else if (snapshot.hasError) {
                    if (snapshot.error == 'Network Error') {
                      return futureNetworkError();
                    } else {
                      return futureDisplayError(
                          content: snapshot.error.toString());
                    }
                  } else {
                    return RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            videoHandler = getVideos();
                          });
                        },
                        child: GridView.builder(
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  (MediaQuery.of(context).size.width ~/ 150)
                                      .toInt(),
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: videoList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FavoriteList(
                                                heading:
                                                    videoList[index].heading,
                                                items: videoList[index].items,
                                              )));
                                },
                                child: Container(
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
                                              videoList[index].heading,
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
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FavoriteList(
                                                          heading:
                                                              videoList[index]
                                                                  .heading,
                                                          items:
                                                              videoList[index]
                                                                  .items,
                                                        )));
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
                              );
                            }));
                  }
                })
            : noDataError());
  }

  AppBar appbar() {
    return AppBar(
      leading: IconButton(
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
        "Favorites",
        style: TextStyle(color: whiteColor),
      ),
    );
  }

  Future? videoHandler;
  List<FavoriteModel> videoList = [];

  Future getVideos() async {
    setState(() {
      videoList.clear();
    });

    try {
      await LocalDBConfig().getFavorites().then((value) {
        if (value != null && value.isNotEmpty) {
          Map<String, List<Map<String, String>>> groupedData = {};

          for (var entry in value) {
            List<String> parts = entry.split(',');

            if (parts.length < 4) continue;

            String heading = parts[0];
            String title = parts[1];
            String pageNo = parts[2];
            String videoUrl = parts[3];

            Map<String, String> videoEntry = {
              "title": title,
              "page_no": pageNo,
              "video_url": videoUrl,
            };

            if (groupedData.containsKey(heading)) {
              groupedData[heading]!.add(videoEntry);
            } else {
              groupedData[heading] = [videoEntry];
            }
          }

          List<FavoriteModel> models = groupedData.entries.map((entry) {
            return FavoriteModel(
              heading: entry.key,
              items: entry.value,
            );
          }).toList();

          setState(() {
            videoList = models;
          });
        }
      });
    } on SocketException catch (e) {
      throw "Network Error. $e";
    } catch (e) {
      showSnackbar(context, content: e.toString(), isSuccess: false);
    }
  }

  @override
  void initState() {
    videoHandler = getVideos();
    super.initState();
  }
}
