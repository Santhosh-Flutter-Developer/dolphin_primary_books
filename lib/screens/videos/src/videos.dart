import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '/model/model.dart';
import '/screens/screens.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import 'download_option.dart';
import 'download_screen.dart';

class Videos extends StatefulWidget {
  final String heading;
  const Videos({super.key, required this.heading});

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  bool isTv = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        nonSearchTitle: Text(
          widget.heading,
          style: TextStyle(color: whiteColor),
        ),
        onChanged: _searchVideos,
        backgroundColor: redColor,
        actions: [
          IconButton(
            icon: Icon(
              _sortingApplied ? Icons.close : Icons.sort_by_alpha_rounded,
              color: Colors.white,
            ),
            onPressed: _sortVideos,
          ),
          FutureBuilder(
            future: videoHandler,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              } else if (snapshot.hasError) {
                return const SizedBox();
              } else {
                if (!isTv) {
                  return IconButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => const ConfirmDialog(
                          title: "Alert",
                          content: "Do you want to Download Videos?",
                        ),
                      ).then((result) async {
                        if (result != null && result) {
                          var result = await Sheet.showSheet(
                            context,
                            widget: DownloadOption(heading: widget.heading),
                            size: 0.9,
                          );

                          if (result != null && result is List<VideoModel>) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DownloadScreen(
                                  videos: result,
                                  heading: widget.heading,
                                ),
                              ),
                            );
                          }
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                    ),
                  );
                }
                return const SizedBox();
              }
            },
          )
        ],
      ),
      body: body(),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: videoHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureWaitingLoading();
        } else if (snapshot.hasError) {
          if (snapshot.error == 'Network Error') {
            return futureNetworkError();
          } else {
            return futureDisplayError(content: snapshot.error.toString());
          }
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                videoHandler = getVideos();
              });
            },
            child: !isTv
                ? ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: videoList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VideoPlay(
                                            url: videoList[index].videoUrl,
                                            heading: videoList[index].title,
                                          )));
                            },
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Expanded(
                                      flex: 1, child: Icon(Iconsax.video)),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          videoList[index].title,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: blueDarkColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        Text(
                                          "Page No. ${videoList[index].pageNo}",
                                          style: TextStyle(
                                              color: blueDarkColor,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: FutureBuilder<bool>(
                                      future: LocalDBConfig().checkFavorite(
                                          "${widget.heading},${videoList[index].title},${videoList[index].pageNo},${videoList[index].videoUrl}"),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return const Icon(Icons.error);
                                        } else {
                                          bool isFavorite =
                                              snapshot.data ?? false;
                                          return IconButton(
                                            onPressed: () async {
                                              if (isFavorite) {
                                                await LocalDBConfig()
                                                    .removeFavorite(
                                                        "${widget.heading},${videoList[index].title},${videoList[index].pageNo},${videoList[index].videoUrl}");
                                                showSnackbar(context,
                                                    content:
                                                        "Video removed from favorites",
                                                    isSuccess: true);
                                              } else {
                                                await LocalDBConfig().setFavorite(
                                                    videoDetails:
                                                        "${widget.heading},${videoList[index].title},${videoList[index].pageNo},${videoList[index].videoUrl}");
                                                showSnackbar(context,
                                                    content:
                                                        "Video added to favorites",
                                                    isSuccess: true);
                                              }
                                              setState(() {});
                                            },
                                            icon: isFavorite
                                                ? Icon(
                                                    Icons.favorite,
                                                    color: redColor,
                                                  )
                                                : const Icon(
                                                    Icons.favorite_border,
                                                  ),
                                          );
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ResponsiveGridList(
                      shrinkWrap: true,
                      desiredItemWidth: isTab(context) ? 200 : 150,
                      minSpacing: 10,
                      children: videoList
                          .map(
                            (video) => VideosCard(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TvVideoPlay(
                                        videoUrl: video.videoUrl,
                                        fav:
                                            "${widget.heading},${video.title},${video.pageNo},${video.videoUrl}"),
                                  ),
                                );
                              },
                              title: video.title,
                              subtitle: video.pageNo,
                              favorite: Expanded(
                                flex: 1,
                                child: FutureBuilder<bool>(
                                  future: LocalDBConfig().checkFavorite(
                                      "${widget.heading},${video.title},${video.pageNo},${video.videoUrl}"),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return const Icon(Icons.error);
                                    } else {
                                      bool isFavorite = snapshot.data ?? false;
                                      return IconButton(
                                        onPressed: () async {
                                          if (isFavorite) {
                                            await LocalDBConfig().removeFavorite(
                                                "${widget.heading},${video.title},${video.pageNo},${video.videoUrl}");
                                            showSnackbar(context,
                                                content:
                                                    "Video removed from favorites",
                                                isSuccess: true);
                                          } else {
                                            await LocalDBConfig().setFavorite(
                                                videoDetails:
                                                    "${widget.heading},${video.title},${video.pageNo},${video.videoUrl}");
                                            showSnackbar(context,
                                                content:
                                                    "Video added to favorites",
                                                isSuccess: true);
                                          }
                                          setState(() {});
                                        },
                                        icon: isFavorite
                                            ? Icon(
                                                Icons.favorite,
                                                color: redColor,
                                              )
                                            : const Icon(
                                                Icons.favorite_border,
                                              ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          );
        }
      },
    );
  }

  Future? videoHandler;
  List<VideoModel> videoList = [];
  List<VideoModel> tmpVideoList = [];
  bool _sortingApplied = false;
  Future getVideos() async {
    setState(() {
      videoList.clear();
    });
    try {
      isTv = await isAndroidTV();

      await DashboardService().getDashboard().then((value) {
        if (value != null && value.isNotEmpty) {
          var data = value["head"]["msg"];

          for (var item in data) {
            if (item["heading"] == widget.heading) {
              var videoListFromItem = item["video_list"] as List;

              setState(() {
                videoList.clear();
              });

              for (var videoItem in videoListFromItem) {
                VideoModel videoModel = VideoModel(
                  title: videoItem["title"].toString(),
                  videoUrl: videoItem["video_link"].toString(),
                  thumbnailUrl: videoItem["thumbnail"].toString(),
                  description: videoItem["description"].toString(),
                  pageNo: videoItem["page_no"].toString(),
                );

                setState(() {
                  videoList.add(videoModel);
                });
              }
              break;
            }
          }

          videoList.sort((a, b) => (int.tryParse(a.pageNo) ?? 0)
              .compareTo((int.tryParse(b.pageNo) ?? 0)));

          tmpVideoList.clear();
          tmpVideoList.addAll(videoList);
        }
      });
    } catch (e) {
      showSnackbar(context, content: e.toString(), isSuccess: false);
    }
  }

  @override
  void initState() {
    videoHandler = getVideos();
    super.initState();
  }

  _searchVideos(String text) {
    List<VideoModel> filteredList = tmpVideoList.where((video) {
      return (video.title).toLowerCase().contains(text.toLowerCase()) ||
          (video.pageNo).toLowerCase().contains(text.toLowerCase());
    }).toList();

    setState(() {
      videoList = filteredList;
    });
  }

  _sortVideos() {
    setState(() {
      if (_sortingApplied) {
        videoList.sort((a, b) => (int.tryParse(a.pageNo) ?? 0)
            .compareTo((int.tryParse(b.pageNo) ?? 0)));
      } else {
        videoList.sort((a, b) => (int.tryParse(b.pageNo) ?? 0)
            .compareTo((int.tryParse(a.pageNo) ?? 0)));
      }
      _sortingApplied = !_sortingApplied;
    });
  }
}
